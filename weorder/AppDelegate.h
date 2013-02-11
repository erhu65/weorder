//
//  AppDelegate.h
//  weorder
//
//  Created by peter on 2/8/13.
//  Copyright (c) 2013 peter. All rights reserved.
//

#import "SurfsUpAppDelegate.h"
#import "WebViewJavascriptBridge.h"

@interface AppDelegate : SurfsUpAppDelegate <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property(strong, nonatomic)NSString* token;

@property (strong, nonatomic) UIWebView *webview;
@property (strong, nonatomic) WebViewJavascriptBridge *javascriptBridge;



- (BOOL) isRetina;
@end
