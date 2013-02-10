
#import "CombinedViewController.h"
#import "DaysViewController.h"
#import "GraphViewController.h"
#import "Record.h"

@interface CombinedViewController ()
@property (nonatomic, weak) DaysViewController *daysViewController;
@property (nonatomic, weak) GraphViewController *graphViewController;
@end

@implementation CombinedViewController
{
	NSArray *_records;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
	if ((self = [super initWithCoder:aDecoder]))
	{
		NSLog(@"initWithCoder %@", self);
        
		// Fill up the array with Record objects, and sort by date.
		_records =
			[@[
				[self makeFakeRecord],
				[self makeFakeRecord],
				[self makeFakeRecord],
				[self makeFakeRecord],
				[self makeFakeRecord],
			]
			sortedArrayUsingComparator:^NSComparisonResult(Record *record1, Record *record2)
			{
				return [record1.date compare:record2.date];
			}];
	}
	return self;
}

- (void)dealloc
{
	NSLog(@"dealloc %@", self);
}
- (Record *)makeFakeRecord
{
	// A Record contains a date and up to 24 NSNumber objects (one for each
	// hour in the day). We first calculate a random fake date in the past,
	// and then create NSNumber objects with random values between 0 and 100.

	NSTimeInterval timeInterval = (int)arc4random_uniform(10000000) * -1;
	NSDate *date = [NSDate dateWithTimeIntervalSinceNow:timeInterval];

	NSMutableArray *values = [NSMutableArray array];
	for (int t = 0; t < 24; ++t)
	{
		[values addObject:@(arc4random_uniform(100))];
	}
	return [[Record alloc] initWithDate:date values:values];
}

- (void)viewDidLoad
{
	[super viewDidLoad];
	// These properties were set in prepareForSegue:, which is called before
	// viewDidLoad. We can now tell the Days view controller about the Graph
	// view controller.
	self.daysViewController.graphViewController = self.graphViewController;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
	if ([segue.identifier isEqualToString:@"EmbedDays"])
	{
		self.daysViewController = segue.destinationViewController;
		self.daysViewController.records = _records;
	}
	else if ([segue.identifier isEqualToString:@"EmbedGraph"])
	{
		self.graphViewController = segue.destinationViewController;
	}
}
- (void)didReceiveMemoryWarning
{
	[super didReceiveMemoryWarning];
	
	if ([self isViewLoaded] && self.view.window == nil)
	{
		self.view = nil;

		[self.daysViewController willMoveToParentViewController:nil];
		[self.daysViewController removeFromParentViewController];
		
		[self.graphViewController willMoveToParentViewController:nil];
		[self.graphViewController removeFromParentViewController];
	}
}
- (IBAction)cancel:(UIStoryboardSegue *)segue
{
    
}
@end
