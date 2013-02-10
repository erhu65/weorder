
@interface Section : NSObject

@property (nonatomic, strong, readonly) NSArray *items;

- (id)initWithArray:(NSArray *)array;

- (id)objectAtIndexedSubscript:(NSUInteger)idx;

@end
