//
//  AppDelegate.m
//  snailGram
//
//  Created by Bobby Ren on 3/1/14.
//  Copyright (c) 2014 SnailGram. All rights reserved.
//

#import "AppDelegate.h"
#import <Parse/Parse.h>

@implementation AppDelegate

@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.

    [Parse setApplicationId:@"054wtpQbuRXuzIVeY2ajbApfzZcqB5L7YJKPSNYQ"
                  clientKey:@"MyRaB1A2neqSRCGVq71qamBAsdtRS9PMjS2YuYs3"];
    [PFAnalytics trackAppOpenedWithLaunchOptions:launchOptions];

    [self setupUserForCurrentDevice];

    return YES;
}
							
- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

-(PostCard *)postCard {
    if (!postCard)
        [self resetPostcard];
    return postCard;
}

-(void)resetPostcard {
    postCard = (PostCard *)[PostCard createEntityInContext:_appDelegate.managedObjectContext];

    postCard.message = @"";
    postCard.to = nil;
    postCard.text = @"";
    postCard.image_url = @"";
    postCard.image_url_back = @"";
}

#pragma mark CoreData
- (NSManagedObjectContext *) managedObjectContext {
    if (_managedObjectContext != nil) {
        return _managedObjectContext;
    }
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil) {
        _managedObjectContext = [[NSManagedObjectContext alloc] init];
        [_managedObjectContext setPersistentStoreCoordinator: coordinator];
    }
    else {
        NSLog(@"Error no persistent store");
    }

    return _managedObjectContext;
}

- (NSManagedObjectModel *)managedObjectModel {
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    _managedObjectModel = [NSManagedObjectModel mergedModelFromBundles:nil];

    return _managedObjectModel;
}

- (NSPersistentStoreCoordinator *)persistentStoreCoordinator {
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }
    NSURL *storeUrl = [NSURL fileURLWithPath: [[self applicationDocumentsDirectory]
                                               stringByAppendingPathComponent: @"helloBear.sqlite"]];
    NSError *error = nil;
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc]
                                   initWithManagedObjectModel:[self managedObjectModel]];
    if(![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType
                                                  configuration:nil URL:storeUrl options:nil error:&error]) {
        /*Error for store creation should be handled in here*/
    }

    return _persistentStoreCoordinator;
}

- (NSString *)applicationDocumentsDirectory {
    return [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
}

#pragma mark parse user
-(void)setupUserForCurrentDevice {
    // set up user
    //[UIPasteboard removePasteboardWithName:PASTEBOARD_NAME];
    UIPasteboard *appPasteBoard = [UIPasteboard pasteboardWithName:PASTEBOARD_NAME create:YES];
    appPasteBoard.persistent = YES;

    NSData* userData = [appPasteBoard valueForPasteboardType:PASTEBOARD_KEY_USERID];
    if (userData) {
        NSString *userID = [NSString stringWithUTF8String:[userData bytes]];
        NSLog(@"UserID Saved: %@", userID);

        [PFUser logInWithUsernameInBackground:userID password:userID block:^(PFUser *user, NSError *error) {
            if (error) {
                NSLog(@"Error: %@", error);
            }
            else {
                NSLog(@"Current user: %@", _currentUser);
            }
        }];
    }
    else {
        // generate an anonmymous user and store the id in the pasteboard
        [PFUser enableAutomaticUser];
        PFUser *user = _currentUser;
        [user saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            if (succeeded) {
                NSLog(@"User saved: %@", user.objectId);
                NSData *data = [user.objectId dataUsingEncoding:NSUTF8StringEncoding];
                [appPasteBoard setData:data forPasteboardType:PASTEBOARD_KEY_USERID];

                [user setUsername:user.objectId];
                [user setPassword:user.objectId];
                [user saveEventually];
            }
            else {
                NSLog(@"Error saving anonymous user: %@", error);
            }
        }];
    }
}
-(PFUser *)currentUser {
    return [PFUser currentUser];
}
@end
