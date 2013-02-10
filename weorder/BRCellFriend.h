//
//  BRBirthdayTableViewCell.h
//  BirthdayReminder
//
//  Created by Nick Kuh on 27/07/2012.
//  Copyright (c) 2012 Nick Kuh. All rights reserved.
//


@class BRRecordFriend;
@interface BRCellFriend : UITableViewCell

@property(nonatomic, strong) BRRecordFriend *record;

@property(nonatomic, strong) NSIndexPath* indexPath;
@property BOOL isSelected;
@property (nonatomic, weak) IBOutlet UIImageView* iconView;
@property (nonatomic, weak) IBOutlet UILabel* nameLabel;
@property (nonatomic, weak) IBOutlet UILabel* lbCount;
@end
