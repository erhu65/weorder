//
//  SurfsUpViewController.m
//  Surf's Up
//
//  Created by Steven Baranski on 9/16/11.
//  Copyright 2011 Razeware LLC. All rights reserved.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.
//

#import "SurfsUpViewController.h"

#import "CustomCell.h"
//#import "PlaceholderViewController.h"

NSString * const REUSE_ID_TOP = @"TopRow";
NSString * const REUSE_ID_MIDDLE = @"MiddleRow";
NSString * const REUSE_ID_BOTTOM = @"BottomRow";
NSString * const REUSE_ID_SINGLE = @"SingleRow";

@implementation SurfsUpViewController

#pragma mark - Private behavior and "Model" methods


-(id)initWithCoder:(NSCoder *)aDecoder{
    
    self = [super initWithCoder:aDecoder];
    if(self){
        self.lang = [LangManager sharedManager].dic;
    }
    return self;
}
- (void)updateViewConstraints
{
    [super updateViewConstraints];
    
    //    [self.view addSubview:self.button];
    //    
    //    NSDictionary *views = @{ @"button" : self.button };
    //    
    //    // Position the button with edge padding
    //    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-20-[button(==100)]|" options:0 metrics:nil views:views]];
    //    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-700-[button(==60)]|" options:0 metrics:nil views:views]];    
    // Vertically center.
    //    NSLayoutConstraint *verticallyCenteredConstraint = [NSLayoutConstraint constraintWithItem:self.button attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:0.0];
    //    [self.view addConstraint:verticallyCenteredConstraint];
}



- (NSString *)tripNameForRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.row)
    {
        case 0:
            return @"";
            break;
        case 1:
            return @"";
            break;
        case 2:
            return @"";
            break;
        
    }
    return @"";
}

- (UIImage *)tripPhotoForRowAtIndexPath:(NSIndexPath *)indexPath
{
    int index = indexPath.row;
    index++;
    NSString* explosionThumbName = [NSString stringWithFormat:@"explosionThumb%d.png", index];
    return [UIImage imageNamed:explosionThumbName];
}

- (NSString *)reuseIdentifierForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger rowCount = [self tableView:[self tableView] numberOfRowsInSection:0];
    NSInteger rowIndex = indexPath.row;
    
    if (rowCount == 1)
    {
        return REUSE_ID_SINGLE;
    }
    
    if (rowIndex == 0)
    {
        return REUSE_ID_TOP;
    }
    
    if (rowIndex == (rowCount - 1))
    {
        return REUSE_ID_BOTTOM;
    }
    
    return REUSE_ID_MIDDLE;
}

- (UIImage *)backgroundImageForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *reuseID = [self reuseIdentifierForRowAtIndexPath:indexPath];
    if ([REUSE_ID_SINGLE isEqualToString:reuseID] == YES)
    {
        UIImage *background = [UIImage imageNamed:@"table_cell_single.png"]; 
        return [background resizableImageWithCapInsets:UIEdgeInsetsMake(0.0, 43.0, 0.0, 64.0)];
    }
    else if ([REUSE_ID_TOP isEqualToString:reuseID] == YES)
    {
        UIImage *background = [UIImage imageNamed:@"table_cell_top.png"]; 
        return [background resizableImageWithCapInsets:UIEdgeInsetsMake(0.0, 43.0, 0.0, 64.0)];
    }
    else if ([REUSE_ID_BOTTOM isEqualToString:reuseID] == YES)
    {
        UIImage *background = [UIImage imageNamed:@"table_cell_bottom.png"]; 
        return [background resizableImageWithCapInsets:UIEdgeInsetsMake(0.0, 34.0, 0.0, 35.0)];
    }
    else    // REUSE_ID_MIDDLE
    {
        UIImage *background = [UIImage imageNamed:@"table_cell_mid.png"]; 
        return [background resizableImageWithCapInsets:UIEdgeInsetsMake(0.0, 30.0, 0.0, 30.0)];
    }
}

- (UIImage *)selectedBackgroundImageForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *reuseID = [self reuseIdentifierForRowAtIndexPath:indexPath];
    if ([REUSE_ID_SINGLE isEqualToString:reuseID] == YES)
    {
        UIImage *background = [UIImage imageNamed:@"table_cell_single_sel.png"]; 
        return [background resizableImageWithCapInsets:UIEdgeInsetsMake(0.0, 43.0, 0.0, 64.0)];
    }
    else if ([REUSE_ID_TOP isEqualToString:reuseID] == YES)
    {
        UIImage *background = [UIImage imageNamed:@"table_cell_top_sel.png"]; 
        return [background resizableImageWithCapInsets:UIEdgeInsetsMake(0.0, 43.0, 0.0, 64.0)];
    }
    else if ([REUSE_ID_BOTTOM isEqualToString:reuseID] == YES)
    {
        UIImage *background = [UIImage imageNamed:@"table_cell_bottom_sel.png"]; 
        return [background resizableImageWithCapInsets:UIEdgeInsetsMake(0.0, 34.0, 0.0, 35.0)];
    }
    else    // REUSE_ID_MIDDLE
    {
        UIImage *background = [UIImage imageNamed:@"table_cell_mid_sel.png"]; 
        return [background resizableImageWithCapInsets:UIEdgeInsetsMake(0.0, 30.0, 0.0, 30.0)];
    }
}

- (void)registerNIBs
{
    NSBundle *classBundle = [NSBundle bundleForClass:[CustomCell class]];
    
    UINib *topNib = [UINib nibWithNibName:REUSE_ID_TOP bundle:classBundle];    
    [[self tableView] registerNib:topNib forCellReuseIdentifier:REUSE_ID_TOP];
    
    UINib *middleNib = [UINib nibWithNibName:REUSE_ID_MIDDLE bundle:classBundle];    
    [[self tableView] registerNib:middleNib forCellReuseIdentifier:REUSE_ID_MIDDLE];
    
    UINib *bottomNib = [UINib nibWithNibName:REUSE_ID_BOTTOM bundle:classBundle];    
    [[self tableView] registerNib:bottomNib forCellReuseIdentifier:REUSE_ID_BOTTOM];
    
    UINib *singleNib = [UINib nibWithNibName:REUSE_ID_SINGLE bundle:classBundle];    
    [[self tableView] registerNib:singleNib forCellReuseIdentifier:REUSE_ID_SINGLE];    
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self registerNIBs];
    
    [[self tableView] setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    [[self tableView] setBackgroundView:[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"bg_sand.png"]]];
    
    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone){
        self.view.backgroundColor = [UIColor grayColor];
        UIImageView *backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"app-background.png"]];
        [self.view insertSubview:backgroundView atIndex:0];
    }
}

-(void)viewWillAppear:(BOOL)animated{
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_handleFacebookMeDidUpdate:) name:BRNotificationFacebookMeDidUpdate object:[BRDModel sharedInstance]];

}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:BRNotificationFacebookMeDidUpdate object:[BRDModel sharedInstance]];
    
    if(nil != HUD){
        [HUD hide:NO];
    }
    [self _findAndResignFirstResponder:self.view];
    //prevent crash when clicking tab veray quickly...
    
}
-(BOOL) _findAndResignFirstResponder:(UIView *)theView{
    if([theView isFirstResponder]){
        [theView resignFirstResponder];
        return YES;
    }
    for(UIView *subView in theView.subviews){
        if([self _findAndResignFirstResponder:subView]){
            return YES;
        }
    }
    return NO;
}

-(IBAction)cancelAndDismiss:(id)sender
{
    NSLog(@"Cancel");
    [self dismissViewControllerAnimated:YES completion:^{
        //view controller dismiss animation completed
    }];
}

- (IBAction)saveAndDismiss:(id)sender
{
    NSLog(@"Save");
    [self dismissViewControllerAnimated:YES completion:^{
        //view controller dismiss animation completed
    }];
}


-(void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    if([self isViewLoaded] && self.view.window == nil){
        
        self.view = nil;
    }
}

-(void)handleErrMsg:(NSString*) errMsg{
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:self.lang[@"error"] message:errMsg delegate:nil cancelButtonTitle:self.lang[@"actionDimiss"]  otherButtonTitles:nil];
    [alert show];
}
-(void)showMsg:(NSString*)msg type:(msgLevel)level{
    
    NSString* levelStr;
    switch (level) {
        case msgLevelInfo:
            levelStr = self.lang[@"info"];
            break;
        case msgLevelWarn:
            levelStr = self.lang[@"warn"];
            break;
        case msgLevelError:
            levelStr = self.lang[@"error"];
            break;
        default:
            levelStr = self.lang[@"info"];
            break;
    }
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:levelStr message:msg delegate:nil cancelButtonTitle:self.lang[@"actionDimiss"]  otherButtonTitles:nil];
    [alert show];
    
}

-(void)showHud:(BOOL) isAnimation{
    
    if(HUD!= nil){
        [HUD hide:NO];
    }    
    
    HUD = [[MBProgressHUD alloc] initWithView:self.view];
    [self.view addSubview:HUD];
    [HUD show:isAnimation];
}
-(void)hideHud:(BOOL) isAnimation{
    [HUD hide:isAnimation];
    if(HUD!= nil){
        HUD = nil;
    }   
}

-(void)navigationBack:(id)sender  {
    [self.navigationController popViewControllerAnimated:YES];    
}

-(void)_handleFacebookMeDidUpdate:(NSNotification *)notification
{
    [self hideHud:YES];  
    NSDictionary *userInfo = [notification userInfo];
    NSString* error = userInfo[@"error"];
    NSString* msg = userInfo[@"msg"];
    if(nil != error){
        [self showMsg:error type:msgLevelWarn];
        return;
    }
    
    if(nil != msg){
        [self showMsg:msg type:msgLevelInfo]; 
        return;
    } 
}

#pragma mark - UITableViewCell
- (void)configureCell:(CustomCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    [[cell tripPhoto] setImage:[self tripPhotoForRowAtIndexPath:indexPath]];
    [[cell tripName] setText:[self tripNameForRowAtIndexPath:indexPath]];
    
    CGRect cellRect = [cell frame];
    UIImageView *backgroundView = [[UIImageView alloc] initWithFrame:cellRect];
    [backgroundView setImage:[self backgroundImageForRowAtIndexPath:indexPath]];
    [cell setBackgroundView:backgroundView];
    
    UIImageView *selectedBackgroundView = [[UIImageView alloc] initWithFrame:cellRect];
    [selectedBackgroundView setImage:[self selectedBackgroundImageForRowAtIndexPath:indexPath]];     
    [cell setSelectedBackgroundView:selectedBackgroundView];
}

#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 10;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *reuseID = [self reuseIdentifierForRowAtIndexPath:indexPath];
    UITableViewCell *cell = [[self tableView] dequeueReusableCellWithIdentifier:reuseID];
    [self configureCell:(CustomCell *)cell forRowAtIndexPath:indexPath];        
    return cell;
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [self tableView:[self tableView] cellForRowAtIndexPath:indexPath];
    return [cell frame].size.height;
}


#pragma mark - Rotation

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    return YES;
}

@end
