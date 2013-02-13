//
//  WORecordNotice.h
//  weorder
//
//  Created by peter on 2/13/13.
//  Copyright (c) 2013 peter. All rights reserved.
//

#import "BRRecordBase.h"

@interface WORecordNotice : BRRecordBase
@property(nonatomic, strong)NSString* _id;
@property(nonatomic, strong)NSString* msg;
@property(nonatomic, strong)NSString* fbId;
@property(nonatomic, strong)NSString* fbName;
@property(nonatomic, assign)BOOL isReceiverRead;
@property(nonatomic, strong)NSDate* created_at;

-(id)initWithJsonDic:(NSDictionary *)dic;
@end
