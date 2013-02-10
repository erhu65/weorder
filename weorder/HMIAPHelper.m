//
//  HMIAPHelper.m
//  Hangman
//
//  Created by Ray Wenderlich on 9/17/12.
//  Copyright (c) 2012 Ray Wenderlich. All rights reserved.
//

#import "HMIAPHelper.h"
#import "IAPProduct.h"
//#import "HMContentController.h"
#import "JSNotifier.h"
#import <StoreKit/StoreKit.h>

@implementation HMIAPHelper

+ (HMIAPHelper *)sharedInstance {
    static dispatch_once_t once;
    static HMIAPHelper * sharedInstance;
    dispatch_once(&once, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

- (void)notifyStatusForProduct:(IAPProduct *)product
                        string:(NSString *)string {
    NSString * message = [NSString stringWithFormat:@"%@: %@",
                          product.skProduct.localizedTitle, string];
    JSNotifier *notify =
    [[JSNotifier alloc]initWithTitle:message];
    [notify showFor:2.0];
    
    UIAlertView* av = [[UIAlertView alloc] initWithTitle:kSharedModel.lang[@"info"] message:message delegate:nil cancelButtonTitle:kSharedModel.lang[@"actionOK"] otherButtonTitles:nil, nil];
    [av show];
    
}

//- (void)provideContentWithURL:(NSURL *)URL {
//    
////    //[[HMContentController sharedInstance]
////     unlockContentWithDirURL:URL];
//}

@end
