//
//  Hotspot.m
//  Recipe 6.6: Grouping Annotations Dynamically
//
//  Created by Hans-Eric Grönlund on 7/6/12.
//  Copyright (c) 2012 Hans-Eric Grönlund. All rights reserved.
//

#import "Hotspot.h"
#import "WORecordStore.h"
#import "MyAnnotationView.h"
#import "Utils.h"

@implementation Hotspot

-(id)initWithCoordinate:(CLLocationCoordinate2D)coordinate 
                  title:(NSString *)title 
               subtitle:(NSString *)subtitle
           userLocation:(CLLocation *)userLocation
{
    self = [super init];
    if (self) {
        self.coordinate = coordinate;
        self.title = title;
        self.subtitle = subtitle;
        self.places = [[NSMutableArray alloc] initWithCapacity:0];
        self.distanceFromUser = 0.0f;
        
        if(nil != userLocation){
            self.distanceFromUser = [Utils fromLocation:userLocation.coordinate toLocation:self.coordinate];
        }
    }
    return self;
}

-(id)initWithRecord:(WORecordStore*)record 
       userLocation:(CLLocation *)userLocation{
    
    self = [super init];
    if (self) {
        
        self.record = record;
        self.title = record.name;
        self.subtitle = record.description;
        
        self.places = [[NSMutableArray alloc] initWithCapacity:0];
        self.distanceFromUser = 0.0f;
       
        CLLocationCoordinate2D coordinate ;
        coordinate.latitude = self.record.lat;
        coordinate.longitude = self.record.lng;
        self.coordinate = coordinate;
        
        if(nil != userLocation){
            self.distanceFromUser = [Utils fromLocation:userLocation.coordinate toLocation:self.coordinate];
        }
        
        
    }
    return self;
}


-(NSString *)title
{
    if ([self placesCount] == 1)
    {
        return _title;
    }
    else
        return [NSString stringWithFormat:@"%i Places", [self.places count]];
}

-(CLLocationCoordinate2D)coordinate
{
    return _coordinate;
}

-(void)setCoordinate:(CLLocationCoordinate2D)coordinate
{
    _coordinate = coordinate;
}

-(void)setTitle:(NSString *)title
{
    _title = title;
}

-(void)setSubtitle:(NSString *)subtitle
{
    _subtitle = subtitle;
}

-(void)addPlace:(Hotspot *)hotspot
{
    [self.places addObject:hotspot];
}

-(int)placesCount
{
    return [self.places count];
}

-(void)cleanPlaces
{
    [self.places removeAllObjects];
    [self.places addObject:self];
}

@end
