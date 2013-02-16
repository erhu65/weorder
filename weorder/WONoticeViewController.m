//
//  WONoticeViewController.m
//  weorder
//
//  Created by peter on 2/13/13.
//  Copyright (c) 2013 peter. All rights reserved.
//

#import "WONoticeViewController.h"
#import "WORecordNotice.h"
#import "WOCellNotice.h"



@interface WONoticeViewController ()
<UITableViewDataSource,UITableViewDelegate,
UIScrollViewDelegate,
WOCellNoticeDelegate>

@property (nonatomic, strong) NSMutableArray* docs;

@property (weak, nonatomic) IBOutlet UITableView *tb;

@property(nonatomic, strong)NSNumber* page;
@property(nonatomic)BOOL isLastPage;

@property (weak, nonatomic) IBOutlet UIBarButtonItem *barBtnEdit;
@property (weak, nonatomic) IBOutlet UILabel *lbUnRead;
@property (weak, nonatomic) IBOutlet UISwitch *swUnread;

@end

@implementation WONoticeViewController
{
    BOOL addItemsTrigger;
}

-(NSMutableArray*)docs{
    
    if(nil == _docs){
        _docs = [[NSMutableArray alloc] init];
    }
    return _docs;
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
	self.barBtnEdit.title = kSharedModel.lang[@"actionEdit"];
    
    self.lbUnRead.text = kSharedModel.lang[@"unread"];
    [BRStyleSheet styleLabel:self.lbUnRead withType:BRLabelTypeLarge];
    
    [[self tb] setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    self.tb.backgroundColor = [UIColor clearColor];
    UIColor *background = [[UIColor alloc] initWithPatternImage:[UIImage imageNamed:kSharedModel.theme[@"bg_sand"]]];
    self.view.backgroundColor  = background;
    self.navigationItem.leftBarButtonItem = nil;


}



-(void)viewWillAppear:(BOOL)animated{
    
    [super viewWillAppear:animated];
    
    if(self.docs.count == 0){
        [self fetchNotice];
    }
}
-(void)fetchNotice{
    
    self.page = @0;
    self.isLastPage = NO;
    [self.docs removeAllObjects];
    [self _fetchNotice:self.page fbId:kSharedModel.fbId];
}

-(void)_fetchNotice:(NSNumber*)page
                fbId:(NSString*)fbId{
    
    if(nil == fbId){
        [kSharedModel fetchFacebookMe];
        return;
    }
    
    [self showHud:YES];
    __weak __block WONoticeViewController* weakSelf = self;
    [kSharedModel fetchNoticeByFbId:fbId
                           withPage:page
                           isUnRead: self.swUnread.on
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
                                   
                                   self.tabBarItem.badgeValue = [(NSNumber*)res[@"unreadCount"] stringValue];
                                   
                                   int unReadCount = [self.tabBarItem.badgeValue integerValue];
                                   if(unReadCount == 0){
                                       self.tabBarItem.badgeValue = nil;
                                   }

                                   [weakSelf.tb reloadData];
                                   
                               } else {
                                 
                               }
                               
                               
                           }];
}

-(void)_updNotice:(NSString*)_id
            atRow:(int) row
{
    [self showHud:YES];
    __weak __block WONoticeViewController* weakSelf = self;
    
    [kSharedModel updNotice:_id
                  withBlock:^(NSDictionary* res){
                      
                      if(nil != res
                         && nil != res[@"error"]){
                          
                          [self showMsg:res[@"error"] type:msgLevelError];
                          return;
                      }
                      
                      WORecordNotice* recordUpded = (WORecordNotice*)res[@"doc"];
                      
                      PRPLog(@"recordUpded: %@ \n\
                             -[%@ , %@]",
                             recordUpded,
                             NSStringFromClass([self class]),
                             NSStringFromSelector(_cmd));
                      
                      weakSelf.docs[row] = recordUpded;
                      NSIndexPath * indexPath = [NSIndexPath indexPathForRow:row inSection:0];
                      
                      [weakSelf.tb reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath]  withRowAnimation:UITableViewRowAnimationAutomatic];
                      
                      self.tabBarItem.badgeValue = [(NSNumber*)res[@"unreadCount"] stringValue];
                      
                      int unReadCount = [self.tabBarItem.badgeValue integerValue];
                      if(unReadCount == 0){
                          self.tabBarItem.badgeValue = nil;
                      }
                      


                      [weakSelf hideHud:YES];
                      
                  }];
}

-(void)_delNotice:(NSString*)_id
            atRow:(int) row
{
    
    [self showHud:YES];
    __weak __block WONoticeViewController* weakSelf = self;
    [kSharedModel delNotice:_id
                      withBlock:^(NSDictionary* res){
                          
                          [weakSelf hideHud:YES];
                          if(nil != res
                             && nil != res[@"error"]){
                              
                              [weakSelf showMsg:res[@"error"] type:msgLevelError];
                              return;
                          }
                          
                          WORecordNotice* record = [weakSelf.docs objectAtIndex:row];
                          [weakSelf.docs removeObject:record];
                          NSIndexPath * indexPath = [NSIndexPath indexPathForRow:row
                                                                       inSection:0];
                          [weakSelf.tb deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
                          
                          self.tabBarItem.badgeValue = [(NSNumber*)res[@"unreadCount"] stringValue];
                          
                          int unReadCount = [self.tabBarItem.badgeValue integerValue];
                          if(unReadCount == 0){
                              self.tabBarItem.badgeValue = nil;
                          }


                          
                      }];    
}


#pragma mark UITableViewDataSource
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    WOCellNotice *cell = [self.tb dequeueReusableCellWithIdentifier:@"WOCellNotice"];
    
    WORecordNotice* record = [self.docs objectAtIndex:[indexPath row]];
    cell.delegate = self;
    cell.record = record;
    cell.indexPath = indexPath;
    UIImage *backgroundImage = [UIImage imageNamed:@"table-row-background.png"];
    cell.backgroundView = [[UIImageView alloc] initWithImage:backgroundImage];
    
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.docs count];
}

#pragma mark UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    return;    
}
// Override to support conditional editing of the table view.
// This only needs to be implemented if you are going to be returning NO
// for some items. By default, all items are editable.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    
    return YES;
}
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        WORecordNotice* record = [self.docs objectAtIndex:[indexPath row]];
        
        [self _delNotice:record._id atRow:[indexPath row]];
    }
}

#pragma mark WOCellNoticeDelegateWillReadNotice
-(void)WOCellNoticeDelegateWillReadNotice:(WORecordNotice *)record withIndexPath:(NSIndexPath *)indexPath{
    
    [self _updNotice:record._id atRow:[indexPath row]];
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
            [self _fetchNotice:self.page fbId:kSharedModel.fbId];
        }
	}
	// Reset the trigger
	addItemsTrigger = NO;
}

- (void) scrollViewDidScroll:(UIScrollView *)scrollView
{
	// Trigger the offset if the user has pulled back more than 50 pixels
//    PRPLog(@"scrollView.contentOffset.y: %f \
//           scrollView.frame.size.height + 80.0f %f \
//           -[%@ , %@]",
//           scrollView.contentOffset.y,
//           (scrollView.frame.size.height + 80.0f),
//           NSStringFromClass([self class]),
//           NSStringFromSelector(_cmd));
    
	if (scrollView.contentOffset.y < -125.0f )
		addItemsTrigger = YES;
}

- (IBAction)_toggleEditOrDone:(UIBarButtonItem *)sender {
    
    if([sender.title isEqualToString:kSharedModel.lang[@"actionEdit"]]){
        
        sender.title = kSharedModel.lang[@"actionDone"];
        self.tb.editing = YES;
    } else {
        sender.title = kSharedModel.lang[@"actionEdit"];
        self.tb.editing = NO;
    }
}

- (IBAction)_toggleUnRead:(id)sender {
    [self fetchNotice];
}

@end
