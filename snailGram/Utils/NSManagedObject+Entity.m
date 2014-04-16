#import "NSManagedObject+Entity.h"

@implementation NSManagedObject (Entity)
+(NSManagedObject *)createEntityInContext:(NSManagedObjectContext *)managedObjectContext {
    NSString *name = [[self class] description];
    NSManagedObject *object = [NSEntityDescription insertNewObjectForEntityForName:name inManagedObjectContext:managedObjectContext];

    return object;
}

-(void)updateEntityWithParams:(NSDictionary *)params {
    NSLog(@"Attributes available: %@", [self.entity attributesByName]);
    [self setValuesForKeysWithDictionary:params];
}
@end
