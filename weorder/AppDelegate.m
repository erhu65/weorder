//
//  AppDelegate.m
//  weorder
//
//  Created by peter on 2/8/13.
//  Copyright (c) 2013 peter. All rights reserved.
//

#import "AppDelegate.h"

#import <MessageUI/MessageUI.h>
#import <MessageUI/MFMailComposeViewController.h>
#import "HMIAPHelper.h"

@interface AppDelegate ()
<UIAlertViewDelegate,
MFMailComposeViewControllerDelegate,
UIWebViewDelegate>
{
    
}
@end


@implementation AppDelegate
@synthesize javascriptBridge = _bridge;



void exceptionHandler(NSException *exception)
{
    NSLog(@"Uncaught exception: %@\nReason: %@\nUser Info: %@\nCall Stack: %@",
          exception.name, exception.reason, exception.userInfo, exception.callStackSymbols);
    
    //Set flag
    NSUserDefaults *settings = [NSUserDefaults standardUserDefaults];
    
    [settings setBool:YES forKey:@"ExceptionOccurredOnLastRun"];
    [settings synchronize];
}

//modefied in iMac
//modified in Mac mini
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
#if !TARGET_IPHONE_SIMULATOR
    // Default exception handling code
    NSUserDefaults *settings = [NSUserDefaults standardUserDefaults];
    
    if ([settings boolForKey:@"ExceptionOccurredOnLastRun"])
    {
        // Reset exception occurred flag
        [settings setBool:NO forKey:@"ExceptionOccurredOnLastRunKey"];
        [settings synchronize];
        
        // Notify the user
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"We're sorry" message:@"An error occurred on the previous run." delegate:self cancelButtonTitle:@"Dismiss" otherButtonTitles:nil];
        [alert addButtonWithTitle:@"Email a Report"];
        [alert show];
    }
    else
    {
        NSSetUncaughtExceptionHandler(&exceptionHandler);
        
        // Redirect stderr output stream to file
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,
                                                             NSUserDomainMask, YES);
        NSString *documentsPath = [paths objectAtIndex:0];
        NSString *stderrPath = [documentsPath stringByAppendingPathComponent:@"stderr.log"];
        
        freopen([stderrPath cStringUsingEncoding:NSASCIIStringEncoding], "w", stderr);
    }
#endif
    
    [application registerForRemoteNotificationTypes:
     UIRemoteNotificationTypeAlert | UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_handleSocketURLDidUpdate:) name:BRNotificationSocketURLDidUpdate object:[BRDModel sharedInstance]];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_handleRegisterUdidDidUpdate:) name:BRNotificationRegisterUdidDidUpdate object:[BRDModel sharedInstance]];
    
    [kSharedModel getSocketUrl];
    //[HMIAPHelper sharedInstance];//restore the pervious purchased products first
    return [super application:application didFinishLaunchingWithOptions:launchOptions];
}
							
- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    [self _handleSocketURLDidUpdate:nil];
    
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:0];
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

-(void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken{
    
    
    NSString * tempToken = [deviceToken description];
    self.token = [tempToken stringByReplacingOccurrencesOfString:@"<" withString:@""];
    self.token = [self.token stringByReplacingOccurrencesOfString:@">" withString:@""];
    self.token = [[self.token componentsSeparatedByString:@" "] componentsJoinedByString:@"" ];
	
    PRPLog(@"got string token %@ -[%@ , %@]",
           self.token,
           NSStringFromClass([self class]),
           NSStringFromSelector(_cmd));
    
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:self.token forKey:KUserDefaultToken];
    [defaults synchronize];
}



-(void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,
                                                         NSUserDomainMask, YES);
    NSString *documentsPath = [paths objectAtIndex:0];
    NSString *stderrPath = [documentsPath stringByAppendingPathComponent:@"stderr.log"];
    
    if (buttonIndex == 1)
    {
        // Email a Report
        MFMailComposeViewController *mailComposer = [[MFMailComposeViewController alloc] init];
        mailComposer.mailComposeDelegate = self;
        [mailComposer setSubject:@"Error Report"];
        [mailComposer setToRecipients:[NSArray arrayWithObject:@"erhu65@gmail.com"]];
        // Attach log file
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,
                                                             NSUserDomainMask, YES);
        NSString *documentsPath = [paths objectAtIndex:0];
        NSString *stderrPath = [documentsPath stringByAppendingPathComponent:@"stderr.log"];
        
        NSData *data = [NSData dataWithContentsOfFile:stderrPath];
        
        [mailComposer addAttachmentData:data mimeType:@"Text/XML" fileName:@"stderr.log"];
        UIDevice *device = [UIDevice currentDevice];
        NSString *emailBody = [NSString stringWithFormat:@"My Model: %@\nMy OS: %@\nMy Version: %@", [device model], [device systemName], [device systemVersion]];
        [mailComposer setMessageBody:emailBody isHTML:NO];
        [self.window.rootViewController presentViewController:mailComposer animated:YES
                                                   completion:nil];
    }
    
    NSSetUncaughtExceptionHandler(&exceptionHandler);
    
    // Redirect stderr output stream to file
    freopen([stderrPath cStringUsingEncoding:NSASCIIStringEncoding], "w", stderr);
}

-(void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
    [self.window.rootViewController dismissViewControllerAnimated:YES completion:nil];
    NSUserDefaults *settings = [NSUserDefaults standardUserDefaults];
    [settings setBool:NO forKey:@"ExceptionOccurredOnLastRun"];
    [settings synchronize];
}

-(void)_handleSocketURLDidUpdate:(NSNotification *)notification
{
    NSDictionary *userInfo = [notification userInfo];
    NSString* error = userInfo[@"error"];
    
    if(nil != userInfo
       && nil != error){
        // Notify the user
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error"
                                                        message:error
                                                       delegate:self
                                              cancelButtonTitle:@"Dismiss" otherButtonTitles:nil];
        [alert show];
    } else {
        if(nil == [BRDModel sharedInstance].socketUrl) return;
        PRPLog(@"[BRDModel sharedInstance].socketUrl: %@-[%@ , %@]",
               [BRDModel sharedInstance].socketUrl,
               NSStringFromClass([self class]),
               NSStringFromSelector(_cmd));
        self.webview = [[UIWebView alloc] init];
        
        [WebViewJavascriptBridge enableLogging];
        _bridge = [WebViewJavascriptBridge bridgeForWebView:self.webview handler:^(id data, WVJBResponseCallback responseCallback) {
            
            NSLog(@"ObjC received message from JS: %@", data);
            responseCallback(@"Response for message from ObjC");
        }];
        NSString* uniqueName = [Utils createUUID:@"_notice_user"];
        NSDictionary* data = @{@"uniqueName": uniqueName};
        [_bridge callHandler:@"JsJoinNoticeHandler"
                        data:data
            responseCallback:^(id response) {
                
                PRPLog(@"callJsJoinRoomHandler responded: %@-[%@ , %@] \n ",
                       response,
                       NSStringFromClass([self class]),
                       NSStringFromSelector(_cmd));
            }];
        [_bridge registerHandler:@"iosGetNoticeCallback" handler:^(id data, WVJBResponseCallback responseCallback) {
            NSDictionary* resDic = (NSDictionary*)data;
            //            NSString* type = resDic[@"type"];
            //            NSString* notice = resDic[@"notice"];
            NSLog(@"iosGetNoticeCallback called: %@", resDic);
            responseCallback(@"Response from iosGetNoticeCallback: ios got chatroom msg");
            [[NSNotificationCenter defaultCenter] postNotificationName:BRNotificationInAppDidUpdate object:self userInfo:resDic];
        }];
        
        
        [_bridge registerHandler:@"testObjcCallback" handler:^(id data, WVJBResponseCallback responseCallback) {
            
            NSLog(@"testObjcCallback called: %@", data);
            responseCallback(@"Response from testObjcCallback");
        }];
        
        [_bridge send:@"A string sent from ObjC before Webview has loaded." responseCallback:^(id responseData) {
            NSLog(@"objc got response! %@", responseData);
        }];
        
        [_bridge callHandler:@"testJavascriptHandler" data:[NSDictionary dictionaryWithObject:@"before ready" forKey:@"foo"]];
        //node.js socket.io webview bridge end...
        [_bridge send:@"A string sent from ObjC after Webview has loaded."];
        NSString* urlNotice = [NSString stringWithFormat:@"%@/notice.html", [BRDModel sharedInstance].socketUrl];
        NSURL* url = [[NSURL alloc] initWithString:urlNotice];
        NSURLRequest *request = [[NSURLRequest alloc] initWithURL:url];
        //self.webview.delegate = self;
        [self.webview loadRequest:request];
    }
    
}

#pragma mark UIWebViewDelegate
-(void)webViewDidFinishLoad:(UIWebView *)webView
{
    PRPLog(@"conenct to notice socek -[%@ , %@]",
           NSStringFromClass([self class]),
           NSStringFromSelector(_cmd));
    
}
-(void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    PRPLog(@"Error for notice socek webview: %@-[%@ , %@]",
           [error description],
           NSStringFromClass([self class]),
           NSStringFromSelector(_cmd));
}

-(void)_handleRegisterUdidDidUpdate:(NSNotification*)notification
{
    NSDictionary *userInfo = [notification userInfo];
    
    NSString* errMsg = userInfo[@"errMsg"];
    
    if(errMsg != nil && [errMsg length] > 0){
        
        if ([errMsg rangeOfString:@"already added"].location != NSNotFound)
            return;
        
        // Notify the user
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error"
                                                        message:errMsg
                                                       delegate:self
                                              cancelButtonTitle:@"Dismiss" otherButtonTitles:nil];
        [alert show];
    } else {
        PRPLog(@"register udid successfully-[%@ , %@]",
               NSStringFromClass([self class]),
               NSStringFromSelector(_cmd));
        
    }
}


- (BOOL) isRetina
{
    if([[UIScreen mainScreen] respondsToSelector:@selector(scale)])
        return [[UIScreen mainScreen] scale] == 2.0 ? YES : NO;
    
    return NO;
}
@end
