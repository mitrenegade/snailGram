//
//  Util.m
//  hellobear_ios
//
//  Created by Bobby Ren on 1/2/14.
//  Copyright (c) 2014 Bobby Ren. All rights reserved.
//

#import "Util.h"

@implementation Util
#if 0
+(void)easyRequest:(NSString *)endpoint method:(NSString *)method params:(id)params completion:(void(^)(NSDictionary *, NSError *))completion {
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];

    NSString *get;
    if ([params isKindOfClass:[NSDictionary class]])
        get = [params JSONRepresentation];
    else
        get = params;
    NSData *getData = [get dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:NO];
    NSString *getLength = [NSString stringWithFormat:@"%d", [getData length]];

    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:endpoint]];
    [request setValue:getLength forHTTPHeaderField:@"Content-Length"];
    [request setHTTPMethod:method];
    [request setHTTPBody:getData];

    // if we need headers like GPRequest
    [request setValue:getLength forHTTPHeaderField:@"Content-Length"];
    [request setValue:@"iPhone" forHTTPHeaderField:@"Device-Type"];
    [request setValue:VERSION forHTTPHeaderField:@"Version-Number"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request setValue:[NSString stringWithFormat:@"application/vnd.pact.v%d", 4] forHTTPHeaderField:@"Accept"];

    [NSURLConnection sendAsynchronousRequest:request queue:queue completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
        if (error) {
            if (completion)
                completion(nil, error);
        }
        else {
            // for debug: see if data is valid
            NSString* json = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            DebugLog(@"Received json: %@", json);
            SBJsonParser *jsonParser = [SBJsonParser new];
            NSDictionary *results = [jsonParser objectWithString:json];

            if (completion) {
                completion(results, nil);
            }
        }
    }];
}
#endif

+(NSString *)timeStringForDate:(NSDate *)date {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"MM/dd/yy HH:mm"];
    return [dateFormatter stringFromDate:date];
}

+ (NSString *)timeAgo:(NSDate *)date
{
    double deltaSeconds = fabs([date timeIntervalSinceNow]);
    double deltaMinutes = deltaSeconds / 60.0f;
    double deltaHours = deltaMinutes / 60.0f;
    double deltaDays = deltaHours / 24;
    double deltaWeeks = deltaDays / 7;
    double deltaMonths = deltaDays / 30; // rough estimate

    if(deltaSeconds < 5)
    {
        return @"Just now";
    }
    else if(deltaSeconds < 60)
    {
        return [NSString stringWithFormat:@"%d sec ago", (int)deltaSeconds];
    }
    else if (deltaMinutes < 60)
    {
        return [NSString stringWithFormat:@"%d min ago", (int)deltaMinutes];
    }
    else if (deltaHours < 24)
    {
        return [NSString stringWithFormat:@"%d hr ago", (int)deltaHours];
    }
    else if (deltaDays < 7)
    {
        if (deltaDays == 1)
            return @"1 day ago";
        return [NSString stringWithFormat:@"%d days ago", (int)deltaDays];
    }
    else if (deltaWeeks < 8)
    {
        return [NSString stringWithFormat:@"%d wk ago", (int)deltaWeeks];
    }
    else if (deltaMonths < 13)
    {
        return [NSString stringWithFormat:@"%d mon ago", (int)deltaMonths];
    }
    else if (deltaMonths < 24)
    {
        return @"Last year";
    }
    else
    {
        return @"In the past";
    }
}

+ (NSString *)simpleTimeAgo:(NSDate *)date {
    double deltaSeconds = fabs([date timeIntervalSinceNow]);
    if (deltaSeconds < 24*3600)
    {
        return @"Today";
    }
    return [self timeAgo:date];
}


@end
