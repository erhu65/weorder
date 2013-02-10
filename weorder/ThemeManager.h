//
//  ThemeManager.h
//  BirthdayReminder
//
//  Created by Peter2 on 1/2/13.
//  Copyright (c) 2013 Nick Kuh. All rights reserved.
//


@interface ThemeManager : NSObject
{
    NSDictionary *_dic;
}

@property(nonatomic, retain) NSDictionary *dic;

+ (ThemeManager *)sharedManager;

@end
