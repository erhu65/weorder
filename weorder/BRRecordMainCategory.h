//
//  BRRecordMainCategory.h
//  BirthdayReminder
//
//  Created by Peter2 on 12/16/12.
//  Copyright (c) 2012 Nick Kuh. All rights reserved.
//

#import "BRRecordBase.h"
@interface BRRecordMainCategory : BRRecordBase


@property(nonatomic, strong)NSString* uid;
@property(nonatomic, strong)NSString* sn;
@property(nonatomic, strong)NSString* name;
@property(nonatomic, strong)NSString* desc;
@property(nonatomic, strong)NSDate* created_at;
@property(nonatomic, strong)NSDate* modified_at;
@property BOOL isUserFavorite;

-(id)initWithJsonDic:(NSDictionary *)dic;
@end
