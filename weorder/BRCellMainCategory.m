//
//  BRCellMainCategory.m
//  BirthdayReminder
//
//  Created by Peter2 on 12/16/12.
//  Copyright (c) 2012 Nick Kuh. All rights reserved.
//

#import "BRCellMainCategory.h"
#import "BRRecordMainCategory.h"
#import "BRStyleSheet.h"
#import "UIImageView+RemoteFile.h"


@interface BRCellMainCategory ()


@end

@implementation BRCellMainCategory


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

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}


-(void)setRecord:(BRRecordMainCategory *)record{
    
    self.nameLb.text = record.name;
    self.descLb.text = record.desc;
    
    if(nil  !=  self.btnFavorite){
        self.btnFavorite.tag = [self.indexPath row];
        [self toggleBtnFavoriteTitle:record.isUserFavorite];
    }
    
    if(nil == _record 
       || _record != record){
        _record = record;
    }
}

-(void)toggleBtnFavoriteTitle:(BOOL)isFavorite{
    if(isFavorite) {
        
        [self.btnFavorite setImage:[UIImage imageNamed:kSharedModel.theme[@"favoriteRemove"]] forState:UIControlStateNormal];
    } else {
        [self.btnFavorite setImage:[UIImage imageNamed:kSharedModel.theme[@"favoriteAdd"]] forState:UIControlStateNormal];
    }
}
-(void) setNameLb:(UILabel *)nameLb
{
    _nameLb = nameLb;
    if (_nameLb) {
        [BRStyleSheet styleLabel:_nameLb withType:BRLabelTypeName];
    }
}

-(void) setDescLb:(UILabel *)descLb
{
    _descLb = descLb;
    if (_descLb) {
        [BRStyleSheet styleLabel:_descLb withType:BRLabelTypeBirthdayDate];
    }
}

- (IBAction)toggleFavorite:(id)sender {
    
    
    [self.tb selectRowAtIndexPath:self.indexPath animated:YES scrollPosition:UITableViewScrollPositionTop];
}


@end
