
#import "GraphViewController.h"
#import "MeasurementsViewController.h"
#import "Record.h"
#import "GraphView.h"

@interface GraphViewController ()
@property (nonatomic, weak) IBOutlet UIScrollView *scrollView;
@property (nonatomic, weak) IBOutlet UIButton *toggleButton;
@property (nonatomic, weak) IBOutlet GraphView *graphView;
@end

@implementation GraphViewController
//k;df
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
	self.title = [self.record dateForDisplay];

	// Add the graph view to the scroll view.
	GraphView *graphView = [[GraphView alloc] initWithFrame:CGRectMake(0, 0, 600, 152)];
	[self.scrollView addSubview:graphView];
	self.scrollView.contentSize = graphView.bounds.size;
	self.graphView = graphView;
	self.graphView.showCircles = YES;
}

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
    
	// Redraw after we come back from the Measurements View Controller,
	// because the values may have changed.
	[self redrawGraph];
}
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
- (void)redrawGraph
{
	self.graphView.values = self.record.values;
	[self.graphView setNeedsDisplay];
}

- (IBAction)toggleGraph:(id)sender
{
	self.graphView.showCircles = !self.graphView.showCircles;
	[self redrawGraph];
}

- (void)setRecord:(Record *)newRecord
{
	if (nil == newRecord 
        || _record != newRecord)
	{
		_record = newRecord;
		[self redrawGraph];
	}
}

@end
