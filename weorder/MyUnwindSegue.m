
#import "MyUnwindSegue.h"

@implementation MyUnwindSegue

- (UIView *)findTopMostViewForViewController:(UIViewController *)viewController
{
	UIView *theView = viewController.view;
	UIViewController *parentViewController = viewController.parentViewController;
	while (parentViewController != nil)
	{
		theView = parentViewController.view;
		parentViewController = parentViewController.parentViewController;
	}
	return theView;
}  

- (void)perform
{
	UIViewController *source = self.sourceViewController;
	UIViewController *destination = self.destinationViewController;

	// Find the views that we will be animating. If the source or destination
	// view controller sits inside a container view controller, then the view
	// to animate will actually be that parent controller's view.
	UIView *sourceView = [self findTopMostViewForViewController:source];
	UIView *destinationView = [self findTopMostViewForViewController:destination];

	// First dismiss the source view controller so that the destination view
	// controller becomes visible again.
	[destination dismissViewControllerAnimated:NO completion:nil];

	// Create a black view that covers the entire destination view, and set it
	// partially opaque. We'll use this to make the destination view appear to
	// rise up out of the background.
	UIView *dimView = [[UIView alloc] initWithFrame:destinationView.frame];
	[destinationView addSubview:dimView];
	dimView.opaque = YES;
	dimView.alpha = 0.5f;
	dimView.backgroundColor = [UIColor blackColor];

	// Add the source view back on top of the destination view
	sourceView.frame = destinationView.bounds;
	[destinationView addSubview:sourceView];

	// The endpoint for the destination view is centered in the screen, which
	// is where it is right now.
	CGPoint destEndPoint = destinationView.center;

	// The start point for the destination view is half-way off the screen.
	// It will only travel half the width of the screen (parallax effect).
	CGPoint destStartPoint = destinationView.center;
	destStartPoint.x -= destinationView.bounds.size.width / 2.0f;
	destinationView.center = destStartPoint;

	// The endpoint for the source view is off-screen on the right.
	CGPoint sourceEndPoint = sourceView.center;
	sourceEndPoint.x += sourceView.bounds.size.width;

	// The start point for the source view is centered in the screen, but
	// because we're adding it as a subview to the destination view, which
	// itself is no longer centered, we have to offset it.
	CGPoint sourceStartPoint = sourceView.center;
	sourceStartPoint.x += sourceView.bounds.size.width / 2.0f;
	sourceView.center = sourceStartPoint;

	// Start the animation.
	[UIView animateWithDuration:0.5f
		delay:0
		options:UIViewAnimationOptionCurveEaseOut
		animations:^(void)
		{
			// Move the views to their endpoints and make the dimView lighter.
			destinationView.center = destEndPoint;
			sourceView.center = sourceEndPoint;
			dimView.alpha = 0.0f;
		}
		completion: ^(BOOL done)
		{
			// These subviews are no longer needed now, so remove them.
			[sourceView removeFromSuperview];
			[dimView removeFromSuperview];
		}];
}

@end
