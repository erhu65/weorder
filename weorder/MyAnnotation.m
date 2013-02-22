//
//  MyAnnotation.m
//  Recipe 6.3: Customizing Annotations
//
//  Created by Hans-Eric Grönlund on 7/3/12.
//  Copyright (c) 2012 Hans-Eric Grönlund. All rights reserved.
//

#import "MyAnnotation.h"

@implementation MyAnnotation

-(id)initWithCoordinate:(CLLocationCoordinate2D)coord title:(NSString *)title subtitle:(NSString *)subtitle contactInformation:(NSString *)contactInfo
{
    self = [super init];
    if (self)
    {
        self.coordinate = coord;
        self.title = title;
        self.subtitle = subtitle;
        self.contactInformation = contactInfo;
    }
    
    return self;
}

@end
