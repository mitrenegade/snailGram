//
//  Address.h
//  snailGram
//
//  Created by Bobby Ren on 3/1/14.
//  Copyright (c) 2014 SnailGram. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Address : NSManagedObject

@property (nonatomic, retain) NSString * street;
@property (nonatomic, retain) NSString * city;
@property (nonatomic, retain) NSString * state;
@property (nonatomic, retain) NSNumber * zip;
@property (nonatomic, retain) NSString * id;
@property (nonatomic, retain) NSSet *inhabitants;
@end

@interface Address (CoreDataGeneratedAccessors)

- (void)addInhabitantsObject:(NSManagedObject *)value;
- (void)removeInhabitantsObject:(NSManagedObject *)value;
- (void)addInhabitants:(NSSet *)values;
- (void)removeInhabitants:(NSSet *)values;

@end
