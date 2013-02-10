//
//  BRCellfBChat.h
//  BirthdayReminder
//
//  Created by Peter2 on 1/1/13.
//  Copyright (c) 2013 Nick Kuh. All rights reserved.
//

@class BRRecordFbChat;

@protocol BRCellfBChatDelegate <NSObject>

@required
-(void)BRCellfBChatDelegateCellTapped:(BRRecordFbChat*)record;

@end

@interface BRCellfBChat : UITableViewCell

@property(nonatomic, weak)UITableView* tb;
@property(nonatomic, strong)BRRecordFbChat* record;
@property(nonatomic, strong)NSIndexPath* indexPath;

@property (weak, nonatomic) IBOutlet UILabel *lbFbUserName;
@property (weak, nonatomic) IBOutlet UILabel *lbFbUserMsg;
@property (weak, nonatomic) IBOutlet UILabel *lbVideoName;
@property (weak, nonatomic) IBOutlet UILabel *lbChatDatetime;
@property(nonatomic, weak)IBOutlet UIImageView* imvThumb;
@property(nonatomic, strong) NSDateFormatter *dateFormatter;

@property (nonatomic, weak)id<BRCellfBChatDelegate>deletate;
@end
