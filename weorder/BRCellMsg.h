//
//  BRCellMsg.h
//  BirthdayReminder
//
//  Created by Peter2 on 1/2/13.
//  Copyright (c) 2013 Nick Kuh. All rights reserved.
//

@class BRRecordMsgBoard;

@interface BRCellMsg : UITableViewCell

@property(nonatomic, strong)BRRecordMsgBoard* record;
@property(nonatomic, strong)NSIndexPath* indexPath;


@property (weak, nonatomic) IBOutlet UILabel *lbFbUserName;
@property (weak, nonatomic) IBOutlet UILabel *lbFbUserMsg;
@property (weak, nonatomic) IBOutlet UILabel *lbChatDatetime;
@property(nonatomic, weak)IBOutlet UIImageView* imvThumb;

@property(nonatomic, strong) NSDateFormatter *dateFormatter;

@end
