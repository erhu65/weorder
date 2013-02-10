//
//  UIImage+CacheExtensions.h
//  we tube
//
//  Created by Huang Peter on 2/15/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (CacheExtensions)
+ (UIImage *)imageNamedCache:(NSString *)name;
+ (void)clearCache;
- (UIImage *) makeThumbnailOfSize:(CGSize)size;
@end
