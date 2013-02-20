//
//  WORecordItemPicOptional.h
//  weorder
//
//  Created by Peter2 on 2/20/13.
//  Copyright (c) 2013 peter. All rights reserved.
//

#import "BRRecordBase.h"

@interface WORecordItemPicOptional : BRRecordBase

@property(nonatomic, strong)NSString* _id;
@property(nonatomic, strong)NSString* desc;
@property(nonatomic, strong)NSString* picKey;
@property(nonatomic, strong)NSString* itemId;

@property(nonatomic, assign)BOOL isPicModified;

-(id)initWithJsonDic:(NSDictionary *)dic;
@end
