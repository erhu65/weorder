//
//  WORecordNotice.m
//  weorder
//
//  Created by peter on 2/13/13.
//  Copyright (c) 2013 peter. All rights reserved.
//

#import "WORecordNotice.h"

@implementation WORecordNotice

-(id)initWithJsonDic:(NSDictionary *)dic{
    
    self = [super init];
    if (self) {
        
        self._id =  [dic objectForKey:@"_id"];
        self.msg = [dic objectForKey:@"msg"];
        self.fbId = [dic objectForKey:@"senderFbId"];
        self.fbName = [dic objectForKey:@"senderFbName"];
        NSNumber* isReceiverRead =(NSNumber* ) [dic objectForKey:@"isReceiverRead"];
        self.isReceiverRead = [isReceiverRead boolValue];
        
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
    return [NSString stringWithFormat:@"fbName: %@ \n\
            fbId: %@ \n \
            created_at: %@ \n\
            self.msg: %@",
            self.fbName,
            self.fbId,
            self.created_at,
            self.msg];
}

@end
