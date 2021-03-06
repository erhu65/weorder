/*
 * Copyright 2010-2012 Amazon.com, Inc. or its affiliates. All Rights Reserved.
 *
 * Licensed under the Apache License, Version 2.0 (the "License").
 * You may not use this file except in compliance with the License.
 * A copy of the License is located at
 *
 *  http://aws.amazon.com/apache2.0
 *
 * or in the "license" file accompanying this file. This file is distributed
 * on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either
 * express or implied. See the License for the specific language governing
 * permissions and limitations under the License.
 */

#import "ElasticLoadBalancingInstance.h"

#import "ElasticLoadBalancingResponse.h"
#import "../AmazonServiceExceptionUnmarshaller.h"

#import "ElasticLoadBalancingInvalidInstanceException.h"
#import "ElasticLoadBalancingLoadBalancerNotFoundException.h"


/**
 * Register Instances With Load Balancer Result
 */

@interface ElasticLoadBalancingRegisterInstancesWithLoadBalancerResponse:ElasticLoadBalancingResponse

{
    NSMutableArray *instances;
}



-(void)setException:(AmazonServiceException *)theException;


/**
 * Default constructor for a new  object.  Callers should use the
 * property methods to initialize this object after creating it.
 */
-(id)init;

/**
 * An updated list of instances for the LoadBalancer.
 */
@property (nonatomic, retain) NSMutableArray *instances;



/**
 * Returns a value from the instances array for the specified index
 */
-(ElasticLoadBalancingInstance *)instancesObjectAtIndex:(int)index;

/**
 * Returns a string representation of this object; useful for testing and
 * debugging.
 *
 * @return A string representation of this object.
 */
-(NSString *)description;


@end
