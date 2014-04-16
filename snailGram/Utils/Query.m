#import "Query.h"

@interface Query ()
@property (nonatomic, strong) NSArray *sortDescriptors;
@end

@implementation Query
@synthesize sortDescriptors;

-(id)initWithPredicates:(NSArray *)otherPredicates {
    self = [super init];
    if (self) {
        predicates = [NSArray arrayWithArray:otherPredicates];
    }
    return self;
}

-(NSArray *)all {
    NSFetchRequest *request = [self request];

    if (self.sortDescriptors)
        [request setSortDescriptors:self.sortDescriptors];

    NSError *error  = nil;
    NSArray *fetchedObjects = [_appDelegate.managedObjectContext executeFetchRequest:request error:&error];

    return fetchedObjects.count ? fetchedObjects : @[];
}

-(Query *)where:(NSDictionary *)attributes {
    NSMutableArray *newPredicates = [NSMutableArray array];
    for (id key in attributes) {
        id attribute = attributes[key];
        NSPredicate *predicate;
        if ([attribute isEqual:[NSNull null]]) {
            predicate = [NSPredicate predicateWithFormat:@"%K = nil", key];
        }
        else {
            predicate = [NSPredicate predicateWithFormat:@"%K = %@", key, attribute];
        }
        [newPredicates addObject:predicate];
    }

    Query * newQuery = [[Query alloc] initWithPredicates:[predicates arrayByAddingObjectsFromArray:newPredicates]];
    [newQuery setEntityDescription:self.entityDescription];
    return newQuery;
}

-(Query *)not:(NSDictionary *)attributes {
    NSMutableArray *newPredicates = [NSMutableArray array];
    for (id key in attributes) {
        id attribute = attributes[key];
        NSPredicate *predicate;
        if ([attribute isEqual:[NSNull null]]) {
            predicate = [NSPredicate predicateWithFormat:@"%K != nil", key];
        }
        else {
            predicate = [NSPredicate predicateWithFormat:@"%K = nil OR %K != %@", key, key, attribute];
        }
        [newPredicates addObject:predicate];
    }

    Query * newQuery = [[Query alloc] initWithPredicates:[predicates arrayByAddingObjectsFromArray:newPredicates]];
    [newQuery setEntityDescription:self.entityDescription];
    return newQuery;
}

-(Query *)lte:(NSDictionary *)attributes {
    NSMutableArray *newPredicates = [NSMutableArray array];
    for (id key in attributes) {
        id attribute = attributes[key];
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"%K <= %@", key, attribute];
        [newPredicates addObject:predicate];
    }

    Query * newQuery = [[Query alloc] initWithPredicates:[predicates arrayByAddingObjectsFromArray:newPredicates]];
    [newQuery setEntityDescription:self.entityDescription];
    return newQuery;
}

-(Query *)gte:(NSDictionary *)attributes {
    NSMutableArray *newPredicates = [NSMutableArray array];
    for (id key in attributes) {
        id attribute = attributes[key];
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"%K >= %@", key, attribute];
        [newPredicates addObject:predicate];
    }

    Query * newQuery = [[Query alloc] initWithPredicates:[predicates arrayByAddingObjectsFromArray:newPredicates]];
    [newQuery setEntityDescription:self.entityDescription];
    return newQuery;
}

-(Query *)ascending:(id)attribute {
    NSSortDescriptor * sortDescriptor = [[NSSortDescriptor alloc] initWithKey:attribute ascending:YES];

    Query * newQuery = [[Query alloc] initWithPredicates:predicates];
    newQuery.sortDescriptors = @[sortDescriptor];

    [newQuery setEntityDescription:self.entityDescription];
    return newQuery;
}

-(Query *)descending:(id)attribute {
    NSSortDescriptor * sortDescriptor = [[NSSortDescriptor alloc] initWithKey:attribute ascending:NO];

    Query * newQuery = [[Query alloc] initWithPredicates:predicates];
    newQuery.sortDescriptors = @[sortDescriptor];

    [newQuery setEntityDescription:self.entityDescription];
    return newQuery;
}

-(NSFetchRequest *)request {
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:self.entityDescription];
    
    [request setPredicate:[NSCompoundPredicate andPredicateWithSubpredicates:predicates]];
    
    return request;
}

@end
