//
//  BRMainCategoryViewController.m
//  BirthdayReminder
//
//  Created by Peter2 on 12/16/12.
//  Copyright (c) 2012 Nick Kuh. All rights reserved.
//

#import "BRMainCategoryViewController.h"
//#import "BRSubCategoryViewController.h"
#import "BRCellMainCategory.h"
#import "BRRecordMainCategory.h"
#import "BRDModel.h"
#import "NSMutableArray+Shuffling.h"


typedef enum mainCategoryFilterMode {
    mainCategoryFilterModeAll = 0,
    mainCategoryFilterModeFavorite = 1
} mainCategoryFilterMode;



@interface UIWindow (AutoLayoutDebug) 
+ (UIWindow *)keyWindow;
- (NSString *)_autolayoutTrace;
@end



@interface BRMainCategoryViewController ()
<UITableViewDelegate, 
UITableViewDataSource,
UIScrollViewDelegate,
UIAlertViewDelegate>

@property(nonatomic, strong)NSMutableArray* docs;

@property mainCategoryFilterMode mode;
@property(nonatomic, strong)NSNumber* page;
@property(nonatomic, strong)NSNumber* lastPage;
@property (weak, nonatomic) IBOutlet UIButton *sortBtn;

@property(nonatomic, weak)IBOutlet UITableView* tb;

@property (weak, nonatomic) IBOutlet UILabel *sortLb;

@property (nonatomic, weak) IBOutlet UILabel *filterNameLabel;
@property (nonatomic, weak) IBOutlet UIView *filterBar; 
@property (nonatomic, strong) IBOutlet NSLayoutConstraint *spaceBetweenFilterBarAndMainTable;
@property(nonatomic, strong)UIAlertView* av;
@property(nonatomic, strong)UIAlertView* avChkisEnableToggleFavorite;
@end

@implementation BRMainCategoryViewController
{
    BOOL addItemsTrigger;
    BOOL _isConfirmToDeleteFavorite;
	NSArray *filterNames;
	NSUInteger activeFilterIndex;
	UITableView *filterTableView;
    NSArray *verticalConstraintsBeforeAnimation; 
    NSArray *verticalConstraintsAfterAnimation;
}

-(NSMutableArray*)docs{
    if(nil == _docs){
        _docs = [[NSMutableArray alloc] init];
    }
    return _docs;
}
-(NSNumber*)page{
    if(_page == nil){
        _page = [[NSNumber alloc] initWithInt:0];
    }
    return _page;
}

-(NSNumber*)lastPage{
    if(_lastPage == nil){
        _lastPage = [[NSNumber alloc] initWithInt:0];
    }
    return _lastPage;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(id)initWithCoder:(NSCoder *)aDecoder{
    
    self = [super initWithCoder:aDecoder];
    if(self){

        _isConfirmToDeleteFavorite = NO;
       
        filterNames = @[self.lang[@"noSort"], self.lang[@"byName"], self.lang[@"byDate"]];
        activeFilterIndex = mainCategoriesSortTypeNoSort;
        [BRDModel sharedInstance].mainCategoriesSortType = activeFilterIndex;
        [BRDModel sharedInstance].mainCategoriesSortIsDesc = FALSE;
        self.filterNameLabel.text = filterNames[activeFilterIndex];

    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Add self as scroll view delegate to catch scroll events
    self.tb.autoresizesSubviews = YES;
    // Add the "Pull to Load" above the table
	UIView *pullView = [[[NSBundle mainBundle] loadNibNamed:@"HiddenHeaderView" owner:self options:nil] lastObject]; 
	pullView.frame = CGRectOffset(pullView.frame, 0.0f, -pullView.frame.size.height);
	[self.tb addSubview:pullView];
	// Do any additional setup after loading the view.
    PRPLog(@"self.tabBarController.selectedIndex: %d -[%@ , %@]",
           self.tabBarController.selectedIndex,
           NSStringFromClass([self class]),
           NSStringFromSelector(_cmd));
    self.mode = self.tabBarController.selectedIndex;
    
    if(self.mode == mainCategoryFilterModeAll){
        [self _populateLang];
        
         self.title = self.lang[@"titleCategory"];
    } else if (self.mode == mainCategoryFilterModeFavorite ){
        
        self.title = self.lang[@"titleFavoriteCategory"];

    }


}
-(void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    

    

    
    
    if(self.docs.count == 0){
       [self _handleRefreshFromFirstPage:nil];
    } 
}

-(void)_handleFacebookMeDidUpdate:(NSNotification *)notification
{
    [super _handleFacebookMeDidUpdate:notification];
    NSDictionary* userInfo = [notification userInfo];
    NSString* error = userInfo[@"error"];
    if(nil != error) return;
    
    [self _handleRefreshFromFirstPage:nil];
}

-(IBAction)_handleRefreshFromFirstPage:(id)sender{
    
    self.docs = nil;
    self.page = @0;
    self.lastPage = @0;
    [self _handleRefresh];
}

-(void)_handleRefresh{
    
    [self showHud:YES];  
    __weak __block BRMainCategoryViewController *weakSelf = self;
    
    if(self.mode == mainCategoryFilterModeAll){
        [[BRDModel sharedInstance] fetchMainCategoriesWithPage:self.page WithBlock:^(NSDictionary* res){
            [weakSelf hideHud:YES];
            NSString* errMsg = res[@"error"];
            weakSelf.page = res[@"page"];
            weakSelf.lastPage = res[@"lastPage"];
            
            NSMutableArray* mTempArr =(NSMutableArray*)res[@"docs"];
            NSRange range = NSMakeRange(0, mTempArr.count); 
            NSMutableIndexSet *indexes = [NSMutableIndexSet indexSetWithIndexesInRange:range];
            [weakSelf.docs insertObjects:res[@"docs"] atIndexes:indexes];
             
            if(nil != errMsg){
                [self handleErrMsg:errMsg];
            } else {

                PRPLog(@"self.docs.count: %d-[%@ , %@]",
                       weakSelf.docs.count,
                       NSStringFromClass([self class]),
                       NSStringFromSelector(_cmd));
                if(weakSelf.docs.count == 0){
                    [self showMsg:kSharedModel.lang[@"infoNoData"] type:msgLevelInfo];                    
                    return;
                }
                
                [weakSelf.tb reloadData];
            }
            
        }];
        
    } else if (self.mode == mainCategoryFilterModeFavorite) {

//        [kSharedModel fetchMainCategoriesFavoriteWithPage:self.page byFB:kSharedModel.fbId WithBlock:^(NSDictionary* res){
//            
//            [weakSelf hideHud:YES];
//            NSString* errMsg = res[@"error"];
//            weakSelf.page = res[@"page"];
//            weakSelf.lastPage = res[@"lastPage"];
//            
//            NSMutableArray* mTempArr =(NSMutableArray*)res[@"docs"];
//            NSRange range = NSMakeRange(0, mTempArr.count); 
//            NSMutableIndexSet *indexes = [NSMutableIndexSet indexSetWithIndexesInRange:range];
//            [weakSelf.docs insertObjects:res[@"docs"] atIndexes:indexes];            
//            
//            if(nil != errMsg){
//                [self handleErrMsg:errMsg];
//            } else {
//                
//                if(weakSelf.docs.count == 0){
//                    [self showMsg:kSharedModel.lang[@"infoNoData"] type:msgLevelInfo];
//                    return;
//                }
//                
//                PRPLog(@"self.docs.count: %d-[%@ , %@]",
//                      weakSelf.docs.count,
//                       NSStringFromClass([self class]),
//                       NSStringFromSelector(_cmd));
//                [weakSelf.tb reloadData];
//            }
//        }];
    }
}
- (void) viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    if(self.mode == mainCategoryFilterModeAll){
//        [[NSNotificationCenter defaultCenter] removeObserver:self name:BRNotificationMainCategoriesDidUpdate object:[BRDModel sharedInstance]];
    }

}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    PRPLog(@"%@-[%@ , %@]",
           [[UIWindow keyWindow] _autolayoutTrace],
           NSStringFromClass([self class]),
           NSStringFromSelector(_cmd));
    if(self.mode == mainCategoryFilterModeFavorite 
       && kSharedModel.isUserMainCategoryFavoriteNeedUpdate){
        [self _handleRefreshFromFirstPage:nil];
        kSharedModel.isUserMainCategoryFavoriteNeedUpdate = NO;
    }
}


//a) if you dont want to rotate:
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (BOOL)shouldAutorotate
{
    return NO;
}
- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}


-(void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration{
    
    
}

- (void)didRotateFromInterfaceOrientation: (UIInterfaceOrientation)fromInterfaceOrientation
{
    [super didRotateFromInterfaceOrientation:
     fromInterfaceOrientation];
    PRPLog(@"%@-[%@ , %@]",
          [[UIWindow keyWindow] _autolayoutTrace],
           NSStringFromClass([self class]),
           NSStringFromSelector(_cmd));
}

- (IBAction)toggleSlide:(id)sender{
    
    [self.noticeChildViewController 
     toggleSlide:sender msg:@"YYY YYY YYY YYY YYY YYY YYY YYY YYY end" 
     stayTime:5.0f];
}

-(void)handleMainCategoriesDidUpdate:(NSNotification *)notification
{
    [self hideHud:YES];
    NSDictionary *userInfo = [notification userInfo];
    NSString* errMsg = userInfo[@"errMsg"];
    self.page = userInfo[@"page"];
    self.lastPage = userInfo[@"lastPage"];
    
    if(errMsg!= nil && [errMsg length] > 0){
        [self handleErrMsg:errMsg];
    } else {
        PRPLog(@"self.docs.count: %d-[%@ , %@]",
                self.docs.count,
               NSStringFromClass([self class]),
               NSStringFromSelector(_cmd));
        self.docs = userInfo[@"docs"];
        [self.tb reloadData];
    }
    
}
-(void)_populateLang
{
    self.sortLb.text = self.lang[@"sort"];
}

#pragma mark UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (tableView == self.tb)
        return [self.docs count];
    else 
        return [filterNames count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	static NSString *CellIdentifier = @"Cell";
    
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	if (cell == nil)
		cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];

    if(tableView == self.tb){
        
        cell = nil;
        static NSString *CellIdentifier = @"BRCellMainCategory";
        BRCellMainCategory *cell =  (BRCellMainCategory *)[self.tb dequeueReusableCellWithIdentifier:CellIdentifier];
        
        BRRecordMainCategory* record = [self.docs objectAtIndex:indexPath.row];
        [cell.btnFavorite addTarget:self action:@selector(_toggleFavoriteHandler:) forControlEvents:UIControlEventTouchUpInside];
        
        if(self.mode == mainCategoryFilterModeFavorite) {

            
//            cell.btnFavorite.hidden = YES;
//            cell.btnFavorite.enabled = NO;
        } else {
            
            
        }
        cell.tb = tableView;
        cell.indexPath = indexPath;
        cell.record = record;


        return cell;
    } else {
		cell.textLabel.text = filterNames[indexPath.row];
//		cell.accessoryType = (activeFilterIndex == indexPath.row) ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
        if([BRDModel sharedInstance].mainCategoriesSortType == indexPath.row){
            UIImage* img_;
            if([BRDModel sharedInstance].mainCategoriesSortIsDesc){
                img_ = [UIImage imageNamed:@"Arrow.png"]; 
            } else{
                img_ = [UIImage imageNamed:@"ArrowAsc.png"]; 
            }
            
            UIImageView* ascOrDescImv =[[UIImageView alloc] initWithImage:img_];
            cell.accessoryView = ascOrDescImv;
        } else {
            cell.accessoryType = UITableViewCellAccessoryNone;
        }
        
        
        cell.textLabel.font = [UIFont systemFontOfSize:14.0f]; 
        cell.textLabel.textColor = [UIColor whiteColor];
    }

    return cell;
}


#pragma mark UIAlertViewDelegate 
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSString *title = [alertView buttonTitleAtIndex:buttonIndex];
    if(alertView == self.av){
        
        if([title isEqualToString:kSharedModel.lang[@"actionOK"]]){
        
            int selectedRow = self.av.tag;
            
            UIButton* btn = [[UIButton alloc] init];
            btn.tag = selectedRow;
             _isConfirmToDeleteFavorite = YES;
           
        }
    } else if(alertView == self.avChkisEnableToggleFavorite) {
        if([title isEqualToString:kSharedModel.lang[@"actionOK"]]){
            
            [self performSegueWithIdentifier:@"segueStoreList" sender:nil];

        }
    }
}


#pragma mark UITableViewDelegate
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (tableView == filterTableView) {
        
        if(activeFilterIndex == indexPath.row){
            [BRDModel sharedInstance].mainCategoriesSortIsDesc =  ![BRDModel sharedInstance].mainCategoriesSortIsDesc;
        } else {
            [BRDModel sharedInstance].mainCategoriesSortIsDesc = FALSE;
        }
        
        activeFilterIndex = indexPath.row; 
        [BRDModel sharedInstance].mainCategoriesSortType = activeFilterIndex;
        self.filterNameLabel.text = filterNames[activeFilterIndex];
        [self hideFilterTable];
        
    } else {

    }
}
#pragma mark UIScrollViewDelegate
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
	// Detect if the trigger has been set, if so add new items
	if (addItemsTrigger)
	{

        BOOL isLastPage = [self.lastPage boolValue];
        if(!isLastPage){
            int page_ = [self.page intValue];
            page_++;
            self.page = [[NSNumber alloc] initWithInt:page_];
            [self _handleRefresh];
        }

	}
	// Reset the trigger
	addItemsTrigger = NO;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
	// Trigger the offset if the user has pulled back more than 50 pixels
	if (scrollView.contentOffset.y < -80.0f)
		addItemsTrigger = YES;
}

#pragma mark show or hide order table view
- (IBAction)filterButtonPressed:(id)sender {
    
    if (filterTableView == nil) [self showFilterTable];
    else [self hideFilterTable];
}

- (void)hideFilterTable {
    
    PRPLog(@"\n sort type: %d  \n ascOrDesc %d \n-[%@ , %@]",
            [BRDModel sharedInstance].mainCategoriesSortType,
            [BRDModel sharedInstance].mainCategoriesSortIsDesc,
           NSStringFromClass([self class]),
           NSStringFromSelector(_cmd));
    
    UIImage* img_;
    if([BRDModel sharedInstance].mainCategoriesSortIsDesc){
        img_ = [UIImage imageNamed:@"Arrow.png"]; 
    } else{
        img_ = [UIImage imageNamed:@"ArrowAsc.png"]; 
    }
    [self.sortBtn setBackgroundImage:img_ forState:UIControlStateNormal];
    
    [self.view removeConstraints: verticalConstraintsAfterAnimation];
    [self.view addConstraints: verticalConstraintsBeforeAnimation];
    
    [UIView animateWithDuration:0.3f animations:^ {
        [self.view layoutIfNeeded]; }
                     completion:^(BOOL finished) {
                         [filterTableView removeFromSuperview]; 
                         filterTableView = nil;
                         [self.view addConstraint: self.spaceBetweenFilterBarAndMainTable];
                         if([BRDModel sharedInstance].mainCategoriesSortType == mainCategoriesSortTypeNoSort){
                             [self.docs shuffle];
                         } else {

                         }
                           [self.tb reloadData];
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
    [self.view removeConstraint: self.spaceBetweenFilterBarAndMainTable];

    viewsDictionary = @{
    @"filterTableView": filterTableView, @"filterBar": self.filterBar, @"mainTableView": self.tb };
    
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
                   @"V:[filterBar][filterTableView(72)][mainTableView]"
                                                          options:0
                                                          metrics:nil views:viewsDictionary];
    verticalConstraintsAfterAnimation = constraints;
    [self.view addConstraints:constraints];
    
    [UIView animateWithDuration:0.3f animations:^ {
        [self.view layoutIfNeeded]; }];
}

#pragma mark Segues
-(void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    NSString *identifier = segue.identifier;
    
    if ([identifier isEqualToString:@"segueSubCategories"]) {
        
        BRCellMainCategory *cell =  (BRCellMainCategory *)sender;
        NSIndexPath *indexPath = [self.tb indexPathForCell:cell];
        
        BRRecordMainCategory* record = self.docs[indexPath.row];
//        PRPLog(@"\n [BRDModel sharedInstance].mainCategoriesSelectedUid %@ \n-[%@ , %@]",
//               [BRDModel sharedInstance].mainCategoriesSelectedUid,
//               NSStringFromClass([self class]),
//               NSStringFromSelector(_cmd));
        
//        [BRDModel sharedInstance].currentSelectMainCategory = record;
//        [BRDModel sharedInstance].mainCategoriesSelectedUid = record.uid;
//        BRSubCategoryViewController *BRSubCategoryViewController_ = (BRSubCategoryViewController *) segue.destinationViewController;        
//        BRSubCategoryViewController *BRSubCategoryViewController_ = (BRSubCategoryViewController *) navigationController.topViewController; 
//        BRSubCategoryViewController_.currentSelectMainCategory = record;
//        BRSubCategoryViewController_.mainCategoriesSelectedUid = record.uid;
//        BRSubCategoryViewController_.byMainCategory = record.uid;

    }
}


@end
