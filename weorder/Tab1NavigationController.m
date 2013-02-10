
#import "Tab1NavigationController.h"
#import "MyUnwindSegue.h"
 
@implementation Tab1NavigationController

- (UIStoryboardSegue *)segueForUnwindingToViewController:(UIViewController *)toViewController fromViewController:(UIViewController *)fromViewController identifier:(NSString *)identifier
{
	if ([identifier isEqualToString:@"segueBackTovideos"])
		return [[MyUnwindSegue alloc] initWithIdentifier:identifier source:fromViewController destination:toViewController];
	else
		return [super segueForUnwindingToViewController:toViewController fromViewController:fromViewController identifier:identifier];
}


@end
