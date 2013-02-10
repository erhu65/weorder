//
//  IAPProduct.m
//  Hangman
//
//  Created by Ray Wenderlich on 9/17/12.
//  Copyright (c) 2012 Ray Wenderlich. All rights reserved.
//

#import "IAPProduct.h"
#import "IAPProductInfo.h"

@implementation IAPProduct

- (id)initWithProductIdentifier:(NSString *)productIdentifier {
    if ((self = [super init])) {
        self.availableForPurchase = NO;
        self.productIdentifier = productIdentifier;
        self.skProduct = nil;
    }
    return self;
}

- (BOOL)allowedToPurchase {
    if (!self.availableForPurchase) return NO;
    
    if (self.purchaseInProgress) return NO;
    
    if (!self.info) return NO;
    
    if (!self.info.consumable && self.purchase) {
        return NO;
    }
    
    return YES;
}

-(NSString*)description
{
    [super description];
    return [NSString stringWithFormat:@"productIdentifier: %@",  self.productIdentifier];
}

@end
