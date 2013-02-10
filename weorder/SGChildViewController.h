//
//  SGChildViewController.h
//  SGZoomingView
//
//  Created by Justin Williams on 10/23/12.
//  Copyright (c) 2012 Second Gear. All rights reserved.
//

#import "BRCoreViewController.h"
@class BRCoreViewController;

@interface SGChildViewController : UIViewController

@property (nonatomic, strong) BRCoreViewController* superviewController;

- (id)init;
- (void)toggleSlide:(id)sender
                msg:(NSString*)msg
                stayTime:(float)stayTime;

@end
