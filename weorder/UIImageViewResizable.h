//
//  UIImageViewResizable.h
//  BirthdayReminder
//
//  Created by Peter2 on 12/19/12.
//  Copyright (c) 2012 Nick Kuh. All rights reserved.
//

@interface UIImageViewResizable : UIImageView <UIGestureRecognizerDelegate>{
    UIPanGestureRecognizer *panGesture;
}

@property(nonatomic) BOOL isZoomable;

- (void) applyGestures;
- (void) scaleToMinimum;

- (void)pinch:(UIPinchGestureRecognizer *)gesture;
- (void)pan:(UIPanGestureRecognizer *)gesture;
- (void)doubleTap:(UITapGestureRecognizer *)gesture;

@end