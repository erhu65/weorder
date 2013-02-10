/***
 * Excerpted from "iOS Recipes",
 * published by The Pragmatic Bookshelf.
 * Copyrights apply to this code. It may not be used to create training material, 
 * courses, books, articles, and the like. Contact us if you are in doubt.
 * We make no guarantees that this code is fit for any purpose. 
 * Visit http://www.pragmaticprogrammer.com/titles/cdirec for more book information.
***/
//
//  PRPDebug.m
//
//  Created by Matt Drance on 8/28/09.
//  Copyright 2009 Bookhouse. All rights reserved.
//

#import "PRPDebug.h"

void PRPDebug(const char *fileName, int lineNumber, NSString *fmt, ...) {
    va_list args;
    va_start(args, fmt);
    
    static NSDateFormatter *debugFormatter = nil;
    if (debugFormatter == nil) {
        debugFormatter = [[NSDateFormatter alloc] init];
        [debugFormatter setDateFormat:@"yyyyMMdd.HH:mm:ss"];
    }
    
    NSString *msg = [[NSString alloc] initWithFormat:fmt arguments:args];
    NSString *filePath = [[NSString alloc] initWithUTF8String:fileName];    
    NSString *timestamp = [debugFormatter stringFromDate:[NSDate date]];
    
    NSDictionary *info = [[NSBundle mainBundle] infoDictionary];
    NSString *appName = [info objectForKey:(NSString *)kCFBundleNameKey];
    fprintf(stdout, "\n %s %s \n[%s:%d] %s\n",
            [timestamp UTF8String],
            [appName UTF8String],
            [[filePath lastPathComponent] UTF8String],
            lineNumber,
            [msg UTF8String]);
    
    va_end(args);

}
