//
//  FbMsgBaordViewController.h
//  BirthdayReminder
//
//  Created by Peter2 on 1/2/13.
//  Copyright (c) 2013 Nick Kuh. All rights reserved.
//

#import "BRCoreViewController.h"


@protocol FbMsgBaordViewControllerDelegate <NSObject>

@optional
-(void)FbMsgBaordViewGetOutterInfo;
-(BOOL)FbMsgBaordViewToggleOutterUI;
-(void)FbMsgBaordViewTriggerOuterGoBack;
-(void)FbMsgBaordViewTriggerOuterAction1:(id)record;
@end
@interface FbMsgBaordViewController : BRCoreViewController


@property(nonatomic, assign)BOOL isVideoWatchModel;
@property(nonatomic, assign)BOOL isShowBarBtnBack;
@property(nonatomic, strong)NSString* videoSelectedUid;
@property(nonatomic, strong)BRRecordVideo* currentSelectedVideo;
@property(nonatomic) double currentSelectedVideoPlayBackTime;


@property(nonatomic, strong)NSString* videoId;
@property(nonatomic, strong)NSNumber* page;
@property(nonatomic)BOOL isLastPage;


@property(nonatomic, weak) id<FbMsgBaordViewControllerDelegate> delegate;

@end
