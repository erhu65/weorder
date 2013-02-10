
@interface DataModel : NSObject

@property (nonatomic, strong, readonly) NSArray *sortedSectionNames;
@property (nonatomic, strong, readonly) NSArray *sortedItems;

- (void)sortByValue;
- (void)clearSortedItems;

- (id)objectForKeyedSubscript:(id)key;
- (id)objectAtIndexedSubscript:(NSUInteger)idx;

@end
