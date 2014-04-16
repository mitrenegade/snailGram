#import <Foundation/Foundation.h>

@interface Util : NSObject

+(void)easyRequest:(NSString *)endpoint method:(NSString *)method params:(id)params completion:(void(^)(NSDictionary *, NSError *))completion;
+(NSString *)timeStringForDate:(NSDate *)date;
+ (NSString *)timeAgo:(NSDate *)date;
+ (NSString *)simpleTimeAgo:(NSDate *)date;

@end
