//
//  SGChildViewController.m
//  SGZoomingView
//
//  Created by Justin Williams on 10/23/12.
//  Copyright (c) 2012 Second Gear. All rights reserved.
//

#import "SGChildViewController.h"
#import "BackgroundLayer.h"
#import <AudioToolbox/AudioToolbox.h>
#import "BRStyleSheet.h"

@interface SGChildViewController ()
@property (nonatomic, assign, getter = isZoomed) BOOL zoomed;
@property (nonatomic, assign) BOOL isSlideDown;
@property (nonatomic, assign) BOOL isDismiss;
@property (nonatomic, strong) UIButton *button;
@property (nonatomic, strong) UILabel *lbNotice;
@property (nonatomic, strong)NSString* msg;
@property float stayTime;

@end

@implementation SGChildViewController
{
    SystemSoundID _pewPewSound;
}

- (id)init
{
    if (self = [super initWithNibName:nil bundle:nil])
    {
        self.view.translatesAutoresizingMaskIntoConstraints = NO;
       // self.view.backgroundColor = [UIColor blueColor];
        self.msg = @"";
        self.stayTime = 0.0f;
        self.isDismiss = NO;
    }
    return self;
}

- (void)updateViewConstraints
{
    [super updateViewConstraints];
    self.lbNotice.translatesAutoresizingMaskIntoConstraints = NO;
    self.button.translatesAutoresizingMaskIntoConstraints = NO;
    self.view.translatesAutoresizingMaskIntoConstraints = NO;
    NSDictionary *views = @{ @"lbNotice": self.lbNotice,
     @"button": self.button};
    
    // Position the lbMsg with edge padding
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-10-[lbNotice]-10-|" options:0 metrics:nil views:views]];
    
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-10-[lbNotice]-20-|" options:0 metrics:nil views:views]];

    // Position the lbMsg with edge padding
//    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[button(==40)]-20-|" options:0 metrics:nil views:views]];
//    
//    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[button(==20)]-20-|" options:0 metrics:nil views:views]];
    
    NSLayoutConstraint *verticallyCenteredConstraint = [NSLayoutConstraint constraintWithItem:self.button attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeBottom multiplier:1.0 constant:4.0];
    [self.view addConstraint:verticallyCenteredConstraint];
    
    NSLayoutConstraint *horizontallyCenteredConstraint = [NSLayoutConstraint constraintWithItem:self.button attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0.0];
    [self.view addConstraint:horizontallyCenteredConstraint];
}
#pragma mark -
#pragma mark View Lifecycle
// +--------------------------------------------------------------------
// | View Lifecycle
// +--------------------------------------------------------------------
//
//- (void)loadView
//{
//    [super loadView];
//    [self.view addSubview:self.button];
//}
//
- (void)viewDidLoad
{
    [super viewDidLoad];
    //self.view.backgroundColor = [[UIColor alloc] initWithPatternImage:[UIImage imageNamed:@"app-background.png"]];
    
    
    //Add gradient background
    CAGradientLayer *bgLayer = [BackgroundLayer brownGradient];
	bgLayer.frame = CGRectMake(0, 0, self.view.frame.size.width, 100.0f);
    [self.view.layer insertSublayer:bgLayer atIndex:0];
    
    self.lbNotice.backgroundColor = [UIColor blackColor];    
    [self.view addSubview:self.lbNotice];
    [self.view addSubview:self.button];
}

#pragma mark -
#pragma mark Instance Methods
// +--------------------------------------------------------------------
// | Instance Methods
// +--------------------------------------------------------------------

- (void)toggleZoom:(id)sender
{
//    NSDictionary *views = @{ @"self" : self.view };
//    
//    UIView *superView = self.superviewController.view;
//    
//    [superView removeConstraints:self.superviewController.noticeHConstraint];
//    [superView removeConstraints:self.superviewController.noticeVConstraint];
//    
//    if (self.isZoomed)
//    {
//        self.superviewController.noticeHConstraint = [NSLayoutConstraint constraintsWithVisualFormat:@"H:[self(==320)]" options:0 metrics:nil views:views];
//        
//        self.superviewController.noticeVConstraint = [NSLayoutConstraint constraintsWithVisualFormat:@"V:[self(==100)]" options:0 metrics:nil views:views];
//    }
//    else
//    {
//        self.superviewController.noticeHConstraint = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|[self]|" options:0 metrics:nil views:views];
//        
//        self.superviewController.noticeVConstraint = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|[self]|" options:0 metrics:nil views:views];
//    }
//    
//    [superView addConstraints:self.superviewController.hConstraint];
//    [superView addConstraints:self.superviewController.vConstraint];
//    
//    self.zoomed = !self.isZoomed;
//    [UIView animateWithDuration:0.3 animations:^{
//        [self.view layoutIfNeeded];
//    }];
}

- (void)toggleSlide:(id)sender  
                msg:(NSString*)msg_
           stayTime:(float)stayTime_{

    if(nil != msg_) self.msg = msg_;
    if(0.0f != stayTime_) self.stayTime = stayTime_;
    _lbNotice.text = self.msg;
    NSDictionary *views = @{ @"self" : self.view };
    UIView *superView = self.superviewController.view;
    
    self.lbNotice.translatesAutoresizingMaskIntoConstraints = NO;
    self.button.translatesAutoresizingMaskIntoConstraints = NO;
    
    [superView removeConstraints:self.superviewController.noticeHConstraint];
    [superView removeConstraints:self.superviewController.noticeVConstraint];
    
    if (self.isSlideDown)
    {
        self.superviewController.noticeHConstraint = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|[self]|" options:0 metrics:nil views:views];
        self.superviewController.noticeVConstraint = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-(-100)-[self(==100)]|" options:0 metrics:nil views:views];
    } else {
        NSString *pewPewPath = [[NSBundle mainBundle] 
                                pathForResource:@"notice" ofType:@"caf"];
        NSURL *pewPewURL = [NSURL fileURLWithPath:pewPewPath];
        AudioServicesCreateSystemSoundID((__bridge CFURLRef)pewPewURL, &_pewPewSound);
        AudioServicesPlaySystemSound(_pewPewSound);
        self.superviewController.noticeHConstraint = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|[self]|" options:0 metrics:nil views:views];
        self.superviewController.noticeVConstraint = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-0-[self(==100)]|" options:0 metrics:nil views:views];
    }
    
    [superView addConstraints:self.superviewController.noticeHConstraint];
    [superView addConstraints:self.superviewController.noticeVConstraint];
    
    self.isSlideDown = !self.isSlideDown;
    __weak __block SGChildViewController* weakSelf = (SGChildViewController*)self;
    [UIView animateWithDuration:0.8f
                          delay:0.0f 
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         // animation 2
                         [self.view layoutIfNeeded];
                     }completion:^(BOOL isFinished){

                         if(weakSelf.isSlideDown ){
                             dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW,
                                                                     self.stayTime * NSEC_PER_SEC);
                             dispatch_after(popTime, dispatch_get_main_queue(), ^(void)
                                            {
                                                 
                                                if(weakSelf.isSlideDown 
                                                   && !weakSelf.isDismiss){
                                                   
                                                    [weakSelf toggleSlide:nil 
                                                                      msg:self.msg
                                                                 stayTime:self.stayTime];
                                                    
                                                }

                                            });
                         }

    }];
//    [UIView animateWithDuration:0.3 
//                     animations:^{
//        [self.view layoutIfNeeded];
//    }];

}
#pragma mark -
#pragma mark Dynamic Accessor Methods
// +--------------------------------------------------------------------
// | Dynamic Accessor Methods
// +--------------------------------------------------------------------
- (void)_dismiss:(id)sender {

    self.isDismiss = YES;
    NSDictionary *views = @{ @"self" : self.view };
   
    UIView *superView = self.superviewController.view;
    
    [superView removeConstraints:self.superviewController.noticeHConstraint];
    [superView removeConstraints:self.superviewController.noticeVConstraint];

    self.superviewController.noticeHConstraint = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|[self]|" options:0 metrics:nil views:views];
    
    self.superviewController.noticeVConstraint = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-(-100)-[self(==100)]|" options:0 metrics:nil views:views];
    
    [superView addConstraints:self.superviewController.noticeHConstraint];
    [superView addConstraints:self.superviewController.noticeVConstraint];

    
    __weak __block SGChildViewController* weakSelf = (SGChildViewController*)self;
    [UIView animateWithDuration:0.8f
                          delay:0.0f 
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         // animation 2
                         [self.view layoutIfNeeded];
                     }completion:^(BOOL isFinished){
                        
                         weakSelf.isDismiss = NO;
                         weakSelf.isSlideDown = NO;
                     }];

}
- (UIButton *)button
{
    if (_button == nil)
    {
        _button = [UIButton buttonWithType:UIButtonTypeCustom];
        UIImage* image = [UIImage imageNamed:@"ArrowAsc"];
        //[_button setImage:image forState:UIControlStateNormal];
        [_button setBackgroundImage:image forState:UIControlStateNormal];
        //_button.frame = (CGRect) {{ 10, 10 }, {100, 44}};
        _button.translatesAutoresizingMaskIntoConstraints = NO;
        //[_button setTitle:@"Dismiss" forState:UIControlStateNormal];
        [_button addTarget:self action:@selector(_dismiss:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _button;
}

-(UILabel*) lbNotice{

    if(nil == _lbNotice){
        _lbNotice = [[UILabel alloc] init];
        _lbNotice.translatesAutoresizingMaskIntoConstraints = NO;
        _lbNotice.text = @"";
        _lbNotice.numberOfLines = 3;
        _lbNotice.textAlignment = NSTextAlignmentCenter;
        [_lbNotice sizeToFit];
        [BRStyleSheet styleLabel:_lbNotice withType:BRLabelTypeName];
        
    }
    return _lbNotice;

}

@end
