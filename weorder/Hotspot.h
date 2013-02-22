//
//  Hotspot.h
//  Recipe 6.6: Grouping Annotations Dynamically
//
//  Created by Hans-Eric Grönlund on 7/6/12.
//  Copyright (c) 2012 Hans-Eric Grönlund. All rights reserved.
//

#import <MapKit/MapKit.h>
@class MyAnnotationView;
@class WORecordStore;

@interface Hotspot : NSObject<MKAnnotation>
{
    CLLocationCoordinate2D _coordinate;
    NSString *_title;
    NSString *_subtitle;
}

@property (nonatomic) CLLocationCoordinate2D coordinate;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *subtitle;

@property (nonatomic, assign) double distanceFromUser;

@property (nonatomic, strong) WORecordStore *record;

@property (nonatomic, strong) NSMutableArray *places;
@property (nonatomic, strong) MyAnnotationView *annotationView;

-(void)addPlace:(Hotspot *)hotspot;
-(int)placesCount;

-(id)initWithCoordinate:(CLLocationCoordinate2D)coordinate title:(NSString *)title 
    subtitle:(NSString *)subtitle
    userLocation:(CLLocation *)userLocation;

-(id)initWithRecord:(WORecordStore*)record 
       userLocation:(CLLocation *)userLocation;

@end
