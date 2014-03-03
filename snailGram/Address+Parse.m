//
//  Address+Parse.m
//  snailGram
//
//  Created by Bobby Ren on 3/2/14.
//  Copyright (c) 2014 SnailGram. All rights reserved.
//

#import "Address+Parse.h"
#import <Parse/Parse.h>
#import <objc/runtime.h>

@implementation Address (Parse)

-(NSString *)className {
    return @"Address";
}

+(Address *)fromPFObject:(PFObject *)object {
    id parseID = object.objectId;
    NSArray *objectArray = [[Address where:@{@"id":parseID}] all];
    Address *address;
    if ([objectArray count]) {
        address = [objectArray firstObject];
    }
    else {
        address = (Address *)[Address createEntityInContext:_appDelegate.managedObjectContext];
    }
    address.pfObject = object;
    [address updateFromParse];
    return address;
}

-(void)updateFromParse {
    self.name = self.pfObject[@"name"];
    self.street = self.pfObject[@"street"];
    self.street2 = self.pfObject[@"street2"];
    self.city = self.pfObject[@"city"];
    self.state = self.pfObject[@"state"];
    self.zip = self.pfObject[@"zip"];
    self.parseID = self.pfObject.objectId;
}

-(void)saveOrUpdateToParseWithCompletion:(void (^)(BOOL))completion {
    if (!self.pfObject)
        self.pfObject = [PFObject objectWithClassName:self.className];

    self.pfObject[@"name"] = self.name;
    self.pfObject[@"street"] = self.street;
    self.pfObject[@"street2"] = self.street2;
    self.pfObject[@"city"] = self.city;
    self.pfObject[@"state"] = self.state;
    self.pfObject[@"zip"] = self.zip;

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
