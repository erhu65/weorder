//
//  BRBRRecordBase.h
//  BirthdayReminder
//
//  Created by Peter2 on 12/18/12.
//  Copyright (c) 2012 Nick Kuh. All rights reserved.
//


@interface BRRecordBase : NSObject


@property(nonatomic, strong)NSString* strImgUrl;
@property(nonatomic, strong)NSURL* awsS3ImgUrl;
@property(nonatomic, strong)NSData* dataImg;
@end
