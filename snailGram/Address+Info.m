//
//  Address+Info.m
//  snailGram
//
//  Created by Bobby Ren on 3/1/14.
//  Copyright (c) 2014 SnailGram. All rights reserved.
//

#import "Address+Info.h"

@implementation Address (Info)

-(NSString *)toString {
    NSString *string = @"";
    if (self.name)
        string = [NSString stringWithFormat:@"%@\n", self.name];
    if (self.street)
        string = [NSString stringWithFormat:@"%@%@\n", string, self.street];
    if (self.street2)
        string = [NSString stringWithFormat:@"%@%@\n", string, self.street2];

    NSString *citystate = @"";
    if ([self.city length] && [self.state length]) {
        citystate = [NSString stringWithFormat:@"%@, %@", self.city, self.state];
    }
    else if ([self.city length])
        citystate = self.city;
    else if ([self.state length])
        citystate = self.state;

    if ([citystate length]) {
        string = [NSString stringWithFormat:@"%@%@\n", string, citystate];
    }

    if (self.zip) {
        string = [NSString stringWithFormat:@"%@%@", string, self.zip];
    }

    return string;
}

+(Address *)createWithInfo:(NSDictionary *)userInfo inContext:(NSManagedObjectContext *)context {
    return [self createInContext:context withName:userInfo[@"name"] street:userInfo[@"street"] street2:userInfo[@"street2"] city:userInfo[@"city"] state:userInfo[@"state"] zip:userInfo[@"zip"]];
}

+(Address *)createInContext:(NSManagedObjectContext *)context withName:(NSString *)name street:(NSString *)street street2:(NSString *)street2 city:(NSString *)city state:(NSString *)state zip:(NSString *)zip {

    if (!name)
        return nil;

    Address *addr = (Address *)[Address createEntityInContext:context];
    addr.name = name;
    if (street)
        addr.street = street;
    if (street2)
        addr.street2 = street2;
    if (city)
        addr.city = city;
    if (state)
        addr.state = state;
    if (zip)
        addr.zip = zip;
    NSError *error;
    if ([context save:&error])
        return addr;

    return nil;
}

@end
