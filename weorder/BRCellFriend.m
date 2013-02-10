//
//  BRBirthdayTableViewCell.m
//  BirthdayReminder
//
//  Created by Nick Kuh on 27/07/2012.
//  Copyright (c) 2012 Nick Kuh. All rights reserved.
//

#import "BRCellFriend.h"
//#import "BRDBirthday.h"
#import "BRRecordFriend.h"
#import "BRStyleSheet.h"
//#import "BRDBirthdayImport.h"
#import "UIImageView+RemoteFile.h"

@implementation BRCellFriend

-(id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        //not get called
        
    }
    return self;
    
}

-(id)initWithCoder:(NSCoder *)aDecoder{
    self = [super initWithCoder:aDecoder];
    if(self){
        

    }
    return self;
}


-(void) setRecord:(BRRecordFriend *)record
{
    _record = record;
    self.nameLabel.text = _record.fbName;
//    self.lbCount.text = [NSString stringWithFormat:@"%d videos", [_record.count integerValue]];
    UIImage *backgroundImage = (self.indexPath.row == 0) ? [UIImage imageNamed:@"table-row-background.png"] : [UIImage imageNamed:@"table-row-icing-background.png"];
    self.backgroundView = [[UIImageView alloc] initWithImage:backgroundImage];
    //self.accessoryView = imageView;
    
    if ([record.strImgUrl length] > 0) {
        [self.iconView setImageWithFbThumb:record.fbId placeHolderImage:[UIImage imageNamed:kSharedModel.theme[@"Icon"]]];
    }
    else self.iconView.image = [UIImage imageNamed:kSharedModel.theme[@"Icon"]];
}

-(void) setIconView:(UIImageView *)iconView
{
    _iconView = iconView;
    if (_iconView) {
        [BRStyleSheet styleRoundCorneredView:_iconView];
    }
}

-(void) setNameLabel:(UILabel *)nameLabel
{
    _nameLabel = nameLabel;
    if (_nameLabel) {
        [BRStyleSheet styleLabel:_nameLabel withType:BRLabelTypeName];
    }
}

-(void) setLbCount:(UILabel *)lbCount
{
    _lbCount= lbCount;
    if (_lbCount) {
        [BRStyleSheet styleLabel:_lbCount withType:BRLabelTypeBirthdayDate];
    }
}



@end

