//
//  NSManagedObject+Query.h
//  GymPact
//
//  Created by Bobby Ren on 10/22/13.
//  Copyright (c) 2013 Harvard University. All rights reserved.
//

#import <CoreData/CoreData.h>
#import "Query.h"

@interface NSManagedObject (Query)
+(Query *)where:(NSDictionary *)conditions;

@end
