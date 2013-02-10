//
//  WWTagEditViewController.h
//  wework
//
//  Created by Peter2 on 2/5/13.
//  Copyright (c) 2013 Peter2. All rights reserved.
//

#import "BRCoreViewController.h"

typedef enum tagEditType {
    tagEditTypeAdd = 0,
    tagEditTypeEdit = 1    
} tagEditType;

@class WWRecordTag;

@interface WWTagEditViewController : BRCoreViewController

@property(nonatomic, strong)WWRecordTag* recordEdit;
@property(nonatomic, assign)tagEditType type;
@property(nonatomic, strong) NSIndexPath* indexPathEdit;
@end
