//
//  WOItemsViewController.h
//  weorder
//
//  Created by Peter2 on 2/19/13.
//  Copyright (c) 2013 peter. All rights reserved.
//

#import "BRCoreViewController.h"

typedef void(^WOItemsViewControllerCompletionBlock)(NSDictionary* res);

typedef enum WOItemsViewControllerMode {
    WOItemsViewControllerModeBackend = 0,
    WOItemsViewControllerModeFrontend = 1
} WOItemsViewControllerMode;



@interface WOItemsViewController : BRCoreViewController
@property(nonatomic, assign) WOItemsViewControllerMode mode;
@property(nonatomic, strong) NSString* fbId;
@property(nonatomic, strong) NSString* fbNmae;
@property(nonatomic, copy)WOItemsViewControllerCompletionBlock complectionBlock;
@end
