#import <CoreData/CoreData.h>

@interface NSManagedObject (Entity)

+(NSManagedObject *)createEntityInContext:(NSManagedObjectContext *)managedObjectContext;
-(void)updateEntityWithParams:(NSDictionary *)params;

@end
