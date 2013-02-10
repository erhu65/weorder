
#import "Record.h"

@interface Record ()
@property (nonatomic, strong, readwrite) NSDate *date;
@end

@implementation Record
{
	NSMutableArray *_values;
}

- (id)initWithDate:(NSDate *)date values:(NSArray *)values
{
	if ((self = [super init]))
	{
		self.date = date;
		_values = [values mutableCopy];
	}
	return self;
}

- (int)total
{
	__block int total = 0;
    
	[self.values enumerateObjectsUsingBlock:^(NSNumber *number, NSUInteger idx, BOOL *stop)
	{
		total += [number intValue];
	}];

	return total;
}

- (NSDateFormatter *)dateFormatter
{
	static NSDateFormatter *dateFormatter;
	if (dateFormatter == nil)
	{
		dateFormatter = [[NSDateFormatter alloc] init];
		[dateFormatter setDateStyle:NSDateFormatterMediumStyle];
		[dateFormatter setTimeStyle:NSDateFormatterNoStyle];
	}
	return dateFormatter;
}

- (NSArray *)values
{
	return _values;
}

- (NSString *)dateForDisplay
{
	return [self.dateFormatter stringFromDate:self.date];
}

- (void)deleteValueAtIndex:(NSUInteger)index
{
	[_values removeObjectAtIndex:index];
}

- (void)replaceValue:(int)value atIndex:(NSUInteger)index
{
	_values[index] = @(value);
}

@end
