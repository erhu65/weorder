//
//  ThemeManager.m
//  BirthdayReminder
//
//  Created by Peter2 on 1/2/13.
//  Copyright (c) 2013 Nick Kuh. All rights reserved.
//
#import "constants.h"
#import "ThemeManager.h"

@implementation ThemeManager

@synthesize dic = _dic;

- (id)init
{
    if ((self = [super init]))
    {
        
    }
    return self;
}


+ (ThemeManager *)sharedManager
{
    static ThemeManager *sharedManager = nil;
    if (sharedManager == nil)
    {
        sharedManager = [[ThemeManager alloc] init];
    }
    //NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    //NSString *lang_ = [settings stringForKey : KUserLang];
    //lang_ = 0, 1, 2, 3,....
    
    //NSString *themeName = [defaults objectForKey:@"lang"] ?: @"lang_default3";
    NSUserDefaults *settings = [NSUserDefaults standardUserDefaults];
    NSString *theme_ = [settings stringForKey : KUserTheme];
    int whichLang_ = [theme_ intValue];
    NSString *themeFileName = nil ;
    switch (whichLang_) {
        case 0:
            themeFileName = @"theme_default";//theme 1 
            break;
        case 2:
            themeFileName = @"theme_chinese";//theme 2
            break;
        default:
            themeFileName = @"theme_default";//theme 1 
            break;
    }
    NSString *path = [[NSBundle mainBundle] pathForResource:themeFileName ofType:@"plist"];
    sharedManager.dic = [NSDictionary dictionaryWithContentsOfFile:path]; 
    
    
    return sharedManager;
}




@end
