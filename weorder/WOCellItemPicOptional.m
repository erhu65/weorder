//
//  WOCellItemPicOptional.m
//  weorder
//
//  Created by Peter2 on 2/20/13.
//  Copyright (c) 2013 peter. All rights reserved.
//

#import "WOCellItemPicOptional.h"
#import "WORecordItemPicOptional.h"

#import "UIImageView+RemoteFile.h"


@implementation WOCellItemPicOptional

-(id)initWithCoder:(NSCoder *)aDecoder{
    self = [super initWithCoder:aDecoder];
    if(self){
        
        
        
    }
    return self;
}


-(void)setRecord:(WORecordItemPicOptional *)record{
    
    
    self.imvPIc.image = [UIImage imageNamed:@"Icon"];
    self.lbDesc.text = record.desc;
    
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

-(void) setLbDesc:(UILabel *)lbDesc
{
    _lbDesc = lbDesc;
    if (_lbDesc) {
        [BRStyleSheet styleLabel:_lbDesc withType:BRLabelTypeDaysUntilBirthdaySubText];
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
