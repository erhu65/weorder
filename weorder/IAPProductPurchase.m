//
//  IAPProductPurchase.m
//  Hangman
//
//  Created by Ray Wenderlich on 9/17/12.
//  Copyright (c) 2012 Ray Wenderlich. All rights reserved.
//

#import "IAPProductPurchase.h"

static NSString *const kProductIdentifierKey =
@"ProductIdentifier";
static NSString *const kConsumableKey = @"Consumable";
static NSString *const kTimesPurchasedKey = @"TimesPurchased";
static NSString *const kLibraryRelativePathKey =
@"LibraryRelativePath";
static NSString *const kContentVersionKey = @"ContentVersion";

@implementation IAPProductPurchase

- (id)initWithProductIdentifier:(NSString *)productIdentifier
                     consumable:(BOOL)consumable
                 timesPurchased:(int)timesPurchased
            libraryRelativePath:(NSString *)libraryRelativePath
                 contentVersion:(NSString *)contentVersion {
    if ((self = [super init])) {
        self.productIdentifier = productIdentifier;
        self.consumable = consumable;
        self.timesPurchased = timesPurchased;
        self.libraryRelativePath = libraryRelativePath;
        self.contentVersion = contentVersion;
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    NSString * productIdentifer = [aDecoder
                                   decodeObjectForKey:kProductIdentifierKey];
    BOOL consumable = [aDecoder
                       decodeBoolForKey:kConsumableKey];
    int timesPurchased = [aDecoder
                          decodeIntForKey:kTimesPurchasedKey];
    NSString * libraryRelativePath = [aDecoder
                                      decodeObjectForKey:kLibraryRelativePathKey];
    NSString * contentVersion = [aDecoder
                                 decodeObjectForKey:kContentVersionKey];
    return [self initWithProductIdentifier:productIdentifer
                                consumable:consumable
                            timesPurchased:timesPurchased
                       libraryRelativePath:libraryRelativePath
                            contentVersion:contentVersion];
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:self.productIdentifier
                  forKey:kProductIdentifierKey];
    [aCoder encodeBool:self.consumable
                forKey:kConsumableKey];
    [aCoder encodeInt:self.timesPurchased 
               forKey:kTimesPurchasedKey];
    [aCoder encodeObject:self.libraryRelativePath 
                  forKey:kLibraryRelativePathKey];
    [aCoder encodeObject:self.contentVersion 
                  forKey:kContentVersionKey];
}

@end
