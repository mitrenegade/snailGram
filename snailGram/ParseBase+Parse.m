//
//  ParseBase+Parse.m
//  snailGram
//
//  Created by Bobby Ren on 3/22/14.
//  Copyright (c) 2014 SnailGram. All rights reserved.
//

#import "ParseBase+Parse.h"

@implementation ParseBase (Parse)

-(NSString *)className {
    return @"ParseBase";
}

-(void)updateFromParse {
    self.createdAt = self.pfObject[@"createdAt"];
    self.updatedAt = self.pfObject[@"updatedAt"];
    self.parseID = self.pfObject[@"objectId"];
    PFUser *user = self.pfObject[@"user"];
    self.pfUserID = user.objectId;
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
