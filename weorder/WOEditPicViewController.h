//
//  WOEditPicViewController.h
//  weorder
//
//  Created by Peter2 on 2/17/13.
//  Copyright (c) 2013 peter. All rights reserved.
//

#import "BRCoreViewController.h"
@class WORecordStorePic;

typedef void(^BRBirthdayEditViewControllerCompletionBlock)(NSDictionary* res);


@interface WOEditPicViewController : BRCoreViewController

@property (strong, nonatomic) NSString *fbId;
@property (strong, nonatomic) WORecordStorePic *recordToEdit;

@property(nonatomic, copy)BRBirthdayEditViewControllerCompletionBlock complectionBlock;

@end
