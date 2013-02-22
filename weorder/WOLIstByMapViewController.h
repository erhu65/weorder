//
//  WOLIstByMapViewController.h
//  weorder
//
//  Created by Peter2 on 2/21/13.
//  Copyright (c) 2013 peter. All rights reserved.
//

#import "BRCoreViewController.h"
@class CLLocation;


typedef void(^WOLIstByMapViewControllerCompletionBlock)(NSDictionary* res);

@interface WOLIstByMapViewController : BRCoreViewController

@property(nonatomic, strong) CLLocation* location;

@property(nonatomic, copy)WOLIstByMapViewControllerCompletionBlock complectionBlock;

@end
