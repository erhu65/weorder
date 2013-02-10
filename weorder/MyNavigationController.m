
#import "MyNavigationController.h"
#import "MyUnwindSegue.h"

@implementation MyNavigationController

- (UIStoryboardSegue *)segueForUnwindingToViewController:(UIViewController *)toViewController fromViewController:(UIViewController *)fromViewController identifier:(NSString *)identifier
{
	if ([identifier isEqualToString:@"segueBackTovideos"] || 
        [identifier isEqualToString:@"DoneEdit"] || [identifier isEqualToString:@"CancelEdit"])
		return [[MyUnwindSegue alloc] initWithIdentifier:identifier source:fromViewController destination:toViewController];
	else
		return [super segueForUnwindingToViewController:toViewController fromViewController:fromViewController identifier:identifier];
}

@end
