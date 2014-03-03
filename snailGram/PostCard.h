//
//  PostCard.h
//  snailGram
//
//  Created by Bobby Ren on 3/2/14.
//  Copyright (c) 2014 SnailGram. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Address;

@interface PostCard : NSManagedObject

@property (nonatomic, retain) NSString * parseID;
@property (nonatomic, retain) NSString * image_url;
@property (nonatomic, retain) NSString * message;
@property (nonatomic, retain) Address *from;
@property (nonatomic, retain) Address *to;

@end
