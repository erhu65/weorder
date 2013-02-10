//
//  LangManager.m
//  moneymove
//
//  Created by peter on 5/16/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//
#import "constants.h"
#import "LangManager.h"

@implementation LangManager
@synthesize dic = _dic;

- (id)init
{
    if ((self = [super init]))
    {

    }
    return self;
}


+ (LangManager *)sharedManager
{
    static LangManager *sharedManager = nil;
    if (sharedManager == nil)
    {
        sharedManager = [[LangManager alloc] init];
    }
    //NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    //NSString *lang_ = [settings stringForKey : KUserLang];
    //lang_ = 0, 1, 2, 3,....
    
    //NSString *themeName = [defaults objectForKey:@"lang"] ?: @"lang_default3";
    NSUserDefaults *settings = [NSUserDefaults standardUserDefaults];
    NSString *lang_ = [settings stringForKey : KUserDefaultLang];
    int whichLang_ = [lang_ intValue];
    NSString *langFileName = nil ;
    switch (whichLang_) {
        case 0:
            langFileName = @"lang_default";//english
            break;
        case 1:
            langFileName = @"lang_chinese";
            break;
        default:
            langFileName = @"lang_default";//english 
            break;
    }
    NSString *path = [[NSBundle mainBundle] pathForResource:langFileName ofType:@"plist"];
    sharedManager.dic = [NSDictionary dictionaryWithContentsOfFile:path]; 
    
    
    return sharedManager;
}


+ (void)switchLang
{
    NSUserDefaults *settings = [NSUserDefaults standardUserDefaults];
    NSString *lang_ = [settings stringForKey : KUserDefaultLang];
    int whichLang_ = [lang_ intValue];
    NSString *langFileName = nil ;
    switch (whichLang_) {
        case 0:
            langFileName = @"lang_default";//english
            break;
        case 1:
            langFileName = @"lang_chinese";
            break;
        default:
            langFileName = @"lang_default";//english 
            break;
    }
    NSString *path = [[NSBundle mainBundle] pathForResource:langFileName ofType:@"plist"];
    [LangManager sharedManager].dic = [NSDictionary dictionaryWithContentsOfFile:path]; 

}



@end
