//
//  WWCellMyRoom.m
//  wework
//
//  Created by Peter2 on 1/28/13.
//  Copyright (c) 2013 Peter2. All rights reserved.
//

#import "WWCellMyRoom.h"
#import "WWRecordMyRoom.h"
#import "BRStyleSheet.h"
#import "UIImageView+RemoteFile.h"


@implementation WWCellMyRoom
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
    }
    return self;
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}

-(void)setRecord:(WWRecordMyRoom *)record{
    
    self.lbRoomName.text =  record.roomName;
    self.lbChatDatetime.text = [record.created_at description];
    self.lbFbName.text = record.fbName;
    //self.btnInvite.titleLabel.text = [record.invitedCount stringValue];
    self.lbInviteCount.text =  [record.invitedCount stringValue];
    
    if ([record.strImgUrl length] > 0) {
        [self.imvFb setImageWithFbThumb:record.fbId placeHolderImage:[UIImage imageNamed:kSharedModel.theme[@"Icon-72"]]];
    }
    else self.imvFb.image = [UIImage imageNamed:kSharedModel.theme[@"Icon-72"]];
    
    //self.accessoryType = UITableViewCellAccessoryNone;
  
    if(nil == _record 
       || _record != record){
        _record = record;
    }
}
-(void) setLbRoomName:(UILabel *)lbRoomName
{
    _lbRoomName = lbRoomName;
    if (_lbRoomName) {
        [BRStyleSheet styleLabel:_lbRoomName withType:BRLabelTypeLarge];
    }
}

-(void) setLbFbName:(UILabel *)lbFbName
{
    _lbFbName = lbFbName;
    if (_lbFbName) {
        [BRStyleSheet styleLabel:_lbFbName withType:BRLabelTypeDaysUntilBirthdaySubText];
    }
}


-(void) setLbChatDatetime:(UILabel *)lbChatDatetime
{
    _lbChatDatetime = lbChatDatetime;
    if (_lbChatDatetime) {
        [BRStyleSheet styleLabel:_lbChatDatetime withType:BRLabelTypeDaysUntilBirthdaySubText];
    }
}

- (IBAction)_prepareToChange:(id)sender {

    [self.delegate WWCellMyRoomDelegateDidEditMode:self.record withIndexPath:self.indexPath];
}


- (IBAction)_prepareChooseTags:(id)sender {
    
    [self.delegate WWCellMyRoomDelegateWillChooseTags:self.record withIndexPath:self.indexPath];
}

@end
