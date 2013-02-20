//
//  WORecordItem.m
//  weorder
//
//  Created by Peter2 on 2/19/13.
//  Copyright (c) 2013 peter. All rights reserved.
//

#import "WORecordItem.h"

@implementation WORecordItem
-(id)initWithJsonDic:(NSMutableDictionary *)dic{
    
    self = [super init];
    if (self) {
        
        self._id =  [dic objectForKey:@"_id"];
        self.desc = [dic objectForKey:@"desc"];
        self.name = [dic objectForKey:@"name"];          
        self.price = (NSNumber*)[dic objectForKey:@"price"]; 
        self.picKey = [dic objectForKey:@"picKey"]; 
        
        self.awsS3ImgUrl =  (NSURL* )[dic objectForKey:@"awsS3ImgUrl"];
        
        self.isPicModified = NO;
        
    }
    return self;
}


@end
