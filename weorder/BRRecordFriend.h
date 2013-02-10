//
//  BRRecordFriend.h
//  BirthdayReminder
//
//  Created by Peter2 on 1/10/13.
//  Copyright (c) 2013 Nick Kuh. All rights reserved.
//
#import "BRRecordBase.h"
@interface BRRecordFriend : BRRecordBase

@property(nonatomic, strong)NSString* fbId;
@property(nonatomic, strong)NSString* fbName;
@property(nonatomic, assign) BOOL isJoint;
@property(nonatomic, strong)NSNumber* count;

-(id)initWithJsonDic:(NSDictionary *)dic;

@end
