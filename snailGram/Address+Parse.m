//
//  Address+Parse.m
//  snailGram
//
//  Created by Bobby Ren on 3/2/14.
//  Copyright (c) 2014 SnailGram. All rights reserved.
//

#import "Address+Parse.h"

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
    [super updateFromParse];

    self.name = self.pfObject[@"name"];
    self.street = self.pfObject[@"street"];
    self.street2 = self.pfObject[@"street2"];
    self.city = self.pfObject[@"city"];
    self.state = self.pfObject[@"state"];
    self.zip = self.pfObject[@"zip"];
    self.parseID = self.pfObject.objectId;

    // user will be already included in self.pfObject[@"user"]
}

-(void)saveOrUpdateToParseWithCompletion:(void (^)(BOOL))completion {
    if (!self.pfObject)
        self.pfObject = [PFObject objectWithClassName:self.className];

    if (self.name)
        self.pfObject[@"name"] = self.name;
    if (self.street)
        self.pfObject[@"street"] = self.street;
    if (self.street2)
        self.pfObject[@"street2"] = self.street2;
    if (self.city)
        self.pfObject[@"city"] = self.city;
    if (self.state)
        self.pfObject[@"state"] = self.state;
    if (self.zip)
        self.pfObject[@"zip"] = self.zip;

    // add user to pfObject
    if (_currentUser) {
        self.pfObject[@"user"] = _currentUser;
        self.pfObject[@"pfUserID"] = _currentUser.objectId;
    }

    [self.pfObject saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (succeeded)
            self.parseID = self.pfObject.objectId;
        if (completion)
            completion(succeeded);
    }];
}

@end
