//
//  BRCellMsg.m
//  BirthdayReminder
//
//  Created by Peter2 on 1/2/13.
//  Copyright (c) 2013 Nick Kuh. All rights reserved.
//

#import "BRCellMsg.h"
#import "BRRecordMsgBoard.h"
#import "BRStyleSheet.h"
#import "UIImageView+RemoteFile.h"


@implementation BRCellMsg
{

}


-(id)initWithCoder:(NSCoder *)aDecoder{
    self = [super initWithCoder:aDecoder];
    if(self){
        
        self.dateFormatter = [[NSDateFormatter alloc] init];
        [self.dateFormatter setDateFormat:@"yyyy-MM-dd 'at' HH:mm:ss"];
        
    }
    return self;
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) 
    {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(void)setRecord:(BRRecordMsgBoard *)record{
    
    self.lbFbUserName.text =  record.fbName;
    self.lbFbUserMsg.text = record.message;
    
    self.lbChatDatetime.text = [record.created_at description];
    
    if ([record.strImgUrl length] > 0) {
        [self.imvThumb setImageWithFbThumb:record.fbId placeHolderImage:[UIImage imageNamed:kSharedModel.theme[@"Icon"]]];
    }
    else self.imvThumb.image = [UIImage imageNamed:kSharedModel.theme[@"Icon"]];
    self.accessoryType = UITableViewCellAccessoryNone;
    
    if(nil == _record 
       || _record != record){
        _record = record;
    }
}



-(void) setLbFbUserName:(UILabel *)lbFbUserName
{
    _lbFbUserName = lbFbUserName;
    if (_lbFbUserName) {
        [BRStyleSheet styleLabel:_lbFbUserName withType:BRLabelTypeDaysUntilBirthdaySubText];
    }
}

-(void) setLbFbUserMsg:(UILabel *)lbFbUserMsg
{
    _lbFbUserMsg = lbFbUserMsg;
    if (_lbFbUserMsg) {
        [BRStyleSheet styleLabel:_lbFbUserMsg withType:BRLabelTypeLarge];
    }
}


-(void) setLbChatDatetime:(UILabel *)lbChatDatetime
{
    _lbChatDatetime = lbChatDatetime;
    if (_lbChatDatetime) {
        [BRStyleSheet styleLabel:_lbChatDatetime withType:BRLabelTypeDaysUntilBirthdaySubText];
    }
}

@end
