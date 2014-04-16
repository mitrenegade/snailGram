#import "NSManagedObject+Query.h"
#import "Query.h"

@implementation NSManagedObject (Query)

+(Query *)where:(NSDictionary *)attributes {
    Query *query = [[Query alloc] initWithPredicates:@[]];
    [query setEntityDescription:[[self class] description]];
    return [query where:attributes];
}

@end
