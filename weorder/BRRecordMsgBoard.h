//
//  BRRecordMsgBoard.h
//  BirthdayReminder
//
//  Created by Peter2 on 1/2/13.
//  Copyright (c) 2013 Nick Kuh. All rights reserved.
//

#import "BRRecordBase.h"

@interface BRRecordMsgBoard : BRRecordBase

@property(nonatomic, strong)NSString* _id;
@property(nonatomic, strong)NSString* fbName;
@property(nonatomic, strong)NSString* fbId;
@property(nonatomic, strong)NSString* message;
@property(nonatomic, strong)NSDate* created_at;


-(id)initWithJsonDic:(NSDictionary *)dic;
@end
