
@interface Record : NSObject

@property (nonatomic, strong, readonly) NSDate *date;
@property (nonatomic, strong, readonly) NSArray *values;
@property (nonatomic, assign, readonly) int total;

- (id)initWithDate:(NSDate *)date values:(NSArray *)values;

- (NSString *)dateForDisplay;

- (void)deleteValueAtIndex:(NSUInteger)index;
- (void)replaceValue:(int)value atIndex:(NSUInteger)index;

@end
