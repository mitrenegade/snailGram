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
    if (self.street && self.street2)
        string = [NSString stringWithFormat:@"%@\n%@", self.street, self.street2];
    else if (self.street)
        string = self.street;
    else if (self.street2)
        string = self.street2;

    NSString *citystate = @"";
    if (self.city && self.state) {
        citystate = [NSString stringWithFormat:@"%@, %@", self.city, self.state];
    }
    else if (self.city)
        citystate = self.city;
    else if (self.state)
        citystate = self.state;

    if ([string length] && [citystate length]) {
        string = [NSString stringWithFormat:@"%@\n%@", string, citystate];
    }

    if (self.zip) {
        string = [NSString stringWithFormat:@"%@\n%@", string, self.zip];
    }

    return string;
}

@end
