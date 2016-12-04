//
//  DWCloudUtil.m
//  dwcloud
//
//  Created by rannger on 14-9-24.
//  Copyright (c) 2014年 rannger. All rights reserved.
//

#import "DWCloudUtil.h"
#import "GTMBase64.h"
#import "HMAC.h"
#import "MD5.h"

static NSString* globalBucketName=nil;
static NSString* globalAccessKey=nil;
static NSString* globalSecretKey=nil;

@implementation DWCloudUtil

+ (void)registerWithAccessKey:(NSString*)accessKey SecretKey:(NSString*)secretKey
{
    globalAccessKey=accessKey;
    globalSecretKey=secretKey;
}

+ (NSString*)accessKey
{
    return globalAccessKey;
}

+ (NSString*)secretKey
{
    return globalSecretKey;
}

+ (void)setBucketName:(NSString*)BucketName
{
    globalBucketName=BucketName;
}

+ (NSString*)bucketName
{
    return globalBucketName;
}

+ (NSString*)uploadURLString
{
    return [NSString stringWithFormat:@"http://%@.bs2ul.yy.com",[self bucketName]];
}

+ (NSString*)downloadURLString
{
    return [NSString stringWithFormat:@"http://%@.bs2dl.yy.com",[self bucketName]];
}

+ (NSString*)photoServiceURLString
{
    return [NSString stringWithFormat:@"http://image.yy.com/%@",[self bucketName]];
}

+ (NSString*)delURLString
{
    return [NSString stringWithFormat:@"http://%@.bs2.yy.com",[self bucketName]];
}

+ (NSString*)photoZoomWithURL:(NSString*)url width:(float)width height:(float)height
{
    return [url stringByAppendingString:[NSString stringWithFormat:@"?imageview/2/w/%.0f/h/%.0f",width,height]];
}

+ (NSString*)photoZoomWithURL:(NSString*)url width:(float)width
{
    return [url stringByAppendingString:[NSString stringWithFormat:@"?imageview/2/w/%.0f",width]];
}

+ (NSString*)photoZoomWithURL:(NSString*)url height:(float)height
{
    return [url stringByAppendingString:[NSString stringWithFormat:@"?imageview/2/h/%.0f",height]];
}

#pragma mark -
+ (NSString*)getAuthorizationWithMethodName:(NSString*)method
                                   fileName:(NSString*)fileName
                              overdueSecond:(NSTimeInterval)overdueSecond
{
    NSTimeInterval expires=[[NSDate date] timeIntervalSince1970]+overdueSecond;
    NSString* name=[NSString stringWithFormat:@"%@\n%@\n%@\n%.0f\n",method,[self bucketName],fileName,expires];
    
    NSData* data=[name hmac];
    NSString* hashing=[GTMBase64 stringByWebSafeEncodingData:data padded:YES];
    NSString* retval=[NSString stringWithFormat:@"%@:%@:%.0f",[self accessKey],hashing,expires];
    
    return retval;
}

+ (NSString*)hashOfFileName:(NSString*)fileName
{
    NSString* f=[NSString stringWithFormat:@"%@/%@",[self bucketName],fileName];
    return [f sha1];
}

+ (NSString*)md5OfFile:(NSString*)filePath
{
    if ([[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
         NSData* data=[NSData dataWithContentsOfFile:filePath];
        return [data MD5];
    }
    return nil;
}

@end
