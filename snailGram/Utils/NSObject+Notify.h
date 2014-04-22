#import <Foundation/Foundation.h>

@interface NSObject (Notify)

-(void)listenFor:(NSString *)notificationName action:(SEL)sel;
-(void)stopListeningFor:(NSString *)notificationName;

-(void)listenFor:(NSString *)notificationName action:(SEL)sel object:(id)obj;
-(void)stopListeningFor:(NSString *)notificationName object:(id)obj;

-(void)notify:(NSString *)notificationName;
-(void)notify:(NSString *)notificationName object:(id)obj userInfo:(NSDictionary *)userInfo;
@end
