//
//  UIView+position.h
//
//  Created by Tyler Neylon on 3/19/10.
//  Copyleft 2010 Bynomial.
//

#import <Foundation/Foundation.h>

@interface UIView (position)

@property (nonatomic) CGPoint frameOrigin;
@property (nonatomic) CGSize frameSize;

@property (nonatomic) CGFloat frameX;
@property (nonatomic) CGFloat frameY;

// Setting these modifies the origin but not the size.
@property (nonatomic) CGFloat frameRight;
@property (nonatomic) CGFloat frameBottom;

@property (nonatomic) CGFloat frameWidth;
@property (nonatomic) CGFloat frameHeight;

@end



/*
 Solution: finer-grained UIView properties
 A better approach is to introduce new properties of all UIView objects (and subclasses) with a few category methods.  This is what UIView+position is about.  With it, you can write code like this to cleanly solve the above cases:
 myView.frameX += 10;
 or
 myView.frameSize = CGSizeMake(20, 20);
 Here’s a list of all the new properties:
 frameOrigin, frameSize
 frameX, frameY
 frameWidth, frameHeight
 frameRight, frameBottom
 The last two properties, when changed, will vary the origin but not the size — that is, they move the view rather than resize it.
 These extra properties have been extraordinarily convenient to me, and I hope they might be for you as well.
 */