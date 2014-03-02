//
//  NSManagedObject+Query.m
//  GymPact
//
//  Created by Bobby Ren on 10/22/13.
//  Copyright (c) 2013 Harvard University. All rights reserved.
//

#import "NSManagedObject+Query.h"
#import "Query.h"

@implementation NSManagedObject (Query)

+(Query *)where:(NSDictionary *)attributes {
    Query *query = [[Query alloc] initWithPredicates:@[]];
    [query setEntityDescription:[[self class] description]];
    return [query where:attributes];
}

@end
