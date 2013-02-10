//
//  BRImportFacebookViewController.m
//  BirthdayReminder
//
//  Created by Nick Kuh on 12/08/2012.
//  Copyright (c) 2012 Nick Kuh. All rights reserved.
//

//
//  BRImportViewController.m
//  BirthdayReminder
//
//  Created by Nick Kuh on 09/08/2012.
//  Copyright (c) 2012 Nick Kuh. All rights reserved.
//

#import "BRFBFriendListViewController.h"
#import "BRPostToFacebookWallViewController.h"
//#import "BRVideoViewController.h"
#import "BRRecordFriend.h"
#import "BRCellFriend.h"
//#import "BRDBirthdayImport.h"

@interface BRFBFriendListViewController ()
<UITableViewDelegate, UITableViewDataSource,
UIAlertViewDelegate>
//Keeps track of selected rows
@property(nonatomic, strong)NSMutableArray* docs;
@property(nonatomic, strong)UIAlertView* avInviteFriend;
@property(nonatomic, weak)BRRecordFriend* selectedRecord;




@end

@implementation BRFBFriendListViewController



-(NSMutableDictionary *) selectedIndexPathToBirthday
{
    if (_selectedIndexPathToBirthday == nil) {
        _selectedIndexPathToBirthday = [NSMutableDictionary dictionary];
    }
    return _selectedIndexPathToBirthday;
}


-(NSMutableArray*)docs{
    
    if(nil == _docs){
        _docs = [[NSMutableArray alloc] init];
    }
    return _docs;
}



-(void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}



- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    UIBarButtonItem *btnBack = [[UIBarButtonItem alloc]
                                initWithTitle:self.lang[@"actionBack"] 
                                style:UIBarButtonItemStyleBordered
                                target:self
                                action:@selector(_unWindBack:)];
    self.navigationItem.leftBarButtonItem = btnBack;

 
}
-(void)_unWindBack:(id)sender  {
    
    [self performSegueWithIdentifier:@"unwindBackToMyRoomlViewController" sender:sender];
    
}

-(void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [[NSNotificationCenter defaultCenter] 
     addObserver:self
     selector:@selector(handleFacebookBirthdaysDidUpdate:) 
     name:BRNotificationFacebookBirthdaysDidUpdate 
     object:[BRDModel sharedInstance]];
    
    if(self.docs.count == 0 
       || nil == kSharedModel.facebookAccount
       ){
        [self showHud:YES];
        [kSharedModel fetchFacebookBirthdays];//fetch friends list form ios SDK first,
        //then to get the access_token to get another list form node.js server
    }
    self.title = kSharedModel.lang[@"titleInvite"];
    [[self tableView] setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    self.tableView.backgroundColor = [UIColor clearColor];
    UIColor *background = [[UIColor alloc] initWithPatternImage:[UIImage imageNamed:kSharedModel.theme[@"bg_sand"]]];
    self.view.backgroundColor  = background;

}


- (void) viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] 
     removeObserver:self 
     name:BRNotificationFacebookBirthdaysDidUpdate 
     object:[BRDModel sharedInstance]];
}

#pragma mark UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.docs count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    BRCellFriend *brTableCell =  (BRCellFriend *)[self.tableView dequeueReusableCellWithIdentifier:@"CellFriend"];
    
    BRRecordFriend *record = self.docs[indexPath.row];
    brTableCell.indexPath = indexPath;
    brTableCell.record = record;
        
    UIImageView *imageView;
    if (record.isJoint) {
        
        imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"icon-import-selected.png"]];
        [self.selectedIndexPathToBirthday setObject:record forKey:indexPath];
    }else {
        imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"icon-import-not-selected.png"]];
    }
    brTableCell.accessoryView = imageView;
    
    return brTableCell;
}

#pragma mark UITableViewDelegate
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    //prevent toggle the select record, we don't need it here
    BOOL isSelected = [self isSelectedAtIndexPath:indexPath];
    
    __weak __block BRRecordFriend *record = self.docs[indexPath.row];
    
    [self showHud:YES];
    __weak __block BRFBFriendListViewController* weakSelf = self;
    
    [kSharedModel toggleInvitedFriend:record.fbId 
                               fbName:record.fbName
                           joinRoomId:self.myRoomId 
                            isInvited:!isSelected
                            withBlock:^(NSDictionary* res){
                       
                       [weakSelf hideHud:YES];
                       
                       if(nil != res 
                          && nil != res[@"error"]){
                           [self showMsg:res[@"error"] type:msgLevelError];
                           
                           return;
                       }
        record.isJoint = !record.isJoint; 
        if (isSelected) {//already selected, so deselect
            [weakSelf.selectedIndexPathToBirthday removeObjectForKey:indexPath];
        }
        else {//not currently selected, so select
            [weakSelf.selectedIndexPathToBirthday setObject:record forKey:indexPath];
        }
        //update the accessory view image
        [weakSelf updateAccessoryForTableCell:[weakSelf.tableView cellForRowAtIndexPath:indexPath] atIndexPath:indexPath];
            
    }];
        
    //enable/disable the import button
    //[self updateImportButton];
}

-(void)handleFacebookBirthdaysDidUpdate:(NSNotification *)notification
{
    NSDictionary *userInfo = [notification userInfo];
    NSString* error = userInfo[@"error"];
    if(nil != error){
        [self showMsg:error type:msgLevelError];
        return;
    }
    
    NSMutableArray* birthdays = userInfo[@"birthdays"];
    if(birthdays.count == 0) {
        
        [self hideHud:YES];
        return;
    }
    __weak __block BRFBFriendListViewController *weakSelf = self;
    [kSharedModel fetchFbFriendsInvited:kSharedModel.access_token 
                                   fbId:kSharedModel.fbId 
                                   myRoomId: self.myRoomId
                              withBlock:^(NSDictionary* res){
        NSString* errMsg = res[@"error"];
        if(nil != errMsg){
            [self handleErrMsg:errMsg];
        } else  {
            NSMutableArray* mArrTemp =(NSMutableArray*)res[@"mArrTemp"];
            NSRange range = NSMakeRange(0, mArrTemp.count); 
            NSMutableIndexSet *indexes = [NSMutableIndexSet indexSetWithIndexesInRange:range];
            [weakSelf.docs removeAllObjects];
            [weakSelf.docs insertObjects:mArrTemp atIndexes:indexes];
            [weakSelf.tableView reloadData];
            [weakSelf hideHud:YES];
        }     

    }];
}

#pragma mark UIAlertViewDelegate 
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSString *title = [alertView buttonTitleAtIndex:buttonIndex];
    if(alertView == self.avInviteFriend){
        
        if([title isEqualToString:kSharedModel.lang[@"actionOK"]]){
            
            UINavigationController *navigationController = [self.storyboard instantiateViewControllerWithIdentifier:@"PostToFacebookWall"];
            BRPostToFacebookWallViewController *facebookWallViewController  = (BRPostToFacebookWallViewController *) navigationController.topViewController;
            facebookWallViewController.facebookID = self.selectedRecord.fbId;
            facebookWallViewController.initialPostText = kSharedModel.lang[@"actionCheckOutWeLearnApp"];
            [self.navigationController presentViewController:navigationController animated:YES completion:nil];
            
        }
    }
}


//Helper method to check whether a row is selected or not
-(BOOL) isSelectedAtIndexPath:(NSIndexPath *)indexPath
{
    return self.selectedIndexPathToBirthday[indexPath] ? YES : NO;
}
//Refreshes the selection tick of a table cell
- (void)updateAccessoryForTableCell:(UITableViewCell *)tableCell atIndexPath:(NSIndexPath *)indexPath
{
    UIImageView *imageView;
    if ([self isSelectedAtIndexPath:indexPath]) {
        imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"icon-import-selected.png"]];
    }else {
        imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"icon-import-not-selected.png"]];
    }
    tableCell.accessoryView = imageView;
}

#pragma mark Segues
- (BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender
{
	if ([identifier isEqualToString:@"segueVideos"])
	{
        BRCellFriend *cell =  (BRCellFriend *)sender;
        NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
        BRRecordFriend* record =  self.docs[indexPath.row];
        
        if([record.count integerValue] == 0){
            self.selectedRecord = record;
            self.avInviteFriend = [[UIAlertView alloc]
              initWithTitle:kSharedModel.lang[@"info"]
              message:kSharedModel.lang[@"actionInviteFriend"]
              delegate:self
              cancelButtonTitle:kSharedModel.lang[@"actionOK"]
              otherButtonTitles:kSharedModel.lang[@"actionCancel"], nil];
            [self.avInviteFriend show];
            
            return NO;
        }
		
	}
	return YES;
}
-(void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    NSString *identifier = segue.identifier;
    
    if ([identifier isEqualToString:@"segueVideos"]) {
        
        BRCellFriend *cell =  (BRCellFriend *)sender;
        NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
//        BRRecordFriend* record =  self.docs[indexPath.row];
//        BRVideoViewController* BRVideoViewController = segue.destinationViewController;
//        BRVideoViewController.fbFriend = record;

    }
}



@end
