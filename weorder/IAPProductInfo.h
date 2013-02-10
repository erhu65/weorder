//
//  IAPProductInfo.h
//  Hangman
//
//  Created by Ray Wenderlich on 9/17/12.
//  Copyright (c) 2012 Ray Wenderlich. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface IAPProductInfo : NSObject

- (id)initFromDict:(NSDictionary *)dict;

@property (nonatomic, strong) NSString * productIdentifier;
@property (nonatomic, strong) NSString * icon;
@property (nonatomic, assign) BOOL consumable;
@property (nonatomic, strong) NSString * consumableIdentifier;
@property (nonatomic, assign) int consumableAmount;
@property (nonatomic, strong) NSString * bundleDir;

@end
