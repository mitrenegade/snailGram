//
//  PostCard.h
//  snailGram
//
//  Created by Bobby Ren on 3/28/14.
//  Copyright (c) 2014 SnailGram. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "ParseBase.h"

@class Address, Payment;

@interface PostCard : ParseBase

@property (nonatomic, retain) NSNumber * back_loaded;
@property (nonatomic, retain) NSNumber * front_loaded;
@property (nonatomic, retain) NSString * message;
@property (nonatomic, retain) NSString * payment_id;
@property (nonatomic, retain) NSString * text;
@property (nonatomic, retain) Payment *payment;
@property (nonatomic, retain) Address *to;

@end
