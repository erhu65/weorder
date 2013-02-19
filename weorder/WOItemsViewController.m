//
//  WOItemsViewController.m
//  weorder
//
//  Created by Peter2 on 2/19/13.
//  Copyright (c) 2013 peter. All rights reserved.
//

#import "WOItemsViewController.h"
#import "WOEditItemViewController.h"
#import "WORecordItem.h"
#import "WOCellItem.h"


@interface WOItemsViewController ()
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

@end

@implementation WOItemsViewController

-(id)initWithCoder:(NSCoder *)aDecoder{
    
    self = [super initWithCoder:aDecoder];
    if(self){
        self.page = @0;
        self.isLastPage = @0;
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
	
    self.cv.backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:kSharedModel.theme[@"bgWood"]]];
    
    if(self.mode == WOItemsViewControllerModeBackend){
        //my itmes list
        self.title = kSharedModel.lang[@"myStroeItems"];
        
    } else {
        //someone else's store items list
        //self.title = kSharedModel.lang[@"myStroeItems"];
        
    }
    [self _fetchItemsByStoreId:self.storeId];
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

-(void)_fetchItemsByStoreId:(NSString*)storeId{
    
    __block __weak WOItemsViewController* weakSelf = (WOItemsViewController*)self;
    
    [kSharedModel fetchItemsByStoreId:storeId 
                               byPage:self.page
                            withBlock:^(NSDictionary* res) {

        NSString* error  = res[@"error"];
        if(nil != error){
            [weakSelf showMsg:error type:msgLevelError];
            return;
        }                       
        PRPLog(@"after successfully _fetchItemsByStoreId res: %@-[%@ , %@]",
               res,
               NSStringFromClass([self class]),
               NSStringFromSelector(_cmd));
                                NSMutableArray* docs =(NSMutableArray*)res[@"docs"];
                                NSRange range = NSMakeRange(weakSelf.docs.count, docs.count); 
                                NSMutableIndexSet *indexes = [NSMutableIndexSet indexSetWithIndexesInRange:range];
                                [weakSelf.docs insertObjects:docs atIndexes:indexes];

                                weakSelf.isLastPage = (NSNumber*)res[@"isLastPage"];
                                weakSelf.page = (NSNumber*) res[@"page"];
                                if(weakSelf.docs.count> 0){
                                    [weakSelf.cv reloadData];
                                }
        
    }];
    
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    NSString *identifier = segue.identifier;
    __block __weak WOItemsViewController* weakSelf = (WOItemsViewController*)self;  
    if ([identifier isEqualToString:@"segueAddItem"]) {
        WOEditItemViewController *destinationVC = (WOEditItemViewController *) segue.destinationViewController;
        destinationVC.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
        destinationVC.storeId = self.storeId;
        destinationVC.complectionBlock = ^(NSDictionary* res){ 
            
            PRPLog(@"after add new item res: %@-[%@ , %@]",
                   res,
                   NSStringFromClass([self class]),
                   NSStringFromSelector(_cmd));
            //[weakSelf _fetchStorePics];
             [weakSelf dismissViewControllerAnimated:YES completion:nil];
            
        };        
    } else if([identifier isEqualToString:@"segueEditItem"]) {
        
        WORecordItem *record = (WORecordItem *)sender;
        WOEditItemViewController *destinationVC = (WOEditItemViewController *) segue.destinationViewController;
        destinationVC.modalTransitionStyle = UIModalTransitionStylePartialCurl;
        destinationVC.recordToEdit = record;
        
        destinationVC.complectionBlock = ^(NSDictionary* res){ 
            
            //[weakSelf _fetchStorePics];
            
            PRPLog(@"after upd old item res: %@-[%@ , %@]",
                   res,
                   NSStringFromClass([self class]),
                   NSStringFromSelector(_cmd));
            
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
    
    static NSString* cellIdentifier = @"WOCellItem";
    
    WOCellItem* cell = [collectionView dequeueReusableCellWithReuseIdentifier:cellIdentifier forIndexPath:indexPath];
    
    WORecordItem* record = self.docs[indexPath.row];
    cell.record = record;
    cell.indexPath = indexPath;
    
    return cell;
}
-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    
    WORecordItem* record = self.docs[indexPath.row];
    
    PRPLog(@"selcte WORecordItem._id: %@-[%@ , %@]",
           record._id,
           NSStringFromClass([self class]),
           NSStringFromSelector(_cmd));
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
            [self _fetchItemsByStoreId:self.storeId];
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
    
	if (scrollView.contentOffset.x > 100)
		addItemsTrigger = YES;
}



@end
