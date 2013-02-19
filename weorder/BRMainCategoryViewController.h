//
//  BRMainCategoryViewController.h
//  BirthdayReminder
//
//  Created by Peter2 on 12/16/12.
//  Copyright (c) 2012 Nick Kuh. All rights reserved.
//

#import "BRCoreViewController.h"


typedef void(^BRMainCategoryViewControllerCompletionBlock)(NSDictionary* res);

typedef enum mainCategoryFilterMode {
    mainCategoryFilterModeAll = 0,
    mainCategoryFilterModeFavorite = 1,
    mainCategoryFilterModeJustForSelection = 2
} mainCategoryFilterMode;


@interface BRMainCategoryViewController : BRCoreViewController

@property(nonatomic, assign) mainCategoryFilterMode mode;

@property(nonatomic, copy)BRMainCategoryViewControllerCompletionBlock complectionBlock;

@end
