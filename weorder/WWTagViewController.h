//
//  WWTagViewController.h
//  wework
//
//  Created by Peter2 on 2/5/13.
//  Copyright (c) 2013 Peter2. All rights reserved.
//

#import "BRCoreViewController.h"

@class WWRecordMyRoom;


@interface WWTagViewController : BRCoreViewController

@property(nonatomic, weak)WWRecordMyRoom* recordMyRoom;

-(IBAction)unwindBackToWWTagViewControllerSave:(UIStoryboardSegue *)segue;
@end
