//
//  WWMyRoomViewController.m
//  wework
//
//  Created by Peter2 on 1/28/13.
//  Copyright (c) 2013 Peter2. All rights reserved.
//

#import "WWMyRoomViewController.h"
#import "BRFBFriendListViewController.h"

#import "WWTagViewController.h"

#import "WWRecordMyRoom.h"
#import "WWCellMyRoom.h"
#import "AppDelegate.h"

@interface WWMyRoomViewController ()
<UITableViewDataSource,UITableViewDelegate,
UIScrollViewDelegate, 
UIAlertViewDelegate,
WWCellMyRoomDelegate>

@property (nonatomic, strong) NSMutableArray* docs;
@property (weak, nonatomic) IBOutlet UITableView *tb;

@property(nonatomic, strong)NSNumber* page;
@property(nonatomic)BOOL isLastPage;

@property (weak, nonatomic) IBOutlet UIBarButtonItem *barBtnEdit;
@property(weak, nonatomic)WWCellMyRoom* cellTemp;
@property(weak, nonatomic)NSIndexPath* indexPathSelectedTemp;

@property(nonatomic, strong)UIAlertView* avChkisEnableToggleFavorite;
@end

@implementation WWMyRoomViewController
{
    BOOL addItemsTrigger;
}

-(NSMutableArray*)docs{
    
    if(nil == _docs){
        _docs = [[NSMutableArray alloc] init];
    }
    return _docs;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    if([self isViewLoaded] && self.view.window == nil){
        //self.imvThumb = nil;
    }
}

-(id)initWithCoder:(NSCoder *)aDecoder{
    
    self = [super initWithCoder:aDecoder];
    if(self){
        addItemsTrigger = NO;
        self.isDisableInAppNotification = NO;
        
        self.page = @0;
        self.isLastPage = YES;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    if(nil != self.byTagName){
        
        self.title = [NSString stringWithFormat:@"%@ - %@", kSharedModel.lang[@"titleMySubject"], self.byTagName];
    } else {
        self.title = kSharedModel.lang[@"titleMySubject"];
    }
    
	// Do any additional setup after loading the view.
    self.barBtnEdit.title = kSharedModel.lang[@"actionEdit"];
  
    [[self tb] setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    self.tb.backgroundColor = [UIColor clearColor];
    UIColor *background = [[UIColor alloc] initWithPatternImage:[UIImage imageNamed:kSharedModel.theme[@"bg_sand"]]];
    self.view.backgroundColor  = background;
    self.navigationItem.leftBarButtonItem = nil;
    
    [self _fetchMyRooms:self.page fbId:kSharedModel.fbId];
    
    UINavigationController *navigationControllerDetail = [self.splitViewController.viewControllers lastObject];
    
    DetailViewController_iPad* detail = (DetailViewController_iPad*)navigationControllerDetail.topViewController;
    self.detailVC = detail;
    
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_handleFacebookMeDidUpdate:) name:BRNotificationFacebookMeDidUpdate object:kSharedModel];

}

- (void) viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [self.tb deselectRowAtIndexPath:[self.tb indexPathForSelectedRow] animated:animated];   
    [[NSNotificationCenter defaultCenter] removeObserver:self name:BRNotificationFacebookMeDidUpdate object:kSharedModel];
    //[kAppDelegate.detail leaveRoom];
}

-(void)_handleFacebookMeDidUpdate:(NSNotification *)notification
{
    NSDictionary *userInfo = [notification userInfo];
    NSString* error = userInfo[@"error"];
    if(nil != error){
        [self hideHud:YES];
        [self showMsg:error type:msgLevelWarn]; 
        return;
    }
    [self _fetchMyRooms:self.page fbId:kSharedModel.fbId];
    //NSDictionary *userInfo = [notification userInfo];
    PRPLog(@"kSharedModel.fbId: %@-[%@ , %@]",
           kSharedModel.fbId,
           NSStringFromClass([self class]),
           NSStringFromSelector(_cmd));
}
- (IBAction)toggleEditOrDone:(UIBarButtonItem *)sender {
   
    if([sender.title isEqualToString:kSharedModel.lang[@"actionEdit"]]){
        
        sender.title = kSharedModel.lang[@"actionDone"];
        self.tb.editing = YES;
    } else {
        sender.title = kSharedModel.lang[@"actionEdit"];
        self.tb.editing = NO;
    }
}

- (IBAction)showAddMyRoomAlertView:(id)sender {
    
    if(nil == kSharedModel.fbId){
    
        [kSharedModel fetchFacebookMe];
        return;
    }
    
    UIAlertView *message = [[UIAlertView alloc] initWithTitle:kSharedModel.lang[@"titleWhatIsYourSubjectName"]
                                                      message:nil
                                                     delegate:self
                                    cancelButtonTitle:kSharedModel.lang[@"actionCancel"]
                                otherButtonTitles:kSharedModel.lang[@"actionAdd"], nil];
    [message setAlertViewStyle:UIAlertViewStylePlainTextInput];
    [message show];
}
#pragma mark UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSString *title = [alertView buttonTitleAtIndex:buttonIndex];
    if(alertView == self.avChkisEnableToggleFavorite) {
        if([title isEqualToString:kSharedModel.lang[@"actionOK"]]){
            
            [self performSegueWithIdentifier:@"segueStoreList" sender:nil];
            
        }
    } else if([title isEqualToString:kSharedModel.lang[@"actionAdd"]]){
        UITextField *tfRoomName = [alertView textFieldAtIndex:0];
        NSString* roomName = tfRoomName.text;
        if(roomName.length == 0){
        
            [self showMsg:kSharedModel.lang[@"warnEmptyText"] type:msgLevelWarn];
            return;
        }
        PRPLog(@"roomName: %@-[%@ , %@]",
               roomName,
               NSStringFromClass([self class]),
               NSStringFromSelector(_cmd));
        [self _sendMyRoom:roomName fbId:kSharedModel.fbId fbName:kSharedModel.fbName];
    
    } else if([title isEqualToString:kSharedModel.lang[@"actionChange"]]) {
        UITextField *tfRoomName = [alertView textFieldAtIndex:0];
        int row = alertView.tag;
        NSString* roomName = tfRoomName.text;
        if(roomName.length == 0){
            
            [self showMsg:kSharedModel.lang[@"warnEmptyText"] type:msgLevelWarn];
            return;
        }        
        PRPLog(@"row %d to be changed \n\
               roomName: %@ \n\
               -[%@ , %@]",
               row,
               roomName,
               NSStringFromClass([self class]),
               NSStringFromSelector(_cmd));
        WWRecordMyRoom* record = [self.docs objectAtIndex:row];
        [self _updMyRoom:roomName _id:record._id atRow:row];
        
    }
}

-(void)_fetchMyRooms:(NSNumber*)page 
          fbId:(NSString*)fbId{
    
    if(nil == fbId){
        [kSharedModel fetchFacebookMe];
        return;
    }
    
    [self showHud:YES];
    __weak __block WWMyRoomViewController* weakSelf = self;
    NSString* tagId = (nil != self.byTagId)?self.byTagId:@"";
    [kSharedModel fetchMyRoomsByFbId:fbId 
                             byTagId:tagId
                            withPage:page 
                           withBlock:^(NSDictionary* res) {
                               
                           [weakSelf hideHud:YES];
                           
                           if(nil != res 
                              && nil != res[@"error"]){
                               
                               [weakSelf showMsg:res[@"error"] type:msgLevelError];
                               return;
                           }

                           NSMutableArray* mTempArr =(NSMutableArray*)res[@"mTempArr"];
                           NSRange range = NSMakeRange(0, mTempArr.count); 
                           NSMutableIndexSet *indexes = [NSMutableIndexSet indexSetWithIndexesInRange:range];
                           [weakSelf.docs insertObjects:mTempArr atIndexes:indexes];
                           
                           weakSelf.isLastPage = [((NSNumber*)res[@"isLastPage"]) boolValue];
                           weakSelf.page = res[@"page"];
                           
                           if(weakSelf.docs.count > 0){
                               
                               PRPLog(@"self.docs.count: %d-[%@ , %@]",
                                      weakSelf.docs.count,
                                      NSStringFromClass([self class]),
                                      NSStringFromSelector(_cmd));
                               [weakSelf.tb reloadData];
                               
                           } 

        
    }];
}

-(void)_sendMyRoom:(NSString*)roomName 
              fbId:(NSString*)fbId
              fbName:(NSString*)fbName  
{    
    [self showHud:YES];
    __weak __block WWMyRoomViewController* weakSelf = self;
    
    [kSharedModel postMyRoom:roomName 
                        fbId:fbId 
                      fbName:fbName 
                   withBlock:^(NSDictionary* res){
                               
                [weakSelf hideHud:YES];
            
                if(nil != res 
                   && nil != res[@"error"]){
                    
                    [self showMsg:res[@"error"] type:msgLevelError];
                    
                 return;
                }
                
                WWRecordMyRoom* recordAdded = (WWRecordMyRoom*)res[@"doc"];  
                [weakSelf.docs insertObject:recordAdded atIndex:0];
                //[weakSelf.tb reloadData];
               NSIndexPath * indexPath = [NSIndexPath indexPathForRow:0
                                                            inSection:0];
            [weakSelf.tb insertRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    }];
}

-(void)_updMyRoom:(NSString*)roomName 
              _id:(NSString*)_id
            atRow:(int) row
{    
    [self showHud:YES];
    __weak __block WWMyRoomViewController* weakSelf = self;
    
    [kSharedModel updMyRoom:roomName 
                        _id:_id 
                  withBlock:^(NSDictionary* res){
       
       [weakSelf hideHud:YES];
       
       if(nil != res 
          && nil != res[@"error"]){
           
           [self showMsg:res[@"error"] type:msgLevelError];
           return;
       }

      WWRecordMyRoom* recordUpded = (WWRecordMyRoom*)res[@"doc"];
      PRPLog(@"recordUpded: %@ \n\
             -[%@ , %@]",
             recordUpded,
             NSStringFromClass([self class]),
             NSStringFromSelector(_cmd));
            weakSelf.docs[row] = recordUpded;
            NSIndexPath * indexPath = [NSIndexPath indexPathForRow:row
                                                                   inSection:0];
            [weakSelf.tb reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath]  withRowAnimation:UITableViewRowAnimationAutomatic];              
    }];
}

-(void)_delMyRoom:(NSString*)_id
            atRow:(int) row
{

    [self showHud:YES];
    __weak __block WWMyRoomViewController* weakSelf = self;
    [kSharedModel delMyRoomById:_id 
                  withBlock:^(NSDictionary* res){
                      
      [weakSelf hideHud:YES];
      if(nil != res 
         && nil != res[@"error"]){
          
          [weakSelf showMsg:res[@"error"] type:msgLevelError];
          return;
      }
                     
      WWRecordMyRoom* record = [weakSelf.docs objectAtIndex:row];
      [weakSelf.docs removeObject:record];
      NSIndexPath * indexPath = [NSIndexPath indexPathForRow:row
                                                   inSection:0];
      [weakSelf.tb deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];  
          //[kAppDelegate.detail leaveRoom];
      
    }];
  
}

#pragma mark WWCellMyRoomDelegate
-(void)WWCellMyRoomDelegateDidEditMode:(WWRecordMyRoom *)record withIndexPath:(NSIndexPath *)indexPath{

    UIAlertView *message = [[UIAlertView alloc] initWithTitle:kSharedModel.lang[@"titleChangeSubjectName"]
                                                      message:nil
                                                     delegate:self
                                            cancelButtonTitle:kSharedModel.lang[@"actionCancel"]
                                            otherButtonTitles:kSharedModel.lang[@"actionChange"], nil];
    [message setAlertViewStyle:UIAlertViewStylePlainTextInput];
    UITextField *tfRoomName = [message textFieldAtIndex:0];
    tfRoomName.text = record.roomName;
    message.tag = [indexPath row];
    [message show];
}
-(void)WWCellMyRoomDelegateWillChooseFriends:(WWRecordMyRoom*)record withIndexPath:(NSIndexPath*)indexPath{
    
    UINavigationController *navigationController = [self.storyboard instantiateViewControllerWithIdentifier:@"ImportFacebook"];
    [self.navigationController presentViewController:navigationController animated:YES completion:nil];
}
-(void)WWCellMyRoomDelegateWillChooseTags:(WWRecordMyRoom*)record withIndexPath:(NSIndexPath*)indexPath{
    
    if(!kSharedModel.isEnebleToggleFavorite){
        self.avChkisEnableToggleFavorite = [[UIAlertView alloc] initWithTitle:kSharedModel.lang[@"info"] message:kSharedModel.lang[@"intoBuyUnlockKeyFirst"] delegate:self cancelButtonTitle:kSharedModel.lang[@"actionOK"] otherButtonTitles:kSharedModel.lang[@"actionCancel"], nil];
        [self.avChkisEnableToggleFavorite show];
        return ;
    }		

    [self performSegueWithIdentifier:@"segueSelectTag" sender:record];
    
}

#pragma mark UITableViewDataSource
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    WWCellMyRoom *WWCellMyRoom = [self.tb dequeueReusableCellWithIdentifier:@"WWCellMyRoom"];
    
    WWRecordMyRoom* record = [self.docs objectAtIndex:[indexPath row]];
    WWCellMyRoom.delegate = self;
    WWCellMyRoom.record = record;
    WWCellMyRoom.indexPath = indexPath;
    UIImage *backgroundImage = [UIImage imageNamed:@"table-row-background.png"];
    WWCellMyRoom.backgroundView = [[UIImageView alloc] initWithImage:backgroundImage];
    
    return WWCellMyRoom;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.docs count];
}

#pragma mark UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    //[tableView deselectRowAtIndexPath:indexPath animated:YES];
    if([self.indexPathSelectedTemp isEqual:indexPath]) return;
       
    WWRecordMyRoom* record = [self.docs objectAtIndex:[indexPath row]];
    //kAppDelegate.detail.fbIdRoomOwner = record.fbId;
    //kAppDelegate.detail.room = record._id;
    
    self.indexPathSelectedTemp = [tableView indexPathForSelectedRow];
    //self.detailVC.title = record.roomName;
    
}
// Override to support conditional editing of the table view.
// This only needs to be implemented if you are going to be returning NO
// for some items. By default, all items are editable.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return YES if you want the specified item to be editable.
//    WWRecordMyRoom* record = [self.docs objectAtIndex:[indexPath row]];
//    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
//    NSString* fbId = [defaults objectForKey:KUserDefaultFbId];
//    
//    if([record.fbId isEqualToString:fbId])return YES;
    return NO;
}
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        WWRecordMyRoom* record = [self.docs objectAtIndex:[indexPath row]];
        [self _delMyRoom:record._id atRow:[indexPath row]];
   
        
    }    
}
//get a callback when a UITableView reload is done?
- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if(indexPath.row == 0){
        NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
        NSString* fbId = [defaults objectForKey:KUserDefaultFbId];
        if(nil != fbId && !self.tb.editing){
            
            double delayInSeconds = 2.0;
            dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
            dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                //self.tb.editing = YES;
               
                
            });
        }
    }
}

#pragma mark UIScrollViewDelegate
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
	// Detect if the trigger has been set, if so add new items
	if (addItemsTrigger)
	{
        if(!self.isLastPage){
            int page_ = [self.page intValue];
            page_++;
            self.page = [[NSNumber alloc] initWithInt:page_];
            [self _fetchMyRooms:self.page fbId:kSharedModel.fbId];
        }
        
	}
	// Reset the trigger
	addItemsTrigger = NO;
}

- (void) scrollViewDidScroll:(UIScrollView *)scrollView
{
	// Trigger the offset if the user has pulled back more than 50 pixels
    PRPLog(@"scrollView.contentOffset.y: %f \
           scrollView.frame.size.height + 80.0f %f \
           -[%@ , %@]",
           scrollView.contentOffset.y,
           (scrollView.frame.size.height + 80.0f),
           NSStringFromClass([self class]),
           NSStringFromSelector(_cmd));
    
	if (scrollView.contentOffset.y < -125.0f )
		addItemsTrigger = YES;
}

#pragma mark Segues
- (BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender
{
	if ([identifier isEqualToString:@"segueSelectTag"])
	{

	}
    
	return YES;
}


-(void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    NSString *identifier = segue.identifier;
    if ([identifier isEqualToString:@"segueFriendsInvited"])
	{
        UIButton* btnFriendsInvited = (UIButton*)sender;
        WWCellMyRoom* cell =(WWCellMyRoom*) btnFriendsInvited.superview.superview;
       ;
		BRFBFriendListViewController* BRFBFriendListViewController = segue.destinationViewController;
        BRFBFriendListViewController.myRoomId =  cell.record._id;
        self.cellTemp = cell;
	} else if ([identifier isEqualToString:@"segueSelectTag"]){
        
        WWRecordMyRoom* recordSelected =(WWRecordMyRoom*) sender;
		WWTagViewController* WWTagViewController = segue.destinationViewController;
        WWTagViewController.recordMyRoom = recordSelected;

	}
}

-(IBAction)unwindBackToMyRoomlViewController:(UIStoryboardSegue *)segue
{
     NSString *identifier = segue.identifier;
    if ([identifier isEqualToString:@"unwindBackToMyRoomlViewController"])
	{
        BRFBFriendListViewController* BRFBFriendListViewController = segue.sourceViewController;
        int count = BRFBFriendListViewController.selectedIndexPathToBirthday.count;
        self.cellTemp.lbInviteCount.text = [NSString stringWithFormat:@"%d", count];
        PRPLog(@"%BRFBFriendListViewController.selectedIndexPathToBirthday.count: %d-[%@ , %@]",
               count,
               NSStringFromClass([self class]),
               NSStringFromSelector(_cmd));
	} 
}

@end
