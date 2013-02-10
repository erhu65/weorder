
#import "Section.h"

@interface Section ()
@property (nonatomic, strong, readwrite) NSMutableArray *items;
@end

@implementation Section

- (id)initWithArray:(NSArray *)array
{
	if ((self = [super init]))
	{
		self.items = [array mutableCopy];
	}
	return self;
}

- (id)objectAtIndexedSubscript:(NSUInteger)idx
{
	return self.items[idx];
}

@end
