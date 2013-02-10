
#import "MasterViewController.h"
#import "DetailViewController.h"
#import "NSDictionary+RWFlatten.h"
#import "Item.h"
#import "Section.h"
#import "DataModel.h"

@interface MasterViewController () <UITableViewDataSource, UITableViewDelegate>
@property (nonatomic, weak) IBOutlet UITableView *tableView;
@property (nonatomic, weak) IBOutlet UISegmentedControl *segmentedControl;
@end

@implementation MasterViewController
{
	DataModel *dataModel;
	BOOL sortedByName;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
	if ((self = [super initWithCoder:aDecoder]))
	{
		dataModel = [[DataModel alloc] init];
		sortedByName = YES;
	}
	return self;
}

- (void)viewDidLoad
{
	[super viewDidLoad];

	if (sortedByName)
		self.segmentedControl.selectedSegmentIndex = 0;
	else
		self.segmentedControl.selectedSegmentIndex = 1;

	[self updateTableContents];
}

- (void)didReceiveMemoryWarning
{
	[super didReceiveMemoryWarning];

	if ([self isViewLoaded] && self.view.window == nil)
	{
		self.view = nil;
		[dataModel clearSortedItems];
	}
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Actions

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
	if ([segue.identifier isEqualToString:@"ShowDetail"])
	{
		DetailViewController *controller = segue.destinationViewController;

		controller.completionBlock = ^(BOOL success)
		{
			if (success)
			{
				// This will cause the table of values to be resorted if necessary.
				[dataModel clearSortedItems];

				[self updateTableContents];
			}
			[self dismissViewControllerAnimated:YES completion:nil];
		};

		UITableViewCell *cell = sender;
		NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];

		if (sortedByName)
		{
			NSString *sectionName = dataModel[indexPath.section];
			Section *section = dataModel[sectionName];
			controller.itemToEdit = section[indexPath.row];
		}
		else
		{
			controller.itemToEdit = dataModel.sortedItems[indexPath.row];
		}
	}
}

- (IBAction)sortChanged:(UISegmentedControl *)sender
{
	if (sender.selectedSegmentIndex == 0)
		sortedByName = YES;
	else
		sortedByName = NO;

	[self updateTableContents];
}

#pragma mark - Application Logic

- (void)updateTableContents
{
	// Lazily sort the list by value if we haven't done that yet.
	if (!sortedByName && dataModel.sortedItems == nil)
	{
		[dataModel sortByValue];
	}

	[self.tableView reloadData];
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	if (sortedByName)
		return [dataModel.sortedSectionNames count];
	else
		return 1;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
	if (sortedByName)
		return dataModel[section];
	else
		return nil;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	if (sortedByName)
	{
		NSString *sectionName = dataModel[section];
		Section *section = dataModel[sectionName];
		return [section.items count];
	}
	else
	{
		return [dataModel.sortedItems count];
	}
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"NumberCell"];

	Item *item;

	if (sortedByName)
	{
		NSString *sectionName = dataModel[indexPath.section];
		Section *section = dataModel[sectionName];
		item = section[indexPath.row];
	}
	else
	{
		item = dataModel.sortedItems[indexPath.row];
	}

	cell.textLabel.text = item.name;
	cell.detailTextLabel.text = [item.value description];
	return cell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
}

@end
