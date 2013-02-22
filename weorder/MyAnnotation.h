//
//  MyAnnotation.h
//  Recipe 6.3: Customizing Annotations
//
//  Created by Hans-Eric Grönlund on 7/3/12.
//  Copyright (c) 2012 Hans-Eric Grönlund. All rights reserved.
//

#import <MapKit/MapKit.h>

@interface MyAnnotation : MKPointAnnotation

-(id)initWithCoordinate:(CLLocationCoordinate2D)coord title:(NSString *)title subtitle:(NSString *)subtitle contactInformation:(NSString *)contactInfo;

@property (nonatomic, strong) NSString *contactInformation;

@end
