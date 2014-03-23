//
//  Payment.h
//  snailGram
//
//  Created by Bobby Ren on 3/22/14.
//  Copyright (c) 2014 SnailGram. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "ParseBase.h"

@class PostCard;

@interface Payment : ParseBase

@property (nonatomic, retain) NSString * create_time;
@property (nonatomic, retain) NSData * data;
@property (nonatomic, retain) NSString * intent;
@property (nonatomic, retain) NSString * paypal_id;
@property (nonatomic, retain) NSString * post_card_id;
@property (nonatomic, retain) NSString * state;
@property (nonatomic, retain) PostCard *postcard;

@end
