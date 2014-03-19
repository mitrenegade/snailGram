//
//  AWSHelper.h
//  Stixx
//
//  Created by Bobby Ren on 11/16/12.
//
//

#import <Foundation/Foundation.h>
#import <AWSS3/AWSS3.h>
#import "AsyncImageUploader.h"

#define AWS_USE_TVM 0
#define TOKEN_VENDING_MACHINE_URL    @"" // add a TVM URL here
#define AWS_S3_ENDPOINT US_EAST_1
/**
 * This indiciates whether or not the TVM is supports SSL connections.
 */
#define USE_SSL                      NO

#define CREDENTIALS_ALERT_MESSAGE    @"Please update the Constants.h file with your credentials or Token Vending Machine URL."

#define AWS_BUCKET @"snailgramcards"

@interface AWSHelper : NSObject <AmazonServiceRequestDelegate>

+(AmazonS3Client *)s3;

+(bool)hasCredentials;
+(void)validateCredentials;
+(void)clearCredentials;
+(void)uploadImage:(UIImage*)image withName:(NSString*)imageName toBucket:(NSString*)bucket withCallback:(void (^)(NSString *))block;
+(NSString*)getURLForKey:(NSString*)imageName inBucket:(NSString*)bucket;
+(void)putObject;
+(void)getObject;

+(UIAlertView *)credentialsAlert;
+(UIAlertView *)errorAlert:(NSString *)message;
+(UIAlertView *)expiredCredentialsAlert;

+(id)urlForPhotoWithKey:(id)key;
+(id)urlForProfileWithKey:(id)key;

@end
