#import "NSObject+Notify.h"

@implementation NSObject (Notify)

-(void)listenFor:(NSString *)notificationName action:(SEL)sel {
    [self listenFor:notificationName action:sel object:nil];
}

-(void)listenFor:(NSString *)notificationName action:(SEL)sel object:(id)obj {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:sel name:notificationName object:obj];
}

-(void)stopListeningFor:(NSString *)notificationName {
    [self stopListeningFor:notificationName object:nil];
}

-(void)stopListeningFor:(NSString *)notificationName object:(id)obj {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:notificationName object:obj];
}

-(void)notify:(NSString *)notificationName {
    [self notify:notificationName object:nil userInfo:nil];
}

-(void)notify:(NSString *)notificationName object:(id)obj userInfo:(NSDictionary *)userInfo {
    [[NSNotificationCenter defaultCenter] postNotificationName:notificationName object:obj userInfo:userInfo];
}
@end
