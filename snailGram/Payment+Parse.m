//
//  Payment+Parse.m
//  snailGram
//
//  Created by Bobby Ren on 3/20/14.
//  Copyright (c) 2014 SnailGram. All rights reserved.
//

#import "Payment+Parse.h"
#import <Parse/Parse.h>
#import <objc/runtime.h>
#import "PostCard+Parse.h"

@implementation Payment (Parse)

-(NSString *)className {
    return @"Payment";
}

+(Payment *)fromPFObject:(PFObject *)object {
    id parseID = object.objectId;
    NSArray *objectArray = [[Payment where:@{@"id":parseID}] all];
    Payment *obj;
    if ([objectArray count]) {
        obj = [objectArray firstObject];
    }
    else {
        obj = (Payment *)[Payment createEntityInContext:_appDelegate.managedObjectContext];
    }
    obj.pfObject = object;
    [obj updateFromParse];
    return obj;
}

-(void)updateFromParse {
    self.intent = self.pfObject[@"intent"];
    self.state = self.pfObject[@"state"];
    self.paypal_id = self.pfObject[@"paypal_id"];
    self.create_time = self.pfObject[@"create_time"];
    self.post_card_id = self.pfObject[@"post_card_id"];

    // relationships
    //self.postcard = self.pfObject[@"postcard"];
}

-(void)saveOrUpdateToParseWithCompletion:(void (^)(BOOL))completion {
    if (!self.pfObject)
        self.pfObject = [PFObject objectWithClassName:self.className];

    if (self.intent)
        self.pfObject[@"intent"] = self.intent;
    if (self.state)
        self.pfObject[@"state"] = self.state;
    if (self.paypal_id)
        self.pfObject[@"paypal_id"] = self.paypal_id;
    if (self.create_time)
        self.pfObject[@"create_time"] = self.create_time;
    if (self.post_card_id)
        self.pfObject[@"post_card_id"] = self.post_card_id;

    // relationships
    // do not save the postcard object relationship because Parse will get stuck in an infinite loop. only store the actual relationship on the main object, so postcard.pfObject should have a payment, but a payment should not point to the postcard on Parse
    //if (self.postcard)
    //    self.pfObject[@"postcard"] = self.postcard.pfObject;

    // use save eventually to handle low internet conditions
    [self.pfObject saveEventually:^(BOOL succeeded, NSError *error) {
        if (succeeded)
            self.parseID = self.pfObject.objectId;
        if (completion)
            completion(succeeded);
    }];
}

#pragma mark Instance variable for category
// http://oleb.net/blog/2011/05/faking-ivars-in-objc-categories-with-associative-references/
// use associative reference in order to add a new instance variable in a category

-(PFObject *)pfObject {
    return objc_getAssociatedObject(self, PFObjectTagKey);
}

-(void)setPfObject:(PFObject *)pfObject {
    objc_setAssociatedObject(self, PFObjectTagKey, pfObject, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

@end
