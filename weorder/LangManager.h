//
//  LangManager.h
//  moneymove
//
//  Created by peter on 5/16/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//



@interface LangManager : NSObject
{
    NSDictionary *_dic;
}

@property(nonatomic, retain) NSDictionary *dic;

+ (LangManager *)sharedManager;
+ (void)switchLang;
@end
