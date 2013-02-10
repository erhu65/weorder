//
//  IAPProduct.h
//  Hangman
//
//  Created by Ray Wenderlich on 9/17/12.
//  Copyright (c) 2012 Ray Wenderlich. All rights reserved.
//

@class SKProduct;
@class IAPProductInfo;
@class IAPProductPurchase;

@interface IAPProduct : NSObject

- (id)initWithProductIdentifier:(NSString *)productIdentifier;
- (BOOL)allowedToPurchase;

@property (nonatomic, assign) BOOL availableForPurchase;
@property (nonatomic, strong) NSString * productIdentifier;
@property (nonatomic, strong) SKProduct * skProduct;
@property (nonatomic, assign) BOOL purchaseInProgress;
@property (nonatomic, strong) IAPProductPurchase * purchase;
@property (nonatomic, strong) IAPProductInfo * info;

@end
