//
//  DWCloudUtil.h
//  dwcloud
//
//  Created by rannger on 14-9-24.
//  Copyright (c) 2014年 rannger. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DWCloudUtil : NSObject

+ (void)setBucketName:(NSString*)BucketName;
+ (void)registerWithAccessKey:(NSString*)accessKey SecretKey:(NSString*)secretKey;
+ (NSString*)uploadURLString;
+ (NSString*)downloadURLString;
+ (NSString*)photoServiceURLString;
+ (NSString*)delURLString;
+ (NSString*)accessKey;
+ (NSString*)secretKey;
+ (NSString*)bucketName;

+ (NSString*)photoZoomWithURL:(NSString*)url width:(float)width height:(float)height;
+ (NSString*)photoZoomWithURL:(NSString*)url width:(float)width;
+ (NSString*)photoZoomWithURL:(NSString*)url height:(float)height;

+ (NSString*)getAuthorizationWithMethodName:(NSString*)method
                                   fileName:(NSString*)fileName
                              overdueSecond:(NSTimeInterval)overdueSecond;
@end
