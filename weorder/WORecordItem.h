//
//  WORecordItem.h
//  weorder
//
//  Created by Peter2 on 2/19/13.
//  Copyright (c) 2013 peter. All rights reserved.
//

#import "BRRecordBase.h"

@interface WORecordItem : BRRecordBase

@property(nonatomic, strong)NSString* _id;
@property(nonatomic, strong)NSString* name;
@property(nonatomic, strong)NSString* desc;
@property(nonatomic, strong)NSNumber* price;
@property(nonatomic, strong)NSString* picKey;


@property(nonatomic, assign)BOOL isPicModified;

-(id)initWithJsonDic:(NSMutableDictionary *)dic;
@end
