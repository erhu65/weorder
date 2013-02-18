//
//  WOCellStore.h
//  weorder
//
//  Created by Peter2 on 2/17/13.
//  Copyright (c) 2013 peter. All rights reserved.
//

@class WORecordStorePic;
@interface WOCellStorePic : UITableViewCell

@property(nonatomic, strong) WORecordStorePic *record;
@property(nonatomic, strong) NSIndexPath* indexPath;

@property (weak, nonatomic) IBOutlet UILabel *lbPicDesc;
@property (weak, nonatomic) IBOutlet UIImageView *imvPic;

@end
