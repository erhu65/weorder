//
//  WOItemsViewController.m
//  weorder
//
//  Created by Peter2 on 2/19/13.
//  Copyright (c) 2013 peter. All rights reserved.
//

#import "WOItemsViewController.h"
#import "WOEditItemViewController.h"
#import "WORecordItem.h"

@interface WOItemsViewController ()

@end

@implementation WOItemsViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	
    if(self.mode == WOItemsViewControllerModeBackend){
        //my itmes list
        self.title = kSharedModel.lang[@"myStroeItems"];
        
    } else {
        //someone else's store items list
        //self.title = kSharedModel.lang[@"myStroeItems"];
        
    }
    
}

- (BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender
{
    //	if ([identifier isEqualToString:@"DoneEdit"])
    //	{
    //		if ([self.textField.text length] > 0)
    //		{
    //			int value = [self.textField.text intValue];
    //			if (value >= 0 && value <= 100)
    //				return YES;
    //		}
    //        
    //		[[[UIAlertView alloc]
    //          initWithTitle:nil
    //          message:@"Value must be between 0 and 100."
    //          delegate:nil
    //          cancelButtonTitle:@"OK"
    //          otherButtonTitles:nil]
    //         show];
    //		return NO;
    //	}
	return YES;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    NSString *identifier = segue.identifier;
    __block __weak WOItemsViewController* weakSelf = (WOItemsViewController*)self;  
    if ([identifier isEqualToString:@"segueAddItem"]) {
        WOEditItemViewController *destinationVC = (WOEditItemViewController *) segue.destinationViewController;
        destinationVC.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
        destinationVC.complectionBlock = ^(NSDictionary* res){ 
            
            PRPLog(@"after add new item res: %@-[%@ , %@]",
                   res,
                   NSStringFromClass([self class]),
                   NSStringFromSelector(_cmd));
            //[weakSelf _fetchStorePics];
             [weakSelf dismissViewControllerAnimated:YES completion:nil];
            
        };        
    } else if([identifier isEqualToString:@"segueEditItem"]) {
        
        WORecordItem *record = (WORecordItem *)sender;
        WOEditItemViewController *destinationVC = (WOEditItemViewController *) segue.destinationViewController;
        destinationVC.modalTransitionStyle = UIModalTransitionStylePartialCurl;
        destinationVC.recordToEdit = record;
        
        destinationVC.complectionBlock = ^(NSDictionary* res){ 
            
            //[weakSelf _fetchStorePics];
            
            PRPLog(@"after upd old item res: %@-[%@ , %@]",
                   res,
                   NSStringFromClass([self class]),
                   NSStringFromSelector(_cmd));
            
            [weakSelf dismissViewControllerAnimated:YES completion:nil];

        };        
    }
    
    
}

@end
