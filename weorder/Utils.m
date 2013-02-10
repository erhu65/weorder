//
//  Utils.m
//  we tube
//
//  Created by Huang Peter on 2/3/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//
#import <QuartzCore/QuartzCore.h>
#import "Utils.h"
#import "PRPDebug.h"

#import <mach/mach.h>
#import <mach/mach_host.h>

static NSFileManager * _fileManager = nil;

@implementation Utils

// OR static NSFileManager * _fileManager = nil;

/*
 * Helper method to return the picture endpoint for a given Facebook
 * object. Useful for displaying user, friend, or location pictures.
 */
+ (UIImage *)fbThumbImage:(NSString *)fb_id_ {
    // Get the object image
    
    NSString* fb_cacheFileName_ = [NSString stringWithFormat:@"%@_fb_thumb.png",  fb_id_];
    NSString *fb_cacheFileName_path_ = [Utils filePathInDocument:fb_cacheFileName_ withSuffix:nil];;
    if([[NSFileManager defaultManager] fileExistsAtPath:fb_cacheFileName_path_]) {
        
        return [Utils readCacheImage:fb_cacheFileName_path_];
    } else {
        NSString *url = [[NSString alloc] initWithFormat:@"https://graph.facebook.com/%@/picture",fb_id_];
        UIImage *image = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:url]]];
        return image;
    }
    

}

//ios 5 you should use caches dir to store data, images
+(NSString *)filePathInCaches:(NSString *)name
                   withSuffix:(NSString*) suffix
{
    NSString* lastName = nil;
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory,  NSUserDomainMask, YES);  
    NSString *documentsPath = [paths objectAtIndex:0];
    if(nil != suffix) {
        lastName = [name stringByAppendingString:suffix];
    } else {
        lastName = name;
    }
    return [documentsPath stringByAppendingPathComponent:lastName]; 
    
}
//ios 5 you can not use document to store your cache data, image
+(NSString *)filePathInDocument:(NSString *)name
                     withSuffix:(NSString*)suffix
{
    NSString* lastName = nil;
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,  NSUserDomainMask, YES);  
    NSString *documentsPath = [paths objectAtIndex:0];
    if(nil != suffix) {
        lastName = [name stringByAppendingString:suffix];
    } else {
        lastName = name;
    }
    return [documentsPath stringByAppendingPathComponent:lastName]; 
}

+(CGSize)resizeWithImageFitScreen:(UIImage*)image
{
    float actualHeight = image.size.height;
    float actualWidth = image.size.width;
    float imgRatio = actualWidth/actualHeight;
    float maxRatio = 320.0/480.0;
    
    if(imgRatio!=maxRatio){
        if(imgRatio < maxRatio){
            imgRatio = 480.0 / actualHeight;
            actualWidth = imgRatio * actualWidth;
            actualHeight = 480.0;
        } else {
            imgRatio = 320.0 / actualWidth;
            actualHeight = imgRatio * actualHeight;
            actualWidth = 320.0;
        }
    }
    //CGRect rect = CGRectMake(0.0, 0.0, actualWidth, actualHeight);
    CGSize newSize = CGSizeMake(actualWidth, actualHeight);
    return newSize;
}
+ (UIImage*)imageWithImage:(UIImage*)image 
              scaledToSize:(CGSize)newSize;
{
    UIGraphicsBeginImageContext( newSize );
    [image drawInRect:CGRectMake(0,0,newSize.width,newSize.height)];
    UIImage* newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

+ (void) saveImageAsThumb:(NSString *)fileName 
                  image: (UIImage *)img
                  scaledToSize:(CGSize)newSize
{
    UIImage* imgResized = [Utils imageWithImage:img scaledToSize:newSize];
	NSData *imageData = [NSData dataWithData:UIImagePNGRepresentation(imgResized)];
    NSString* thumbPath = [[NSString alloc] initWithFormat:@"%@", fileName];
    NSString *filePath = [Utils filePathInDocument:thumbPath withSuffix:nil];
	[imageData writeToFile:filePath atomically:YES];
}

+(NSString*)cachefileName:(NSString *)pic_url
{
    NSURL* imageURL = [NSURL URLWithString:pic_url];
    NSArray* urlPathArr_ = [imageURL pathComponents];
    NSString* cache_pic_name_ = [urlPathArr_ objectAtIndex:4];
    return cache_pic_name_;
}

+(void)cacheFile:(NSString *)fileName
        fileUrl: (NSString *) url
        isSaveThumb: (BOOL) isSaveThumb{
    
    NSString *filePath = [Utils filePathInCaches:fileName withSuffix:nil];
    
    if(![[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
        
        UIImage *image = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:url]]];
     
        NSData *pngData = UIImagePNGRepresentation(image);
        [pngData writeToFile:filePath atomically:YES];
        //Write the file
        //[img release];
        //[pngData release];
        if(isSaveThumb) {
            [Utils saveImageAsThumb:fileName image:image scaledToSize:CGSizeMake(120.0f, 120.0f)];
        }
    }
}


+(UIImage *) readCacheImage: (NSString *) filePath{

    NSData *pngData = [NSData dataWithContentsOfFile:filePath];
    UIImage *image = [UIImage imageWithData:pngData];
    return image;    
}
+(BOOL)writeStr:(NSString *) str 
        ToFilePath: (NSString *) path{

    NSError *error = nil;
    [str writeToFile:path 
                  atomically:YES 
                    encoding:NSUTF8StringEncoding 
                       error:&error]; //Write the file
        
    if(nil == error) {
        return YES;
    } else {
        return NO;
    }
}

+(NSString *) readStrFromFilePath:(NSString *)filePath{
    NSString *text = nil;
    if([[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
     	text = [[NSString alloc] initWithContentsOfFile:filePath
                                                        usedEncoding:nil
                                                               error:nil];
    }
    return  text;
}

+(NSMutableString *) strCut: (NSString *) strOriginal
                  cutLength: (int) cutLength
                  endStr: (NSString *) endStr{
    NSMutableString *strOriginal3 = nil ;
    if(nil == strOriginal || [strOriginal length] == 0 ) {
        strOriginal3 = [[NSMutableString alloc] initWithFormat:@""];
        return strOriginal3;
    
    };

    
    if([strOriginal length] > cutLength) {
        NSString *strOriginal2 =  [strOriginal substringToIndex: cutLength];
        strOriginal3 = [strOriginal2 mutableCopy];
        
        [strOriginal3 appendString:@"..."];
    } else {
        NSString *strOriginal2 =  [strOriginal substringToIndex: [strOriginal length]];
        strOriginal3 = [strOriginal2 mutableCopy];
    }
    if(nil != endStr) {
        [strOriginal3 appendString:endStr];

    }
        return strOriginal3;
}


+ (NSString *)createUUID: (NSString*) suffix
{
    // Create universally unique identifier (object)
    CFUUIDRef uuidObject = CFUUIDCreate(kCFAllocatorDefault);
    
    // Get the string representation of CFUUID object.
    NSString *uuidStr = (__bridge_transfer NSString *)CFUUIDCreateString(kCFAllocatorDefault, uuidObject);
    
    // If needed, here is how to get a representation in bytes, returned as a structure
    // typedef struct {
    //   UInt8 byte0;
    //   UInt8 byte1;
    //   ...
    //   UInt8 byte15;
    // } CFUUIDBytes;
    //CFUUIDBytes bytes = CFUUIDGetUUIDBytes(uuidObject);
    
    CFRelease(uuidObject);
    if(nil !=  suffix) {
        NSString* finalStr = [[NSString alloc] initWithFormat:@"%@%@", uuidStr, suffix];
        return finalStr;
    }
    return uuidStr;
}
+ (NSString*)MD5: (NSString*) str_raw

{
    const char *cStr = [str_raw UTF8String];
    unsigned char result[16];
    CC_MD5( cStr, strlen(cStr), result ); // This is the md5 call
    return [NSString stringWithFormat:
            @"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x",
            result[0], result[1], result[2], result[3],
            result[4], result[5], result[6], result[7],
            result[8], result[9], result[10], result[11],
            result[12], result[13], result[14], result[15]
            ];
}

+ (void) saveImage: (UIImage *)img
          filePath: (NSString*) path{
	NSData *imageData = [NSData dataWithData:UIImagePNGRepresentation(img)];
    
	[imageData writeToFile:path atomically:YES];
}

/**
 * Helper method to parse URL query parameters
 */
+ (NSDictionary *)parseURLParams:(NSString *)query {
	NSArray *pairs = [query componentsSeparatedByString:@"&"];
	NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
	for (NSString *pair in pairs) {
		NSArray *kv = [pair componentsSeparatedByString:@"="];
		NSString *val =
        [[kv objectAtIndex:1]
         stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        
		[params setObject:val forKey:[kv objectAtIndex:0]];
	}
    return params;
}
//
//+(NSString *) getDatabasePath
//{
//    NSString *databasePath = [(AppDelegate *)[[UIApplication sharedApplication] delegate] databasePath];
//    
//    return databasePath; 
//}

+(NSString*)moneyFormatter:(int) sum_
{
    NSNumberFormatter* numberFormatter = [[NSNumberFormatter alloc] init];
    [numberFormatter setFormatterBehavior: NSNumberFormatterBehavior10_4];
    [numberFormatter setNumberStyle: NSNumberFormatterDecimalStyle];
    NSString *numberString = [numberFormatter stringFromNumber: [NSNumber numberWithInteger: abs(sum_)]];
    return numberString;
}
+(NSString*)moneyFormatter:(int) sum_ 
                  currancy:(NSString*)_currancy
{
    NSString* res_ = nil;
    NSString* postive_negative_ = @"";
    if(sum_>0){
        postive_negative_ = @"+";
    } else if (sum_< 0) {
        postive_negative_ = @"-";
    }
    NSString* str_number_format = [Utils moneyFormatter:sum_];
    res_ = [NSString stringWithFormat:@"%@ %@ %@", postive_negative_, _currancy, str_number_format];
    return res_;
}
+(void) savePNGForView:(UIView *)targetView rect:(CGRect)rect fileName:(NSString *)fileName
{
    UIImage *image;
    CGPoint pt = rect.origin;
    
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextConcatCTM(context, CGAffineTransformMakeTranslation(-(int)pt.x, -(int)pt.y - 20));
    [targetView.layer renderInContext:context];
    image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    NSData *data = UIImagePNGRepresentation(image);
    NSString *filePath =  [Utils filePathInDocument:fileName withSuffix:nil];
    
    if ([data writeToFile:filePath atomically:YES]) {
        
        PRPLog(@"save ok: [%@, %@]",
               NSStringFromClass([self class]),
               NSStringFromSelector(_cmd));    
    } else {
        PRPLog(@"save fail [%@, %@]",
               NSStringFromClass([self class]),
               NSStringFromSelector(_cmd));    
    }
}
+(UIImage *) getPNGScreenShotByView:(UIView *)targetView rect:(CGRect)rect{

    UIImage *image;
    CGPoint pt = rect.origin;
    
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextConcatCTM(context, CGAffineTransformMakeTranslation(-(int)pt.x, -(int)pt.y - 20));
    [targetView.layer renderInContext:context];
    image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    NSData *data = UIImagePNGRepresentation(image);
    image = [UIImage imageWithData:data];
    return image;
}


+ (UIImage*)scaleAndRotateImage:(UIImage *)image
{
    int kMaxResolution = 320; // Or whatever
    
    CGImageRef imgRef = image.CGImage;
    
    CGFloat width = CGImageGetWidth(imgRef);
    CGFloat height = CGImageGetHeight(imgRef);
    
    CGAffineTransform transform = CGAffineTransformIdentity;
    CGRect bounds = CGRectMake(0, 0, width, height);
    if (width > kMaxResolution || height > kMaxResolution) {
        CGFloat ratio = width/height;
        if (ratio > 1) {
            bounds.size.width = kMaxResolution;
            bounds.size.height = bounds.size.width / ratio;
        }
        else {
            bounds.size.height = kMaxResolution;
            bounds.size.width = bounds.size.height * ratio;
        }
    }
    
    CGFloat scaleRatio = bounds.size.width / width;
    CGSize imageSize = CGSizeMake(CGImageGetWidth(imgRef), CGImageGetHeight(imgRef));
    CGFloat boundHeight;
    UIImageOrientation orient = image.imageOrientation;
    switch(orient) {
            
        case UIImageOrientationUp: //EXIF = 1
            transform = CGAffineTransformIdentity;
            break;
            
        case UIImageOrientationUpMirrored: //EXIF = 2
            transform = CGAffineTransformMakeTranslation(imageSize.width, 0.0);
            transform = CGAffineTransformScale(transform, -1.0, 1.0);
            break;
            
        case UIImageOrientationDown: //EXIF = 3
            transform = CGAffineTransformMakeTranslation(imageSize.width, imageSize.height);
            transform = CGAffineTransformRotate(transform, M_PI);
            break;
            
        case UIImageOrientationDownMirrored: //EXIF = 4
            transform = CGAffineTransformMakeTranslation(0.0, imageSize.height);
            transform = CGAffineTransformScale(transform, 1.0, -1.0);
            break;
            
        case UIImageOrientationLeftMirrored: //EXIF = 5
            boundHeight = bounds.size.height;
            bounds.size.height = bounds.size.width;
            bounds.size.width = boundHeight;
            transform = CGAffineTransformMakeTranslation(imageSize.height, imageSize.width);
            transform = CGAffineTransformScale(transform, -1.0, 1.0);
            transform = CGAffineTransformRotate(transform, 3.0 * M_PI / 2.0);
            break;
            
        case UIImageOrientationLeft: //EXIF = 6
            boundHeight = bounds.size.height;
            bounds.size.height = bounds.size.width;
            bounds.size.width = boundHeight;
            transform = CGAffineTransformMakeTranslation(0.0, imageSize.width);
            transform = CGAffineTransformRotate(transform, 3.0 * M_PI / 2.0);
            break;
            
        case UIImageOrientationRightMirrored: //EXIF = 7
            boundHeight = bounds.size.height;
            bounds.size.height = bounds.size.width;
            bounds.size.width = boundHeight;
            transform = CGAffineTransformMakeScale(-1.0, 1.0);
            transform = CGAffineTransformRotate(transform, M_PI / 2.0);
            break;
            
        case UIImageOrientationRight: //EXIF = 8
            boundHeight = bounds.size.height;
            bounds.size.height = bounds.size.width;
            bounds.size.width = boundHeight;
            transform = CGAffineTransformMakeTranslation(imageSize.height, 0.0);
            transform = CGAffineTransformRotate(transform, M_PI / 2.0);
            break;
            
        default:
            [NSException raise:NSInternalInconsistencyException format:@"Invalid image orientation"];
            
    }
    
    UIGraphicsBeginImageContext(bounds.size);
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    if (orient == UIImageOrientationRight || orient == UIImageOrientationLeft) {
        CGContextScaleCTM(context, -scaleRatio, scaleRatio);
        CGContextTranslateCTM(context, -height, 0);
    }
    else {
        CGContextScaleCTM(context, scaleRatio, -scaleRatio);
        CGContextTranslateCTM(context, 0, -height);
    }
    
    CGContextConcatCTM(context, transform);
    
    CGContextDrawImage(UIGraphicsGetCurrentContext(), CGRectMake(0, 0, width, height), imgRef);
    UIImage *imageCopy = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    //[self setRotatedImage:imageCopy];
    return imageCopy;
}

+ (UIImage *)scale:(UIImage *)image toSize:(CGSize)size
{
    UIGraphicsBeginImageContext(size);
    [image drawInRect:CGRectMake(0, 0, size.width, size.height)];
    UIImage *scaledImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return scaledImage;
}


+ (int)scannNumberFromStr:(NSString *)originalString_ 
{

    // Intermediate
    NSString *numberString = nil;
    if([originalString_ length] == 0) return 0;
    NSScanner *scanner = [NSScanner scannerWithString:originalString_];
    NSCharacterSet *numbers = [NSCharacterSet characterSetWithCharactersInString:@"0123456789"];
    // Throw away characters before the first number.

    [scanner scanUpToCharactersFromSet:numbers intoString:NULL];
    // Collect numbers.
    PRPLog(@"originalString_:%@  \n numbers:%@ \n numberString: %@ [%@, %@]",
           originalString_,
           numbers,
           numberString,
           NSStringFromClass([self class]),
           NSStringFromSelector(_cmd));
    
    [scanner scanCharactersFromSet:numbers intoString:&numberString];
    // Result.
    if(nil == numberString)return 0;
    int number = [numberString integerValue];
    
    return number;
}

//Cache
+(void) showImageAsync:(UIImageView*)imv_
               fromUrl:(NSString*)url_
             cacheName:(NSString*)cacheName
{
    if(nil == _fileManager) {
        _fileManager = [[NSFileManager alloc] init];
    }
    
    if(nil == cacheName ){
        NSURL* imageURL = [NSURL URLWithString:url_];
        NSArray* urlPathArr_ = [imageURL pathComponents];
        cacheName = [urlPathArr_ objectAtIndex:4];
    }
    
    NSString* picPathInCaches_ = [Utils filePathInCaches:cacheName  withSuffix:nil];
    NSURL* imageURL = [NSURL URLWithString:url_];
    
    BOOL isPicCachedExist_ = [_fileManager fileExistsAtPath:picPathInCaches_];
    
    NSArray *images = [NSArray arrayWithObjects:
                       [UIImage imageNamed:@"image.png"],
                       [UIImage imageNamed:@"image2.png"],
                       [UIImage imageNamed:@"image3.png"],
                       [UIImage imageNamed:@"image4.gif"],
                       nil];
    imv_.animationImages = images;
    imv_.animationDuration = 1;
    imv_.animationRepeatCount = 0; // 0 = nonStop repeat
    [imv_ startAnimating];
    
    if(isPicCachedExist_){
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            if(nil != imv_){
                UIImage *img_ = [Utils readCacheImage:picPathInCaches_];
                [imv_ stopAnimating];
                [imv_ setImage:img_];
            }
        });
        
    } else {
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW , 0), ^{
            
            
            NSData *imageData = [NSData dataWithContentsOfURL:imageURL];
            UIImage *myImage = [UIImage imageWithData:imageData];
            [Utils saveImage:myImage filePath:picPathInCaches_];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                if(nil != imv_){
                    [imv_ stopAnimating];
                    [imv_ setImage:myImage];
                }
            });
        });
    }    
}

//No Cache
+(void) showImageAsync:(UIImageView*)imv_
               fromUrl:(NSString*)url_{
    
    if(nil == _fileManager) {
        _fileManager = [[NSFileManager alloc] init];
    }
     
    
    NSArray *images = [NSArray arrayWithObjects:
                       [UIImage imageNamed:@"trans_01.png"],
                       [UIImage imageNamed:@"trans_02.png"],
                       [UIImage imageNamed:@"trans_03.png"],
                       [UIImage imageNamed:@"trans_04.png"],
                       nil];
        imv_.animationImages = images;
    imv_.animationDuration = 1;
    imv_.animationRepeatCount = 0; // 0 = nonStop repeat
    [imv_ startAnimating];
    
    NSURL* imageURL = [NSURL URLWithString:url_];    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW , 0), ^{

        
        NSData *imageData = [NSData dataWithContentsOfURL:imageURL];
        UIImage *myImage = [UIImage imageWithData:imageData];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if(nil != imv_){
                [imv_ stopAnimating];
                [imv_ setImage:myImage];
            }
        });
    });
}

// adjust the height of a multi-line label to make it align vertical with top
+ (void) alignLabelWithTop:(UILabel *)label {
	CGSize maxSize = CGSizeMake(label.frame.size.width, 999);
	label.adjustsFontSizeToFitWidth = NO;
    
	// get actual height
	CGSize actualSize = [label.text sizeWithFont:label.font constrainedToSize:maxSize lineBreakMode:label.lineBreakMode];
	CGRect rect = label.frame;
	rect.size.height = actualSize.height;
	label.frame = rect;
}

+ (BOOL)isPushEnabled {
    UIApplication *application = [UIApplication sharedApplication];
    return application.enabledRemoteNotificationTypes != UIRemoteNotificationTypeNone;
}


+ (double) radians:(double)degrees {
    return degrees * M_PI / 180.0;
}

+ (double) degrees:(double)radians {
    return radians * 180.0 / M_PI;
}

//+(CLLocationDistance)fromLocation:(CLLocationCoordinate2D)locationA toLocation:(CLLocationCoordinate2D)locationB
//{
//    CLLocationDegrees a_lat_ = [Utils degrees:locationA.latitude];
//    CLLocationDegrees a_lng_ = [Utils degrees:locationA.longitude];
//    
//    CLLocationDegrees b_lat_ = [Utils degrees:locationB.latitude];
//    CLLocationDegrees b_lng_ = [Utils degrees:locationB.longitude];
//    
//    CLLocation *locA_ = [[CLLocation alloc] initWithLatitude:a_lat_ longitude:a_lng_];
//    
//    CLLocation *locB_ = [[CLLocation alloc] initWithLatitude:b_lat_ longitude:b_lng_];
//    
//    CLLocationDistance distance = [locA_ distanceFromLocation:locB_];
//    
//    //Distance in Meters
//    //1 meter == 100 centimeter
//    
//    //1 meter == 3.280 feet
//    
//    //1 meter == 10.76 square feet
//    [locA_ release];
//    [locB_ release];
//    
//    return distance;
//}


+ (NSUInteger)amountOfFreeMemory
{
    mach_port_t             host_port = mach_host_self();
    mach_msg_type_number_t  host_size = sizeof(vm_statistics_data_t) / sizeof(integer_t);
    vm_size_t               pagesize;
    vm_statistics_data_t    vm_stat;
    
    host_page_size(host_port, &pagesize);
    
    if (host_statistics(host_port, HOST_VM_INFO, (host_info_t)&vm_stat, &host_size) != KERN_SUCCESS){
    
        PRPLog(@"Failed to fetch vm statistics [%@, %@]",
               NSStringFromClass([self class]),
               NSStringFromSelector(_cmd));
    }
    //natural_t   mem_used = (vm_stat.active_count + vm_stat.inactive_count + vm_stat.wire_count) * pagesize;
    natural_t   mem_free = vm_stat.free_count * pagesize;
    //natural_t   mem_total = mem_used + mem_free;
    
    return mem_free;
}

+ (BOOL)chkDataPathLocalExist:(NSString*)localPath
{
    BOOL isLocalPathExist = NO;
    BOOL isDir;
    BOOL exists = [[NSFileManager defaultManager] fileExistsAtPath:localPath isDirectory:&isDir];
    if (exists) {
        /* file exists */
        if (isDir) {
            isLocalPathExist = YES;
            /* file is a directory */
            PRPLog(@"localPth exixt: %@ \n \
                   -[%@ , %@]",
                   localPath,
                   NSStringFromClass([self class]),
                   NSStringFromSelector(_cmd));
            
        }
    } else {
        PRPLog(@"localPth not exixt: %@ \n \
               -[%@ , %@]",
               localPath,
               NSStringFromClass([self class]),
               NSStringFromSelector(_cmd));
    }
    return isLocalPathExist;
}



@end
