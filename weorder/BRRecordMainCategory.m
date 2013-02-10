//
//  BRRecordMainCategory.m
//  BirthdayReminder
//
//  Created by Peter2 on 12/16/12.
//  Copyright (c) 2012 Nick Kuh. All rights reserved.
//

#import "BRRecordMainCategory.h"

@implementation BRRecordMainCategory

-(id)initWithJsonDic:(NSDictionary *)dic{

    self = [super init];
    if (self) {
        
        self.uid = [dic objectForKey:@"_id"];
        self.sn = [dic objectForKey:@"sn"];
        self.name = [dic objectForKey:@"name"];
        self.desc = [dic objectForKey:@"desc"];
        self.created_at = [dic objectForKey:@"created_at"];
        self.modified_at = [dic objectForKey:@"modified_at"];
        
        NSNumber* isFavorite = (NSNumber*) [dic objectForKey:@"isFavorite"];
        self.isUserFavorite = [isFavorite boolValue];
    }
    return self;
}
@end
