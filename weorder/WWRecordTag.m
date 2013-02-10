//
//  WWRecordTag.m
//  wework
//
//  Created by Peter2 on 2/5/13.
//  Copyright (c) 2013 Peter2. All rights reserved.
//

#import "WWRecordTag.h"

@implementation WWRecordTag

-(id)initWithJsonDic:(NSDictionary *)dic{
    
    self = [super init];
    if (self) {
        
        self._id = [dic objectForKey:@"_id"];
        self.fbId = [dic objectForKey:@"fbId"];
        self.fbName = [dic objectForKey:@"fbName"];
        self.tagName = [dic objectForKey:@"tagName"];
        self.created_at = [NSDate date];
        NSNumber* isSelected = (NSNumber*) [dic objectForKey:@"isSelected"];
        self.isSelected = [isSelected boolValue];
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
    return [NSString stringWithFormat:@"self.fbId: %@ \n self.fbName: %@ \n self.tagName: %@", self.fbId, self.fbName, self.tagName ];
}
@end
