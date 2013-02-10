//
//  BRStyleSheet.m
//  BirthdayReminder
//
//  Created by Nick Kuh on 27/07/2012.
//  Copyright (c) 2012 Nick Kuh. All rights reserved.
//

#import "BRStyleSheet.h"
#import "BRBlueButton.h"
#import "BRRedButton.h"
#import <QuartzCore/QuartzCore.h>


#define kFontLightOnDarkTextColour [UIColor colorWithRed:255.0/255 green:251.0/255 blue:218.0/255 alpha:1.0]
#define kFontDarkOnLightTextColour [UIColor colorWithRed:1.0/255 green:1.0/255 blue:1.0/255 alpha:1.0]

#define kFontNavigationTextColour [UIColor colorWithRed:106.f/255.f green:62.f/255.f blue:39.f/255.f alpha:1.f]
#define kFontNavigationDisabledTextColour [UIColor colorWithRed:106.f/255.f green:62.f/255.f blue:39.f/255.f alpha:0.6f]
#define kNavigationButtonBackgroundColour [UIColor colorWithRed:255.f/255.f green:245.f/255.f blue:225.f/255.f alpha:1.f]
#define kToolbarButtonBackgroundColour [UIColor colorWithRed:39.f/255.f green:17.f/255.f blue:5.f/255.f alpha:1.f]
#define kLargeButtonTextColour [UIColor whiteColor]

#define kFontNavigation [UIFont fontWithName:@"HelveticaNeue-Bold" size:18.f]
#define kFontName [UIFont fontWithName:@"HelveticaNeue-Bold" size:15.f]
#define kFontBirthdayDate [UIFont fontWithName:@"HelveticaNeue" size:13.f]
#define kFontDaysUntilBirthday [UIFont fontWithName:@"HelveticaNeue-Bold" size:25.f]
#define kFontDaysUntillBirthdaySubText [UIFont fontWithName:@"HelveticaNeue" size:9.f]
#define kFontLarge [UIFont fontWithName:@"HelveticaNeue-Bold" size:17.f]
#define kFontButton [UIFont fontWithName:@"HelveticaNeue-Bold" size:30.f]
#define kFontNotes [UIFont fontWithName:@"HelveticaNeue" size:16.f]
#define kFontPicPhoto [UIFont fontWithName:@"HelveticaNeue-Bold" size:12.f]
#define kFontDropShadowColour [UIColor colorWithRed:1.0/255 green:1.0/255 blue:1.0/255 alpha:0.75]
@implementation BRStyleSheet

+(void) initStyles
{
    
    
    // UINavigationBar
    UIImage *gradientImage44 = [[UIImage imageNamed:@"surf_gradient_textured_44"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 0, 0, 0)];
    UIImage *gradientImage32 = [[UIImage imageNamed:@"surf_gradient_textured_32"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 0, 0, 0)];
    [[UINavigationBar appearance] setBackgroundImage:gradientImage44 forBarMetrics:UIBarMetricsDefault];
    [[UINavigationBar appearance] setBackgroundImage:gradientImage32 forBarMetrics:UIBarMetricsLandscapePhone];
    
    [[UINavigationBar appearance] setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIColor colorWithRed:255.0/255.0 green:255.0/255.0 blue:255.0/255.0 alpha:1.0], UITextAttributeTextColor, [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.8], UITextAttributeTextShadowColor, [NSValue valueWithUIOffset:UIOffsetMake(0, -1)], UITextAttributeTextShadowOffset, [UIFont fontWithName:@"Arial-Bold" size:0.0], UITextAttributeFont, nil]];  
    
    // UIBarButtonItem - About
    
    UIImage *button30 = [[UIImage imageNamed:@"button_textured_30"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 5, 0, 5)];
    UIImage *button24 = [[UIImage imageNamed:@"button_textured_24"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 5, 0, 5)];
    [[UIBarButtonItem appearance] setBackgroundImage:button30 forState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
    [[UIBarButtonItem appearance] setBackgroundImage:button24 forState:UIControlStateNormal barMetrics:UIBarMetricsLandscapePhone];
    
    [[UIBarButtonItem appearance] setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIColor colorWithRed:220.0/255.0 green:104.0/255.0 blue:1.0/255.0 alpha:1.0], UITextAttributeTextColor, [UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:1.0], UITextAttributeTextShadowColor, [NSValue valueWithUIOffset:UIOffsetMake(0, 1)], UITextAttributeTextShadowOffset, [UIFont fontWithName:@"AmericanTypewriter" size:0.0], UITextAttributeFont, nil] forState:UIControlStateNormal];
    NSDictionary *barButtonItemTextAttributes;
    
    //NAVIGATION BUTTONS
    
    //Tint of the navigation button backgrounds
    [[UIBarButtonItem appearanceWhenContainedIn:[UINavigationBar class],nil] setTintColor:kNavigationButtonBackgroundColour];
    
    barButtonItemTextAttributes = [NSDictionary dictionaryWithObjectsAndKeys:
                                   kFontNavigationTextColour, UITextAttributeTextColor,
                                   [UIColor whiteColor], UITextAttributeTextShadowColor,
                                   [NSValue valueWithUIOffset:UIOffsetMake(0, 1)], UITextAttributeTextShadowOffset,nil];
    [[UIBarButtonItem appearanceWhenContainedIn:[UINavigationBar class], nil] setTitleTextAttributes:barButtonItemTextAttributes forState:UIControlStateNormal];
    
    NSDictionary *disabledBarButtonItemTextAttributes = [NSDictionary dictionaryWithObjectsAndKeys:
                                                         kFontNavigationDisabledTextColour, UITextAttributeTextColor,
                                                         [UIColor whiteColor], UITextAttributeTextShadowColor,
                                                         [NSValue valueWithUIOffset:UIOffsetMake(0, 1)], UITextAttributeTextShadowOffset,nil];
    [[UIBarButtonItem appearanceWhenContainedIn:[UINavigationBar class], nil] setTitleTextAttributes:disabledBarButtonItemTextAttributes forState:UIControlStateDisabled];
    

    
    //BUTTONS
    [[BRBlueButton appearance] setBackgroundImage:[UIImage imageNamed:@"button-blue.png"] forState:UIControlStateNormal];
    [[BRBlueButton appearance] setTitleColor:kLargeButtonTextColour forState:UIControlStateNormal]; 
    [[BRBlueButton appearance] setFont:kFontLarge];
    
    [[BRRedButton appearance] setBackgroundImage:[UIImage imageNamed:@"button-red.png"] forState:UIControlStateNormal];
    [[BRRedButton appearance] setTitleColor:kLargeButtonTextColour forState:UIControlStateNormal];
    [[BRRedButton appearance] setFont:kFontLarge];
    
    //TABLE VIEW
    [[UITableView appearance] setBackgroundColor:[UIColor clearColor]];
    //[[UITableViewCell appearance] setSelectionStyle:UITableViewCellSelectionStyleNone];
    [[UITableView appearance] setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    
    
    
    // UISlider
    
    UIImage *minImage = [[UIImage imageNamed:@"slider_minimum.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 5, 0, 0)];
    UIImage *maxImage = [[UIImage imageNamed:@"slider_maximum.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 5, 0, 0)];
    UIImage *thumbImage = [UIImage imageNamed:@"thumb.png"];
    
    [[UISlider appearance] setMaximumTrackImage:maxImage forState:UIControlStateNormal];
    [[UISlider appearance] setMinimumTrackImage:minImage forState:UIControlStateNormal];
    [[UISlider appearance] setThumbImage:thumbImage forState:UIControlStateNormal];    
    
    // UISegmentedControl
    
    UIImage *segmentSelected = [[UIImage imageNamed:@"segcontrol_sel.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 15, 0, 15)];
    UIImage *segmentUnselected = [[UIImage imageNamed:@"segcontrol_uns.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 15, 0, 15)];
    UIImage *segmentSelectedUnselected = [UIImage imageNamed:@"segcontrol_sel-uns.png"];
    UIImage *segUnselectedSelected = [UIImage imageNamed:@"segcontrol_uns-sel.png"];
    UIImage *segmentUnselectedUnselected = [UIImage imageNamed:@"segcontrol_uns-uns.png"];
    
    [[UISegmentedControl appearance] setBackgroundImage:segmentUnselected forState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
    [[UISegmentedControl appearance] setBackgroundImage:segmentSelected forState:UIControlStateSelected barMetrics:UIBarMetricsDefault];
    
    [[UISegmentedControl appearance] setDividerImage:segmentUnselectedUnselected forLeftSegmentState:UIControlStateNormal
                                   rightSegmentState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
    [[UISegmentedControl appearance] setDividerImage:segmentSelectedUnselected forLeftSegmentState:UIControlStateSelected
                                   rightSegmentState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
    [[UISegmentedControl appearance] setDividerImage:segUnselectedSelected forLeftSegmentState:UIControlStateNormal
                                   rightSegmentState:UIControlStateSelected barMetrics:UIBarMetricsDefault];
    
    
    //UIToolbar style 1. 
    //Toolbar cake background image
    [[UIToolbar appearance] setBackgroundImage:[UIImage imageNamed:@"tool-bar-background.png"]  forToolbarPosition:UIToolbarPositionAny barMetrics:UIBarMetricsDefault];
    
    //UIToolbar style 2.   
//    UIImage *gradientTop = [[UIImage imageNamed:@"surf_gradient_textured_44"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 0, 0, 0)];
//    [[UIToolbar appearance] setBackgroundImage:gradientTop 
//                            forToolbarPosition:UIToolbarPositionAny 
//                                    barMetrics:UIBarMetricsDefault]; 

}

+(void)styleLabel:(UILabel *)label withType:(BRLabelType)labelType
{
    switch (labelType) {
        case BRLabelTypeName:
            label.font = kFontName;
            label.layer.shadowColor = kFontDropShadowColour.CGColor;
            label.layer.shadowOffset = CGSizeMake(1.0f, 1.0f);
            label.layer.shadowRadius = 0.0f;
            label.layer.masksToBounds = NO;
            label.textColor = kFontLightOnDarkTextColour;
            break;
        case BRLabelTypeBirthdayDate:
            label.font = kFontBirthdayDate;
            label.textColor = kFontDarkOnLightTextColour;
            break;
        case BRLabelTypeDaysUntilBirthday:
            label.font = kFontDaysUntilBirthday;
            label.textColor = kFontLightOnDarkTextColour;
            break;
        case BRLabelTypeDaysUntilBirthdaySubText:
            label.font = kFontDaysUntillBirthdaySubText;
            label.textColor = kFontLightOnDarkTextColour;
            break;
        case BRLabelTypeLarge:
            label.textColor = kFontLightOnDarkTextColour;
            label.layer.shadowColor = kFontDropShadowColour.CGColor;
            label.layer.shadowOffset = CGSizeMake(1.0f, 1.0f);
            label.layer.shadowRadius = 0.0f;
            label.layer.masksToBounds = NO;
            break;
        default:
            label.textColor = kFontLightOnDarkTextColour;
            break;
    }
    
}

+(void)styleRoundCorneredView:(UIView *)view
{
    view.layer.cornerRadius = 4.f;
    view.layer.masksToBounds = YES;
    view.clipsToBounds = YES;
}

+(void)styleTextView:(UITextView *)textView
{
    textView.backgroundColor = [UIColor clearColor];
    textView.font = kFontNotes;
    textView.textColor = kFontLightOnDarkTextColour;
    textView.layer.shadowColor = kFontDropShadowColour.CGColor;
    textView.layer.shadowOffset = CGSizeMake(1.0f, 1.0f);
    textView.layer.shadowRadius = 0.0f;
    textView.layer.masksToBounds = NO;
}


@end
