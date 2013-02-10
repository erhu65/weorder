
#import "GraphView.h"

@implementation GraphView

- (void)drawRect:(CGRect)rect
{
	// Exit if there is nothing to draw
	if ([self.values count] == 0)
		return;

	CGContextRef context = UIGraphicsGetCurrentContext();

	// Erase the background
	[self.backgroundColor setFill];
	UIRectFill(self.bounds);

	// Compensate for UIKit coordinate system
	CGContextTranslateCTM(context, 0.0f, self.bounds.origin.y + self.bounds.size.height);     
	CGContextScaleCTM(context, 1.0f, -1.0f);

	// Add a small margin around the content
	const CGFloat HorzMargin = 10.0f;
	const CGFloat VertMargin = 10.0f;
	CGRect contentRect = CGRectInset(self.bounds, HorzMargin, VertMargin);
	CGContextTranslateCTM(context, HorzMargin, VertMargin);
	// Configure the line style
	CGContextSetLineCap(context, kCGLineCapRound);
	CGContextSetLineJoin(context, kCGLineJoinRound);
	CGContextSetLineWidth(context, 4.0f);
	CGContextSetRGBStrokeColor(context, 0.6f, 0.0f, 0.0f, 1.0f);

	// Calculate how big to draw the lines
	CGFloat x = 0.0f;
	CGFloat stepX = contentRect.size.width / ([self.values count] - 1);
	CGFloat scaleY = contentRect.size.height / 100.0f;

	// Move to the first point on the line
	CGContextBeginPath(context);
	CGContextMoveToPoint(context, x, [self.values[0] floatValue] * scaleY);

	// Add strokes between the points
	for (NSUInteger t = 1; t < [self.values count]; ++t)
	{
		x += stepX;
		CGContextAddLineToPoint(context, x, [self.values[t] floatValue] * scaleY);
	}

	// Finally, draw the entire graph
	CGContextStrokePath(context);

	// Set up a drop shadow for what we'll draw next
	CGContextSetShadowWithColor(context, CGSizeZero, 4.0f, [UIColor blackColor].CGColor);
	CGContextSetRGBFillColor(context, 1.0f, 0.0f, 0.0f, 1.0f);

	// Draw circles on top of the points, if enabled
	if (self.showCircles)
	{
		__block CGFloat circleX = 0.0f;
		const CGFloat Radius = 5.0f;
		[self.values enumerateObjectsUsingBlock:^(NSNumber *value, NSUInteger idx, BOOL *stop)
		{
			CGFloat circleY = [value floatValue] * scaleY;
			CGRect circleRect = CGRectMake(circleX - Radius, circleY - Radius, Radius*2.0f, Radius*2.0f);
			CGContextFillEllipseInRect(context, circleRect);
			circleX += stepX;
		}];
	}
}

@end
