//
//  Address.h
//  snailGram
//
//  Created by Bobby Ren on 3/2/14.
//  Copyright (c) 2014 SnailGram. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Recipient;

@interface Address : NSManagedObject

@property (nonatomic, retain) NSString * city;
@property (nonatomic, retain) NSString * parseID;
@property (nonatomic, retain) NSString * state;
@property (nonatomic, retain) NSString * street;
@property (nonatomic, retain) NSString * street2;
@property (nonatomic, retain) NSString * zip;
@property (nonatomic, retain) NSSet *inhabitants;
@end

@interface Address (CoreDataGeneratedAccessors)

- (void)addInhabitantsObject:(Recipient *)value;
- (void)removeInhabitantsObject:(Recipient *)value;
- (void)addInhabitants:(NSSet *)values;
- (void)removeInhabitants:(NSSet *)values;

@end
