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
        
        NSDictionary* _creator = [dic objectForKey:@"_creator"];
        self.mainCategoryId = [_creator objectForKey:@"_id"];
        self.mainCategoryNme = [_creator objectForKey:@"name"];
        
        self.created_at = (NSDate*)[dic objectForKey:@"created_at"];
        NSDictionary* loc = [dic objectForKey:@"loc"];
        NSNumber* lat = (NSNumber*)[loc objectForKey:@"lat"];
        NSNumber* lng = (NSNumber*)[loc objectForKey:@"lng"];
        double latDouble = [lat doubleValue];
        double lngDouble = [lng doubleValue];
        if(latDouble != 0.0f && lngDouble != 0.0f){
            self.lat = latDouble;
            self.lng = lngDouble;
        }
       
        
        self.strImgUrl = [NSString stringWithFormat:@"https://graph.facebook.com/%@/picture?", self.fbId];
        
//        PRPLog(@"[self description]:%@  -[%@ , %@] \n ",
//               [self description],
//               NSStringFromClass([self class]),
//               NSStringFromSelector(_cmd));
        
    }
    return self;
}

//-(NSString*)description
//{
//    [super description];
//    return [NSString stringWithFormat:@"name: %@ \n\
//            mainCategoryNme: %@ \n\
//            fbId: %@ ",
//            self.name,
//            self.mainCategoryNme,
//            self.fbId];
//}

@end
