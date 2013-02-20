//
//  WOEditItemPicOptioinalViewController.h
//  weorder
//
//  Created by Peter2 on 2/20/13.
//  Copyright (c) 2013 peter. All rights reserved.
//

#import "BRCoreViewController.h"
@class WORecordItemPicOptional;
@class WORecordItem;

typedef void(^WOEditItemPicOptioinalViewControllerCompletionBlock)(NSDictionary* res);

@interface WOEditItemPicOptioinalViewController : BRCoreViewController


@property (nonatomic,  strong) WORecordItemPicOptional *recordToEdit;
@property(nonatomic, weak) WORecordItem* item;
@property(nonatomic, copy)WOEditItemPicOptioinalViewControllerCompletionBlock complectionBlock;
@end
