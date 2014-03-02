//
//  NSManagedObject+Entity.h
//  hellobear_ios
//
//  Created by Bobby Ren on 12/29/13.
//  Copyright (c) 2013 Bobby Ren. All rights reserved.
//

#import <CoreData/CoreData.h>

@interface NSManagedObject (Entity)

+(NSManagedObject *)createEntityInContext:(NSManagedObjectContext *)managedObjectContext;

@end
