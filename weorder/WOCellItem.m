//
//  WOCellItem.m
//  weorder
//
//  Created by Peter2 on 2/19/13.
//  Copyright (c) 2013 peter. All rights reserved.
//

#import "WOCellItem.h"
#import "WORecordItem.h"
#import "UIImageView+RemoteFile.h"
#import "QuartzCore/QuartzCore.h"

@implementation WOCellItem

-(id)initWithCoder:(NSCoder *)aDecoder{
    self = [super initWithCoder:aDecoder];
    if(self){
        
        
        
    }
    return self;
}


-(void)setRecord:(WORecordItem *)record{
    
    
    self.imvPIc.image = [UIImage imageNamed:@"Icon"];
    self.lbNmae.text = record.name;
    self.lbPrice.text = [NSString stringWithFormat:@"%i", [record.price integerValue]];
    
    self.layer.masksToBounds = NO;
    self.layer.borderColor = [UIColor grayColor].CGColor;
    self.layer.borderWidth = 7.0f;
    self.layer.contentsScale = [UIScreen mainScreen].scale;
    self.layer.shadowOpacity = 0.75f;
    self.layer.shadowRadius = 5.0f;
    self.layer.shadowOffset = CGSizeZero;
    self.layer.shadowPath = [UIBezierPath bezierPathWithRect:self.bounds].CGPath;
    self.layer.shouldRasterize = YES;

    self.backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:kSharedModel.theme[@"bgWood"]]];
    
    if (nil != record.awsS3ImgUrl) {
        [self.imvPIc setImageWithS3URL:record.awsS3ImgUrl placeHolderImage:[UIImage imageNamed:kSharedModel.theme[@"Icon"]] withUniqueKey:record.picKey];
    }
    else self.imvPIc.image = [UIImage imageNamed:kSharedModel.theme[@"Icon"]];
    
    if(nil == _record 
       || _record != record){
        _record = record;
    }
}

-(void) setLbNmae:(UILabel *)lbNmae
{
    _lbNmae = lbNmae;
    if (_lbNmae) {
        [BRStyleSheet styleLabel:_lbNmae withType:BRLabelTypeName];
    }
}

-(void) setLbPrice:(UILabel *)lbPrice
{
    _lbPrice = lbPrice;
    if (_lbPrice) {
        [BRStyleSheet styleLabel:_lbPrice withType:BRLabelTypeDaysUntilBirthdaySubText];
    }
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
