//
//  WOCellNotice.m
//  weorder
//
//  Created by peter on 2/13/13.
//  Copyright (c) 2013 peter. All rights reserved.
//

#import "WOCellNotice.h"
#import "WORecordNotice.h"

#import "BRStyleSheet.h"
#import "UIImageView+RemoteFile.h"

@implementation WOCellNotice

-(id)initWithCoder:(NSCoder *)aDecoder{
    self = [super initWithCoder:aDecoder];
    if(self){
        
        
    }
    return self;
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        self.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    return self;
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}

-(void)setRecord:(WORecordNotice *)record{
    
    self.lbMsg.text =  record.msg;
    self.lbFbName.text = record.fbName;
    self.lbDatetime.text = [record.created_at description];

    
    if ([record.strImgUrl length] > 0) {
        [self.imvFb setImageWithFbThumb:record.fbId placeHolderImage:[UIImage imageNamed:kSharedModel.theme[@"Icon"]]];
    }
    else self.imvFb.image = [UIImage imageNamed:kSharedModel.theme[@"Icon"]];
    
    if(record.isReceiverRead){
        self.btnRead.titleLabel.text = kSharedModel.lang[@"read"];
        self.btnRead.hidden = YES;
    } else {
        self.btnRead.titleLabel.text = kSharedModel.lang[@"unread"];
        self.btnRead.hidden = NO;
    }
    
    if(nil == _record
       || _record != record){
        _record = record;
    }
}
-(void) setLbMsg:(UILabel *)lbMsg
{
    _lbMsg = lbMsg;
    if (_lbMsg) {
        [BRStyleSheet styleLabel:_lbMsg withType:BRLabelTypeDaysUntilBirthdaySubText];
    }
}

-(void) setLbFbName:(UILabel *)lbFbName
{
    _lbFbName = lbFbName;
    if (_lbFbName) {
        [BRStyleSheet styleLabel:_lbFbName withType:BRLabelTypeDaysUntilBirthdaySubText];
    }
}


-(void) setLbDatetime:(UILabel *)lbDatetime
{
    _lbDatetime = lbDatetime;
    if (_lbDatetime) {
        [BRStyleSheet styleLabel:_lbDatetime withType:BRLabelTypeDaysUntilBirthdaySubText];
    }
}

- (IBAction)readNotice:(id)sender {
    
    UIButton* btnRead =( UIButton*) sender;
    btnRead.hidden = YES;
    [self.delegate WOCellNoticeDelegateWillReadNotice:self.record withIndexPath:self.indexPath];
}


@end
