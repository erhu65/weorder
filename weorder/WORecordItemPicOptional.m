//
//  WORecordItemPicOptional.m
//  weorder
//
//  Created by Peter2 on 2/20/13.
//  Copyright (c) 2013 peter. All rights reserved.
//

#import "WORecordItemPicOptional.h"

@implementation WORecordItemPicOptional

-(id)initWithJsonDic:(NSDictionary *)dic{
    
    self = [super init];
    if (self) {
        
        self.desc = [dic objectForKey:@"desc"];
        self.picKey = [dic objectForKey:@"picKey"];
        self.itemId = [dic objectForKey:@"itemId"];
        
        if(nil != [dic objectForKey:@"_id"]){
            self._id =  [dic objectForKey:@"_id"];
        }
        if(nil != [dic objectForKey:@"awsS3ImgUrl"]){
            self.awsS3ImgUrl =  (NSURL* )[dic objectForKey:@"awsS3ImgUrl"];
        }
        
        self.isPicModified = NO;
    }
    return self;
}

@end
