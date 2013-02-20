//
//  WOItemPicOptionalViewController.m
//  weorder
//
//  Created by Peter2 on 2/20/13.
//  Copyright (c) 2013 peter. All rights reserved.
//

#import "WOItemPicOptionalViewController.h"
#import "WOEditItemPicOptioinalViewController.h"
#import "WORecordItem.h"
#import "WORecordItemPicOptional.h"
#import "WOCellItemPicOptional.h"
#import "LineLayout.h"

@interface WOItemPicOptionalViewController ()

<UICollectionViewDataSource, UICollectionViewDelegate,
UIScrollViewDelegate>
{
    
    BOOL addItemsTrigger;
}
@property(nonatomic, strong)NSNumber* page;
@property(nonatomic, strong)NSNumber* isLastPage;
@property(nonatomic, strong)NSMutableArray* docs;
@property(nonatomic, strong)NSIndexPath * indexPathTmp;
@property (weak, nonatomic) IBOutlet UICollectionView *cv;

@property (weak, nonatomic) IBOutlet UILabel *lbItemPicOptional;

@end

@implementation WOItemPicOptionalViewController

-(id)initWithCoder:(NSCoder *)aDecoder{
    
    self = [super initWithCoder:aDecoder];
    if(self){
        self.page = @0;
        self.isLastPage = @1;
    }
    return self;
}

-(NSMutableArray*)docs{
    
    if(nil == _docs){
        _docs = [[NSMutableArray alloc] init];
    }
    return _docs;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    self.lbItemPicOptional.text = kSharedModel.lang[@"ItemPicOptional"];
    [BRStyleSheet styleLabel:self.lbItemPicOptional withType:BRLabelTypeName];
    
    PRPLog(@"self.item._id: %@-[%@ , %@]",
           self.item._id,
           NSStringFromClass([self class]),
           NSStringFromSelector(_cmd));
    self.cv.backgroundView =  [[UIImageView alloc] initWithImage:[UIImage imageNamed:kSharedModel.theme[@"bgWood"]]];
   
    [self _fetchItemPicOptionalsByItem:self.item];
}

- (void)_fetchItemPicOptionalsByItem:(WORecordItem*)reocrd{
     [self showHud:YES];
    __block __weak WOItemPicOptionalViewController* weakSelf = (WOItemPicOptionalViewController*)self;
    [kSharedModel fetchItemPicOptionalsByItem:reocrd 
                                       byPage:self.page
                                    withBlock:^(NSDictionary* res) { 
                                        
                                        NSString* error  = res[@"error"];
                                        if(nil != error){
                                            
                                            [weakSelf showMsg:error type:msgLevelError];
                                            return;
                                        }
                                        
                                        NSMutableArray* docs =(NSMutableArray*)res[@"docs"];
                                        NSRange range = NSMakeRange(0, docs.count); 
                                        NSMutableIndexSet *indexes = [NSMutableIndexSet indexSetWithIndexesInRange:range];
                                        [weakSelf.docs insertObjects:docs atIndexes:indexes]; 
                                        weakSelf.isLastPage = (NSNumber*)res[@"isLastPage"];
                                        weakSelf.page = (NSNumber*) res[@"page"];
                                        if(weakSelf.docs.count> 0){
                                            [weakSelf.cv reloadData];
                                        }
                                         [weakSelf hideHud:YES];
                                    }];
    
}

- (BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender
{
    //	if ([identifier isEqualToString:@"DoneEdit"])
    //	{
    //		if ([self.textField.text length] > 0)
    //		{
    //			int value = [self.textField.text intValue];
    //			if (value >= 0 && value <= 100)
    //				return YES;
    //		}
    //        
    //		[[[UIAlertView alloc]
    //          initWithTitle:nil
    //          message:@"Value must be between 0 and 100."
    //          delegate:nil
    //          cancelButtonTitle:@"OK"
    //          otherButtonTitles:nil]
    //         show];
    //		return NO;
    //	}
	return YES;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    NSString *identifier = segue.identifier;
    __block __weak WOItemPicOptionalViewController* weakSelf = (WOItemPicOptionalViewController*)self;  
    if ([identifier isEqualToString:@"segueAddItempicOptional"]) {
        WOEditItemPicOptioinalViewController *destinationVC = (WOEditItemPicOptioinalViewController *) segue.destinationViewController;
        destinationVC.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
        destinationVC.item = self.item;
        destinationVC.complectionBlock = ^(NSDictionary* res){ 
            
            PRPLog(@"after add new itemPicOptional res: %@-[%@ , %@]",
                   res,
                   NSStringFromClass([self class]),
                   NSStringFromSelector(_cmd));
            if(nil !=  res){
                WORecordItemPicOptional* record = res[@"record"];
                int insertRow = weakSelf.docs.count;
                [weakSelf.docs addObject:record];
                NSIndexPath* insertedIndexPath = [NSIndexPath indexPathForRow:insertRow inSection:0];
                NSArray* arrOfIndexPath = @[insertedIndexPath];
                [weakSelf.cv insertItemsAtIndexPaths:arrOfIndexPath];
                [weakSelf.cv scrollToItemAtIndexPath:insertedIndexPath atScrollPosition:UICollectionViewScrollPositionRight animated:YES];
            }
            
            [weakSelf dismissViewControllerAnimated:YES completion:nil];
            
        };        
    } else if([identifier isEqualToString:@"segueEditItempicOptional"]) {
        
        
        WOCellItemPicOptional* selectedCell =(WOCellItemPicOptional*) sender;
        NSIndexPath* slectedIndexPath = [self.cv indexPathForCell:selectedCell];
        WORecordItemPicOptional *record = self.docs[slectedIndexPath.row];
        
        WOEditItemPicOptioinalViewController *destinationVC = (WOEditItemPicOptioinalViewController *) segue.destinationViewController;
        destinationVC.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
        destinationVC.recordToEdit = record;
        
        destinationVC.complectionBlock = ^(NSDictionary* res){ 
            
            PRPLog(@"after upd old itemPicOptional res: %@-[%@ , %@]",
                   res,
                   NSStringFromClass([self class]),
                   NSStringFromSelector(_cmd));
            if(nil !=  res){
                NSString* type = res[@"type"];
                
                //do update
                if(nil != res[@"record"]){
                    WORecordItemPicOptional* recordUpdated = res[@"record"];
                    self.docs[slectedIndexPath.row] = recordUpdated;
                    NSArray* arrOfIndexPath = @[slectedIndexPath];
                    [weakSelf.cv reloadItemsAtIndexPaths:arrOfIndexPath];

                } else if (nil != type 
                           && [type isEqualToString:@"del"]){
                    //do remove
                    [self.docs removeObject:record];
                    NSArray* arrOfIndexPath = @[slectedIndexPath];
                    [weakSelf.cv deleteItemsAtIndexPaths:arrOfIndexPath];
                    
                }
                
            }
            
            [weakSelf dismissViewControllerAnimated:YES completion:nil];
            
        };        
    }
}


#pragma mark UICollectionViewDataSource, UICollectionViewDelegate
-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    return 1;
}
-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    
    return self.docs.count;
}
-(UICollectionViewCell*)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    
    static NSString* cellIdentifier = @"WOCellItemPicOptional";
    
    WOCellItemPicOptional* cell = [collectionView dequeueReusableCellWithReuseIdentifier:cellIdentifier forIndexPath:indexPath];
    
    WORecordItemPicOptional* record = self.docs[indexPath.row];
    cell.record = record;
    cell.indexPath = indexPath;
    
    return cell;
}
-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    
//    WORecordItemPicOptional* record = self.docs[indexPath.row];
//    PRPLog(@"selcte WORecordItemPicOptional._id: %@-[%@ , %@]",
//           record._id,
//           NSStringFromClass([self class]),
//           NSStringFromSelector(_cmd));
}

#pragma mark UIScrollViewDelegate
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
	// Detect if the trigger has been set, if so add new items
	if (addItemsTrigger)
	{
        
        BOOL isLastPage = [self.isLastPage boolValue];
        if(!isLastPage){
            int page_ = [self.page intValue];
            page_++;
            self.page = [[NSNumber alloc] initWithInt:page_];
            [self _fetchItemPicOptionalsByItem:self.item];
        }
	}
	// Reset the trigger
	addItemsTrigger = NO;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
	// Trigger the offset if the user has pulled back more than 50 pixels
    PRPLog(@"scrollView.contentOffset.x: %f-[%@ , %@]",
           scrollView.contentOffset.x,
           NSStringFromClass([self class]),
           NSStringFromSelector(_cmd));
    
	if (scrollView.contentOffset.x < -70)
		addItemsTrigger = YES;
}


@end
