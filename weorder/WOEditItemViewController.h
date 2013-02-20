//
//  WOEditItemViewController.h
//  weorder
//
//  Created by Peter2 on 2/19/13.
//  Copyright (c) 2013 peter. All rights reserved.
//

#import "BRCoreViewController.h"
@class WORecordItem;
@class WOItemPicOptionalViewController;

typedef void(^WOEditItemViewControllerCompletionBlock)(NSDictionary* res);

@interface WOEditItemViewController : BRCoreViewController


@property (strong, nonatomic) WORecordItem *recordToEdit;
@property(nonatomic, strong) NSString* storeId;
@property(nonatomic, copy)WOEditItemViewControllerCompletionBlock complectionBlock;


@property(nonatomic, strong) WOItemPicOptionalViewController* embedWOItemPicOptionalViewController;
@end
