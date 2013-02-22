//
//  MyAnnotationView.m
//  Recipe 6.3: Customizing Annotations
//
//  Created by Hans-Eric Grönlund on 7/3/12.
//  Copyright (c) 2012 Hans-Eric Grönlund. All rights reserved.
//

#import "MyAnnotationView.h"

@implementation MyAnnotationView


- (id)initWithAnnotation:(id <MKAnnotation>)annotation reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithAnnotation:annotation reuseIdentifier:reuseIdentifier];
    if (self)
    {
        UIImage *myImage;
        if([reuseIdentifier isEqualToString:KMyAnnotationViewTypeMore]){
            
            myImage = [UIImage imageNamed:kSharedModel.theme[@"pinMore"]];
            self.canShowCallout = NO;
            
        } else if([reuseIdentifier isEqualToString:KMyAnnotationViewTypeSingle]) {
            
            myImage = [UIImage imageNamed:kSharedModel.theme[@"pinSingle"]];
            self.canShowCallout = YES;
            self.calloutOffset = CGPointMake(0, -20);

        }
        
        self.image = myImage;
        self.frame = CGRectMake(0, 0, 40, 40);
        //Use contentMode to ensure best scaling of image
        self.contentMode = UIViewContentModeScaleAspectFill;
        //Use centerOffset to adjust the position of the image
        self.centerOffset = CGPointMake(1, 1);

        // Additional customizations:
        //
         
        self.draggable = YES;

        // Left callout accessory view
        UIImageView *leftAccessoryView = [[UIImageView alloc] initWithImage:myImage];
        leftAccessoryView.frame = CGRectMake(0, 0, 20, 20);
        leftAccessoryView.contentMode = UIViewContentModeScaleAspectFill;
        self.leftCalloutAccessoryView = leftAccessoryView;
        
        // Right callout accessory view
        self.rightCalloutAccessoryView = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
    }
    return self;
}

/*
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}
*/

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
