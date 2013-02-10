//
//  FbChatRoomViewController.m
//  BirthdayReminder
//
//  Created by Peter2 on 12/28/12.
//  Copyright (c) 2012 Nick Kuh. All rights reserved.
//

#import "FbChatRoomViewController.h"
#import "WebViewJavascriptBridge.h"
#import "BRDModel.h"
#import "BRRecordFbChat.h"
#import "BRCellfBChat.h"
//#import "BRRecordSubCategory.h"
#import "QuartzCore/QuartzCore.h"
#import "UIView+position.h"

#import "HorizontalTableViewCell.h"
#import "NSMutableArray+Shuffling.h"

#import "Utils.h"
#import "UIImage+Sprite.h"

#define KTempTfInKeyboard 7789

#define KTbFriendsOnLine 1342


@interface FbChatRoomViewController ()
<UITableViewDataSource,UITableViewDelegate,
UIScrollViewDelegate,
BRCellfBChatDelegate>

@property (weak, nonatomic) IBOutlet UIWebView *webview;

@property (weak, nonatomic) IBOutlet UITableView *tbFriendsOnLine;

@property (weak, nonatomic) IBOutlet UITextView* tvOutPut;
@property (weak, nonatomic) IBOutlet UITextField *tfMsg;



@property (weak, nonatomic) IBOutlet UIButton* joinRoomButton;
@property (weak, nonatomic) IBOutlet UIButton* chatButton;
@property (strong, nonatomic) WebViewJavascriptBridge *javascriptBridge;
@property (weak, nonatomic) IBOutlet UITextField *tfChat;

@property (strong, nonatomic) IBOutlet UIToolbar *tb;

@property (weak, nonatomic) IBOutlet UIToolbar *toolBarRoom;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *barBtnTalk;


@property (weak, nonatomic) IBOutlet UIImageView *imageView;

@property (weak, nonatomic) IBOutlet UIButton *btnLeave;

@property (weak, nonatomic) IBOutlet UISwitch *switchSound;

//@property (weak, nonatomic) IBOutlet UIBarButtonItem *barBtnJoin;

@property (weak, nonatomic) IBOutlet UILabel *lbRoomCount;
@property (weak, nonatomic) IBOutlet UITableView *tbFbChat;
@property(nonatomic, strong)NSNumber* page;
@property(nonatomic)BOOL isLastPage;
@property(strong, nonatomic) NSMutableArray* mArrFbChat;
@property(strong, nonatomic) NSMutableDictionary* mDicFriendOnLine;
@property(strong, nonatomic) NSMutableArray* mArrFriendOnLine;



//@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityChatRoom;
//


@property (weak, nonatomic) IBOutlet UIBarButtonItem *btnZoom;
@property(nonatomic) BOOL isZoomed;
@property (weak, nonatomic) IBOutlet UIView *vContainer;

@property (nonatomic, strong) NSArray *hConstraintVContainer;
@property (nonatomic, strong) NSArray *vConstraintVContainer;

@end


@implementation FbChatRoomViewController
{
    BOOL addItemsTrigger;
    SystemSoundID _soundAdd;
    SystemSoundID _soundDel;
    SystemSoundID _soundJoin;
    SystemSoundID _soundLeave;
    SystemSoundID _soundExplosion;
}
@synthesize javascriptBridge = _bridge;


-(NSMutableArray*)mArrAnimationQueue{
    
    if(nil == _mArrAnimationQueue){
        _mArrAnimationQueue = [[NSMutableArray alloc] init];
    }
    return _mArrAnimationQueue;
}
-(NSMutableArray*)mArrDownloadQueue{
    
    if(nil == _mArrDownloadQueue){
        _mArrDownloadQueue = [[NSMutableArray alloc] init];
    }
    return _mArrDownloadQueue;
}


-(NSMutableDictionary*)mDicFriendOnLine
{
    if(nil == _mDicFriendOnLine){
        _mDicFriendOnLine = [[NSMutableDictionary alloc] init];
    }
    
    return _mDicFriendOnLine;
}
-(NSMutableArray*)mArrFriendOnLine
{
    if(nil == _mArrFriendOnLine){
        _mArrFriendOnLine = [[NSMutableArray alloc] init];        
    }

//    [_mArrFriendOnLine removeAllObjects];    
//    if(self.isJoinFbChatRoom){
//        [self.mDicFriendOnLine enumerateKeysAndObjectsUsingBlock:^(id key, id object, BOOL *stop) {
//            NSString* fbId = (NSString*)key;
//            NSString* fbName = (NSString*)object;
//            NSDictionary* friend = @{@"fbId": fbId,
//                                     @"fbName": fbName};
//            [_mArrFriendOnLine addObject:friend];
//            
//        }];
//
//    }
    
    return _mArrFriendOnLine;
}


-(void)setIsLeaving:(BOOL)isLeaving{
    
    _isLeaving = isLeaving;
    if(isLeaving){
        
        [[NSNotificationCenter defaultCenter] removeObserver:self name:BRNotificationFacebookMeDidUpdate object:[BRDModel sharedInstance]];
        [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
        [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardDidShowNotification object:nil];
        //Clear A UIWebView to trigger window.onunload
        [self.webview loadHTMLString:@"" baseURL:[NSURL URLWithString:BASE_URL]];    
    }
}



- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    if([self isViewLoaded] && self.view.window == nil){
        //self.imvThumb = nil;
        self.tb = nil;
    }
}

-(id)initWithCoder:(NSCoder *)aDecoder{
    
    self = [super initWithCoder:aDecoder];
    if(self){
        
        self.isDisableInAppNotification = NO;
        
        addItemsTrigger = NO;
        self.page = @0;
        self.isLastPage = NO;
        
        self.isJoinFbChatRoom = NO;
        self.isLeaving = NO;
        self.isZoomed = YES;
        self.mArrFbChat = [[NSMutableArray alloc] init];
        self.isDisableInAppNotification = YES;
   
        
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
  
    //node.js socket.io webview bridge start...
    [self.view  insertSubview:self.webview atIndex:0];
    
    //add custom key input to the dummy textfield
    self.tfChat.inputAccessoryView = [self accessoryView];
    self.tfChat.backgroundColor = [UIColor whiteColor];
    [self.tfChat.layer setCornerRadius:18];
    self.tfChat.borderStyle = UITextBorderStyleBezel;
    self.tfChat.frameWidth = 180.0f;
    self.tfChat.frameHeight = 30.0f;
    
//    self.barBtnJoin.title = self.lang[@"actionJoin"];
    self.barBtnTalk.title = self.lang[@"actionTalk"];
    self.btnZoom.title = self.lang[@"actionFull"];
    //hide activityChatRoom first
    //self.activityChatRoom.hidden = YES;
   
    
    self.tbFbChat.backgroundColor = [UIColor clearColor];
    self.view.backgroundColor = [UIColor clearColor];
    self.tfMsg.clearButtonMode = UITextFieldViewModeWhileEditing;
    [BRStyleSheet styleLabel:self.lbRoomCount withType:BRLabelTypeLarge];
    
	CGAffineTransform rotateTable = CGAffineTransformMakeRotation(-M_PI_2);
	self.tbFriendsOnLine.transform = rotateTable;
	self.tbFriendsOnLine.frame = CGRectMake(0, 500, self.tbFriendsOnLine.frame.size.width, self.tbFriendsOnLine.frame.size.height);
    UIImage* backgroundImage = [UIImage imageNamed:@"tool-bar-background.png"];
    self.tbFriendsOnLine.backgroundView = [[UIImageView alloc] initWithImage:backgroundImage];
    
    [self.switchSound setOnTintColor:[UIColor colorWithRed:0 green:175.0/255.0 blue:176.0/255.0 alpha:1.0]];
 
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_handleFacebookMeDidUpdate:) name:BRNotificationFacebookMeDidUpdate object:[BRDModel sharedInstance]];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardDidShowNotification object:nil];
}
- (void) viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:BRNotificationFacebookMeDidUpdate object:[BRDModel sharedInstance]];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardDidShowNotification object:nil];
    
    if(self.isLeaving){
        [self leaveRoom];
    }
}
-(void) toggleChatRoomEdit:(BOOL)isEditing
{
    self.tbFbChat.editing = isEditing;
}
- (IBAction)leaveRoom:(id)sender {
    [self leaveRoom];
}

-(void) leaveRoom{
    
    if(self.isJoinFbChatRoom){
      
        [self playSoundEffect:@"leave" soundId:_soundLeave];
    } else {
       
        [self playSoundEffect:@"join" soundId:_soundLeave];
    }
    addItemsTrigger = NO;
    self.isJoinFbChatRoom = NO;
    self.room = nil;
    self.page = @0;
    self.isLastPage = NO;  
    self.isEnableSound = YES;
    
    [self.mArrFbChat removeAllObjects];
    [self.mArrFriendOnLine removeAllObjects];
    [self.mDicFriendOnLine removeAllObjects]; 
    [self.tbFbChat reloadData];
    [self.tbFriendsOnLine reloadData];
    [self.mArrDownloadQueue removeAllObjects];
    [self.mArrAnimationQueue removeAllObjects];
    self.uniquDataKey = @"";
    self.fbIdRoomOwner = nil;
    //self.tbFbChat.editing = NO;
    
//    for (int i = 0; i <30; i++) {
//        NSDictionary* friendDummy = @{@"fbId": @"100000103740638",
//                                      @"fbname": @"test user", 
//                                      @"isOnLine": @1};
//        [_mArrFriendOnLine addObject:friendDummy];
//    }

    
    
    //self.barBtnJoin.title = self.lang[@"actionJoin"];
    //self.barBtnJoin.enabled = YES;

    //Clear A UIWebView to trigger window.onunload
    //Clear A UIWebView to trigger window.onunload
    NSURL* url = [[NSURL alloc] initWithString:BASE_URL];
    NSURLRequest *request = [[NSURLRequest alloc] initWithURL:url];
    [self.webview loadRequest:request];  
    //self.activityChatRoom.hidden = YES;
    //[self.activityChatRoom stopAnimating];
    [self hideHud:YES];
}

-(void)_handleFacebookMeDidUpdate:(NSNotification *)notification
{
    NSDictionary *userInfo = [notification userInfo];
    NSString* error = userInfo[@"error"];
    if(nil != error){
        [self showMsg:error type:msgLevelWarn]; 
        //self.barBtnJoin.title = kSharedModel.lang[@"actionJoin"];
        //self.barBtnJoin.enabled = YES;
        return;
    }

    PRPLog(@"[BRDModel sharedInstance].fbName: %@-[%@ , %@]",
           [BRDModel sharedInstance].fbName,
           NSStringFromClass([self class]),
           NSStringFromSelector(_cmd));
    
    
    NSString* name = [BRDModel sharedInstance].fbName;
    NSString* fbId = [BRDModel sharedInstance].fbId;
    [self callJsJoinRoomHandler:name withFbId:fbId];

}

#pragma mark node.js socekt helper methods
-(void)_callJsDelMsgHandler:(NSString*)_id{
    
    NSDictionary* data = @{@"type": @"chat",
                           @"action": @"del",
                           @"fbId": kSharedModel.fbId,
                           @"_id": _id
                           };
    
    [_bridge callHandler:@"JsSendMsgHandler" data:data responseCallback:^(id response) {
        NSLog(@"_callJsDelMsgHandler responded: %@", response);
        
    }];
}

-(void)_callJsSendAnimationHandler:(NSString*)animationId{
    
    NSDictionary* data = @{@"type": @"chat",
                           @"action": @"playAnimation",
                           @"fbId": kSharedModel.fbId,
                           @"animationId": animationId,
                           };
    
    [_bridge callHandler:@"JsSendMsgHandler" data:data responseCallback:^(id response) {
        NSLog(@"_callJsSendAnimationHandler responded: %@", response);
        
    }];
}


- (void)callJsSendMsgHandler:(NSString*)newMsg  {
    
    if([self.delegate respondsToSelector:@selector(FbChatRoomViewControllerDelegateGetOutterInfo)]){
        [self.delegate FbChatRoomViewControllerDelegateGetOutterInfo];
        PRPLog(@"uniquDataKey:%@  -[%@ , %@] \n ",
               self.uniquDataKey,
               NSStringFromClass([self class]),
               NSStringFromSelector(_cmd));
    }
    
    if(nil != self.imvGratiffiThumb.image){
        [self.delegate FbChatRoomViewControllerDelegateProcessFileUpload];
        self.imvGratiffiThumb.image = nil;
    } else {
        
        self.uniquDataKey = @"";
        [self _postChat:@"chat" msg:newMsg fbId:kSharedModel.fbId
                 fbName:kSharedModel.fbName roomId:self.room];   
    }
}
-(void)postChatAfterUploadFile{
   
    [self _postChat:@"chat" msg:self.tfMsg.text fbId:kSharedModel.fbId
             fbName:kSharedModel.fbName roomId:self.room];   
}

- (void)callJsJoinRoomHandler:(NSString*)fbName
                            withFbId:(NSString*)fbId{
    
    if(nil == self.room) return;
    
    if([self.delegate respondsToSelector:@selector(FbChatRoomViewControllerDelegateGetOutterInfo)]){
        [self.delegate FbChatRoomViewControllerDelegateGetOutterInfo];
        PRPLog(@"self.room:%@   -[%@ , %@] \n ",
               self.room,
               NSStringFromClass([self class]),
               NSStringFromSelector(_cmd));
    }
    if([self.delegate respondsToSelector:@selector(FbChatRoomViewControllerDelegateGetOutterInfo)]){
        [self.delegate FbChatRoomViewControllerDelegateGetOutterInfo];
        PRPLog(@"uniquDataKey:%@  -[%@ , %@] \n ",
               self.uniquDataKey,
               NSStringFromClass([self class]),
               NSStringFromSelector(_cmd));
    }
    NSDictionary* data =  @{@"room": self.room,
                            @"fbId": fbId,
                            @"fbName": fbName,
                            @"uniquDataKey": self.uniquDataKey};
    
    [_bridge callHandler:@"JsJoinRoomHandler" 
                    data:data 
        responseCallback:^(id response) {
        PRPLog(@"callJsJoinRoomHandler responded: %@-[%@ , %@] \n ",
               response,
               NSStringFromClass([self class]),
               NSStringFromSelector(_cmd));
    }];
}
- (void) _cancelSendMsg
{
	//[self.tfChat setText:@""];
    self.barBtnTalk.enabled = YES;
    UITextField* tfTemp = (UITextField*)[self.tb viewWithTag:KTempTfInKeyboard];
    [tfTemp resignFirstResponder];
    //[tfTemp setText:@""];
}

-(IBAction)_presentBrush{
    if(nil == self.room){
    
        [self showMsg:kSharedModel.lang[@"warnPleaseJoinSubjectFirst"] type:msgLevelWarn];
        return;
    }
    
    [self.delegate FbChatRoomViewControllerDelegateTriggerOuterAction2];
     //self.barBtnTalk.enabled = YES;
}


-(IBAction)_sendMsgToRoom
{
    if(nil == self.room){
        [self showMsg:kSharedModel.lang[@"warnPleaseJoinSubjectFirst"] type:msgLevelWarn];
        return;
    }
    
    if(self.tfMsg.text.length == 0 && nil == self.imvGratiffiThumb.image){
    
        [self showMsg:kSharedModel.lang[@"warnPleaseAddMsgOrGratiffi"] type:msgLevelWarn];
        return;
    }
    
    self.barBtnTalk.enabled = NO;
//    UITextField* tfTemp = (UITextField*)[self.tb viewWithTag:KTempTfInKeyboard];
//    if(tfTemp.text.length == 0){
//        [self showMsg:self.lang[@"warnEmptyText"] type:msgLevelWarn];
//        return;
//    }

    if(!self.isJoinFbChatRoom){
        [self showMsg:self.lang[@"infoJoinRoomFirst"] type:msgLevelInfo];
        //[self.activityChatRoom stopAnimating];
        //self.activityChatRoom.hidden = YES;
        [self hideHud:YES];
        self.barBtnTalk.enabled = YES;
        [self.tfMsg resignFirstResponder];
        return;
    }
    [self showHud:YES];
    //self.activityChatRoom.hidden = NO;
    //[self.activityChatRoom startAnimating];
    
    [self callJsSendMsgHandler: self.tfMsg.text];
    //[tfTemp resignFirstResponder];
    
   
}

-(IBAction)_prepareTextForSendMsgToRoom:(id)sender
{
    self.barBtnTalk.enabled = NO;
    double delayInSeconds = 2.0;
    
    __block __weak FbChatRoomViewController* weakSelf = (FbChatRoomViewController*)self;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        weakSelf.barBtnTalk.enabled = YES;
    });
    
    
    [self.tfChat becomeFirstResponder];
}

- (IBAction)joinRoomWithFBAccount:(UIBarButtonItem*)sender {
    
    NSString* btnTitle = sender.title;    
    if(!self.isJoinFbChatRoom){
        
        [WebViewJavascriptBridge enableLogging];
        
        _bridge = [WebViewJavascriptBridge bridgeForWebView:self.webview handler:^(id data, WVJBResponseCallback responseCallback) {
            
            NSLog(@"ObjC received message from JS: %@", data);
            responseCallback(@"Response for message from ObjC");
        }];
        
        [_bridge registerHandler:@"testObjcCallback" handler:^(id data, WVJBResponseCallback responseCallback) {
            
            NSLog(@"testObjcCallback called: %@", data);
            responseCallback(@"Response from testObjcCallback");
        }];
        
        [_bridge registerHandler:@"iosGetMsgCallback" handler:^(id data, WVJBResponseCallback responseCallback) {
        
            NSDictionary* resDic = (NSDictionary*)data;
            PRPLog(@"iosGetMsgCallback called :%@  -[%@ , %@] \n ",
                   resDic,
                   NSStringFromClass([self class]),
                   NSStringFromSelector(_cmd));

            NSString* type = resDic[@"type"];
            if([type isEqualToString:@"chat"] 
            || [type isEqualToString:@"server"]){
            
                //NSString* type = resDic[@"type"];
                NSString* roomCount = (NSString*)resDic[@"roomCount"];
                NSString* fbName = (NSString*)resDic[@"fbName"];
                //NSString* senderFbId =  (NSString*)resDic[@"senderFbId"];
                NSString* msg = (NSString*)resDic[@"msg"];
                NSString* fbId = (NSString*)resDic[@"fbId"];
                
                if([type isEqualToString:@"chat"]){
                    
                    if([kSharedModel.fbId isEqualToString:fbId]){
                        
                    }

                }
                
                if([type isEqualToString:@"server"]){
                    
                    __weak  FbChatRoomViewController* weakSelf = (FbChatRoomViewController* ) self;
                    NSDictionary* friendsOnLine = resDic[@"friendsOnLine"];
                    
                    if(nil != friendsOnLine){
                        
                        [friendsOnLine enumerateKeysAndObjectsUsingBlock:^(id key, id object, BOOL *stop) {
                            NSString* fbId = (NSString*)key;
                            NSString* fbName = (NSString*)object;
                            
                            [weakSelf.mDicFriendOnLine setObject:fbName forKey:fbId];
//                            NSMutableDictionary* friendOnLine = [weakSelf _findInviteFriendsByFbId:fbId];
//                            friendOnLine[@"isOnLine"] = @1;
//                            [weakSelf.tbFriendsOnLine reloadData];
                        }];
                        if([weakSelf.page integerValue] == 0){
                            
                            [weakSelf _fetchFriendInviteInRoom:weakSelf.room];
                            

                        }
                    }
                    
                    NSString* friendFbName = [self.mDicFriendOnLine objectForKey:fbId];
                    NSString* subType = resDic[@"subType"];
                    if(nil != subType 
                       && [subType isEqualToString:@"userJoin"]
                       && nil == friendFbName){
                        NSString* userJoinFbName = resDic[@"userJoinFbName"];
                        
                        [weakSelf.mDicFriendOnLine setObject:userJoinFbName forKey:fbId];
                        NSMutableDictionary* friendOnLine = [weakSelf _findInviteFriendsByFbId:fbId];
                        friendOnLine[@"isOnLine"] = @1;
                        
                        [weakSelf.mArrFriendOnLine shuffle];
                        
                        [weakSelf.tbFriendsOnLine reloadData];
                        
                        [self playSoundEffect:@"join" soundId:_soundJoin];    
                        
                    } else if(nil != subType 
                              && [subType isEqualToString:@"userLeave"]
                        && nil != friendFbName) {
                       
                        NSMutableDictionary* friendOnLine = [weakSelf _findInviteFriendsByFbId:fbId];
                        friendOnLine[@"isOnLine"] = @0;
                        
                        [weakSelf.mDicFriendOnLine removeObjectForKey:fbId];
                        [weakSelf.tbFriendsOnLine reloadData];
                        [self playSoundEffect:@"leave" soundId:_soundLeave];
                    }
                    
                    PRPLog(@"self.mDicFriendOnLine :%@ \n\
                           self.mArrFriendOnLine :%@\n\
                           -[%@ , %@] \n ",
                           weakSelf.mDicFriendOnLine ,
                           weakSelf.mArrFriendOnLine ,
                           NSStringFromClass([self class]),
                           NSStringFromSelector(_cmd));
                }
                
                if([fbName isEqualToString:@"me"]) fbId = kSharedModel.fbId;
                
                if([fbName isEqualToString:@"server"]
                   && [msg rangeOfString:@"Good to see your"].location != NSNotFound){
                   
                    self.isJoinFbChatRoom = YES;
                    [self _fetchChatByRoom:self.room withPage:self.page];
                    [self.tbFriendsOnLine reloadData];

                }
                
                if(nil != roomCount){
                    self.lbRoomCount.text = [NSString stringWithFormat:@"%@: %@",kSharedModel.lang[@"onLine"], roomCount];
                }
                
                 NSString* action = (NSString*)resDic[@"action"];
                
                if([type isEqualToString:@"chat"] 
                   && nil != action 
                   && [action isEqualToString:@"del"]
                   && ![fbId isEqualToString:kSharedModel.fbId]
                   ){
                    
                    NSString* _id = (NSString*)resDic[@"_id"];
                    PRPLog(@"the chat creator del chat by _id :%@  -[%@ , %@] \n ",
                           _id,
                           NSStringFromClass([self class]),
                           NSStringFromSelector(_cmd));  
                    BRRecordFbChat* recordFound = [self _findChatById:_id];
                    
                    if(nil != recordFound){
                        
                        NSUInteger* indexFound = [self.mArrFbChat indexOfObject:recordFound];
                        [self.mArrFbChat removeObject:recordFound];
                        NSIndexPath * indexPathFound = [NSIndexPath indexPathForRow:indexFound inSection:0];
                        [self.tbFbChat deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPathFound] withRowAnimation:UITableViewRowAnimationFade];
                        [self.delegate FbChatRoomViewControllerDelegateDelRecord:recordFound];
                        [self playSoundEffect:@"del" soundId:_soundDel];
                        NSMutableDictionary* friendOnLine = [self _findInviteFriendsByFbId:fbId];
                        NSUInteger rowIndex = [self.mArrFriendOnLine indexOfObject:friendOnLine];
                        NSIndexPath * indexPathOfPlayer = [NSIndexPath indexPathForRow:rowIndex inSection:0];
                        [self.tbFriendsOnLine scrollToRowAtIndexPath:indexPathOfPlayer atScrollPosition:UITableViewScrollPositionMiddle animated:YES];
                        
                    }

                } else if ([type isEqualToString:@"chat"] 
                           && nil != action 
                           && [action isEqualToString:@"playAnimation"]
                           && ![fbId isEqualToString:kSharedModel.fbId]) {
                   
                    NSString* animationId = (NSString*)resDic[@"animationId"];
                    [self _playAnimation:[animationId intValue]  playerFbId:fbId];
                
                }else if (([type isEqualToString:@"chat"] 
                    && ![fbId isEqualToString:kSharedModel.fbId] ) 
                   || [type isEqualToString:@"server"]){
                    
                    BRRecordFbChat* recordNew = [[BRRecordFbChat alloc] initWithJsonDic:resDic];
                    [self.delegate FbChatRoomViewControllerDelegateProcessFileDownloadUnZip:recordNew];
                    
                    [self hideHud:YES];
                    self.barBtnTalk.enabled = YES;
                    
                }
                
            }

            responseCallback(@"Response from iosGetMsgCallback: ios got chatroom msg");
        }];
        [_bridge send:@"A string sent from ObjC before Webview has loaded." responseCallback:^(id responseData) {
            NSLog(@"objc got response! %@", responseData);
        }];
        
        [_bridge callHandler:@"testJavascriptHandler" data:[NSDictionary dictionaryWithObject:@"before ready" forKey:@"foo"]];
        //node.js socket.io webview bridge end... 
        
        NSURL* url = [[NSURL alloc] initWithString:[BRDModel sharedInstance].socketUrl];
        NSURLRequest *request = [[NSURLRequest alloc] initWithURL:url];
        [self.webview loadRequest:request];
        [_bridge send:@"A string sent from ObjC after Webview has loaded."];
        //self.barBtnJoin.title = self.lang[@"actionLeave"];
        //self.barBtnJoin.enabled = FALSE;
        //self.activityChatRoom.hidden = NO;
        //[self.activityChatRoom startAnimating];
        [self showHud:YES];
        if(nil != [BRDModel sharedInstance].fbId){
            
            [self _handleFacebookMeDidUpdate:nil];
        } else {
            [[BRDModel sharedInstance] fetchFacebookMe];
        }
    
    } else if([btnTitle isEqualToString:self.lang[@"actionLeave"]]){
        [self leaveRoom];

    } 

}

-(void)addNewChatFromOthers:(BRRecordFbChat *)recordNew{
    
    [self.mArrFbChat insertObject:recordNew atIndex:0];
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
    NSArray* arrIndexPathNew = @[indexPath];
    
    [[self tbFbChat] beginUpdates];
    [self.tbFbChat insertRowsAtIndexPaths:arrIndexPathNew withRowAnimation:UITableViewRowAnimationAutomatic];
    [[self tbFbChat] endUpdates];
    [[self tbFbChat] setContentOffset:CGPointZero animated:YES];
    if([recordNew.type isEqualToString:@"chat"]){
        
        [self playSoundEffect:@"add" soundId:_soundAdd];
        NSMutableDictionary* friendOnLine = [self _findInviteFriendsByFbId:recordNew.fbId];
        NSUInteger rowIndex = [self.mArrFriendOnLine indexOfObject:friendOnLine];
        NSIndexPath * indexPathOfPlayer = [NSIndexPath indexPathForRow:rowIndex inSection:0];
        [self.tbFriendsOnLine scrollToRowAtIndexPath:indexPathOfPlayer atScrollPosition:UITableViewScrollPositionMiddle animated:YES];
    }
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
    tfTemp.text = self.tfChat.text;
    [tfTemp becomeFirstResponder];
}
- (UIToolbar *) accessoryView
{
	self.tb = [[UIToolbar alloc] initWithFrame:CGRectMake(0.0f, 0.0f, self.view.frame.size.width, 44.0f)];
	self.tb .tintColor = [UIColor darkGrayColor];
	NSMutableArray *items = [NSMutableArray array];
	[items addObject:BARBUTTON(@"Cancel", @selector(_cancelSendMsg))];
    [items addObject:SYSBARBUTTON(UIBarButtonSystemItemFlexibleSpace, nil)];

//    [items addObject:BARBUTTON(@"add graffiti", @selector(_presentBrush))];
//    UIBarButtonItem* fixedSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];  
//    fixedSpace.width = 100;  
//    [items addObject:fixedSpace];
//	[items addObject:BARBUTTON(@"Send", @selector(_sendMsgToRoom))];
	self.tb.items = items;	
    int tfWidth = 0;
    if(IS_IPHONE){
        tfWidth = 165;
    } else {
        tfWidth = 500;
    }

    UITextField *tfTemp = [[UITextField alloc] initWithFrame:CGRectMake(85.0, 8.0, tfWidth, 30)];
    tfTemp.backgroundColor = [UIColor whiteColor];
    [tfTemp.layer setCornerRadius:18];
    tfTemp.borderStyle = UITextBorderStyleBezel;
    tfTemp.tag = KTempTfInKeyboard;
    [self.tb addSubview:tfTemp];
	return self.tb ;
}

- (IBAction)toggleOutterUI:(UIBarButtonItem*)sender {
    BOOL isZoomed = [self.delegate FbChatRoomViewControllerDelegateToggleOutterUI];
    if(isZoomed){
        sender.title = self.lang[@"actionSplit"];
    } else {
        sender.title = self.lang[@"actionFull"];
    }
}

- (IBAction)_back:(id)sender {
    
    UIBarButtonItem* barBtnBack = (UIBarButtonItem* )sender;
    barBtnBack.enabled = NO;    
    [self.delegate FbChatRoomViewControllerDelegateTriggerOuterGoBack];
//    [self dismissViewControllerAnimated:YES completion:^{
//    
//    }];
}

#pragma mark UITableViewDataSource
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(tableView.tag == KTbFriendsOnLine){
        
        HorizontalTableViewCell *cellFriend = (HorizontalTableViewCell *)[self.tbFriendsOnLine dequeueReusableCellWithIdentifier:@"HorizontalTableViewCell"];
        NSDictionary* record = [self.mArrFriendOnLine objectAtIndex:[indexPath row]];
        cellFriend.lbFbName.text = record[@"fbName"];
        NSString *url = [[NSString alloc] initWithFormat:@"https://graph.facebook.com/%@/picture",record[@"fbId"]];
        [Utils showImageAsync:cellFriend.imvFb  fromUrl:url cacheName:record[@"fbId"]];
        BOOL isOnline = [(NSNumber*)record[@"isOnLine"] intValue];
        if(isOnline){
            cellFriend.imvIsOnLine.image = [UIImage imageNamed:kSharedModel.theme[@"greenlight"]];
        } else {
            cellFriend.imvIsOnLine.image = [UIImage imageNamed:kSharedModel.theme[@"redlight"]];
        }
        return cellFriend;     
        
    } else {
        
        BRCellfBChat *cellfBChat = (BRCellfBChat *)[self.tbFbChat dequeueReusableCellWithIdentifier:@"BRCellfBChat"];
        cellfBChat.tb = tableView;
        BRRecordFbChat* record = [self.mArrFbChat objectAtIndex:[indexPath row]];
        cellfBChat.record = record;
        cellfBChat.indexPath = indexPath;
        cellfBChat.deletate = self;
        UIImage *backgroundImage = [UIImage imageNamed:@"table-row-background.png"];
        cellfBChat.backgroundView = [[UIImageView alloc] initWithImage:backgroundImage];
        return cellfBChat;
    }
    
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(tableView.tag == KTbFriendsOnLine){
        PRPLog(@"[self.mArrFriendOnLine count]: %d-[%@ , %@] \n ",
                [self.mArrFriendOnLine count],
                   NSStringFromClass([self class]),
                   NSStringFromSelector(_cmd));

        return [self.mArrFriendOnLine count];
    } else {
         return [self.mArrFbChat count];
    }
   
}

// Override to support conditional editing of the table view.
// This only needs to be implemented if you are going to be returning NO
// for some items. By default, all items are editable.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return YES if you want the specified item to be editable.
    if(tableView.tag == KTbFriendsOnLine){
        return NO;
    } else {
        BRRecordFbChat* record = [self.mArrFbChat objectAtIndex:[indexPath row]];
        NSString* type = record.type;
        
        if([type isEqualToString:@"chat"] 
           && ([self.fbIdRoomOwner isEqualToString:kSharedModel.fbId] 
               || [record.fbId isEqualToString:kSharedModel.fbId]))return YES;
        return NO;

    }
    
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (editingStyle == UITableViewCellEditingStyleInsert) {
        
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationTop];
    } else if (editingStyle == UITableViewCellEditingStyleDelete) {
        
        BRRecordFbChat* record = [self.mArrFbChat objectAtIndex:[indexPath row]];
        [self _delChat:record._id atRow:[indexPath row]];
        if(![record.uniquDataKey isEqualToString:@""]){
            [self.delegate FbChatRoomViewControllerDelegateDelRecordAWSS3:record];
        }
        
    }    
}

#pragma mark UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];

}
-(void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath{
    
//    BRRecordFbChat* record = [self.mArrFbChat objectAtIndex:[indexPath row]];
//    PRPLog(@"record.currentYoutubeKey: %@-[%@ , %@] \n ",
//           record.currentYoutubeKey,
//           
//           NSStringFromClass([self class]),
//           NSStringFromSelector(_cmd));
//    
//    
//    BRRecordFbChat* record = self.tappedRecord;
//    [self.delegate triggerOuterAction1:record];

}
#pragma mark BRCellfBChatDelegate method
-(void)BRCellfBChatDelegateCellTapped:(BRRecordFbChat *)record
{
    [self.delegate FbChatRoomViewControllerDelegateDelPreseintGrattiti:record];
}

-(void)_postChat:(NSString*)type
             msg:(NSString*)msg
            fbId:(NSString*)fbId 
          fbName:(NSString*)fbNmae
          roomId:(NSString*)roomId  
{    
    [self showHud:YES];
    __weak __block FbChatRoomViewController* weakSelf = self;    
    
    [kSharedModel postChat:type 
                       msg:msg 
              uniquDataKey:self.uniquDataKey 
                      fbId:fbId 
                    fbName:fbNmae 
                    roomId:roomId 
                 withBlock:^(NSDictionary* res){
                     
                     [weakSelf hideHud:YES];
                     if(nil != res 
                        && nil != res[@"error"]){
                         [weakSelf showMsg:res[@"error"] type:msgLevelError];
                         return;
                     }
                     BRRecordFbChat* recordAdded = (BRRecordFbChat*)res[@"doc"];                                          
                     [weakSelf.mArrFbChat insertObject:recordAdded atIndex:0];
                     //[weakSelf.tbFbChat reloadData];
                     NSIndexPath * indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
                     [weakSelf.tbFbChat insertRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
                    
                     NSDictionary* data = @{@"type": @"chat",
                                            @"msg": recordAdded.msg,
                                            @"fbId":  kSharedModel.fbId,
                                            @"fbName": kSharedModel.fbName,
                                            @"uniquDataKey": self.uniquDataKey,
                                            @"_id": recordAdded._id
                                            };
                     
                     [self playSoundEffect:@"add" soundId:_soundAdd];
                     [_bridge callHandler:@"JsSendMsgHandler" data:data responseCallback:^(id response) {
                         NSLog(@"JsSendMsgHandler responded: %@", response);
                         weakSelf.tfMsg.text = @"";
                         
                         [weakSelf.tfMsg resignFirstResponder];
                     }];
                 }];
}




- (void)_fetchChatByRoom:(NSString*)roomId 
               withPage:(NSNumber*)page{
    
    [self showHud:YES];
    __weak __block FbChatRoomViewController* weakSelf = (FbChatRoomViewController*)self;
    [kSharedModel fetchChatByRoom:roomId
                            withPage:page 
                           withBlock:^(NSDictionary* res) {
                                
                               [weakSelf hideHud:YES];
                               
                               if(nil != res 
                                  && nil != res[@"error"]){
                                   
                                   [weakSelf showMsg:res[@"error"] type:msgLevelError];
                                   return;
                               }
                               
                               NSMutableArray* mTempArr =(NSMutableArray*)res[@"mTempArr"];
                               NSMutableArray* mTempArrTestExist = [mTempArr mutableCopy];
                               [mTempArrTestExist enumerateObjectsUsingBlock:^(id object, NSUInteger index, BOOL *stop) {
                                   
                                   BRRecordFbChat* newRecord = (BRRecordFbChat*)object;
                                   if(![newRecord.uniquDataKey isEqualToString:@""]){
                                       NSString* localPathDir =  [Utils filePathInDocument:newRecord.uniquDataKey withSuffix:nil];
                                       BOOL isLocalPathExists = [weakSelf _chkDataPathLocalExist:localPathDir];
                                       if(!isLocalPathExists){
                                           [mTempArr removeObject:newRecord];
                                           [weakSelf.mArrDownloadQueue addObject:newRecord];
                                       }
                                   }

                               }];
                               
                               NSRange range = NSMakeRange(0, mTempArr.count); 
                               NSMutableIndexSet *indexes = [NSMutableIndexSet indexSetWithIndexesInRange:range];
                               [weakSelf.mArrFbChat insertObjects:mTempArr atIndexes:indexes];
                               
                               weakSelf.isLastPage = [((NSNumber*)res[@"isLastPage"]) boolValue];
                               weakSelf.page = res[@"page"];
                               
                               if(weakSelf.mArrFbChat.count > 0){
                                   
                                   PRPLog(@"self.mArrFbChat.count: %d-[%@ , %@]",
                                          weakSelf.mArrFbChat.count,
                                          NSStringFromClass([self class]),
                                          NSStringFromSelector(_cmd));
                                   [weakSelf.tbFbChat reloadData];
                               } 
                           }];
    
}
- (void)_fetchFriendInviteInRoom:(NSString*)roomId{
    
    [self showHud:YES];
    __weak __block FbChatRoomViewController* weakSelf = (FbChatRoomViewController*)self;
    [kSharedModel fetchFriendInviteInRoom:roomId
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
                            [weakSelf.mArrFriendOnLine insertObjects:mTempArr atIndexes:indexes];
                            
                            

                            if(weakSelf.isJoinFbChatRoom){
                                [weakSelf.mDicFriendOnLine enumerateKeysAndObjectsUsingBlock:^(id key, id object, BOOL *stop) {
                                    NSString* fbId = (NSString*)key;                                    
                                    NSMutableDictionary* friendInvited = [weakSelf _findInviteFriendsByFbId:fbId];
                                    
                                    friendInvited[@"isOnLine"] = @1;
                                    
                                }];
                                
                            }
                            
                            if(weakSelf.mArrFriendOnLine.count > 0){
                                PRPLog(@"self.mArrFriendOnLine.count: %d-[%@ , %@]",
                                       weakSelf.mArrFriendOnLine.count,
                                       NSStringFromClass([self class]),
                                       NSStringFromSelector(_cmd));
                                [weakSelf.tbFriendsOnLine reloadData];
                                
                            } 
                        }];
}


-(void)_delChat:(NSString*)_id
            atRow:(int) row
{
    
    [self showHud:YES];
    __weak __block FbChatRoomViewController* weakSelf = (FbChatRoomViewController*)self;
    [kSharedModel delChat:_id 
                      withBlock:^(NSDictionary* res){
                          
                          [weakSelf hideHud:YES];
                          if(nil != res 
                             && nil != res[@"error"]){
                              
                              [weakSelf showMsg:res[@"error"] type:msgLevelError];
                              return;
                          }
                          
                          BRRecordFbChat* record = [weakSelf.mArrFbChat objectAtIndex:row];
                          
                          [weakSelf.mArrFbChat removeObject:record];
                          [self playSoundEffect:@"del" soundId:_soundDel];
                          NSIndexPath * indexPath = [NSIndexPath indexPathForRow:row inSection:0];
                          [weakSelf.tbFbChat deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
                          [weakSelf _callJsDelMsgHandler:record._id];
                          
                      }];
    
}

-(BRRecordFbChat*)_findChatById:(NSString*)_id
{
    __block BRRecordFbChat* recordFound;
    [self.mArrFbChat enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop){
        BRRecordFbChat* record = (BRRecordFbChat*) obj;
        NSString* __id = record._id;
        
        if([__id isEqualToString:_id]) {
            stop = YES;
            recordFound = record;
        }
    }];
    
    return recordFound;
}

-(NSMutableDictionary*)_findInviteFriendsByFbId:(NSString*)fbId
{
    __block NSMutableDictionary* recordFound;
    [self.mArrFriendOnLine enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop){
        NSMutableDictionary* record = (NSMutableDictionary*) obj;
        NSString* fbId_ = record[@"fbId"];
        
        if([fbId_ isEqualToString:fbId]) {
            stop = YES;
            recordFound = record;
        }
    }];
    return recordFound;
}

-(BOOL)_chkDataPathLocalExist:(NSString*)localPath
{
    BOOL isLocalPathExist = NO;
    BOOL isDir;
    BOOL exists = [[NSFileManager defaultManager] fileExistsAtPath:localPath isDirectory:&isDir];
    if (exists) {
        /* file exists */
        if (isDir) {
            isLocalPathExist = YES;
            /* file is a directory */
            PRPLog(@"localPth exixt: %@ \n \
                   -[%@ , %@]",
                   localPath,
                   NSStringFromClass([self class]),
                   NSStringFromSelector(_cmd));
            
        }
    } else {
        PRPLog(@"localPth not exixt: \n \
               -[%@ , %@]",
               localPath,
               NSStringFromClass([self class]),
               NSStringFromSelector(_cmd));
    }
    return isLocalPathExist;
}

- (IBAction)toggleSound:(UISwitch*)sender {
    
    self.isEnableSound = sender.on;
    
    PRPLog(@"self.isEnableSound : %d \
           -[%@ , %@]",
           self.isEnableSound,
           NSStringFromClass([self class]),
           NSStringFromSelector(_cmd));  
}

- (void)playAnimation:(int)animationId {
    
    NSString* strAnimationId = [NSString stringWithFormat:@"%d", animationId];
    [self _callJsSendAnimationHandler:strAnimationId];
    
    [self _playAnimation:animationId 
                    playerFbId:kSharedModel.fbId];
}

- (void)_playAnimation:(int)animationId 
                  playerFbId:(NSString*)fbId {
    
    
    NSDictionary* animation = @{@"fbId": fbId, @"animationId": [NSNumber numberWithInt:animationId]};
    
    [self.mArrAnimationQueue addObject:animation];
    [self playAnimationInQueue];

}

- (void)playAnimationInQueue{
    
    NSDictionary* animation = [self.mArrAnimationQueue lastObject];
   
    if(nil == animation || self.isPlayingAnimation) return;
 
    NSString* fbId = animation[@"fbId"];
    NSNumber* animationNum = (NSNumber*)animation[@"animationId"];
    int animationId = [animationNum intValue];
    animationId++;
    NSString* spriteKey = [NSString stringWithFormat:@"animation%d", animationId];
    NSString* spriteName = kSharedModel.theme[spriteKey];
    FbChatRoomViewController* weakSelf = (FbChatRoomViewController*)self;
   
    NSMutableDictionary* friendOnLine = [self _findInviteFriendsByFbId:fbId];
    NSUInteger rowIndex = [self.mArrFriendOnLine indexOfObject:friendOnLine];
    NSIndexPath * indexPathOfPlayer = [NSIndexPath indexPathForRow:rowIndex inSection:0];
    
    if(fbId != kSharedModel.fbId){
        
        [self.tbFriendsOnLine scrollToRowAtIndexPath:indexPathOfPlayer atScrollPosition:UITableViewScrollPositionMiddle animated:YES];        
        int mod =  (rowIndex % 9);
        PRPLog(@"mod: %d -[%@ , %@]",
               mod,
               NSStringFromClass([self class]),
               NSStringFromSelector(_cmd));
    } else {
        
    }
    
    @autoreleasepool {
        UIImageView* imvFired =  [[UIImageView alloc] initWithImage:nil];
        [self.view addSubview:imvFired];
        
        NSString *url = [[NSString alloc] initWithFormat:@"https://graph.facebook.com/%@/picture",fbId];
        [Utils showImageAsync:imvFired  fromUrl:url cacheName:fbId];
        imvFired.alpha = 0.0f;
        imvFired.center = CGPointMake(350.0f, 1000.0f);
        imvFired.contentMode = UIViewContentModeCenter;
        // Fade out the view right away
        self.isPlayingAnimation = YES;
        NSString* soundFileName = [NSString stringWithFormat:@"explosion%d", animationId];
        [self playSoundEffect:soundFileName soundId:_soundExplosion];  
        [UIView animateWithDuration:2.0
                              delay: 0.0
                            options: UIViewAnimationOptionCurveEaseInOut
                         animations:^{
                             imvFired.alpha = 1.0f;
                             imvFired.center = self.view.center;
                             
                         }
                         completion:^(BOOL finished){
                             
                             double delayInSeconds = 6.4;
                             dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
                             dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                                 
                                 weakSelf.isPlayingAnimation = NO;
                                 [weakSelf.mArrAnimationQueue removeObject:animation];
                                 [weakSelf playAnimationInQueue];
                                 imvFired.animationImages = nil;
                             });                             
                             
                             imvFired.image = nil;
                             imvFired.alpha = 1.0f;
                             
                             if ([imvFired isAnimating]) {
                                 [imvFired stopAnimating];
                             }
                             
                             // This cool sprite sheet can be found at http://gushh.net/blog/free-game-sprites-explosion-2/ 
                             // I added numbers to this image to make testing and debuging easier.
                             //smoke_1_40_128.png
                             //explosion_4_39_128_debug
                             UIImage *spriteSheet = [UIImage imageNamed:spriteName];
                             NSArray *arrayWithSprites = [spriteSheet spritesWithSpriteSheetImage:spriteSheet 
                                                                                       spriteSize:CGSizeMake(128, 128)];
                             [imvFired setAnimationImages:arrayWithSprites];    
                             int indexOfImage = [imvFired.animationImages count];
                             PRPLog(@"Sprite images: %i-[%@ , %@]",
                                    indexOfImage,
                                    NSStringFromClass([self class]),
                                    NSStringFromSelector(_cmd));
                             
                             float animationDuration = [imvFired.animationImages count] * 0.100; // 100ms per frame
                             
                             [imvFired setAnimationRepeatCount:1];
                             [imvFired setAnimationDuration:animationDuration]; 
                             [imvFired startAnimating];
                             

                    
                         }];
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
            [self _fetchChatByRoom:self.room withPage:self.page];
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



@end
