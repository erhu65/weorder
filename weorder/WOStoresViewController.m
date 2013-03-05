//
//  WOStoresViewController.m
//  weorder
//
//  Created by Peter2 on 2/26/13.
//  Copyright (c) 2013 peter. All rights reserved.
//

//center of Taichung city , for simulator..
#define centerLat 24.1369
#define centerLong 120.6786


#define KWOLIstByMapViewControllerPickerViewRadins 123401
#define KWOLIstByMapViewControllerActionSheetRadins 123402

#define KWOLIstByMapViewControllerPickerViewType 123403
#define KWOLIstByMapViewControllerActionSheetType 123404


#import "WOStoresViewController.h"
#import "BRRecordMainCategory.h"
#import "Hotspot.h"
#import "WORecordStore.h"
#import "MyAnnotationView.h"
#import "Utils.h"



@interface WOStoresViewController ()
<CLLocationManagerDelegate,
UIPickerViewDelegate, UIPickerViewDataSource, 
UIActionSheetDelegate>

@property(nonatomic, strong) CLLocation* location;

@property (weak, nonatomic) IBOutlet UIBarButtonItem *barBtnRadian;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *barBtnType;


@property (strong, nonatomic) NSMutableArray* annotations;

@property (strong, nonatomic) NSString * mainCategoryId;
@property (nonatomic, assign) NSInteger searchRadins;

@property (nonatomic, assign) NSInteger searchMainCategoryIndex;
@property (nonatomic, strong) NSMutableArray* docsMainCategory;

@end

@implementation WOStoresViewController
{
    CLLocationManager *locationManager;
}

-(NSMutableArray*)docsMainCategory{
    if(nil == _docsMainCategory){
        _docsMainCategory = [[NSMutableArray alloc] init];
    }
    return _docsMainCategory;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.searchRadins = 0;
    self.title = kSharedModel.lang[@"storeByMap"];
    
    self.barBtnRadian.title =  kSharedModel.lang[@"radian"];
    self.barBtnType.title =  kSharedModel.lang[@"type"];
    
    locationManager = [[CLLocationManager alloc] init];
    locationManager.delegate = self;
    locationManager.distanceFilter = kCLDistanceFilterNone;
    locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    
    if(nil != self.location){
        
        [self _fetchStoresByLocatioin:self.location 
                       mainCategoryId:self.mainCategoryId
                        rangeInMeters:self.searchRadins 
                                 fbId:kSharedModel.fbId];
    } else {
        [locationManager startUpdatingLocation];
    }

    __weak __block WOStoresViewController *weakSelf =(WOStoresViewController *) self;
    [[BRDModel sharedInstance] fetchMainCategoriesWithPage:@(-1) WithBlock:^(NSDictionary* res){
        [weakSelf hideHud:YES];
        NSString* errMsg = res[@"error"];
        
        NSMutableArray* mTempArr =(NSMutableArray*)res[@"docs"];
        NSRange range = NSMakeRange(0, mTempArr.count); 
        NSMutableIndexSet *indexes = [NSMutableIndexSet indexSetWithIndexesInRange:range];
        [weakSelf.docsMainCategory insertObjects:res[@"docs"] atIndexes:indexes];
        
        weakSelf.searchMainCategoryIndex = weakSelf.docsMainCategory.count;
        
        if(nil != errMsg){
            [self handleErrMsg:errMsg];
        } else {
            
            PRPLog(@"self.docsMainCategory.count: %d-[%@ , %@]",
                   weakSelf.docsMainCategory.count,
                   NSStringFromClass([self class]),
                   NSStringFromSelector(_cmd));
        }
    }];
}

-(void)viewWillAppear:(BOOL)animated{
    
    [super viewWillAppear:animated];
    
}

-(void)viewDidAppear:(BOOL)animated{
    
    [super viewDidAppear:animated];
    
    [self.noticeChildViewController
     toggleSlide:nil msg:kSharedModel.lang[@"searchStoreByTypeOrRadins"]
     stayTime:5.0f];
    
}

-(void)viewWillDisappear:(BOOL)animated{
    
    [super viewWillDisappear:animated];
}


-(void)_fetchStoresByLocatioin:(CLLocation*)location
                mainCategoryId:(NSString*)mainCategoryId
                 rangeInMeters:(double)rangeInMeters  
                          fbId:(NSString*)fbId
{
    [self showHud:YES];
    
    __block __weak WOStoresViewController* weakSelf = (WOStoresViewController*)self;
    [self.annotations removeAllObjects];
    
    [kSharedModel fetchStoresByLocatioin:(CLLocation*)location
                          mainCategoryId:mainCategoryId 
                           rangeInMeters:(double)rangeInMeters  
                                    fbId:(NSString*)fbId
                               withBlock:^(NSDictionary* res) {
                                   
                                   NSString* error  = res[@"error"];
                                   if(nil != error){
                                       [weakSelf showMsg:error type:msgLevelError];
                                       return;
                                   }                       
                                   PRPLog(@"after successfully _fetchStoresByLocatioin res: %@-[%@ , %@]",
                                          res,
                                          NSStringFromClass([self class]),
                                          NSStringFromSelector(_cmd));
                                   NSMutableArray* docsLocation =(NSMutableArray*)res[@"docsLocation"];
                                   weakSelf.annotations  = docsLocation;
                                   [weakSelf hideHud:YES];
                                   
                                   [weakSelf.annotations enumerateObjectsUsingBlock:^(id obj, NSUInteger index, BOOL *stop){
                                       
                                       Hotspot* hotsppot = (Hotspot*)obj;
                                       hotsppot.distanceFromUser = [Utils fromLocation:self.location.coordinate toLocation:hotsppot.coordinate];
                                       
                                       PRPLog(@"hotsppot.distanceFromUser: %f \n\
                                              - [%@ , %@]",
                                              hotsppot.distanceFromUser,
                                              NSStringFromClass([self class]),
                                              NSStringFromSelector(_cmd));
                                   }];    
                                   
                               }];
}



@end
