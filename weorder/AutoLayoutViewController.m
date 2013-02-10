
#import "AutoLayoutViewController.h"

@interface UIWindow (AutoLayoutDebug) 
+ (UIWindow *)keyWindow;
- (NSString *)_autolayoutTrace;
@end


@interface AutoLayoutViewController () <UITableViewDataSource, UITableViewDelegate>
@property (nonatomic, weak) IBOutlet UITableView *tableView;
@property (nonatomic, weak) IBOutlet UILabel *filterNameLabel;


@property (nonatomic, weak) IBOutlet UIView *filterBar; 
@property (nonatomic, strong) IBOutlet NSLayoutConstraint *spaceBetweenFilterBarAndMainTable;
@end

@implementation AutoLayoutViewController
{
	NSArray *filterNames;
	NSUInteger activeFilterIndex;
	UITableView *filterTableView;
    
    NSArray *verticalConstraintsBeforeAnimation; 
    NSArray *verticalConstraintsAfterAnimation;
}

- (void)viewDidLoad
{
	[super viewDidLoad];

	filterNames = @[ @"Show All", @"By Name", @"By Date", @"By Popularity" ];
	activeFilterIndex = 0;

	self.filterNameLabel.text = filterNames[activeFilterIndex];
}

- (void)didReceiveMemoryWarning
{
	[super didReceiveMemoryWarning];
	// Dispose of any resources that can be recreated.
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	if (tableView == self.tableView)
		return 50;
	else
		return [filterNames count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	static NSString *CellIdentifier = @"Cell";

	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	if (cell == nil)
		cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];

	if (tableView == self.tableView)
	{
		cell.textLabel.text = [NSString stringWithFormat:@"Row %d", indexPath.row];
	}
	else
	{
		cell.textLabel.text = filterNames[indexPath.row];
		cell.accessoryType = (activeFilterIndex == indexPath.row) ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
        cell.textLabel.font = [UIFont systemFontOfSize:14.0f]; 
        cell.textLabel.textColor = [UIColor whiteColor];
	}

	return cell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (tableView == filterTableView) {
        activeFilterIndex = indexPath.row; 
        self.filterNameLabel.text =filterNames[activeFilterIndex];
        [self hideFilterTable];
    
    }
}


- (IBAction)filterButtonPressed:(id)sender {
    
    if (filterTableView == nil) [self showFilterTable];
    else [self hideFilterTable];
}

- (void)hideFilterTable {
    
    [self.view removeConstraints: verticalConstraintsAfterAnimation];
    [self.view addConstraints: verticalConstraintsBeforeAnimation];
    
    [UIView animateWithDuration:0.3f animations:^ {
        [self.view layoutIfNeeded]; }
                     completion:^(BOOL finished) {
                         [filterTableView removeFromSuperview]; 
                         filterTableView = nil;
                         [self.view addConstraint: self.spaceBetweenFilterBarAndMainTable];
                     }];
                         
}

- (void)showFilterTable
{
    

    filterTableView = [[UITableView alloc]
                       initWithFrame:CGRectZero style:UITableViewStylePlain];
    filterTableView.translatesAutoresizingMaskIntoConstraints = NO;
    filterTableView.dataSource = self; 
    filterTableView.delegate = self;
    
    filterTableView.rowHeight = 24.0f; 
    filterTableView.backgroundColor = [UIColor blackColor]; 
    filterTableView.separatorColor = [UIColor darkGrayColor];
    
    [self.view addSubview:filterTableView];
    
    NSDictionary *viewsDictionary = NSDictionaryOfVariableBindings(filterTableView);
    NSArray *constraints = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|[filterTableView]|" options:0
                                                                   metrics:nil
                                                                     views:viewsDictionary];
    [self.view addConstraints:constraints];
//    constraints = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|[filterTableView]|" options:0
//                                                          metrics:nil
//                                                            views:viewsDictionary];
//    [self.view addConstraints:constraints];
    
    
    [self.view removeConstraint: self.spaceBetweenFilterBarAndMainTable];
//    
//    NSLayoutConstraint *constraint = [NSLayoutConstraint constraintWithItem:self.filterBar attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:filterTableView attribute:NSLayoutAttributeTop
//                                                                 multiplier:1.0f constant:0.0f];
//    [self.view addConstraint:constraint];
//    
//    constraint = [NSLayoutConstraint constraintWithItem:filterTableView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.tableView attribute:NSLayoutAttributeTop multiplier:1.0f constant:0.0f];
//    
//    [self.view addConstraint:constraint];
//    
//    constraint = [NSLayoutConstraint constraintWithItem:filterTableView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0f
//                                               constant:96.0f];
//    [self.view addConstraint:constraint];
    
    
    viewsDictionary = @{
    @"filterTableView": filterTableView, @"filterBar": self.filterBar, @"mainTableView": self.tableView };
    
    /// this is new
    constraints = [NSLayoutConstraint constraintsWithVisualFormat:
                   @"V:[filterBar][filterTableView(0)][mainTableView]"
                                                          options:0
                                                          metrics:nil views:viewsDictionary];
    verticalConstraintsBeforeAnimation = constraints;
    [self.view addConstraints:constraints]; 
    [self.view layoutIfNeeded];
    [self.view removeConstraints:constraints]; /// until here
    
    
    constraints = [NSLayoutConstraint constraintsWithVisualFormat:
                   @"V:[filterBar][filterTableView(96)][mainTableView]"
                                                          options:0
                                                          metrics:nil views:viewsDictionary];
    verticalConstraintsAfterAnimation = constraints;
    [self.view addConstraints:constraints];
    
    [UIView animateWithDuration:0.3f animations:^ {
        [self.view layoutIfNeeded]; }];

}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    NSLog(@"%@", [[UIWindow keyWindow] _autolayoutTrace]); }
- (void)didRotateFromInterfaceOrientation: (UIInterfaceOrientation)fromInterfaceOrientation
{
    [super didRotateFromInterfaceOrientation:
     fromInterfaceOrientation];
    NSLog(@"%@", [[UIWindow keyWindow] _autolayoutTrace]); 
}
@end
