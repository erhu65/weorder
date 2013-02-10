//
//  Utils.h
//  we tube
//
//  Created by Huang Peter on 2/3/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//
#import <Foundation/Foundation.h>

@interface Utils : NSObject

+(NSString *)filePathInCaches:(NSString *)name
                   withSuffix:(NSString*) suffix;
+(NSString *)filePathInDocument:(NSString *)name
                     withSuffix:(NSString*) suffix;
+ (UIImage *)fbThumbImage:(NSString *)fb_id_;

+(CGSize)resizeWithImageFitScreen:(UIImage*)image;

+ (UIImage*)imageWithImage:(UIImage*)image 
              scaledToSize:(CGSize)newSize;

+ (void) saveImageAsThumb:(NSString *)fileName 
                  image: (UIImage *)img
                  scaledToSize:(CGSize)newSize;

+(NSString*)cachefileName:(NSString*)pic_url;
+(void)cacheFile:(NSString *) fileName 
       fileUrl: (NSString *) url
       isSaveThumb: (BOOL) isSaveThumb;
+(UIImage *) readCacheImage: (NSString *) filePath;

+(BOOL)writeStr:(NSString *) str 
        ToFilePath: (NSString *) path;
+(NSString *) readStrFromFilePath: (NSString *) filePath;


+(NSMutableString *) strCut: (NSString *) strOriginal
                  cutLength: (int) cutLength
                  endStr: (NSString *) endStr;
+ (NSString *)createUUID: (NSString*) suffix;
+ (NSString*)MD5: (NSString*) str_raw;
+ (void) saveImage: (UIImage *)img
          filePath: (NSString*) path;
+(NSDictionary *)parseURLParams:(NSString *)query;
//+(NSString *) getDatabasePath;

+(NSString*)moneyFormatter:(int) sum_;
+(NSString*)moneyFormatter:(int) sum_ 
                  currancy:(NSString*)_currancy;
+(void) savePNGForView:(UIView *)targetView rect:(CGRect)rect fileName:(NSString *)fileName;
+(UIImage *) getPNGScreenShotByView:(UIView *)targetView rect:(CGRect)rect;
+ (UIImage*)scaleAndRotateImage:(UIImage *)image;
+ (UIImage *)scale:(UIImage *)image toSize:(CGSize)size;
+ (int)scannNumberFromStr:(NSString *)originalString_ ;

+(void) showImageAsync:(UIImageView*)imv_
               fromUrl:(NSString*)url_
             cacheName:(NSString*)cacheName;
+(void) showImageAsync:(UIImageView*)imv_
               fromUrl:(NSString*)url_;

+ (void) alignLabelWithTop:(UILabel *)label;
+ (BOOL)isPushEnabled;

+ (double) radians:(double)degrees;
+ (double) degrees:(double)radians;

//+(CLLocationDistance)fromLocation:(CLLocationCoordinate2D)locationA toLocation:(CLLocationCoordinate2D)locationB;

+ (NSUInteger)amountOfFreeMemory;
+ (BOOL)chkDataPathLocalExist:(NSString*)localPath;
@end
