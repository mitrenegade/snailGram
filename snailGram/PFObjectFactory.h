//
//  PFObjectFactory.h
//  NightPulse
//
//  Created by Sachin Nene on 9/22/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Parse/Parse.h>

@protocol PFObjectFactory

+(Address *)fromPFObject:(PFObject *)object;
-(void)updateFromParse;
-(void)saveOrUpdateToParse;

@property (nonatomic, retain) NSString * className;
@property (nonatomic, retain) PFObject *pfObject;

@end
