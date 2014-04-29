//
//  AppDelegate.h
//  snailGram
//
//  Created by Bobby Ren on 3/1/14.
//  Copyright (c) 2014 SnailGram. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ShellViewController.h"

@class PFUser;
@class PostCard;
@interface AppDelegate : UIResponder <UIApplicationDelegate, UIAlertViewDelegate>
{
    PostCard *postCard;
}
@property (strong, nonatomic) UIWindow *window;
@property (nonatomic, retain, readonly) NSManagedObjectModel *managedObjectModel;
@property (nonatomic, retain, readonly) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, retain, readonly) NSPersistentStoreCoordinator *persistentStoreCoordinator;

@property (nonatomic, strong) PostCard *postCard;

-(void)resetPostcard;
-(void)loadPostcardWithCompletion:(void(^)(BOOL success))completion;
-(PFUser *)currentUser;
-(void)promptForEmail:(NSString *)title message:(NSString *)message;

@end
