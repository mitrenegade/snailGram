/*
 * Copyright 2010-2012 Amazon.com, Inc. or its affiliates. All Rights Reserved.
 *
 * Licensed under the Apache License, Version 2.0 (the "License").
 * You may not use this file except in compliance with the License.
 * A copy of the License is located at
 *
 *  http://aws.amazon.com/apache2.0
 *
 * or in the "license" file accompanying this file. This file is distributed
 * on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either
 * express or implied. See the License for the specific language governing
 * permissions and limitations under the License.
 */

#import "AsyncImageUploader.h"
#import "AWSHelper.h"

@implementation AsyncImageUploader
@synthesize callback;

#pragma mark - Class Lifecycle

-(id)init //WithImageNo:(int)theImageNo progressView:(UIProgressView *)theProgressView
{
    self = [super init];
    if (self)
    {
        isExecuting = NO;
        isFinished  = NO;
        callback = nil;
    }
    
    return self;
}

#pragma mark - Overwriding NSOperation Methods

/*
 * For concurrent operations, you need to override the following methods:
 * start, isConcurrent, isExecuting and isFinished.
 *
 * Please refer to the NSOperation documentation for more details.
 * http://developer.apple.com/library/ios/#documentation/Cocoa/Reference/NSOperation_class/Reference/Reference.html
 */

-(void)uploadImage:(UIImage*)image name:(NSString*)imageName withBucket:(NSString*)bucket withCallback:(AWSUploadCallback)callbackFun
{
    // Makes sure that start method always runs on the main thread.
    if (![NSThread isMainThread])
    {
        [self performSelectorOnMainThread:@selector(start) withObject:nil waitUntilDone:NO];
        return;
    }
    
    [self setCallback:callbackFun];
    
    [self willChangeValueForKey:@"isExecuting"];
    isExecuting = YES;
    [self didChangeValueForKey:@"isExecuting"];
    
    NSString *bucketName = bucket; //[NSString stringWithFormat:@"s3-async-demo2-ios-for-%@", [AWS_ACCESS_KEY lowercaseString]];
    NSString *keyName    = imageName; //[NSString stringWithFormat:@"image%d", imageName];
    //NSString *filename   = [[NSBundle mainBundle] pathForResource:imageName ofType:@"png"];
    NSData * data = UIImageJPEGRepresentation(image, .85);

    /*
    // Creates the Bucket to put the Object.
    S3CreateBucketResponse *createBucketResponse = [[AWSHelper s3] createBucketWithName:bucketName];
    if(createBucketResponse.error != nil)
    {
        NSLog(@"Error: %@", createBucketResponse.error);
    }
     */
    
    // Puts the file as an object in the bucket.
    S3PutObjectRequest *putObjectRequest = [[[S3PutObjectRequest alloc] initWithKey:keyName inBucket:bucketName] autorelease];
    //putObjectRequest.filename = filename;
    putObjectRequest.data = data;
    putObjectRequest.delegate = self;
    putObjectRequest.cannedACL = [S3CannedACL publicRead];
    [putObjectRequest setContentType:@"image/jpeg"];
    
    [[AWSHelper s3] putObject:putObjectRequest];
}

-(BOOL)isConcurrent
{
    return YES;
}

-(BOOL)isExecuting
{
    return isExecuting;
}

-(BOOL)isFinished
{
    return isFinished;
}

#pragma mark - AmazonServiceRequestDelegate Implementations

-(void)request:(AmazonServiceRequest *)request didCompleteWithResponse:(AmazonServiceResponse *)response
{
    // do callback
    callback(YES, response);
    [self finish];
}

-(void)request:(AmazonServiceRequest *)request didSendData:(long long)bytesWritten totalBytesWritten:(long long)totalBytesWritten totalBytesExpectedToWrite:(long long)totalBytesExpectedToWrite {
    NSLog(@"Progress: %f%%", (float)totalBytesWritten / totalBytesExpectedToWrite * 100);
}

-(void)request:(AmazonServiceRequest *)request didFailWithError:(NSError *)error
{
    NSLog(@"%@", error);
    // do callback
    callback(NO, error);
    
    [self finish];
}

-(void)request:(AmazonServiceRequest *)request didFailWithServiceException:(NSException *)exception
{
    NSLog(@"%@", exception);
    
    // do callback
    callback(NO, exception);
    [self finish];
}

#pragma mark - Helper Methods

-(void)finish
{
    [self willChangeValueForKey:@"isExecuting"];
    [self willChangeValueForKey:@"isFinished"];
    
    isExecuting = NO;
    isFinished  = YES;
    
    [self didChangeValueForKey:@"isExecuting"];
    [self didChangeValueForKey:@"isFinished"];
    
    NSLog(@"Finished!");
}

#pragma mark -

@end
