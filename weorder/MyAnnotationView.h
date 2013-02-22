//
//  MyAnnotationView.h
//  Recipe 6.3: Customizing Annotations
//
//  Created by Hans-Eric Grönlund on 7/3/12.
//  Copyright (c) 2012 Hans-Eric Grönlund. All rights reserved.
//

#import <MapKit/MapKit.h>
#import "Hotspot.h"

#define KMyAnnotationViewTypeMore @"KMyAnnotationViewTypeMore"
#define KMyAnnotationViewTypeSingle @"KMyAnnotationViewTypeSingle"

typedef enum KMyAnnotationViewType {
    KMyAnnotationViewTagMore = 9012
,
    KMyAnnotationViewTagSingle = 9002
} KMyAnnotationViewType;


@interface MyAnnotationView : MKAnnotationView
@property (nonatomic, weak) Hotspot *annotation;
@end
