//
//  WOCellItemPicOptional.h
//  weorder
//
//  Created by Peter2 on 2/20/13.
//  Copyright (c) 2013 peter. All rights reserved.
//

@class WORecordItemPicOptional;

@interface WOCellItemPicOptional : UICollectionViewCell

@property(nonatomic, strong)WORecordItemPicOptional* record;
@property(nonatomic, strong)NSIndexPath* indexPath;

@property (weak, nonatomic) IBOutlet UIImageView *imvPIc;
@property (weak, nonatomic) IBOutlet UILabel *lbDesc;

@end
