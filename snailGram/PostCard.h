//
//  PostCard.h
//  snailGram
//
//  Created by Bobby Ren on 4/30/15.
//  Copyright (c) 2015 SnailGram. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "ParseBase.h"

@class Address, Payment;

@interface PostCard : ParseBase

@property (nonatomic, retain) NSNumber * back_loaded;
@property (nonatomic, retain) NSNumber * front_loaded;
@property (nonatomic, retain) NSString * image_url;
@property (nonatomic, retain) NSString * image_url_back;
@property (nonatomic, retain) NSString * image_url_full;
@property (nonatomic, retain) NSString * message;
@property (nonatomic, retain) NSString * payment_id;
@property (nonatomic, retain) NSString * text;
@property (nonatomic, retain) NSNumber * is_testing;
@property (nonatomic, retain) Payment *payment;
@property (nonatomic, retain) Address *to;

@end
