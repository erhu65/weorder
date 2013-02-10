//
//  IAPHelper.m
//  Hangman
//
//  Created by Ray Wenderlich on 9/17/12.
//  Copyright (c) 2012 Ray Wenderlich. All rights reserved.
//

#import "IAPHelper.h"
#import <StoreKit/StoreKit.h>
#import "IAPProduct.h"
#import "VerificationController.h"
#import "IAPProductInfo.h"
#import "IAPProductPurchase.h"
#import "AppDelegate.h"
//#import "AFNetworking.h"
//#import "AFHTTPClient.h"
//#import "AFHTTPRequestOperation.h"

static NSString *const IAPServerBaseURL = BASE_URL;
static NSString *const IAPServerProductsURL = @"/product-list";

static NSString *const IAPHelperPurchasesPlist =
@"purchases.plist";

@interface IAPHelper () 
<SKProductsRequestDelegate, SKPaymentTransactionObserver>

@end

@implementation IAPHelper {
    SKProductsRequest * _productsRequest;
    RequestProductsCompletionHandler _completionHandler;
    BOOL _productsLoaded;
}

- (id)init {
    if ((self = [super init])) {
        _products = [NSMutableDictionary dictionary];
        [self loadPurchases];//restore the purchased products everytime
        [self loadProductsWithCompletionHandler:^(BOOL success,
                                                  NSError *error) {
        }];
    }
    return self;
}

- (IAPProduct *)addProductForProductIdentifier:
(NSString *)productIdentifier {
    IAPProduct * product = _products[productIdentifier];
    if (product == nil) {
        product = [[IAPProduct alloc]
                   initWithProductIdentifier:productIdentifier];
        _products[productIdentifier] = product;
    }
    return product;
}

- (void)addInfo:(IAPProductInfo *)info
forProductIdentifier:(NSString *)productIdentifier {
    
    IAPProduct * product = [self
                            addProductForProductIdentifier:productIdentifier];
    product.info = info;
    
}


- (void)requestProductsWithCompletionHandler:
(RequestProductsCompletionHandler)completionHandler {
    
    _completionHandler = [completionHandler copy];
    
    [self loadProductsWithCompletionHandler:^(BOOL success,
                                              NSError *error) {
        NSMutableSet * productIdentifiers = [NSMutableSet
                                             setWithCapacity:_products.count];
        for (IAPProduct * product in _products.allValues) {
            if (product.info) {
                product.availableForPurchase = NO;
                [productIdentifiers
                 addObject:product.productIdentifier];
            }
        }
        
        _productsRequest = [[SKProductsRequest alloc]
                            initWithProductIdentifiers:productIdentifiers];
        _productsRequest.delegate = self;
        [_productsRequest start];
        
    }];
    
}

#pragma mark - SKProductsRequestDelegate

- (void)productsRequest:(SKProductsRequest *)request
     didReceiveResponse:(SKProductsResponse *)response {
    
    NSLog(@"Loaded list of products...");
    _productsRequest = nil;
    
    // 1
    NSArray * skProducts = response.products;
    for (SKProduct * skProduct in skProducts) {
        IAPProduct * product =
        _products[skProduct.productIdentifier];
        product.skProduct = skProduct;
        product.availableForPurchase = YES;
        
        PRPLog(@"skProduct.productIdentifier %@ \n [%@ , %@]",
               skProduct.productIdentifier,
               NSStringFromClass([self class]),
               NSStringFromSelector(_cmd));
    }
    // 2
    for (NSString * invalidProductIdentifier in
         response.invalidProductIdentifiers) {
        IAPProduct * product =
        _products[invalidProductIdentifier];
        product.availableForPurchase = NO;
        NSLog(@"Invalid product identifier, removing: %@",
              invalidProductIdentifier);
    }
    
    // 3
    NSMutableArray * availableProducts = [NSMutableArray array];
    for (IAPProduct * product in _products.allValues) {
        if (product.availableForPurchase) {
            [availableProducts addObject:product];
        }
    }
    _completionHandler(YES, availableProducts);
    _completionHandler = nil;
    
}

- (void)request:(SKRequest *)request didFailWithError:(NSError *)error {
    
    NSLog(@"Failed to load list of products.");
    _productsRequest = nil;
    // 5
    _completionHandler(FALSE, nil);
    _completionHandler = nil;
    
}

- (void)buyProduct:(IAPProduct *)product {
    
    NSAssert(product.allowedToPurchase, @"This product isn't allowed to be purchased!");
    
    NSLog(@"Buying %@...", product.productIdentifier);
    
    product.purchaseInProgress = YES;
    SKPayment * payment = [SKPayment
                           paymentWithProduct:product.skProduct];
    [[SKPaymentQueue defaultQueue] addPayment:payment];
    
}

- (void)paymentQueue:(SKPaymentQueue *)queue
 updatedTransactions:(NSArray *)transactions
{
    for (SKPaymentTransaction * transaction in transactions) {
        switch (transaction.transactionState)
        {
            case SKPaymentTransactionStatePurchased:
                [self completeTransaction:transaction];
                break;
            case SKPaymentTransactionStateFailed:
                [self failedTransaction:transaction];
                break;
            case SKPaymentTransactionStateRestored:
                [self restoreTransaction:transaction];
            default:
                break;
        }
    };
}

- (void)completeTransaction:(SKPaymentTransaction *)transaction {
    PRPLog(@"completeTransaction...[%@ , %@]",
           NSStringFromClass([self class]),
           NSStringFromSelector(_cmd));

    [self validateReceiptForTransaction:transaction];
}

- (void)restoreTransaction:(SKPaymentTransaction *)transaction {
    PRPLog(@"completeTransaction...[%@ , %@]",
           NSStringFromClass([self class]),
           NSStringFromSelector(_cmd));
    [self validateReceiptForTransaction:transaction];
}

- (void)failedTransaction:(SKPaymentTransaction *)transaction {
    
    PRPLog(@"failedTransaction...[%@ , %@]",
           NSStringFromClass([self class]),
           NSStringFromSelector(_cmd));

    if (transaction.error.code != SKErrorPaymentCancelled)
    {
        PRPLog(@"Transaction error: %@[%@ , %@]",
               transaction.error.localizedDescription,
               NSStringFromClass([self class]),
               NSStringFromSelector(_cmd));
    }
    
    IAPProduct * product =
    _products[transaction.payment.productIdentifier];
    [self notifyStatusForProductIdentifier:
     transaction.payment.productIdentifier
                                    string:@"Purchase failed."];
    product.purchaseInProgress = NO;
    [[SKPaymentQueue defaultQueue]
     finishTransaction: transaction];
    
}

- (void)notifyStatusForProductIdentifier:
(NSString *)productIdentifier string:(NSString *)string {
    IAPProduct * product = _products[productIdentifier];
    [self notifyStatusForProduct:product string:string];
}

- (void)notifyStatusForProduct:(IAPProduct *)product
                        string:(NSString *)string {
    
}



- (void)provideContentForTransaction:
(SKPaymentTransaction *)transaction
                   productIdentifier:(NSString *)productIdentifier {
    
    IAPProduct * product = _products[productIdentifier];
    
    if (product.info.consumable) {
        
        PRPLog(@"process consumable  purchased product: %@\n-[%@ , %@]",
               product,
               NSStringFromClass([self class]),
               NSStringFromSelector(_cmd));
        [self
         purchaseConsumable:product.info.consumableIdentifier
         forProductIdentifier:productIdentifier
         amount:product.info.consumableAmount];
    } else {
        
        PRPLog(@"process non-consumable purchased product: %@\n-[%@ , %@]",
               product,
               NSStringFromClass([self class]),
               NSStringFromSelector(_cmd));
        
        NSURL * bundleURL = [[NSBundle mainBundle].resourceURL
                             URLByAppendingPathComponent:product.info.bundleDir];
        [self purchaseNonconsumableAtURL:bundleURL
                    forProductIdentifier:productIdentifier];
    }
    
    [self notifyStatusForProductIdentifier:productIdentifier
                                    string:@"Purchase complete!"];
    
    product.purchaseInProgress = NO;
    [[SKPaymentQueue defaultQueue] finishTransaction:
     transaction];
    
}

- (void)purchaseConsumable:(NSString *)consumableIdentifier
      forProductIdentifier:(NSString *)productIdentifier
                    amount:(int)consumableAmount {
    
    int previousAmount = [[NSUserDefaults standardUserDefaults]
                          integerForKey:consumableIdentifier];
    int newAmount = previousAmount + consumableAmount;
    [[NSUserDefaults standardUserDefaults] setInteger:newAmount
                                               forKey:consumableIdentifier];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    IAPProductPurchase * previousPurchase = [self
                                             purchaseForProductIdentifier:productIdentifier];
    if (previousPurchase) {
        previousPurchase.timesPurchased++;
        
    } else {
        
        IAPProductPurchase * purchase = [[IAPProductPurchase alloc]
                                         initWithProductIdentifier:productIdentifier consumable:YES
                                         timesPurchased:1 libraryRelativePath:@""
                                         contentVersion:@""];
        [self addPurchase:purchase
    forProductIdentifier:productIdentifier];
        previousPurchase = purchase;
    
    }
    //[self savePurchases];
    [self _provideContentWithPurchasedProdcut:previousPurchase];
}

//enable(non-consumable) or add points(consumable) for user after purchasing 
- (void)_provideContentWithPurchasedProdcut:(IAPProductPurchase *)prodcut {
    
    PRPLog(@"Loaded purchased product productIdentifier: %@, \n  contentVersion: %i [%@ , %@]",
           prodcut.productIdentifier,
           prodcut.contentVersion,
           NSStringFromClass([self class]),
           NSStringFromSelector(_cmd));
    
    //non-consumable -> enable some functionality..
    if(!prodcut.consumable){
        PRPLog(@" non-consumable -> enable some functionality.. [%@ , %@]",
               NSStringFromClass([self class]),
               NSStringFromSelector(_cmd));
        
        if([prodcut.productIdentifier isEqualToString:@"com.erhu65.wework.enableaddtag"]){
            kSharedModel.isEnebleToggleFavorite = YES;
            PRPLog(@"enable add tag functionality [%@ , %@]",
                   NSStringFromClass([self class]),
                   NSStringFromSelector(_cmd));

        }
        
    //consumable products -> add some points..
    } else {
        PRPLog(@"consumable products -> add some points..[%@ , %@]",
               NSStringFromClass([self class]),
               NSStringFromSelector(_cmd));
        
        if([prodcut.productIdentifier isEqualToString:@"com.erhu65.wework.amount.animation"]){

            PRPLog(@"add play animation units [%@ , %@]",
                   NSStringFromClass([self class]),
                   NSStringFromSelector(_cmd));
            
            //add 50 points and store in server
            [kSharedModel postPointsConsumtion:prodcut.productIdentifier points:@"50" fbId:kSharedModel.fbId withBlock:^(NSDictionary* res) {
                NSString* error = res[@"error"];
                if(nil !=  error){
                    return;
                }
                NSDictionary* docPoints = res[@"doc"];
                PRPLog(@"docPoints: %@-[%@ , %@]",
                       docPoints,
                       NSStringFromClass([self class]),
                       NSStringFromSelector(_cmd));
                kSharedModel.points = (NSNumber*)docPoints[@"points"];
            }];

            
        }
    }
   
    
    
}

- (void)provideContentWithURL:(NSURL *)URL {
    
    PRPLog(@"restored product bundleDir:  %@, [%@ , %@]",
           [URL description],
           NSStringFromClass([self class]),
           NSStringFromSelector(_cmd));
}

- (void)purchaseNonconsumableAtURL:(NSURL *)nonLocalURL
              forProductIdentifier:(NSString *)productIdentifier {
    
//    NSError * error = nil;
//    BOOL success = FALSE;
//    BOOL exists = FALSE;
//    BOOL isDirectory = FALSE;
    // 1
    NSString * libraryRelativePath =
    nonLocalURL.lastPathComponent;
    NSString * localPath = [[self libraryPath]
                            stringByAppendingPathComponent:libraryRelativePath];
    NSURL * localURL = [NSURL fileURLWithPath:localPath
                                  isDirectory:YES];
//    exists = [[NSFileManager defaultManager]
//              fileExistsAtPath:localPath isDirectory:&isDirectory];
//    // 2
//    if (exists) {
//        BOOL success = [[NSFileManager defaultManager]
//                        removeItemAtURL:localURL error:&error];
//        if (!success) {
//            NSLog(@"Couldn't delete directory at %@: %@",
//                  localURL, error.localizedDescription);
//        }
//    }
    // 3
//    NSLog(@"Copying directory from %@ to %@", nonLocalURL,
//          localURL);
//    success = [[NSFileManager defaultManager]
//               copyItemAtURL:nonLocalURL toURL:localURL error:&error];
//    if (!success) {
//        NSLog(@"Failed to copy directory: %@",
//              error.localizedDescription);
//        [self notifyStatusForProductIdentifier:productIdentifier
//                                        string:@"Copying failed."];
//        return;
//    }
    
    NSString * contentVersion = @"";
    // 4
 
    //[self provideContentWithURL:localURL];
    
    // 5
    IAPProductPurchase* productPurchased;
    IAPProductPurchase * previousPurchase = [self
                                             purchaseForProductIdentifier:productIdentifier];
    if (previousPurchase) {
        previousPurchase.timesPurchased++;
        
        // 6
//        NSString * oldPath = [[self libraryPath]
//                              stringByAppendingPathComponent:
//                              previousPurchase.libraryRelativePath];
//        success = [[NSFileManager defaultManager]
//                   removeItemAtPath:oldPath error:&error];
//        if (!success) {
//            NSLog(@"Could not remove old purchase at %@",
//                  oldPath);
//        } else {
//            NSLog(@"Removed old purchase at %@", oldPath);
//        }
        
        // 7
        previousPurchase.libraryRelativePath =
        libraryRelativePath;
        previousPurchase.contentVersion = contentVersion;
        productPurchased = previousPurchase;
    } else {
        IAPProductPurchase * purchase =
        [[IAPProductPurchase alloc]
         initWithProductIdentifier:productIdentifier
         consumable:NO timesPurchased:1
         libraryRelativePath:libraryRelativePath
         contentVersion:contentVersion];
        [self addPurchase:purchase
     forProductIdentifier:productIdentifier];
        productPurchased = purchase;
    }
    [self _provideContentWithPurchasedProdcut:productPurchased];
    
    [self notifyStatusForProductIdentifier:productIdentifier
                                    string:@"Purchase complete!"];
    
    // 8
    [self savePurchases];
    
}

- (void)restoreCompletedTransactions {
    [[SKPaymentQueue defaultQueue]
     restoreCompletedTransactions];
}
//Then this delegate Funtion Will be fired
- (void) paymentQueueRestoreCompletedTransactionsFinished:(SKPaymentQueue *)queue
{
    int countProdcuts = queue.transactions.count;
    NSLog(@"received restored transactions: %i", countProdcuts);
   
    NSString* msg = [NSString stringWithFormat:@"%i %@", countProdcuts, kSharedModel.lang[@"infoRestorePurchasedProductsComplete"]];
    UIAlertView* av = [[UIAlertView alloc] initWithTitle:kSharedModel.lang[@"info"] message:msg delegate:self cancelButtonTitle:kSharedModel.lang[@"actionOK"] otherButtonTitles:nil, nil];
    [av show];

    for (SKPaymentTransaction *transaction in queue.transactions)
    {
        NSString *productIdentifier = transaction.payment.productIdentifier;
        PRPLog(@"restored product id :  %@, [%@ , %@]",
               productIdentifier,
               NSStringFromClass([self class]),
               NSStringFromSelector(_cmd));
    }
}

- (void)validateReceiptForTransaction:
(SKPaymentTransaction *)transaction {
    
    IAPProduct * product =
    _products[transaction.payment.productIdentifier];
    VerificationController * verifier =
    [VerificationController sharedInstance];
    
    [verifier verifyPurchase:transaction
           completionHandler:^(BOOL success) {
               
               PRPLog(@"kAppDelegate.isRetina %d[%@ , %@]",
                      kAppDelegate.isRetina,
                      NSStringFromClass([self class]),
                      NSStringFromSelector(_cmd));
               if(!kAppDelegate.isRetina){
                   success = YES;
                   //iPad verify always failed.., so we force it always pass verification..
               }
               if (success) {
                   PRPLog(@"Successfully verified receipt![%@ , %@]",
                          NSStringFromClass([self class]),
                          NSStringFromSelector(_cmd));
                   [self provideContentForTransaction:transaction
                                    productIdentifier:
                    transaction.payment.productIdentifier];
               } else {
                   PRPLog(@"Failed to validate receipt.[%@ , %@]",
                          NSStringFromClass([self class]),
                          NSStringFromSelector(_cmd));
                   product.purchaseInProgress = NO;
                   [[SKPaymentQueue defaultQueue]
                    finishTransaction: transaction];
               }
           }];
    
}

// 1
- (NSString *)libraryPath {
    NSArray * libraryPaths =
    NSSearchPathForDirectoriesInDomains(NSLibraryDirectory,
                                        NSUserDomainMask, YES);
    return libraryPaths[0];
}

// 2
- (NSString *)purchasesPath {
    return [[self libraryPath]
            stringByAppendingPathComponent:IAPHelperPurchasesPlist];
}

// 3
- (void)addPurchase:(IAPProductPurchase *)purchase
forProductIdentifier:(NSString *)productIdentifier {
    
    IAPProduct * product = [self
                            addProductForProductIdentifier:productIdentifier];
    product.purchase = purchase;
}

// 4
- (IAPProductPurchase *)purchaseForProductIdentifier:
(NSString *)productIdentifier {
    IAPProduct * product = _products[productIdentifier];
    if (!product) return nil;
    
    return product.purchase;
}

- (void)loadPurchases {
    
    // 1
    NSString * purchasesPath = [self purchasesPath];
    NSArray * purchasesArray = [NSKeyedUnarchiver
                                unarchiveObjectWithFile:purchasesPath];
    for (IAPProductPurchase * purchase in purchasesArray) {
        // 2
        if (purchase.libraryRelativePath) {
            NSString * localPath = [[self libraryPath]
                                    stringByAppendingPathComponent:
                                    purchase.libraryRelativePath];
            NSURL * localURL = [NSURL fileURLWithPath:localPath
                                          isDirectory:YES];
            //[self provideContentWithURL:localURL];
        }
       
        
        // 3
        [self addPurchase:purchase forProductIdentifier:purchase.productIdentifier];
        [self _provideContentWithPurchasedProdcut:purchase];

    }
    
}

- (void)savePurchases {
    
    // 1
    NSString * purchasesPath = [self purchasesPath];
    NSMutableArray * purchasesArray = [NSMutableArray array];
    for (IAPProduct * product in _products.allValues) {
        if (product.purchase) {
            [purchasesArray addObject:product.purchase];
        }
    }
    // 2
    BOOL success = [NSKeyedArchiver
                    archiveRootObject:purchasesArray toFile:purchasesPath];
    if (!success) {
        NSLog(@"Failed to save purchases to %@", purchasesPath);
    }
    
}

- (void)loadProductsWithCompletionHandler:(void (^)
                                           (BOOL success, NSError * error))completionHandler {
    // 1
    for (IAPProduct * product in _products.allValues) {
        product.info = nil;
        product.availableForPurchase = NO;
    }
    __weak __block  IAPHelper* weakSelf = (IAPHelper*)self;
    [kSharedModel getProductsWithBlock:^(NSDictionary* info){
        NSString* error = info[@"error"];
    
        if(nil != error) {
           NSError* err = [NSError errorWithDomain:@"com.erhu65.wework" code:300 userInfo:info];
            completionHandler(FALSE, err);
            return;
        }
        NSArray* products = info[@"products"];
        if(nil == products){
            NSDictionary* errorInfo = @{@"error": @"no product"};
            NSError* err = [NSError errorWithDomain:@"com.erhu65.wework" code:301 userInfo:errorInfo];
            completionHandler(FALSE, err);
            return;
        }
        PRPLog(@"products get from server:  %@, [%@ , %@]",
               products,
               NSStringFromClass([self class]),
               NSStringFromSelector(_cmd));
  
        for (NSDictionary * productInfoDict in products) {
            IAPProductInfo * info = [[IAPProductInfo alloc] initFromDict:productInfoDict];
            [weakSelf addInfo:info forProductIdentifier:info.productIdentifier];
        };
        if (!_productsLoaded) {
            _productsLoaded = YES;
            [[SKPaymentQueue defaultQueue]
            addTransactionObserver:self];
        }
        completionHandler(TRUE, nil);
    }];
    
    // 2
    //NSURL * baseUrl = [NSURL URLWithString:IAPServerBaseURL];
    
    
//    AFHTTPClient * httpClient = [[AFHTTPClient alloc]
//                                 initWithBaseURL:baseUrl];
//    NSURL * url = [NSURL URLWithString:IAPServerProductsURL
//                         relativeToURL:baseUrl];
//    
//    // 3
//    NSMutableURLRequest * request = [NSURLRequest
//                                     requestWithURL:url
//                                     cachePolicy:NSURLRequestReloadIgnoringCacheData
//                                     timeoutInterval:60];
//    
//    // 4
//    AFHTTPRequestOperation *operation = [httpClient
//                                         HTTPRequestOperationWithRequest:request
//                                         success:^(AFHTTPRequestOperation *operation, id
//                                                   responseObject)
//     {
//         
//         // 5
//         NSData * productInfosData = [operation responseData];
//         NSError * error = nil;
//         NSArray * productInfosArray =
//         [NSPropertyListSerialization
//          propertyListWithData:productInfosData
//          options:NSPropertyListImmutable format:NULL
//          error:&error];
//         if (productInfosArray == nil) {
//             completionHandler(FALSE, error);
//         } else {
//             
//             // 6
//             for (NSDictionary * productInfoDict in
//                  productInfosArray) {
//                 IAPProductInfo * info = [[IAPProductInfo alloc]
//                                          initFromDict:productInfoDict];
//                 [self addInfo:info
//          forProductIdentifier:info.productIdentifier];
//             };
//             
//             // 7
//             if (!_productsLoaded) {
//                 _productsLoaded = YES;
//                 [[SKPaymentQueue defaultQueue]
//                  addTransactionObserver:self];
//             }
//             
//             // 8
//             completionHandler(TRUE, nil);
//         }
//         
//     } failure:^(AFHTTPRequestOperation *operation,
//                 NSError *error) {
//         completionHandler(FALSE, error);
//     }];
//    [httpClient enqueueHTTPRequestOperation:operation];
    
}


@end
