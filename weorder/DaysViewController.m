
#import "DaysViewController.h"
#import "GraphViewController.h"
#import "MeasurementsViewController.h"
#import "Record.h"

@implementation DaysViewController

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

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	// Redraw after we come back from the Measurements View Controller,
	// because the total may have changed.
	[self.tableView reloadData];
}
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
	if ([segue.identifier isEqualToString:@"ShowRecord"])
	{
		NSIndexPath *indexPath = [self.tableView indexPathForCell:sender];
		MeasurementsViewController *controller = segue.destinationViewController;
		Record *record = _records[indexPath.row];
		controller.record = record;
		// Make the back button say the date again
		UIBarButtonItem *backButton = [[UIBarButtonItem alloc]
			initWithTitle:[record dateForDisplay]
			style:UIBarButtonItemStylePlain
			target:nil
            action:nil];
		self.parentViewController.navigationItem.backBarButtonItem = backButton;
	}
}
#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	return [self.records count];
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
	Record *record = self.records[indexPath.row];
	cell.textLabel.text = [record dateForDisplay];
	cell.detailTextLabel.text = [NSString stringWithFormat:@"Total: %d", record.total];

	return cell;
}
#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	Record *record = self.records[indexPath.row];
	self.graphViewController.record = record;
}

@end
