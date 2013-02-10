
@interface Item : NSObject

+ (id)itemWithName:(NSString *)name value:(NSNumber *)value;

- (id)initWithName:(NSString *)name value:(NSNumber *)value;

@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSNumber *value;

@end
