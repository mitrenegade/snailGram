//
//  Address+Info.h
//  snailGram
//
//  Created by Bobby Ren on 3/1/14.
//  Copyright (c) 2014 SnailGram. All rights reserved.
//

#import "Address.h"

@interface Address (Info)
-(NSString *)toString;


+(Address *)createWithInfo:(NSDictionary *)userInfo inContext:(NSManagedObjectContext *)context;
+(Address *)createInContext:(NSManagedObjectContext *)context withName:(NSString *)name street:(NSString *)street street2:(NSString *)street2 city:(NSString *)city state:(NSString *)state zip:(NSString *)zip;

@end
