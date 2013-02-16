//
//  WOCellStore.m
//  weorder
//
//  Created by Peter2 on 2/17/13.
//  Copyright (c) 2013 peter. All rights reserved.
//

#import "WOCellStorePic.h"

@implementation WOCellStorePic

- (id)initWithCoder:(NSCoder *)aDecoder {
	
	assert([aDecoder isKindOfClass:[NSCoder class]]);
	
	self = [super initWithCoder:aDecoder];
	
	if (self) {
		
		CGFloat k90DegreesClockwiseAngle = (CGFloat) (90 * M_PI / 180.0);
		
		self.transform = CGAffineTransformRotate(CGAffineTransformIdentity, k90DegreesClockwiseAngle);
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

@end
