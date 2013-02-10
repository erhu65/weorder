//
//  ErrorHandler.h
//  Recipe 1-10: Default Error Handling
//
//  Created by Hans-Eric Grönlund on 8/31/12.
//  Copyright (c) 2012 Hans-Eric Grönlund. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ErrorHandler : NSObject<UIAlertViewDelegate>

@property (strong, nonatomic)NSError *error;
@property (nonatomic)BOOL fatalError;

-(id)initWithError:(NSError *)error fatal:(BOOL)fatalError;

+(void)handleError:(NSError *)error fatal:(BOOL)fatalError;


@end
