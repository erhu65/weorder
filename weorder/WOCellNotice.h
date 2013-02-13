//
//  WOCellNotice.h
//  weorder
//
//  Created by peter on 2/13/13.
//  Copyright (c) 2013 peter. All rights reserved.
//


@class WORecordNotice;

@protocol WOCellNoticeDelegate <NSObject>

@required
-(void)WOCellNoticeDelegateWillReadNotice:(WORecordNotice*)record withIndexPath:(NSIndexPath*)indexPath;


@end

@interface WOCellNotice : UITableViewCell

@property(nonatomic, strong)WORecordNotice* record;
@property(nonatomic, strong)NSIndexPath* indexPath;

@property (weak, nonatomic) IBOutlet UILabel *lbMsg;
@property (weak, nonatomic) IBOutlet UILabel *lbFbName;
@property (weak, nonatomic) IBOutlet UIImageView *imvFb;
@property (weak, nonatomic) IBOutlet UILabel *lbDatetime;
@property (weak, nonatomic) IBOutlet UIButton *btnRead;


@property(nonatomic, weak) id <WOCellNoticeDelegate> delegate;

@end
