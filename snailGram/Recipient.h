//
//  Recipient.h
//  snailGram
//
//  Created by Bobby Ren on 3/2/14.
//  Copyright (c) 2014 SnailGram. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Address;

@interface Recipient : NSManagedObject

@property (nonatomic, retain) NSString * email;
@property (nonatomic, retain) NSString * parseID;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * phone;
@property (nonatomic, retain) NSSet *addresses;
@end

@interface Recipient (CoreDataGeneratedAccessors)

- (void)addAddressesObject:(Address *)value;
- (void)removeAddressesObject:(Address *)value;
- (void)addAddresses:(NSSet *)values;
- (void)removeAddresses:(NSSet *)values;

@end
