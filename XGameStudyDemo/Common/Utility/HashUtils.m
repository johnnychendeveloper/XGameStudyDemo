//
//  HashUtils.m
//  XGameStudyDemo
//
//  Created by JohnnyChen on 16/11/23.
//  Copyright © 2016年 YY.Inc. All rights reserved.
//

#import "HashUtils.h"
#import <CommonCrypto/CommonDigest.h>
#include <openssl/md5.h>
#include <openssl/sha.h>

static const int kMd5BufferLength = 16;
static const int kSHa1BufferLength = 20;


@interface NSString(Hash)

- (NSString*)md5;
- (NSString*)sha1;
- (NSString*)sha256;

@end

@interface NSData(Hash)

- (NSData*)md5;
- (NSData*)sha1;
- (NSString*)hexString;

@end

@interface NSFileHandle(Hash)
- (NSString*)md5;
- (NSString*)sha1;
@end

@implementation HashUtils

+(NSString *)sha1HexString:(NSString *)str
{
    return [str sha1];
}

+ (NSString *)md5HexString:(NSString *)str
{
    return [str md5];
}

+ (NSString *)sha256HexString:(NSString *)str
{
    return [str sha256];
}

+ (NSString *)fileMd5HexString:(NSString *)filePath
{
    NSFileHandle *handle = [NSFileHandle fileHandleForReadingAtPath:filePath];
    if(handle == nil)
        return nil;
    return [handle md5];
}

+ (NSString *)fileSha1HexString:(NSString *)filePath
{
    NSFileHandle *handle = [NSFileHandle fileHandleForReadingAtPath:filePath];
    if(handle == nil)
        return nil;
    return [handle sha1];
}

+ (NSString *)dataMd5HexString:(NSData *)data
{
    return [[data md5] hexString];
}
@end

@implementation NSString(Hash)

- (NSString *)md5
{
    return [[[self dataUsingEncoding:NSUTF8StringEncoding] md5] hexString];
}

- (NSString *)sha1
{
    return [[[self dataUsingEncoding:NSUTF8StringEncoding] sha1] hexString];
}

- (NSString *)sha256
{
    const char* str = [self UTF8String];
    unsigned char result[CC_SHA256_DIGEST_LENGTH];
    CC_SHA256(str, (CC_LONG)strlen(str), result);
    
    NSMutableString *ret = [NSMutableString stringWithCapacity:CC_SHA256_DIGEST_LENGTH];
    for(int i = 0; i<CC_SHA256_DIGEST_LENGTH; i++)
    {
        [ret appendFormat:@"%02x",result[i]];
    }
    return ret;
}
@end

@implementation NSData(Hash)

- (NSData *)md5
{
    const unsigned char *cstr = [self bytes];
    unsigned char result[kMd5BufferLength];
    MD5(cstr, [self length], result);
    return [NSData dataWithBytes:result length:kMd5BufferLength];
}

- (NSData *)sha1
{
    const unsigned char *buffer = [self bytes];
    unsigned char result[kSHa1BufferLength];
    SHA1(buffer, [self length], result);
    return [NSData dataWithBytes:result length:kSHa1BufferLength];
}

- (NSString *)hexString
{
    const NSUInteger length = [self length];
    const unsigned char *str = [self bytes];
    NSMutableString *hexStr = [NSMutableString stringWithCapacity:length*2];
    for (NSUInteger i=0; i<length; i++) {
        [hexStr appendFormat:@"%02x", str[i]];
    }
    return hexStr;
}

@end

static const int kBufferSize = 1024;

@implementation NSFileHandle(Hash)

- (NSString *)md5
{
    assert(self != nil);
    MD5_CTX ctx;
    MD5_Init(&ctx);
    NSData* data = [self readDataOfLength:kBufferSize];
    while (data && [data length] > 0) {
        MD5_Update(&ctx, [data bytes], [data length]);
        data = [self readDataOfLength:kBufferSize];
    }
    unsigned char result[kMd5BufferLength];
    MD5_Final(result, &ctx);
    return [[NSData dataWithBytes:result length:kMd5BufferLength] hexString];
}

- (NSString *)sha1
{
    assert(self != nil);
    SHA_CTX ctx;
    SHA1_Init(&ctx);
    NSData* data = [self readDataOfLength:kBufferSize];
    while (data && [data length] > 0) {
        SHA1_Update(&ctx, [data bytes], [data length]);
        data = [self readDataOfLength:kBufferSize];
    }
    unsigned char result[kSHa1BufferLength];
    SHA1_Final(result, &ctx);
    return [[NSData dataWithBytes:result length:kSHa1BufferLength] hexString];
}


@end




















