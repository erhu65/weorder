//
//  WWRecordMyRoom.m
//  wework
//
//  Created by Peter2 on 1/28/13.
//  Copyright (c) 2013 Peter2. All rights reserved.
//

#import "WWRecordMyRoom.h"

@implementation WWRecordMyRoom


-(id)initWithJsonDic:(NSDictionary *)dic{
    
    self = [super init];
    if (self) {
        
        self._id =  [dic objectForKey:@"_id"];
        self.fbName = [dic objectForKey:@"fbName"];
        self.fbId = [dic objectForKey:@"fbId"];
        self.created_at = (NSDate*)[dic objectForKey:@"created_at"];
        self.roomName = [dic objectForKey:@"roomName"];
        self.invitedCount = (NSNumber*)[dic objectForKey:@"invitedCount"];
        
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
    return [NSString stringWithFormat:@"fbName: %@ \n \
            fbId: %@ \n \
            created_at: %@ \n\
            self.roomName: %@",
            self.fbName,
            self.fbId,
            self.created_at,
            self.roomName];
}
@end
