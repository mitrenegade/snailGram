//
//  PostCard.h
//  snailGram
//
//  Created by Bobby Ren on 3/20/14.
//  Copyright (c) 2014 SnailGram. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "ParseBase.h"

@class Address, Payment;

@interface PostCard : ParseBase

@property (nonatomic, retain) NSString * image_url;
@property (nonatomic, retain) NSString * image_url_back;
@property (nonatomic, retain) NSString * message;
@property (nonatomic, retain) NSString * text;
@property (nonatomic, retain) Address *to;
@property (nonatomic, retain) NSSet *payments;
@end

@interface PostCard (CoreDataGeneratedAccessors)

- (void)addPaymentsObject:(Payment *)value;
- (void)removePaymentsObject:(Payment *)value;
- (void)addPayments:(NSSet *)values;
- (void)removePayments:(NSSet *)values;

@end
