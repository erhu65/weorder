//
//  BRCellMainCategory.h
//  BirthdayReminder
//
//  Created by Peter2 on 12/16/12.
//  Copyright (c) 2012 Nick Kuh. All rights reserved.
//

@class BRRecordMainCategory;



@interface BRCellMainCategory : UITableViewCell

@property (weak, nonatomic) IBOutlet UIButton *btnFavorite;
@property(nonatomic, weak) UITableView* tb;
@property(nonatomic, strong)BRRecordMainCategory* record;
@property(nonatomic, strong)NSIndexPath* indexPath;
@property(nonatomic, weak)IBOutlet UILabel* nameLb;
@property(nonatomic, weak)IBOutlet UILabel* descLb;

-(void)toggleBtnFavoriteTitle:(BOOL)isFavorite;
@end


