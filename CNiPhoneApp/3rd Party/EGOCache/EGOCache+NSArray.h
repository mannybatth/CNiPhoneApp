#import "EGOCache.h"

@interface EGOCache (NSArray)

- (void)setArray:(NSArray*)array forKey:(NSString*)key;
- (void)setArray:(NSArray*)array forKey:(NSString*)key withTimeoutInterval:(NSTimeInterval)timeoutInterval;

- (NSArray*)arrayForKey:(NSString*)key;
@end