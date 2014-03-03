//
//  PFObjectFactory.h
//  NightPulse
//
//  Created by Sachin Nene on 9/22/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Parse/Parse.h>

static char const * const PFObjectTagKey = "PFObjectTagKey";

@protocol PFObjectFactory

+(Address *)fromPFObject:(PFObject *)object;
-(void)updateFromParse;
-(void)saveOrUpdateToParseWithCompletion:(void(^)(BOOL success))completion;

@property (nonatomic, retain) NSString * className;
@property (nonatomic, retain) PFObject *pfObject;

@end
