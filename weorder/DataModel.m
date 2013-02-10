
#import "DataModel.h"
#import "Item.h"
#import "Section.h"

@interface DataModel ()
@property (nonatomic, strong, readwrite) NSArray *sortedSectionNames;
@property (nonatomic, strong, readwrite) NSArray *sortedItems;
@end

@implementation DataModel
{
	NSDictionary *dictionary;
}

- (id)init
{
	if ((self = [super init]))
	{
		Section *physics = [[Section alloc] initWithArray:@[
			[Item itemWithName:@"Avogadro" value:@6.02214129e23],
			[Item itemWithName:@"Boltzman" value:@1.3806503e-23],
			[Item itemWithName:@"Planck" value:@6.626068e-34],
			[Item itemWithName:@"Rydberg" value:@1.097373e-7]
			]];

		Section *mathematics = [[Section alloc] initWithArray:@[
			[Item itemWithName:@"e" value:@2.71828183],
			[Item itemWithName:@"π" value:@3.14159265],
			[Item itemWithName:@"Pythagoras’ constant" value:@1.414213562],
			[Item itemWithName:@"Tau (τ)" value:@6.2831853]
			]];

		Section *fun = [[Section alloc] initWithArray:@[
			[Item itemWithName:@"Absolute Zero" value:@-273.15],
			[Item itemWithName:@"Beverly Hills" value:@90210],
			[Item itemWithName:@"Golden Ratio" value:@1.618],
			[Item itemWithName:@"Number of Human Bones" value:@214],
			[Item itemWithName:@"Unlucky Number" value:@13]
			]];

		dictionary = @{
			@"Physics Constants" : physics,
			@"Mathematics" : mathematics,
			@"Fun Numbers" : fun,
			};

		self.sortedSectionNames = [[dictionary allKeys] sortedArrayUsingSelector:@selector(compare:)];
	}
	return self;
}

- (void)sortByValue
{
	NSMutableArray *allItems = [NSMutableArray arrayWithCapacity:50];

	[dictionary enumerateKeysAndObjectsUsingBlock:^(NSString *key, Section *section, BOOL *stop)
	{
		[allItems addObjectsFromArray:section.items];
	}];

	self.sortedItems = [allItems sortedArrayUsingSelector:@selector(compare:)];
}

- (void)clearSortedItems
{
	self.sortedItems = nil;
}

- (id)objectForKeyedSubscript:(id)key
{
	return dictionary[key];
}

- (id)objectAtIndexedSubscript:(NSUInteger)idx
{
	return self.sortedSectionNames[idx];
}

@end

