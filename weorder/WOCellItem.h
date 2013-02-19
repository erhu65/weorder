//
//  WOCellItem.h
//  weorder
//
//  Created by Peter2 on 2/19/13.
//  Copyright (c) 2013 peter. All rights reserved.
//

@class WORecordItem;

@interface WOCellItem : UICollectionViewCell

@property(nonatomic, strong)WORecordItem* record;
@property(nonatomic, strong)NSIndexPath* indexPath;

@property (weak, nonatomic) IBOutlet UIImageView *imvPIc;
@property (weak, nonatomic) IBOutlet UILabel *lbNmae;
@property (weak, nonatomic) IBOutlet UILabel *lbPrice;

@end
