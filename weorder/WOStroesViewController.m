//
//  WOStroesViewController.m
//  weorder
//
//  Created by peter on 2/10/13.
//  Copyright (c) 2013 peter. All rights reserved.
//

#import "WOStroesViewController.h"
#import "AppDelegate.h"

@interface WOStroesViewController ()

@end

@implementation WOStroesViewController


-(id)initWithCoder:(NSCoder *)aDecoder{
    
    self = [super initWithCoder:aDecoder];
    if(self){

        
    }
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    
    if(nil == kSharedModel.fbId){
        [kSharedModel fetchFacebookMe];
    }
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_handleFacebookMeDidUpdate:) name:BRNotificationFacebookMeDidUpdate object:kSharedModel];
    
}

- (void) viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:BRNotificationFacebookMeDidUpdate object:kSharedModel];
}

-(void)_handleFacebookMeDidUpdate:(NSNotification *)notification
{
    NSDictionary *userInfo = [notification userInfo];
    NSString* error = userInfo[@"error"];
    if(nil != error){
        [self hideHud:YES];
        [self showMsg:error type:msgLevelWarn];
        return;
    }
    PRPLog(@"kSharedModel.fbId: %@ \
           kAppDelegate.token: %@ \
           - [%@ , %@]",
           kSharedModel.fbId,
           kAppDelegate.token,
           NSStringFromClass([self class]),
           NSStringFromSelector(_cmd));
}


@end
