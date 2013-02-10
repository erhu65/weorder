
#import "EditViewController.h"

@interface EditViewController () <UIActionSheetDelegate>
@property (nonatomic, weak) IBOutlet UITextField *textField;
@property (nonatomic, weak) IBOutlet UIButton *deleteButton;
@end

@implementation EditViewController

- (id)initWithCoder:(NSCoder *)aDecoder
{
	if ((self = [super initWithCoder:aDecoder]))
	{
		NSLog(@"initWithCoder %@", self);
	}
	return self;
}

- (void)dealloc
{
	NSLog(@"dealloc %@", self);
}

- (void)viewDidLoad
{
	[super viewDidLoad];

	self.textField.text = [NSString stringWithFormat:@"%d", self.value];
}

- (void)viewDidAppear:(BOOL)animated
{
	[super viewDidAppear:animated];
    
	// Ignore this the first time it is called (which happens just before the
	// segue animation), but show the keyboard the second time (which happens
	// after this view controller is properly presented after the animation
	// from the segue completes).
    if (self.presentingViewController != nil)
	{
		[self.textField becomeFirstResponder];
	}
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
	if ([segue.identifier isEqualToString:@"DoneEdit"])
	{
		self.value = [self.textField.text intValue];
	}
}

- (BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender
{
	if ([identifier isEqualToString:@"DoneEdit"])
	{
		if ([self.textField.text length] > 0)
		{
			int value = [self.textField.text intValue];
			if (value >= 0 && value <= 100)
				return YES;
		}
        
		[[[UIAlertView alloc]
				initWithTitle:nil
				message:@"Value must be between 0 and 100."
				delegate:nil
				cancelButtonTitle:@"OK"
				otherButtonTitles:nil]
			show];
		return NO;
	}
	return YES;
}

- (IBAction)delete:(id)sender
{
	UIActionSheet *actionSheet = [[UIActionSheet alloc]
		initWithTitle:@"Really delete?"
		delegate:self
		cancelButtonTitle:@"Cancel"
		destructiveButtonTitle:@"Delete"
		otherButtonTitles:nil];

	[actionSheet showFromRect:self.deleteButton.frame inView:self.view animated:YES];
}

#pragma mark - UIActionSheetDelegate
- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex
{
	if (buttonIndex != actionSheet.cancelButtonIndex)
	{
		[self performSegueWithIdentifier:@"DeleteValue" sender:nil];
	}
}
@end
