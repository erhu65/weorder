//
//  FbMsgBaordViewController.m
//  BirthdayReminder
//
//  Created by Peter2 on 1/2/13.
//  Copyright (c) 2013 Nick Kuh. All rights reserved.
//

#import "FbMsgBaordViewController.h"
#import "BRDModel.h"
#import "BRRecordMsgBoard.h"
//#import "BRRecordVideo.h"
#import "BRCellMsg.h"
#import "QuartzCore/QuartzCore.h"
#import "UIView+position.h"

#define KTempTfInKeyboard 7789

@interface FbMsgBaordViewController ()
<UITableViewDataSource,UITableViewDelegate,
UIScrollViewDelegate>


@property (nonatomic, strong) NSMutableArray* docs;
@property (weak, nonatomic) IBOutlet UITextField *tfMsg;
@property (weak, nonatomic) IBOutlet UITableView *tbMsgBoard;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityMsgBoard;
@property (weak, nonatomic) IBOutlet UILabel *lbTitle;

@property (weak, nonatomic) IBOutlet UIBarButtonItem *barBtnMsg;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *barBtnBack;

@property (strong, nonatomic) UIToolbar *tb;
@property (strong, nonatomic) IBOutlet UIToolbar *tbBottom;
@property(strong, nonatomic) NSMutableArray* mArrMsg;

@end

@implementation FbMsgBaordViewController
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
        self.mArrMsg = [[NSMutableArray alloc] init];
        self.isVideoWatchModel = YES;
        self.isShowBarBtnBack = NO;
        addItemsTrigger = NO;
        self.isDisableInAppNotification = YES;
        
        
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    self.lbTitle.text = kSharedModel.lang[@"titleMsgBoard"];
    self.barBtnBack.title = kSharedModel.lang[@"actionBack"];
    self.barBtnMsg.title = kSharedModel.lang[@"actionMsg"];
    
    //hide activityChatRoom first
    self.activityMsgBoard.hidden = YES;
    
    self.tbMsgBoard.backgroundColor = [UIColor clearColor];
    [BRStyleSheet styleLabel:self.lbTitle withType:BRLabelTypeLarge];
    
    //add custom key input to the dummy textfield
    self.tfMsg.inputAccessoryView = [self accessoryView];
    self.tfMsg.backgroundColor = [UIColor whiteColor];
    [self.tfMsg.layer setCornerRadius:18];
    self.tfMsg.borderStyle = UITextBorderStyleBezel;
    self.tfMsg.frameWidth = 180.0f;
    self.tfMsg.frameHeight = 30.0f;
    self.tfMsg.clearButtonMode = UITextFieldViewModeAlways;
    self.tbMsgBoard.dataSource = self;
    self.tbMsgBoard.delegate = self;
    self.barBtnBack.enabled = NO;

    if(!self.isShowBarBtnBack) {    
        NSMutableArray *items = [self.tbBottom.items mutableCopy];
        [items removeObject:self.barBtnBack];
        [self.tbBottom setItems:items animated:NO];
        //remove the back barButtonItem
    } 
    [self _fetchMsgs:@0 videoId:self.videoId];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_handleFacebookMeDidUpdate:) name:BRNotificationFacebookMeDidUpdate object:[BRDModel sharedInstance]];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_handleDidPostVideoMsg:) name:BRNotificationDidPostVideoMsg object:[BRDModel sharedInstance]];
    
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_handleDidGetVideoMsgs:) name:BRNotificationGetVideoMsgsDidUpdate object:[BRDModel sharedInstance]];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardDidShowNotification object:nil];
    
 
    
    [self.tbMsgBoard setContentOffset:CGPointMake(0.0, 0.0) animated:YES];

}
- (void) viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];

    [[NSNotificationCenter defaultCenter] removeObserver:self name:BRNotificationFacebookMeDidUpdate object:[BRDModel sharedInstance]];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:BRNotificationDidPostVideoMsg object:[BRDModel sharedInstance]];
//    [[NSNotificationCenter defaultCenter] removeObserver:self name:BRNotificationGetVideoMsgsDidUpdate object:[BRDModel sharedInstance]];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardDidShowNotification object:nil];    
    
}
-(void)_handleFacebookMeDidUpdate:(NSNotification *)notification
{
    NSDictionary *userInfo = [notification userInfo];
    NSString* error = userInfo[@"error"];
    if(nil != error){
        [self showMsg:error type:msgLevelWarn]; 
        self.barBtnMsg.enabled = YES;
        [self.activityMsgBoard stopAnimating];
        self.activityMsgBoard.hidden = YES;
        return;
    }
    
    //NSDictionary *userInfo = [notification userInfo];
    PRPLog(@"[BRDModel sharedInstance].fbName: %@-[%@ , %@]",
           [BRDModel sharedInstance].fbName,
           NSStringFromClass([self class]),
           NSStringFromSelector(_cmd));
    [self _sendMsg:nil];
}

-(void)_handleDidPostVideoMsg:(NSNotification*)notification
{
    
    [self.activityMsgBoard stopAnimating];
    self.activityMsgBoard.hidden = YES;

    NSDictionary *userInfo = [notification userInfo];
    NSString* error = userInfo[@"error"];
    if(nil != error && error.length > 0){
        [self showMsg:error type:msgLevelWarn]; 
        self.barBtnMsg.enabled = YES;
        return;
    }
    //NSDictionary *userInfo = [notification userInfo];
    PRPLog(@"post msg successfully do refresh table view -[%@ , %@]",
           NSStringFromClass([self class]),
           NSStringFromSelector(_cmd));
    self.barBtnMsg.enabled = YES;    
    
    if([self.docs count] > 3){
        NSIndexPath *firstRow = [NSIndexPath indexPathForRow:0 inSection:0];
        [self.tbMsgBoard scrollToRowAtIndexPath:firstRow atScrollPosition:UITableViewRowAnimationTop animated:YES];
    }
    [self _fetchMsgs:@0 videoId:self.videoId];
    
}

-(void)_fetchMsgs:(NSNumber*)page 
         videoId:(NSString*)videoId{
    
    [self.activityMsgBoard startAnimating];
    self.activityMsgBoard.hidden = NO;
    __weak __block FbMsgBaordViewController* weakSelf = self;
    [kSharedModel fetchVideoMsgsByVideoId:videoId withPage:page withBlock:^(NSDictionary* res) {
        
        [weakSelf.activityMsgBoard stopAnimating];
        weakSelf.activityMsgBoard.hidden = YES;
        
        NSString* error = res[@"error"];
        if(nil != error){
            [self handleErrMsg:error];
        } else {
            
            NSMutableArray* mTempArr =(NSMutableArray*)res[@"mTempArr"];
            NSRange range = NSMakeRange(0, mTempArr.count); 
            NSMutableIndexSet *indexes = [NSMutableIndexSet indexSetWithIndexesInRange:range];
            [weakSelf.docs insertObjects:mTempArr atIndexes:indexes];
            
            weakSelf.isLastPage = [((NSNumber*)res[@"isLastPage"]) boolValue];
            weakSelf.page = res[@"page"];
           
            self.barBtnBack.enabled = YES;           
            if(self.docs.count > 0){
                PRPLog(@"self.docs.count: %d-[%@ , %@]",
                       weakSelf.docs.count,
                       NSStringFromClass([self class]),
                       NSStringFromSelector(_cmd));
                [weakSelf.tbMsgBoard reloadData];
               
            } 
        }
    
    }];
}
//-(void)_handleDidGetVideoMsgs:(NSNotification*)notification{
//    
//    [self.activityMsgBoard stopAnimating];
//    self.activityMsgBoard.hidden = YES;
//    NSDictionary *userInfo = [notification userInfo];
//    NSString* error = userInfo[@"error"];
//    if(nil != error){
//        [self showMsg:error type:msgLevelWarn]; 
//        return;
//    }
//    self.isLastPage = [((NSNumber*)userInfo[@"isLastPage"]) boolValue];
//    self.page = userInfo[@"page"];
//    [self.tbMsgBoard reloadData];
//    self.barBtnBack.enabled = YES;
//   
//
//    PRPLog(@"get video msgs count: %d  do reload\n  self.page:%@ \n self.isLastPage: %d\n -[%@ , %@]",
//           self.docs.count,
//           self.page,
//           self.isLastPage,
//           NSStringFromClass([self class]),
//           NSStringFromSelector(_cmd));     
//}

- (void) _cancelSendMsg
{
	//[self.tfChat setText:@""];
    self.barBtnMsg.enabled = YES;
    UITextField* tfTemp = (UITextField*)[self.tb viewWithTag:KTempTfInKeyboard];
    [tfTemp resignFirstResponder];
    //[tfTemp setText:@""];
}
-(void)_sendMsg:(UIBarButtonItem*)sender
{
    if(nil != sender){
        sender.enabled = NO;
        double delayInSeconds = 3.0;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            sender.enabled = YES;
            
        });
    }

    self.activityMsgBoard.hidden = NO;
    [self.activityMsgBoard startAnimating];
    UITextField* tfTemp = (UITextField*)[self.tb viewWithTag:KTempTfInKeyboard];
    if(tfTemp.text.length == 0 
       && self.tfMsg.text.length == 0 ){
        [self showMsg:self.lang[@"warnEmptyText"] type:msgLevelWarn];
        return;
    }
    
    if(nil == [BRDModel sharedInstance].fbId){
        
        self.tfMsg.text = tfTemp.text;
        [[BRDModel sharedInstance] fetchFacebookMe];
        return;
    } 
    NSString* msg = (tfTemp.text.length > 0)?tfTemp.text:self.tfMsg.text;
    PRPLog(@"fbName:%@ \n fbId:%@ \n msg:%@ \n videoId:%@ \n -[%@ , %@]",
           [BRDModel sharedInstance].fbName,
           [BRDModel sharedInstance].fbId,
           msg,
           self.videoId,
           NSStringFromClass([self class]),
           NSStringFromSelector(_cmd));
  
    [tfTemp resignFirstResponder];
  
    [kSharedModel postMsg:msg 
                ByVideoId:self.videoId 
                     fbId:[BRDModel sharedInstance].fbId 
                   fbName:[BRDModel sharedInstance].fbName];
}

-(IBAction)_prepareTextForSendMsgToRoom:(id)sender
{
    self.barBtnMsg.enabled = NO;
    [self.tfMsg becomeFirstResponder];
}

#pragma mark chat textfield/keyboard 
- (void) keyboardWillHide: (NSNotification *) notification
{
    UITextField* tfTemp = (UITextField*)[self.tb viewWithTag:KTempTfInKeyboard];
    tfTemp.text = @"";
    
}
- (void) keyboardWillShow: (NSNotification *) notification
{
    UITextField* tfTemp = (UITextField*)[self.tb viewWithTag:KTempTfInKeyboard];
    tfTemp.text = @"";
    [tfTemp becomeFirstResponder];
}

- (UIToolbar *) accessoryView
{
	self.tb = [[UIToolbar alloc] initWithFrame:CGRectMake(0.0f, 0.0f, self.view.frame.size.width, 44.0f)];
	self.tb .tintColor = [UIColor darkGrayColor];
	NSMutableArray *items = [NSMutableArray array];
	[items addObject:BARBUTTON(@"Cancel", @selector(_cancelSendMsg))];
	[items addObject:SYSBARBUTTON(UIBarButtonSystemItemFlexibleSpace, nil)];
	[items addObject:BARBUTTON(@"Send", @selector(_sendMsg:))];
    
	self.tb.items = items;	
    UITextField *tfTemp = [[UITextField alloc] initWithFrame:CGRectMake(85.0, 8.0, 165.0, 30)];
    tfTemp.backgroundColor = [UIColor whiteColor];
    [tfTemp.layer setCornerRadius:18];
    tfTemp.borderStyle = UITextBorderStyleBezel;
    tfTemp.tag = KTempTfInKeyboard;
    [self.tb addSubview:tfTemp];
	return self.tb ;
}

- (IBAction)_back:(id)sender {
    
    UIBarButtonItem* barBtnBack = (UIBarButtonItem* )sender;
    barBtnBack.enabled = NO;    
    
    [self.delegate FbMsgBaordViewTriggerOuterGoBack];
}

#pragma mark UITableViewDataSource
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    BRCellMsg *BRCellMsg = [self.tbMsgBoard dequeueReusableCellWithIdentifier:@"BRCellMsg"];
    
    BRRecordMsgBoard* record = [self.docs objectAtIndex:[indexPath row]];
    BRCellMsg.record = record;
    
    UIImage *backgroundImage = [UIImage imageNamed:@"table-row-background.png"];
    BRCellMsg.backgroundView = [[UIImageView alloc] initWithImage:backgroundImage];
    
    return BRCellMsg;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.docs count];
}

#pragma mark UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
}
// Override to support conditional editing of the table view.
// This only needs to be implemented if you are going to be returning NO
// for some items. By default, all items are editable.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return YES if you want the specified item to be editable.
    BRRecordMsgBoard* record = [self.docs objectAtIndex:[indexPath row]];
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    NSString* fbId = [defaults objectForKey:KUserDefaultFbId];
    
    if([record.fbId isEqualToString:fbId])return YES;
    return NO;
}
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        BRRecordMsgBoard* record = [self.docs objectAtIndex:[indexPath row]];
        [self.docs removeObject:record];
        //add code here for when you hit delete
        // Animate the deletion from the table.
      
        [kSharedModel delMsgById:record._id VideoId:self.videoId];
        
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
        
    }    
}
//get a callback when a UITableView reload is done?
- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if(indexPath.row == 0){
        NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
        NSString* fbId = [defaults objectForKey:KUserDefaultFbId];
        if(nil != fbId && !self.tbMsgBoard.editing){
            
            double delayInSeconds = 2.0;
            dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
            dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                self.tbMsgBoard.editing = YES;
                
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
            [self _fetchMsgs:self.page videoId:self.videoId];
        }
        
	}
	// Reset the trigger
	addItemsTrigger = NO;
}

- (void) scrollViewDidScroll:(UIScrollView *)scrollView
{
	// Trigger the offset if the user has pulled back more than 50 pixels
	if (scrollView.contentOffset.y > (scrollView.frame.size.height + 80.0f) )
		addItemsTrigger = YES;
}

@end
