//
//  AWSHelper.m
//  Stixx
//
//  Created by Bobby Ren on 11/16/12.
//
//

#import "AWSHelper.h"

static AmazonS3Client       *s3  = nil;
@implementation AWSHelper

+(AmazonS3Client *)s3
{
    [AWSHelper validateCredentials];
    return s3;
}

+(bool)hasCredentials
{
    return YES;
}

+(void)validateCredentials
{
    if (s3==nil) {
        [AWSHelper clearCredentials];
        
        s3  = [[AmazonS3Client alloc] initWithAccessKey:AWS_ACCESS_KEY withSecretKey:AWS_SECRET_KEY];
    }
}

+(void)clearCredentials
{
    s3  = nil;
}

+(void)uploadImage:(UIImage*)image withName:(NSString*)imageName toBucket:(NSString*)bucket withCallback:(void (^)(NSString *))block{
    AsyncImageUploader * uploader = [[AsyncImageUploader alloc] init];
    [uploader uploadImage:image name:imageName withBucket:(NSString*)bucket withCallback:^(BOOL success, id response) {
        NSLog(@"Success: %d", success);
        if (success) {
            NSLog(@"Response: %@", response);
            NSString * url = [self getURLForKey:imageName inBucket:bucket];
            NSLog(@"URL: %@", url);

            if (block)
                block(url);
        }
        else {
            NSError * error = (NSError*) response;
            NSLog(@"Error: %@", error);
            // todo: handle typical error:
            // Error: AmazonServiceException { RequestId:B13EC740D9C486DA, ErrorCode:RequestTimeout, Message:Your socket connection to the server was not read from or written to within the timeout period. Idle connections will be closed. }

            if (block)
                block(nil);
        }
    }];
}

+(NSString*)getURLForKey:(NSString*)imageName inBucket:(NSString*)bucket {
    // get image url - based on temporary credentials and nonpublic image
    S3ResponseHeaderOverrides *override = [[S3ResponseHeaderOverrides alloc] init];
    override.contentType = @"image/png";
    
    S3GetPreSignedURLRequest *gpsur = [[S3GetPreSignedURLRequest alloc] init];
    gpsur.key     = imageName;
    gpsur.bucket  = bucket;
    gpsur.expires = [NSDate dateWithTimeIntervalSinceNow:(NSTimeInterval) 3600];  // Added an hour's worth of seconds to the current time.
    gpsur.responseHeaderOverrides = override;
    
    NSURL *url = [self.s3 getPreSignedURL:gpsur];
    //NSLog(@"url for key %@: %@", imageName, url);
    NSString * urlString = [NSString stringWithFormat:@"%@", url];
    return urlString;
}

+(UIAlertView *)credentialsAlert
{
    return [[[UIAlertView alloc] initWithTitle:@"AWS Credentials" message:CREDENTIALS_ALERT_MESSAGE delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] autorelease];
}

+(UIAlertView *)errorAlert:(NSString *)message
{
    return [[[UIAlertView alloc] initWithTitle:@"Error" message:message delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] autorelease];
}

+(UIAlertView *)expiredCredentialsAlert
{
    return [[[UIAlertView alloc] initWithTitle:@"AWS Credentials" message:@"Credentials Expired, retry your request." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] autorelease];
}

+(id)urlForPhotoWithKey:(id)key {
    return [NSString stringWithFormat:@"https://%@.s3.amazonaws.com/%@", AWS_BUCKET, key];
}

+(id)urlForProfileWithKey:(id)key {
    return [self urlForPhotoWithKey:key];
}
@end
