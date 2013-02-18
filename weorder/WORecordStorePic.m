//
//  WORecordStorePic.m
//  weorder
//
//  Created by Peter2 on 2/18/13.
//  Copyright (c) 2013 peter. All rights reserved.
//

#import "WORecordStorePic.h"

@implementation WORecordStorePic
-(id)initWithJsonDic:(NSDictionary *)dic{
    
    self = [super init];
    if (self) {
        
        self._id =  [dic objectForKey:@"_id"];
        self.description = [dic objectForKey:@"description"];
        self.uniqueKey = [dic objectForKey:@"uniqueKey"];
        self.fbId = [dic objectForKey:@"fbId"];
        self.awsS3ImgUrl =  (NSURL* )[dic objectForKey:@"awsS3ImgUrl"];

        //self.strImgUrl = [NSString stringWithFormat:@"https://graph.facebook.com/%@/picture?", self.fbId];
        self.isPicModified = NO;
        
    }
    return self;
}


@end
