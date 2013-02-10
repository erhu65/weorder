//
//  WWRecordTag.h
//  wework
//
//  Created by Peter2 on 2/5/13.
//  Copyright (c) 2013 Peter2. All rights reserved.
//

#import "BRRecordBase.h"

@interface WWRecordTag : BRRecordBase

@property(nonatomic, strong)NSString* _id;
@property(nonatomic, strong)NSString* fbName;
@property(nonatomic, strong)NSString* fbId;
@property(nonatomic, strong)NSString* tagName;
@property(nonatomic, strong)NSDate* created_at;
@property(nonatomic, assign) BOOL isSelected;

-(id)initWithJsonDic:(NSDictionary *)dic;
@end
