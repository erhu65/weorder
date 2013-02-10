//
//  WWCellMyRoom.h
//  wework
//
//  Created by Peter2 on 1/28/13.
//  Copyright (c) 2013 Peter2. All rights reserved.
//

@class WWRecordMyRoom;

@protocol WWCellMyRoomDelegate <NSObject>

-(void)WWCellMyRoomDelegateDidEditMode:(WWRecordMyRoom*)record withIndexPath:(NSIndexPath*)indexPath;

-(void)WWCellMyRoomDelegateWillChooseFriends:(WWRecordMyRoom*)record withIndexPath:(NSIndexPath*)indexPath;

-(void)WWCellMyRoomDelegateWillChooseTags:(WWRecordMyRoom*)record withIndexPath:(NSIndexPath*)indexPath;

@end

@interface WWCellMyRoom : UITableViewCell


@property(nonatomic, strong)WWRecordMyRoom* record;
@property(nonatomic, strong)NSIndexPath* indexPath;


@property (weak, nonatomic) IBOutlet UILabel *lbRoomName;
@property (weak, nonatomic) IBOutlet UILabel *lbFbName;

@property (weak, nonatomic) IBOutlet UIImageView *imvFb;
@property (weak, nonatomic) IBOutlet UILabel *lbChatDatetime;

@property (weak, nonatomic) IBOutlet UIButton *btnInvite;
@property (weak, nonatomic) IBOutlet UILabel *lbInviteCount;

@property (weak, nonatomic) IBOutlet UIButton *btnEdit;

@property(nonatomic, weak) id <WWCellMyRoomDelegate> delegate;

@end
