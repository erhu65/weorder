//
//  BRCoreViewController.m
//  BirthdayReminder
//
//  Created by Nick Kuh on 05/07/2012.
//  Copyright (c) 2012 Nick Kuh. All rights reserved.
//

#import "BRCoreViewController.h"

typedef enum videosFilterMode {
    videosFilterModeAll = 0,
    videosFilterModeFavorite = 1
} videosFilterMode;


@interface BRCoreViewController ()
{
    

}

@end

@implementation BRCoreViewController



-(id)initWithCoder:(NSCoder *)aDecoder{
    
    self = [super initWithCoder:aDecoder];
    if(self){
        self.lang = [LangManager sharedManager].dic;
        self.isDisableInAppNotification = NO;
        self.isEnableSound = YES;
    }
    return self;
}

- (void)updateViewConstraints
{
    [super updateViewConstraints];
    
//    [self.view addSubview:self.button];
//    
//    NSDictionary *views = @{ @"button" : self.button };
//    
//    // Position the button with edge padding
//    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-20-[button(==100)]|" options:0 metrics:nil views:views]];
//    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-700-[button(==60)]|" options:0 metrics:nil views:views]];    
    // Vertically center.
    //    NSLayoutConstraint *verticallyCenteredConstraint = [NSLayoutConstraint constraintWithItem:self.button attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:0.0];
    //    [self.view addConstraint:verticallyCenteredConstraint];
}


-(void) viewDidLoad
{
    [super viewDidLoad];

    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone){
        self.view.backgroundColor = [UIColor grayColor];
        UIImageView *backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"app-background.png"]];
        [self.view insertSubview:backgroundView atIndex:0];
    }

    
    if(!self.isDisableInAppNotification){
        
        self.noticeChildViewController.view.translatesAutoresizingMaskIntoConstraints = NO;
        self.noticeChildViewController = [[SGChildViewController alloc] init];
        self.noticeChildViewController.superviewController = self;
        //self.noticeChildViewController.view.backgroundColor = [UIColor blueColor];
        NSDictionary *views = @{@"noticeVidew" : self.noticeChildViewController.view};
        
        // Set the width of the container box to be 250
        self.noticeHConstraint = [NSLayoutConstraint constraintsWithVisualFormat:@"H:[noticeVidew(==200)]" options:0 metrics:nil views:views];
        [self.view addConstraints:self.noticeHConstraint];
        
        // Set the height of the container box to be 250
        self.noticeVConstraint = [NSLayoutConstraint constraintsWithVisualFormat:@"V:[noticeVidew(==100)]" options:0 metrics:nil views:views];
        [self.view addConstraints:self.noticeVConstraint];
        
        // Vertically align
        self.noticeVerticalAlignconstrain = [NSLayoutConstraint constraintWithItem:self.noticeChildViewController.view attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeTop multiplier:1.0 constant:0.0];
        [self.view addConstraint:self.noticeVerticalAlignconstrain];
        
        // Horizontally align
        self.noticeHorizontalAlignconstrain = [NSLayoutConstraint constraintWithItem:self.noticeChildViewController.view attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0.0];
        [self.view addConstraint:self.noticeHorizontalAlignconstrain];
        
        // Containment
        [self addChildViewController:self.noticeChildViewController];
        [self.view addSubview:self.noticeChildViewController.view];
        [self.noticeChildViewController didMoveToParentViewController:self];

    }
    
}

-(void)viewWillAppear:(BOOL)animated{
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_handleFacebookMeDidUpdate:) name:BRNotificationFacebookMeDidUpdate object:[BRDModel sharedInstance]];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_handelBRNotificationInAppDidUpdate:) name:BRNotificationInAppDidUpdate object:nil];
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];

    [[NSNotificationCenter defaultCenter] removeObserver:self name:BRNotificationFacebookMeDidUpdate object:[BRDModel sharedInstance]];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:BRNotificationInAppDidUpdate object:nil];
    
    
   if(nil != HUD){
      [HUD hide:NO];
    }
    [self _findAndResignFirstResponder:self.view];
    //prevent crash when clicking tab veray quickly...
    
}

-(void)_handelBRNotificationInAppDidUpdate:(NSNotification*)notification
{   
    NSDictionary *userInfo = [notification userInfo];
    //NSString* type = userInfo[@"type"];
    NSDate* now = [NSDate date];
    NSDateFormatter *f2 = [[NSDateFormatter alloc] init];
    [f2 setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSString *strNow = [f2 stringFromDate:now];
    
    NSString* notice = [NSString stringWithFormat:@"%@ \n %@", userInfo[@"notice"], strNow];
    
    [self.noticeChildViewController 
     toggleSlide:nil msg:notice
     stayTime:5.0f];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:notice forKey:KUserDefaultNotice];
    [defaults synchronize];
    
}

-(BOOL) _findAndResignFirstResponder:(UIView *)theView{
    if([theView isFirstResponder]){
        [theView resignFirstResponder];
        return YES;
    }
    for(UIView *subView in theView.subviews){
        if([self _findAndResignFirstResponder:subView]){
            return YES;
        }
    }
    return NO;
}


-(IBAction)cancelAndDismiss:(id)sender
{
    NSLog(@"Cancel");
    [self dismissViewControllerAnimated:YES completion:^{
        //view controller dismiss animation completed
    }];
}

- (IBAction)saveAndDismiss:(id)sender
{
    NSLog(@"Save");
    [self dismissViewControllerAnimated:YES completion:^{
        //view controller dismiss animation completed
    }];
}


-(void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    if([self isViewLoaded] && self.view.window == nil){
        
        self.view = nil;
    }
}

-(void)handleErrMsg:(NSString*) errMsg{

    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:self.lang[@"error"] message:errMsg delegate:nil cancelButtonTitle:self.lang[@"actionDimiss"]  otherButtonTitles:nil];
    [alert show];
}
-(void)showMsg:(NSString*)msg type:(msgLevel)level{

    NSString* levelStr;
    switch (level) {
        case msgLevelInfo:
            levelStr = self.lang[@"info"];
            break;
        case msgLevelWarn:
            levelStr = self.lang[@"warn"];
            break;
        case msgLevelError:
            levelStr = self.lang[@"error"];
            break;
        default:
            levelStr = self.lang[@"info"];
            break;
    }
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:levelStr message:msg delegate:nil cancelButtonTitle:self.lang[@"actionDimiss"]  otherButtonTitles:nil];
    [alert show];

}

-(void)showHud:(BOOL) isAnimation{
    
    if(HUD!= nil){
        [HUD hide:NO];
    }    

    HUD = [[MBProgressHUD alloc] initWithView:self.view];
    [self.view addSubview:HUD];
    [HUD show:isAnimation];
}
-(void)hideHud:(BOOL) isAnimation{
    [HUD hide:isAnimation];
    if(HUD!= nil){
        HUD = nil;
    }   
}

-(void)navigationBack:(id)sender  {
    [self.navigationController popViewControllerAnimated:YES];

}

-(void)_handleFacebookMeDidUpdate:(NSNotification *)notification
{
    [self hideHud:YES];  
    NSDictionary *userInfo = [notification userInfo];
    NSString* error = userInfo[@"error"];
    NSString* msg = userInfo[@"msg"];
    if(nil != error){
        [self showMsg:error type:msgLevelWarn];
        return;
    }
    
    if(nil != msg){
        [self showMsg:msg type:msgLevelInfo]; 
        return;
    } 
}


-(void)playSoundEffect:(NSString*)soundName 
               soundId:(SystemSoundID)soundId{
    
    if(self.isEnableSound){
        NSString *soundPath = [[NSBundle mainBundle] 
                               pathForResource:soundName ofType:@"caf"];
        NSURL *soundURL = [NSURL fileURLWithPath:soundPath];
        AudioServicesCreateSystemSoundID((__bridge CFURLRef)soundURL, &soundId);
        AudioServicesPlaySystemSound(soundId);

    }
}
@end
