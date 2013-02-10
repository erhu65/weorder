//
//  UIImagePickerController+NonRotating.m
//  wework
//
//  Created by Peter2 on 1/26/13.
//  Copyright (c) 2013 Peter2. All rights reserved.
//


/*
 iPad app supporting landscape only displays a UIImagePickerController via a UIPopoverController. The UIImagePickerController requires Portrait orientation, but the app is forcing landscape only. Error and... crash
 */
#import "UIImagePickerController+NonRotating.h"

@implementation UIImagePickerController (NonRotating)


- (BOOL)shouldAutorotate
{
    return NO;
}

-(UIInterfaceOrientation)preferredInterfaceOrientationForPresentation
{
    return UIInterfaceOrientationPortrait;
}
@end
