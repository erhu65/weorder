//
//  FbChatRoomViewController.h
//  BirthdayReminder
//
//  Created by Peter2 on 12/28/12.
//  Copyright (c) 2012 Nick Kuh. All rights reserved.
//

#import "BRCoreViewController.h"
@class BRRecordFbChat;

@protocol FbChatRoomViewControllerDelegate <NSObject>

@optional

-(BOOL)FbChatRoomViewControllerDelegateToggleOutterUI;
-(void)FbChatRoomViewControllerDelegateTriggerOuterGoBack;
-(void)FbChatRoomViewControllerDelegateTriggerOuterAction1:(id)record;
-(void)FbChatRoomViewControllerDelegateTriggerOuterAction2;
-(void)FbChatRoomViewControllerDelegateProcessFileUpload;
-(void)FbChatRoomViewControllerDelegateProcessFileDownloadUnZip:
(BRRecordFbChat*)record;
-(void)FbChatRoomViewControllerDelegateDelRecord:(BRRecordFbChat*)record;
-(void)FbChatRoomViewControllerDelegateDelRecordAWSS3:(BRRecordFbChat*)record;
-(void)FbChatRoomViewControllerDelegateDelPreseintGrattiti:(BRRecordFbChat*)record;
-(void)FbChatRoomViewControllerDelegateGetOutterInfo;

@end


@interface FbChatRoomViewController : BRCoreViewController
@property (nonatomic) BOOL isJoinFbChatRoom;
@property(nonatomic, strong)NSString* room;
@property(nonatomic, strong) NSString* fbIdRoomOwner;


@property(nonatomic) BOOL isLeaving;
@property(nonatomic, strong) NSString* uniquDataKey;

@property(nonatomic, strong) NSMutableArray *mArrDownloadQueue;

@property(strong, nonatomic)NSMutableArray* mArrAnimationQueue;
@property(nonatomic, assign)BOOL isPlayingAnimation;


@property (weak, nonatomic) IBOutlet UIImageView *imvGratiffiThumb;

@property(nonatomic, weak) id<FbChatRoomViewControllerDelegate> delegate;

- (IBAction)joinRoomWithFBAccount:(UIBarButtonItem*)sender;
- (void)playAnimation:(int)animationId;
- (void)playAnimationInQueue;


-(void) leaveRoom;
-(void) toggleChatRoomEdit:(BOOL)isEditing;
-(void)postChatAfterUploadFile;
-(void)addNewChatFromOthers:(BRRecordFbChat*)chat;

@end
