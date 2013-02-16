//
//  WORecordStore.h
//  weorder
//
//  Created by Peter2 on 2/16/13.
//  Copyright (c) 2013 peter. All rights reserved.
//

#import "BRRecordBase.h"

@interface WORecordStore : BRRecordBase
@property(nonatomic, strong)NSString* _id;
@property(nonatomic, strong)NSString* name;
@property(nonatomic, strong)NSString* description;

@property(nonatomic, strong)NSString* fbId;
@property(nonatomic, strong)NSString* fbName;

@property(nonatomic, assign) double lat;
@property(nonatomic, assign) double lng;

@property(nonatomic, strong)NSDate* created_at;

-(id)initWithJsonDic:(NSDictionary *)dic;
@end
