//
//  FiksuTrackingManager.h
//
//  Copyright 2012 Fiksu, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface FiksuTrackingManager : NSObject

+ (void)applicationDidFinishLaunching:(NSDictionary*)launchOptions;

+ (void)setClientID:(NSString*)clientID;
+ (NSString*)clientID;

+ (void)setAppTrackingEnabled:(BOOL)enabled;
+ (BOOL)isAppTrackingEnabled;

+ (BOOL)handleURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication;

+ (void)uploadEvent:(NSString *)event withInfo:(NSDictionary *)eventInfo;
+ (void)uploadRegistrationEvent:(NSString *)username;
+ (void)uploadPurchaseEvent:(NSString *)username currency:(NSString *)currency;
+ (void)uploadPurchaseEvent:(NSString *)username price:(double)price currency:(NSString *)currency;
+ (void)uploadCustomEvent;

@end
