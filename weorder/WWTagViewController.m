//
//  WWTagViewController.m
//  wework
//
//  Created by Peter2 on 2/5/13.
//  Copyright (c) 2013 Peter2. All rights reserved.
//

#import "WWTagViewController.h"
#import "WWTagEditViewController.h"
#import "WWMyRoomViewController.h"
#import "BRDModel.h"
#import "WWRecordTag.h"
#import "WWRecordMyRoom.h"
#import "AppDelegate.h"

@interface WWTagViewController ()
<UITableViewDataSource, UITableViewDelegate>


@property (nonatomic, strong) NSMutableArray* docs;
@property (weak, nonatomic) IBOutlet UITableView *tb;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *barBtnEdit;

//Keeps track of selected rows
@property (nonatomic, strong) NSMutableDictionary *selectedIndexPaths;

@end

@implementation WWTagViewController


-(NSMutableDictionary *) selectedIndexPaths
{
    if (nil == _selectedIndexPaths) {
        _selectedIndexPaths = [NSMutableDictionary dictionary];
    }
    return _selectedIndexPaths;
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
        self.title = kSharedModel.lang[@"titleTags"];
        
    }
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = kSharedModel.lang[@"titleTags"];
	// Do any additional setup after loading the view.
    self.barBtnEdit.title = kSharedModel.lang[@"actionEdit"];
    
    [[self tb] setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    self.tb.backgroundColor = [UIColor clearColor];
    UIColor *background = [[UIColor alloc] initWithPatternImage:[UIImage imageNamed:kSharedModel.theme[@"bg_sand"]]];
    self.view.backgroundColor  = background;
    
    //selection mode
    if(nil != self.recordMyRoom){
    
        self.navigationItem.leftBarButtonItem = nil;
        self.navigationItem.rightBarButtonItem = nil;
    }
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_handleFacebookMeDidUpdate:) name:BRNotificationFacebookMeDidUpdate object:kSharedModel];
    
    
    if(nil != kSharedModel.fbId 
       && self.docs.count == 0){
        [self _fetchTagsByFbId:kSharedModel.fbId];
    }
}

- (void) viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:BRNotificationFacebookMeDidUpdate object:kSharedModel];
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

-(void)_fetchTagsByFbId:(NSString*)fbId{
    
    [self showHud:YES];
    __weak __block WWTagViewController* weakSelf = self;
    NSString* roomId = (nil != self.recordMyRoom)?self.recordMyRoom._id:@"";
    [kSharedModel fetchTagsByFbId:fbId 
                         ByRoomId:roomId 
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
                                                              
                               if(weakSelf.docs.count > 0){
                                   
                                   PRPLog(@"self.docs.count: %d-[%@ , %@]",
                                          weakSelf.docs.count,
                                          NSStringFromClass([self class]),
                                          NSStringFromSelector(_cmd));
                                   [weakSelf.tb reloadData];
                                   
                               } else {
                                   [weakSelf showMsg:kSharedModel.lang[@"infoNoData"] type:msgLevelInfo];
                               } 
                               
                               
                           }];
}

-(void)_sendTag:(NSString*)tagName 
              fbId:(NSString*)fbId
            fbName:(NSString*)fbName  
{    
    [self showHud:YES];
    __weak __block WWTagViewController* weakSelf = self;
    [kSharedModel postTag:tagName 
                        fbId:fbId 
                      fbName:fbName 
                   withBlock:^(NSDictionary* res){
                       
                       [weakSelf hideHud:YES];
                       
                       if(nil != res 
                          && nil != res[@"error"]){
                           
                           [self showMsg:res[@"error"] type:msgLevelError];
                           
                           return;
                       }
                       
                       WWRecordTag* recordAdded = (WWRecordTag*)res[@"doc"];  
                       [weakSelf.docs insertObject:recordAdded atIndex:0];
                       //[weakSelf.tb reloadData];
                       NSIndexPath * indexPath = [NSIndexPath indexPathForRow:0
                                                                    inSection:0];
                       [weakSelf.tb insertRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
                   }];
}

-(void)_updTag:(NSString*)tagName 
              _id:(NSString*)_id
            atIndexPath:(NSIndexPath*) indexPathEdit
{    
    [self showHud:YES];
    __weak __block WWTagViewController* weakSelf = self;
    
    [kSharedModel updTag:tagName 
                    fbId:kSharedModel.fbId
                        _id:_id 
                  withBlock:^(NSDictionary* res){
                      
                      [weakSelf hideHud:YES];
                      
                      if(nil != res 
                         && nil != res[@"error"]){
                          
                          [self showMsg:res[@"error"] type:msgLevelError];
                          return;
                      }
                      
                      WWRecordTag* recordUpded = (WWRecordTag*)res[@"doc"];
                      PRPLog(@"recordUpded: %@ \n\
                             -[%@ , %@]",
                             recordUpded,
                             NSStringFromClass([self class]),
                             NSStringFromSelector(_cmd));
                      weakSelf.docs[indexPathEdit.row] = recordUpded;

                      [weakSelf.tb reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPathEdit]  withRowAnimation:UITableViewRowAnimationAutomatic];              
                  }];
}

-(void)_delTag:(NSString*)_id
            atIndexPath:(NSIndexPath*) indexPath
{
    [self showHud:YES];
    __weak __block WWTagViewController* weakSelf = self;
    [kSharedModel delTagById:_id 
                      withBlock:^(NSDictionary* res){
                          
                          [weakSelf hideHud:YES];
                          if(nil != res 
                             && nil != res[@"error"]){
                              
                              [weakSelf showMsg:res[@"error"] type:msgLevelError];
                              return;
                          }
                          
                          WWRecordTag* record = [weakSelf.docs objectAtIndex:indexPath.row];
                          [weakSelf.docs removeObject:record];
                          [weakSelf.tb deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];  
                          
                      }];
    
}

#pragma mark UITableViewDataSource
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *WWCellTag = [self.tb dequeueReusableCellWithIdentifier:@"WWCellTag"];
    WWRecordTag* record = [self.docs objectAtIndex:[indexPath row]];
    
    UIImage *backgroundImage = [UIImage imageNamed:@"app-background.png"];
    WWCellTag.backgroundView = [[UIImageView alloc] initWithImage:backgroundImage];
    
    WWCellTag.textLabel.text = record.tagName;
    
    UIImage *imgTag = [UIImage imageNamed:kSharedModel.theme[@"tag"]];
    WWCellTag.imageView.image = imgTag;
    [BRStyleSheet styleLabel:WWCellTag.textLabel withType:BRLabelTypeName];
    
    //selection mode
    if(nil != self.recordMyRoom){
        WWCellTag.selectionStyle = UITableViewCellSeparatorStyleNone;
        WWCellTag.accessoryType = UITableViewCellAccessoryNone;
        
        UIImageView *imageView;
        if (record.isSelected) {
            imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"icon-import-selected.png"]];
            [self.selectedIndexPaths setObject:record forKey:indexPath];
        }else {
            imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"icon-import-not-selected.png"]];
        }
        WWCellTag.accessoryView = imageView;
    }
    
    return WWCellTag;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.docs count];
}

#pragma mark UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    //selection mode
    if(nil != self.recordMyRoom){
        
        __weak __block WWRecordTag *record = self.docs[indexPath.row];
        [self showHud:YES];
        __weak __block WWTagViewController* weakSelf = self;
        BOOL isSelected = [weakSelf isSelectedAtIndexPath:indexPath];
        
        [kSharedModel toggleRoomSelectTag:record._id 
                                   byRoom:self.recordMyRoom._id 
                               isSelected:!isSelected 
                               withBlock:^(NSDictionary* res){
 
                                    [weakSelf hideHud:YES];
                                    if(nil != res 
                                       && nil != res[@"error"]){
                                        [self showMsg:res[@"error"] type:msgLevelError];
                                        
                                        return;
                                    }
                                    record.isSelected = !record.isSelected; 
                                   //WWRecordTag* record = [self.docs objectAtIndex:[indexPath row]];
                                   if (isSelected) {//already selected, so deselect
                                       [weakSelf.selectedIndexPaths removeObjectForKey:indexPath];
                                   }
                                   else {//not currently selected, so select
                                       [weakSelf.selectedIndexPaths setObject:record forKey:indexPath];
                                   }
                                   [weakSelf updateAccessoryForTableCell:[tableView cellForRowAtIndexPath:indexPath] atIndexPath:indexPath];
                                    //update the accessory view image
                                    [weakSelf updateAccessoryForTableCell:[weakSelf.tb cellForRowAtIndexPath:indexPath] atIndexPath:indexPath];
                                    
                                }];

        
        


    }
}

-(void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath{
    
    WWRecordTag *record = self.docs[indexPath.row];
    [self performSegueWithIdentifier:@"segueTagRelateRooms" sender:record];
}
// Override to support conditional editing of the table view.
// This only needs to be implemented if you are going to be returning NO
// for some items. By default, all items are editable.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return YES if you want the specified item to be editable.
    return YES;
}
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        WWRecordTag* record = [self.docs objectAtIndex:[indexPath row]];
        [self _delTag:record._id atIndexPath:indexPath];
        
    }    
}


//Helper method to check whether a row is selected or not
-(BOOL) isSelectedAtIndexPath:(NSIndexPath *)indexPath
{
    return self.selectedIndexPaths[indexPath] ? YES : NO;
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
    if([identifier isEqualToString:@"segueAddTag"] && nil == kSharedModel.fbId){
    
        [self showMsg:kSharedModel.lang[@"warnConnectFBFirst"] type:msgLevelWarn];
        [kSharedModel fetchFacebookMe];
        return NO;
    }
    
	if(nil != self.recordMyRoom) return NO;//selection mode
	return YES;
}

-(void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    NSString *identifier = segue.identifier;
    if ([identifier isEqualToString:@"segueEditTag"])
	{
        UITableViewCell *WWCellTag = (UITableViewCell*)sender;
        NSIndexPath* indexPahtSelected = [self.tb indexPathForCell:WWCellTag];
        WWRecordTag* recordSelected = [self.docs objectAtIndex:[indexPahtSelected row]];
		WWTagEditViewController* WWTagEditViewController = segue.destinationViewController;
        WWTagEditViewController.recordEdit = recordSelected;
        WWTagEditViewController.type = tagEditTypeEdit;
        WWTagEditViewController.indexPathEdit = indexPahtSelected;
        
	} else if ([identifier isEqualToString:@"segueAddTag"]) {
        
		WWTagEditViewController* WWTagEditViewController = segue.destinationViewController;
        
        WWTagEditViewController.recordEdit = [[WWRecordTag alloc] init];
        WWTagEditViewController.recordEdit.fbId = kSharedModel.fbId;
        WWTagEditViewController.recordEdit.fbName = kSharedModel.fbName;
        
        WWTagEditViewController.type = tagEditTypeAdd;
    } else if ([identifier isEqualToString:@"segueTagRelateRooms"]) {
        WWRecordTag* record = (WWRecordTag*)sender;
		WWMyRoomViewController* WWMyRoomViewController = segue.destinationViewController;
        WWMyRoomViewController.byTagId = record._id;
        WWMyRoomViewController.byTagName = record.tagName;
    }
}

-(IBAction)unwindBackToWWTagViewControllerSave:(UIStoryboardSegue *)segue
{
    WWTagEditViewController* WWTagEditViewController = segue.sourceViewController;
    if(WWTagEditViewController.type == tagEditTypeEdit){
        WWRecordTag* recordToUpd = WWTagEditViewController.recordEdit;
        NSIndexPath* indexPathEdit = WWTagEditViewController.indexPathEdit;
        
        [self _updTag:recordToUpd.tagName 
                  _id:recordToUpd._id 
          atIndexPath:indexPathEdit];
        
    } else if(WWTagEditViewController.type == tagEditTypeAdd) {
        WWRecordTag* recordToAdd = WWTagEditViewController.recordEdit;
        
      [self _sendTag:recordToAdd.tagName 
                fbId:recordToAdd.fbId 
              fbName:recordToAdd.fbName];
    }   
}
@end
