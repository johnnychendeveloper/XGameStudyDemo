//
//  HashUtils.h
//  XGameStudyDemo
//
//  Created by JohnnyChen on 16/11/23.
//  Copyright © 2016年 YY.Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HashUtils : NSObject

+ (NSString *)sha1HexString:(NSString *)str;
+ (NSString *)md5HexString:(NSString *)str;
+ (NSString *)sha256HexString:(NSString *)str;

+ (NSString *)fileMd5HexString:(NSString *)filePath;
+ (NSString *)fileSha1HexString:(NSString *)filePath;

+ (NSString *)dataMd5HexString:(NSData *)data;

@end
