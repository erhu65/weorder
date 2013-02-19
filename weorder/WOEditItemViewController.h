//
//  WOEditItemViewController.h
//  weorder
//
//  Created by Peter2 on 2/19/13.
//  Copyright (c) 2013 peter. All rights reserved.
//

#import "BRCoreViewController.h"
@class WORecordItem;

typedef void(^WOEditItemViewControllerCompletionBlock)(NSDictionary* res);

@interface WOEditItemViewController : BRCoreViewController

@property (strong, nonatomic) NSString *fbId;
@property (strong, nonatomic) WORecordItem *recordToEdit;

@property(nonatomic, copy)WOEditItemViewControllerCompletionBlock complectionBlock;

@end
