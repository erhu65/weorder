
#import "MeasurementsViewController.h"
#import "EditViewController.h"
#import "Record.h"

@interface MeasurementsViewController ()

@end

@implementation MeasurementsViewController

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

-(void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
	if ([segue.identifier isEqualToString:@"EditValue"])
	{
		UINavigationController *navigationController = segue.destinationViewController;
		EditViewController *controller = (EditViewController *)navigationController.topViewController;
        
		NSIndexPath *indexPath = [self.tableView indexPathForCell:sender];
		NSNumber *number = self.record.values[indexPath.row];
		controller.value = [number intValue];
	}
}
- (IBAction)done:(UIStoryboardSegue *)segue
{
	NSLog(@"segue = %@", segue);
	EditViewController *controller = segue.sourceViewController;
	NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
	[self.record replaceValue:controller.value atIndex:indexPath.row];
	[self.tableView reloadData];
}

- (IBAction)deleteValue:(UIStoryboardSegue *)segue
{
	NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
	[self.record deleteValueAtIndex:indexPath.row];
	[self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	return [self.record.values count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    NSNumber *number = self.record.values[indexPath.row];
    cell.textLabel.text = [number description];
    return cell;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
	if (editingStyle == UITableViewCellEditingStyleDelete)
	{
		[self.record deleteValueAtIndex:indexPath.row];
		[tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
	}
}

#pragma mark - EditViewControllerDelegate

- (void)editViewControllerDidCancel:(EditViewController *)controller
{
	[self dismissViewControllerAnimated:YES completion:nil];
}

- (void)editViewController:(EditViewController *)controller didChangeValue:(int)newValue
{
	NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
	[self.record replaceValue:newValue atIndex:indexPath.row];
	[self.tableView reloadData];

	[self dismissViewControllerAnimated:YES completion:nil];
}

@end
