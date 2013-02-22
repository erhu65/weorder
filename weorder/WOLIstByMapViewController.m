//
//  WOLIstByMapViewController.m
//  weorder
//
//  Created by Peter2 on 2/21/13.
//  Copyright (c) 2013 peter. All rights reserved.
//

#define centerLat 24.1369
#define centerLong 120.6786
#define spanDeltaLat 4.9
#define spanDeltaLong 5.8
#define scaleLat 9.0
#define scaleLong 11.0

#define KWOLIstByMapViewControllerPickerViewRadins 101


#import "WOLIstByMapViewController.h"
#import "Hotspot.h"
#import "WORecordStore.h"
#import "MyAnnotationView.h"
#import "Utils.h"
#import <MapKit/MapKit.h>

@interface WOLIstByMapViewController ()
<MKMapViewDelegate, CLLocationManagerDelegate,
UIPickerViewDelegate, UIPickerViewDataSource, UIActionSheetDelegate>
{
    CLLocationDegrees _zoomLevel;
    CLLocationManager *locationManager;
}


@property (weak, nonatomic) IBOutlet MKMapView *mapView;

@property (weak, nonatomic) IBOutlet UIBarButtonItem *barBtnSearch;
@property (weak, nonatomic) IBOutlet UISearchBar *search;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *barBtnCurrent;
@property (strong, nonatomic) NSMutableArray* annotations;
//@property (strong, nonatomic) NSArray* annotationsTmp;


@property (nonatomic, assign) NSInteger searchRadins;
@end


@implementation WOLIstByMapViewController



-(float)randomFloatFrom:(float)a to:(float)b
{
    float random = ((float) rand()) / (float) RAND_MAX;
    float diff = b - a;
    float r = random * diff;
    return a + r;
}

-(void)generateAnnotations
{
    srand((unsigned)time(0));
    
    for (int i=0; i<1000; i++)
    {
        CLLocationCoordinate2D randomLocation =
        CLLocationCoordinate2DMake([self randomFloatFrom:37.0 to:42.0], [self randomFloatFrom:-72.0 to:-79.0]);
        
        Hotspot *place = [[Hotspot alloc] initWithCoordinate:randomLocation title:[NSString stringWithFormat:@"Place %d title", i] subtitle:[NSString stringWithFormat:@"Place %d subtitle", i] userLocation:self.location];
        [self.annotations addObject:place];
    }
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    self.searchRadins = 0;
    self.title = kSharedModel.lang[@"storeByMap"];
    
    self.barBtnSearch.title = kSharedModel.lang[@"actionSearch"];
    self.search.backgroundImage = [UIImage imageNamed:kSharedModel.theme[@"bgWood"]];
    self.search.inputAccessoryView = [self accessoryView];
    
    self.barBtnCurrent.title = kSharedModel.lang[@"current"];
    
    //self.annotations = [[NSMutableArray alloc] initWithCapacity:1000];
    //[self generateAnnotations];
    //self.annotationsTmp = [[NSArray alloc] initWithArray:self.annotations];
    
    self.mapView.delegate = self;

    CLLocationCoordinate2D noLocation;
    MKCoordinateRegion viewRegion = MKCoordinateRegionMakeWithDistance(noLocation, 500, 500);
    MKCoordinateRegion adjustedRegion = [self.mapView regionThatFits:viewRegion];          
    [self.mapView setRegion:adjustedRegion animated:YES];
    self.mapView.showsUserLocation = YES;

    locationManager = [[CLLocationManager alloc] init];
    locationManager.delegate = self;
    locationManager.distanceFilter = kCLDistanceFilterNone;
    locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    
    if(nil != self.location){
        [self _resetVisibleZoom:self.location];
        [self _fetchStoresByLocatioin:self.location 
                        rangeInMeters:self.searchRadins 
                                 fbId:kSharedModel.fbId];

    } else {
        [locationManager startUpdatingLocation];
    }
    

}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.noticeChildViewController.view.hidden = YES;
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    self.noticeChildViewController.view.hidden = NO;
    
    [self.noticeChildViewController
     toggleSlide:nil msg:kSharedModel.lang[@"dragTheRedPinOrTypeYourAdddressToMovePin"]
     stayTime:5.0f];
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    self.noticeChildViewController.view.hidden = YES;
}


-(void)_fetchStoresByLocatioin:(CLLocation*)location
                 rangeInMeters:(double)rangeInMeters  
                          fbId:(NSString*)fbId
{
    [self showHud:YES];
    __block __weak WOLIstByMapViewController* weakSelf = (WOLIstByMapViewController*)self;
    [self.annotations removeAllObjects];
    
    [kSharedModel fetchStoresByLocatioin:(CLLocation*)location
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
                                
                                [weakSelf.mapView removeAnnotations:weakSelf.mapView.annotations];
                                [weakSelf.mapView addAnnotations:weakSelf.annotations];
                                [weakSelf _resetVisibleZoom:self.location];
                            }];
    
}



#pragma mark MKMapViewDelegate
- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>)annotation
{
    // if it's the user location, just return nil.
    if ([annotation isKindOfClass:[MKUserLocation class]])
        return nil;
	else
    {
        Hotspot *place = annotation;

        MyAnnotationView *anotioinMore = (MyAnnotationView *)[self.mapView dequeueReusableAnnotationViewWithIdentifier:KMyAnnotationViewTypeMore];
        
        MyAnnotationView *anotioinSingle = (MyAnnotationView *)[self.mapView dequeueReusableAnnotationViewWithIdentifier:KMyAnnotationViewTypeSingle];
        if(nil == anotioinMore){
            // No cached view were available, create a new one
            anotioinMore = [[MyAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:KMyAnnotationViewTypeMore];
        }
        
        if(nil == anotioinSingle){
            // No cached view were available, create a new one
            anotioinSingle = [[MyAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:KMyAnnotationViewTypeSingle];
        }
        
        if ([place placesCount] > 1){
            
            place.annotationView = anotioinMore; 
            anotioinMore.tag = KMyAnnotationViewTagMore;
            return anotioinMore;
        } else {
            place.annotationView = anotioinSingle; 
            anotioinMore.tag = KMyAnnotationViewTagSingle;
            return anotioinSingle;
        }
        
	}
}
-(void)mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated
{
    if (_zoomLevel != mapView.region.span.longitudeDelta)
    {        
        [self group:self.annotations];
        _zoomLevel = mapView.region.span.longitudeDelta;
        
        NSSet *visibleAnnotations = [mapView annotationsInMapRect:mapView.visibleMapRect];
        for (Hotspot *place in visibleAnnotations)
        {
            if ([place placesCount] > 1){
                place.annotationView.image = [UIImage imageNamed:kSharedModel.theme[@"pinMore"]];
                place.annotationView.tag = KMyAnnotationViewTagMore;
                place.annotationView.canShowCallout = NO;
                
                //place.annotationView.pinColor = MKPinAnnotationColorGreen;
                //place.annotationView.canShowCallout = NO;
            } else {
                place.annotationView.image = [UIImage imageNamed:kSharedModel.theme[@"pinSingle"]];
                place.annotationView.tag = KMyAnnotationViewTagSingle;
                place.annotationView.canShowCallout = YES;
               
                //place.annotationView.pinColor = MKPinAnnotationColorRed;
                //place.annotationView.canShowCallout = YES;
            }
            place.annotationView.annotation = place;
                
        }
        
    }
}
-(void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control
{
    MyAnnotationView* myAnnotaioinView =(MyAnnotationView*) view;
    Hotspot* selectedAnnotaion = myAnnotaioinView.annotation;
    
    PRPLog(@"selectedAnnotaion.record._id: %@ \n\
           - [%@ , %@]",
           selectedAnnotaion.record._id,
           NSStringFromClass([self class]),
           NSStringFromSelector(_cmd));  
}

#pragma mark CLLocationManagerDelegate
//only for ios 6
- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations{
    
    self.location = [locations objectAtIndex:0];
    [locationManager stopUpdatingLocation];
 
    
    //for testing...
    CLLocation* locationFound = [[CLLocation alloc] initWithLatitude:centerLat longitude: centerLong];
    self.location = locationFound;
    
    [self _fetchStoresByLocatioin:self.location 
                    rangeInMeters:self.searchRadins 
                             fbId:kSharedModel.fbId];
    PRPLog(@"self.location.coordinate.latitude: %f \n\
           self.location.coordinate.longitude: %f \n\
           - [%@ , %@]",
           self.location.coordinate.latitude,
           self.location.coordinate.longitude,
           NSStringFromClass([self class]),
           NSStringFromSelector(_cmd));
}

-(void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error{
    
    self.location = nil;
}

-(IBAction)_moveToMyCurrentLocation
{
    PRPLog(@"self.mapView.userLocation.location.coordinate.latitude: %f \n\
           self.mapView.userLocation.location.coordinate..longitude: %f \n\
           - [%@ , %@]",
           self.mapView.userLocation.location.coordinate.latitude,
           self.mapView.userLocation.location.coordinate.longitude,
           NSStringFromClass([self class]),
           NSStringFromSelector(_cmd));
    
    if(self.mapView.userLocation.location.coordinate.latitude == 0.0f){
        
        [self showMsg:kSharedModel.lang[@"gpsIsNotActivated"] type:msgLevelWarn];
        return;
    }
    
    [locationManager startUpdatingLocation];
}

- (IBAction)_back:(id)sender {
    self.complectionBlock(nil);
}

-(void)_resetVisibleZoom:(CLLocation*) location{
    
    MKCoordinateSpan span = MKCoordinateSpanMake(0.5f, 0.5f);
    MKCoordinateRegion region = MKCoordinateRegionMake(location.coordinate, span);
    [self.mapView setRegion:region animated:YES];
}

- (IBAction)_showRadinsActionSheet:(id)sender
{    
    
    UIActionSheet *actionSheet = [[UIActionSheet alloc] 
                                  initWithTitle:kSharedModel.lang[@"searchByRadians"]  delegate:self 
                                  cancelButtonTitle:kSharedModel.lang[@"actionCancel"]  destructiveButtonTitle:nil 
                                  otherButtonTitles:kSharedModel.lang[@"actionDone"] , nil];
   	actionSheet.actionSheetStyle = UIActionSheetStyleDefault;
    [actionSheet showInView:self.tabBarController.view];
    
	// Build the picker
	UIPickerView *pickerView = [[UIPickerView alloc] init];
	pickerView.tag = KWOLIstByMapViewControllerPickerViewRadins;
	pickerView.delegate = self;
	pickerView.dataSource = self;
	pickerView.showsSelectionIndicator = YES;
    NSInteger selectedRow;
    if(self.searchRadins == 0){
        selectedRow = 19;
    } else {
        selectedRow = self.searchRadins;
        selectedRow--;
    }
    
    [pickerView selectRow:selectedRow inComponent:0 animated:YES];
    
    pickerView.frame = CGRectMake(0.0f, 150.0f, 320.0f, 20.0f);
    CGPoint center = actionSheet.center;
    actionSheet.frame = CGRectMake(0.0f, 0.0f, 320.0f, 400.0f);
    actionSheet.center = center;
    
	// Embed the picker
	[actionSheet insertSubview:pickerView atIndex:0];  
}

#pragma mark UIActionSheetDelegate
-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    NSString* btnTitle = [actionSheet buttonTitleAtIndex:buttonIndex];
    
	if ([btnTitle isEqualToString:kSharedModel.lang[@"actionDone"]]) {
        UIPickerView *pickerView =(UIPickerView *)[actionSheet viewWithTag:KWOLIstByMapViewControllerPickerViewRadins];
        NSInteger selectedRow = [pickerView selectedRowInComponent:0];
        self.searchRadins = ++selectedRow;
        if(self.searchRadins == 20){
            self.searchRadins = 0;
        } 
        PRPLog(@"search by %i KM \n\
               [%@, %@]",
               self.searchRadins,
               NSStringFromClass([self class]),
               NSStringFromSelector(_cmd));
        
        
//        if(self.mapView.userLocation.coordinate.latitude == 0.0f 
//           || self.searchRadins == 0.0f){
//            self.annotations = [self.annotationsTmp mutableCopy];
//        } else {
//            
//            __block NSMutableArray* arrFilter = [[NSMutableArray alloc] init];
//            [self.annotationsTmp enumerateObjectsUsingBlock:^(id obj, NSUInteger index, BOOL *stop){
//                Hotspot* hotsppot = (Hotspot*)obj;
//                PRPLog(@"hotsppot.distanceFromUser: %f \n\
//                       - [%@ , %@]",
//                       hotsppot.distanceFromUser,
//                       NSStringFromClass([self class]),
//                       NSStringFromSelector(_cmd));
//                
//                NSInteger searchRadinsMeters = self.searchRadins* 1000;
//                if(hotsppot.distanceFromUser != 0.0f 
//                   && hotsppot.distanceFromUser <= searchRadinsMeters){
//                    [arrFilter addObject:hotsppot];
//                } 
//                    
//            }];
//            self.annotations = arrFilter;
//        }
        [self _resetVisibleZoom:self.location];
	} 

}

#pragma mark UIPickerViewDataSource, UIPickerViewDelegate
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
	return 1; // three columns
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
	return 20; // twenty items per column
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
     ++row;
    if(row == 20){
        return kSharedModel.lang[@"noLImit"];
    } else {
        return [NSString stringWithFormat:@"%i KM", row];
    }
	
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{

}

-(void)_fileterByRadian:(int)range{

    if(self.mapView.userLocation.location.coordinate.latitude == 0.0f){
        
        [self showMsg:kSharedModel.lang[@"gpsIsNotActivated"] type:msgLevelWarn];
        return;
    }
    
    
    [self _resetVisibleZoom:self.location];
}

-(void)_addressReverse:(NSString*)address_
{
    CLGeocoder* myGeocoder  = [[CLGeocoder alloc] init];
    __block CLLocationCoordinate2D current_reverse_;
    current_reverse_.latitude = 0.0f;
    current_reverse_.longitude = 0.0f;
    [myGeocoder
     geocodeAddressString:address_
     completionHandler:^(NSArray *placemarks, NSError *error) {
         
         if ([placemarks count] > 0 &&
             error == nil){
             CLPlacemark *firstPlacemark = [placemarks objectAtIndex:0];
             
             PRPLog(@"Found %lu placemark(s) \n\
                    Longitude = %f \n\
                    Latitude = %f \n\
                    address_: %@ \n\
                    [%@, %@]",
                    (unsigned long)[placemarks count],
                    firstPlacemark.location.coordinate.longitude,
                    firstPlacemark.location.coordinate.latitude,
                    address_,
                    NSStringFromClass([self class]),
                    NSStringFromSelector(_cmd));
             
             
             current_reverse_.latitude = firstPlacemark.location.coordinate.latitude;
             current_reverse_.longitude = firstPlacemark.location.coordinate.longitude;
             CLLocation* locationFound = [[CLLocation alloc] initWithLatitude:current_reverse_.latitude longitude: current_reverse_.longitude];
             self.location = locationFound;
             [self _resetVisibleZoom:self.location];
             
             return;
         } else if ([placemarks count] == 0 &&
                    error == nil){
             
             PRPLog(@"Found no placemarks. [%@, %@]",
                    NSStringFromClass([self class]),
                    NSStringFromSelector(_cmd));
             current_reverse_.latitude = 0.0f;
             current_reverse_.longitude = 0.0f;
             [self showMsg:kSharedModel.lang[@"notFoundAddressLocation"] type:msgLevelInfo];
             
             
         }else if (error != nil){
             PRPLog(@"Found no placemarks: %@ [%@, %@]",
                    error,
                    NSStringFromClass([self class]),
                    NSStringFromSelector(_cmd));
             current_reverse_.latitude =  0.0f;
             current_reverse_.longitude =  0.0f;
             [self showMsg:kSharedModel.lang[@"notFoundAddressLocation"] type:msgLevelInfo];
             
         }
         
     }];
}


-(IBAction)_search
{  
    if(self.search.text.length == 0){
        [self showMsg:kSharedModel.lang[@"plseaseFillSearchField"] type:msgLevelInfo];
        return;
    }
    
    [self.search resignFirstResponder];
    [self _addressReverse:self.search.text]; 
}

-(void)group:(NSArray *)annotations
{
    float latDelta = self.mapView.region.span.latitudeDelta / scaleLat;
    float longDelta = self.mapView.region.span.longitudeDelta / scaleLong;
    
    [self.annotations makeObjectsPerformSelector:@selector(cleanPlaces)];
    NSMutableArray *visibleAnnotations = [[NSMutableArray alloc] initWithCapacity:0];
    
    for (Hotspot *current in annotations)
    {
        [self.mapView deselectAnnotation:current animated:YES];
        CLLocationDegrees lat = current.coordinate.latitude;
        CLLocationDegrees longi = current.coordinate.longitude;
        
        bool found = FALSE;
        for (Hotspot *temp in visibleAnnotations)
        {
            if(fabs(temp.coordinate.latitude - lat) < latDelta &&
               fabs(temp.coordinate.longitude - longi) < longDelta)
            {
                [self.mapView removeAnnotation:current];
                found = TRUE;
                [temp addPlace:current];
                break;
            }
        }
        if (!found)
        {
            [visibleAnnotations addObject:current];
            [self.mapView addAnnotation:current];
            

        }
    }
}
@end
