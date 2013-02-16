//
//  WORecordStore.m
//  weorder
//
//  Created by Peter2 on 2/16/13.
//  Copyright (c) 2013 peter. All rights reserved.
//

#import "WORecordStore.h"

@implementation WORecordStore

-(id)initWithJsonDic:(NSDictionary *)dic{
    
    self = [super init];
    if (self) {
        
        self._id =  [dic objectForKey:@"_id"];
        self.name = [dic objectForKey:@"name"];
        self.description = [dic objectForKey:@"description"];
        self.fbId = [dic objectForKey:@"fbId"];
        self.fbName = [dic objectForKey:@"fbName"];
        
        self.created_at = (NSDate*)[dic objectForKey:@"created_at"];
        
        self.strImgUrl = [NSString stringWithFormat:@"https://graph.facebook.com/%@/picture?", self.fbId];
        
        PRPLog(@"[self description]:%@  -[%@ , %@] \n ",
               [self description],
               NSStringFromClass([self class]),
               NSStringFromSelector(_cmd));
        
    }
    return self;
}

-(NSString*)description
{
    [super description];
    return [NSString stringWithFormat:@"name: %@ \n\
            fbId: %@ ",
            self.name,
            self.fbId];
}

@end
