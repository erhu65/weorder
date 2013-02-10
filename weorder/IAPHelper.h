//
//  IAPHelper.h
//  Hangman
//
//  Created by Ray Wenderlich on 9/17/12.
//  Copyright (c) 2012 Ray Wenderlich. All rights reserved.
//

typedef void (^RequestProductsCompletionHandler)(BOOL success, NSArray * products);

@class IAPProduct;

@interface IAPHelper : NSObject

@property (nonatomic, strong) NSMutableDictionary * products;

- (void)requestProductsWithCompletionHandler:(RequestProductsCompletionHandler)completionHandler;
- (void)buyProduct:(IAPProduct *)product;
- (void)restoreCompletedTransactions;

@end

