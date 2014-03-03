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
    else if (self.street2)
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

@end
