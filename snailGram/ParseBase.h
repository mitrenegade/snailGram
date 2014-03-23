//
//  ParseBase.h
//  snailGram
//
//  Created by Bobby Ren on 3/22/14.
//  Copyright (c) 2014 SnailGram. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface ParseBase : NSManagedObject

@property (nonatomic, retain) NSDate * createdAt;
@property (nonatomic, retain) NSString * parseID;
@property (nonatomic, retain) NSDate * updatedAt;
@property (nonatomic, retain) NSString * pfUserID;

-(void)updateFromParse;
@end
