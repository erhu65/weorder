//
//  UIImage+CacheExtensions.m
//  we tube
//
//  Created by Huang Peter on 2/15/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "UIImage+CacheExtensions.h"


static NSMutableDictionary *UIImageCache;

@implementation UIImage (CacheExtensions)

+ (UIImage *)imageNamedCache:(NSString *)name 
{
    id result;
    if (!UIImageCache)
        UIImageCache = [[NSMutableDictionary alloc] init];
    else {
        result = [UIImageCache objectForKey:name];
        if (result) return result;
    }
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,  NSUserDomainMask, YES);  
    NSString *documentsPath = [paths objectAtIndex:0];  
    NSString *imagePath = [documentsPath stringByAppendingPathComponent:name];
    result = [UIImage imageWithContentsOfFile:imagePath];  
    if(result) {
            [UIImageCache setObject:result forKey:name];
            return result;
    }
    
    // First, check the main bundle for the image
//    NSString *imagePath = [[NSBundle mainBundle] pathForResource:name ofType:nil];
//    
//    result = [UIImage imageWithContentsOfFileimagePath];
//    if(result) {
//        [UIImageCache setObject:result forKey:name];
//        return result;
//    }
//    
//    // If not found, search for the image in the caches directory
//    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES); 
//    NSString *cachesImagePath = [[paths lastObject] stringByAppendingPathComponent:name];
//    
//    result = [UIImage imageWithContentsOfFile:cachesImagePath];
//    if(result) {
//        [UIImageCache setObject:result forKey:name];
//        return result;
//    }
    
    return nil;
}

+ (void)clearCache
{
    if (UIImageCache)
    [UIImageCache removeAllObjects];
}

- (UIImage *) makeThumbnailOfSize:(CGSize)size;
{
    UIGraphicsBeginImageContext(size);  
    // draw scaled image into thumbnail context
    [self drawInRect:CGRectMake(0, 0, size.width, size.height)];
    UIImage *newThumbnail = UIGraphicsGetImageFromCurrentImageContext();        
    // pop the context
    UIGraphicsEndImageContext();
    if(newThumbnail == nil) 
        NSLog(@"could not scale image");
    return newThumbnail;
}


@end