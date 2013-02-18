//
//  WORecordStorePic.h
//  weorder
//
//  Created by Peter2 on 2/18/13.
//  Copyright (c) 2013 peter. All rights reserved.
//

#import "BRRecordBase.h"

@interface WORecordStorePic : BRRecordBase

@property(nonatomic, strong)NSString* _id;
@property(nonatomic, strong)NSString* uniqueKey;
@property(nonatomic, strong)NSString* description;

@property(nonatomic, strong)NSString* fbId;

@property(nonatomic, assign)BOOL isPicModified;

-(id)initWithJsonDic:(NSDictionary *)dic;

@end
