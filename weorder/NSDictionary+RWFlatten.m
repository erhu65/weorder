
#import "NSDictionary+RWFlatten.h"

@implementation NSDictionary (RWFlatten)

- (NSArray *)rw_flattenIntoArray
{
	NSMutableArray *allValues = [NSMutableArray arrayWithCapacity:[self count]];

	[self enumerateKeysAndObjectsUsingBlock:^(NSString *key, NSArray *array, BOOL *stop)
	{
		[allValues addObjectsFromArray:array];
	}];

	return allValues;
}

@end
