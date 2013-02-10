/******************************************************************************
 * Copyright (c) 2010, Maher Ali <maher.ali@gmail.com>
 * Advanced iOS 4 Programming: Developing Mobile Applications for Apple iPhone, iPad, and iPod touch
 *
 * Permission is hereby granted, free of charge, to any person obtaining a
 * copy of this software and associated documentation files (the "Software"),
 * to deal in the Software without restriction, including without limitation
 * the rights to use, copy, modify, merge, publish, distribute, sublicense,
 * and/or sell copies of the Software, and to permit persons to whom the
 * Software is furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included
 * in all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
 * OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
 * THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
 * FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
 * DEALINGS IN THE SOFTWARE.
 ******************************************************************************/

#import "Connectivity.h"

#define EXTERNAL_HOST @"google.com"

@implementation UIDevice (DeviceConnectivity)

+(BOOL)cellularConnected{// EDGE or GPRS
  SCNetworkReachabilityFlags    flags = 0;
  SCNetworkReachabilityRef      netReachability = NULL;
  
  netReachability     = SCNetworkReachabilityCreateWithName(CFAllocatorGetDefault(), [EXTERNAL_HOST UTF8String]);
  if(netReachability){
    SCNetworkReachabilityGetFlags(netReachability, &flags);
    CFRelease(netReachability);
  }
  if(flags & kSCNetworkReachabilityFlagsIsWWAN){
    return YES;
  }
  return NO;
}

+(BOOL)wiFiConnected{
  if([self cellularConnected]){
    return NO;
  }
  return [self networkConnected];
}

+(BOOL)networkConnected{
  SCNetworkReachabilityFlags     flags = 0;
  SCNetworkReachabilityRef       netReachability = NULL;
  BOOL                           retrievedFlags = NO;
  
  netReachability     = SCNetworkReachabilityCreateWithName(CFAllocatorGetDefault(), [EXTERNAL_HOST UTF8String]);
  if(netReachability){
    retrievedFlags      = SCNetworkReachabilityGetFlags(netReachability, &flags);
    CFRelease(netReachability);
  }
  if (!retrievedFlags || !flags){
    return NO;
  }
  return YES;
}

@end
