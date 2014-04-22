#import <Foundation/Foundation.h>

@interface Query : NSObject
{
    NSArray *predicates;
    NSArray *sortDescriptors;
}

-(id)initWithPredicates:(NSArray *)otherPredicates;

@property (nonatomic, strong) NSString *entityDescription;

-(Query *)where:(NSDictionary *)attributes;
-(Query *)lte:(NSDictionary *)attributes;
-(Query *)gte:(NSDictionary *)attributes;
-(Query *)not:(NSDictionary *)attributes;
-(NSArray *)all;
-(Query *)ascending:(id)attribute;
-(Query *)descending:(id)attribute;
@end
