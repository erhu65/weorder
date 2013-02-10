//
//  BRRecordMsgBoard.m
//  BirthdayReminder
//
//  Created by Peter2 on 1/2/13.
//  Copyright (c) 2013 Nick Kuh. All rights reserved.
//

#import "BRRecordMsgBoard.h"

@implementation BRRecordMsgBoard


-(id)initWithJsonDic:(NSDictionary *)dic{
    
    self = [super init];
    if (self) {

        self._id =  [dic objectForKey:@"_id"];
        self.fbName = [dic objectForKey:@"fbName"];
        self.fbId = [dic objectForKey:@"fbId"];
        self.created_at = (NSDate*)[dic objectForKey:@"created_at"];
        self.message = [dic objectForKey:@"message"];
        
        
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
    return [NSString stringWithFormat:@"fbName: %@ \n fbId: %@ \n created_at: %@ \n self.message: %@", self.fbName, self.fbId, self.created_at, self.message];
}
@end