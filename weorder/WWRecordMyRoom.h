//
//  WWRecordMyRoom.h
//  wework
//
//  Created by Peter2 on 1/28/13.
//  Copyright (c) 2013 Peter2. All rights reserved.
//

#import "BRRecordBase.h"

@interface WWRecordMyRoom : BRRecordBase

@property(nonatomic, strong)NSString* _id;
@property(nonatomic, strong)NSString* fbName;
@property(nonatomic, strong)NSString* fbId;
@property(nonatomic, strong)NSString* roomName;
@property(nonatomic, strong)NSDate* created_at;

@property(nonatomic, strong)NSNumber* invitedCount;


-(id)initWithJsonDic:(NSDictionary *)dic;
@end
