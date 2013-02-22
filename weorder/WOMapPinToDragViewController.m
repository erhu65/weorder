//
//  WOMapPinToDragViewController.m
//  weorder
//
//  Created by Peter2 on 2/21/13.
//  Copyright (c) 2013 peter. All rights reserved.
//

#import "WOMapPinToDragViewController.h"
#import <MapKit/MapKit.h>

@interface WOMapPinToDragViewController ()
<MKMapViewDelegate,
CLLocationManagerDelegate>
{
    CLLocationManager *locationManager;
}

@property(nonatomic, strong) NSString* address;
@property(nonatomic, strong) MKPointAnnotation *annotation;

@property (weak, nonatomic) IBOutlet UIBarButtonItem *barBtnSearch;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *barBtnBack;
@property (weak, nonatomic) IBOutlet UISearchBar *search;

@property (weak, nonatomic) IBOutlet MKMapView *mapView;

@property (weak, nonatomic) IBOutlet UIBarButtonItem *barBtnDone;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *barBtnCurrent;

@end

@implementation WOMapPinToDragViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
	
    self.barBtnBack.title = kSharedModel.lang[@"actionBack"];
    self.barBtnSearch.title = kSharedModel.lang[@"actionSearch"];
    self.search.backgroundImage = [UIImage imageNamed:kSharedModel.theme[@"bgWood"]];
    self.search.inputAccessoryView = [self accessoryView];
    
    self.barBtnDone.title = kSharedModel.lang[@"actionDone"];
    self.barBtnCurrent.title = kSharedModel.lang[@"current"];
    
    self.mapView.delegate = self;
    

    CLLocationCoordinate2D noLocation;
    MKCoordinateRegion viewRegion = MKCoordinateRegionMakeWithDistance(noLocation, 500, 500);
    MKCoordinateRegion adjustedRegion = [self.mapView regionThatFits:viewRegion];          
    [self.mapView setRegion:adjustedRegion animated:YES];
    self.mapView.showsUserLocation = YES;
    
//    self.annotation = [[MKPointAnnotation alloc] init];
//    self.annotation.coordinate = CLLocationCoordinate2DMake(39.9, -76.6);//defaul location is Apple headquartor
//    [self.mapView addAnnotation:self.annotation];
//    [self.mapView setCenterCoordinate:self.location.coordinate  animated:YES];
//    [self _resetVisibleZoom:self.location];
    
    //get user's location
    locationManager = [[CLLocationManager alloc] init];
    locationManager.delegate = self;
    locationManager.distanceFilter = kCLDistanceFilterNone;
    locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    
    if(nil != self.location){
        [self _resetPin:nil]; 
        [self _resetVisibleZoom:self.location];
        [self _geocoderToAddress:self.location];
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


#pragma mark MKMapViewDelegate
- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation
{
    // Don't create annotation views for the user location annotation
    if ([annotation isKindOfClass:[MKPointAnnotation class]])
    {
        static NSString *draggableAnnotationId = @"draggableAnnotation";
        
        // Create an annotation view, but reuse a cached one if available
        MKPinAnnotationView *annotationView =
        (MKPinAnnotationView *)[self.mapView
                                dequeueReusableAnnotationViewWithIdentifier:draggableAnnotationId];
        if(annotationView)
        {
            // Cached view found, associate it with the annotation
            annotationView.annotation = annotation;
        }
        else
        {
            // No cached view were available, create a new one
            annotationView = [[MKPinAnnotationView alloc] initWithAnnotation:annotation
                                                             reuseIdentifier:draggableAnnotationId];
            annotationView.draggable = YES;
        }
        
        return annotationView;
    }
    
    // Use a default annotation view for the user location annotation
    return nil;
}

-(void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view didChangeDragState:(MKAnnotationViewDragState)newState fromOldState:(MKAnnotationViewDragState)oldState
{
    if (newState == MKAnnotationViewDragStateEnding)
    {
        MKPointAnnotation *annotation = view.annotation;
        CLLocation* locationDrop = [[CLLocation alloc] initWithLatitude:annotation.coordinate.latitude longitude: view.annotation.coordinate.longitude];
        self.location = locationDrop;
        [self _geocoderToAddress:self.location];
        [self _resetVisibleZoom:self.location];
        
        PRPLog(@"Drop Pin Lat: %f \n\
               Drop Pin Long: %f \n\
               - [%@ , %@]",
               self.location.coordinate.latitude,
               self.location.coordinate.longitude,
               NSStringFromClass([self class]),
               NSStringFromSelector(_cmd));
    }
}

#pragma mark CLLocationManagerDelegate
//only for ios 6
- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations{
    
    self.location = [locations objectAtIndex:0];
    [self _geocoderToAddress:self.location];
    [self _resetPin:nil];  
    
    [locationManager stopUpdatingLocation];
    [self _resetVisibleZoom:self.location];
    
    PRPLog(@"self.location.coordinate.latitude: %f \n\
           self.location.coordinate.longitude: %f \n\
           - [%@ , %@]",
           self.location.coordinate.latitude,
           self.location.coordinate.longitude,
           NSStringFromClass([self class]),
           NSStringFromSelector(_cmd));
}
-(IBAction)_moveToMyCurrentLocation
{
    if(self.mapView.userLocation.location.coordinate.latitude == 0.0f){
        
        [self showMsg:kSharedModel.lang[@"gpsIsNotActivated"] type:msgLevelError];
        return;
    }
    [locationManager startUpdatingLocation];
}


- (IBAction)_back:(id)sender {
    self.complectionBlock(nil);
}

- (IBAction)_done:(id)sender {
    
    NSDictionary* res;
    if(nil != self.location){
        
        if(nil != self.address){
            res = @{@"location": self.location, @"address": self.address};
        } else {
            res = @{@"location": self.location};
        }
        
    }
    self.complectionBlock(res);
    
}


-(void)_resetVisibleZoom:(CLLocation*) location{
    
    MKCoordinateSpan span = MKCoordinateSpanMake(0.002f, 0.002f);
    MKCoordinateRegion region = MKCoordinateRegionMake(location.coordinate, span);
    [self.mapView setRegion:region animated:YES];
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
             [self _geocoderToAddress:self.location];
             [self _resetVisibleZoom:self.location];
                          
             [self _resetPin:nil];   
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

-(void)_geocoderToAddress:(CLLocation*)location
{
    CLGeocoder* myGeocoder  = [[CLGeocoder alloc] init];
    // Reverse Geocode a CLLocation to a CLPlacemark
    [myGeocoder reverseGeocodeLocation:location
               completionHandler:^(NSArray *placemarks, NSError *error){
                   
                   // Make sure the geocoder did not produce an error
                   // before continuing
                   if(!error){
                       CLPlacemark *topResult = [placemarks objectAtIndex:0];
                       self.address = [NSString stringWithFormat:@"%@ %@,%@ %@", 
                                               [topResult subThoroughfare],[topResult thoroughfare],
                                               [topResult locality], [topResult administrativeArea]];
                       PRPLog(@"reverse location to address successfully: %@ \n\
                              [%@, %@]",
                              self.address,
                              NSStringFromClass([self class]),
                              NSStringFromSelector(_cmd));

                       // Iterate through all of the placemarks returned
                       // and output them to the console
                       for(CLPlacemark *placemark in placemarks){
                           NSLog(@"%@",[placemark description]);
                       }
                   }
                   else{
                       // Our geocoder had an error, output a message
                       // to the console
                       NSLog(@"There was a reverse geocoding error\n%@",
                             [error localizedDescription]);
                   }
               }
     ];

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


-(IBAction)_resetPin:(id)sender 
{
    if(self.location.coordinate.latitude != 0.0f 
       && self.location.coordinate.longitude != 0.0f){
        //[self addPin:nil];
        [self.mapView removeAnnotation:self.annotation];        
        self.annotation = [[MKPointAnnotation alloc] init];
        self.annotation.coordinate = self.location.coordinate;
        [self.mapView addAnnotation:self.annotation];        
    }   
}


@end
