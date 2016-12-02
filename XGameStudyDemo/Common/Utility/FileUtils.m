//
//  FileUtils.m
//  XGameStudyDemo
//
//  Created by JohnnyChen on 16/11/23.
//  Copyright © 2016年 YY.Inc. All rights reserved.
//

#import "FileUtils.h"
#import "HashUtils.h"
#import "ZipArchive.h"

@interface FileUtils()

+ (NSString *)getCacheDirectory;
+ (NSString *)getUserPortraitFileName:(NSString *)fileName;
@end

@implementation FileUtils

+ (NSString *)getCacheDirectory
{
    static NSString *cacheDirectory;
    do{
        if(cacheDirectory)
            break;
        NSArray *directories = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
        if([directories count] < 1)
            break;
        
        cacheDirectory = [directories objectAtIndex:0];
        
        NSUInteger length = [cacheDirectory length];
        if(length < 1)
        {
            cacheDirectory = nil;
            break;
        }
        if('/' == [cacheDirectory characterAtIndex:length - 1])
            break;
        cacheDirectory = [cacheDirectory stringByAppendingString:@"/"];
        
    } while(false);
    return cacheDirectory;
}

+ (BOOL)isFileExists:(NSString *)filePath
{
    return [[NSFileManager defaultManager] fileExistsAtPath:filePath];
}

+ (NSString *)getUserPortraitFileName:(NSString *)fileName
{
    if([fileName length] < 1)
        return nil;
    NSString *ext = [[fileName pathExtension] lowercaseString];
    if(NSOrderedSame == [ext compare:@"jpg"])
        return fileName;
    return [[HashUtils md5HexString:fileName] stringByAppendingString:@".jpg"];
}

+ (NSString *)parseFileNameFromUrl:(NSString *)url
{
    NSInteger indexOfLastSlash = -1;
    for(NSUInteger i = [url length];i>0; i--)
    {
        if('/' == [url characterAtIndex:i-1])
        {
            indexOfLastSlash = i-1;
            break;
        }
    }
    if(-1 == indexOfLastSlash)
    {
        return url;
    }
    else
    {
        return [url substringFromIndex:indexOfLastSlash + 1];
    }
}

+ (NSString *)getLocalDirectory:(LocalFileType)type
{
    NSString *cacheDirectory = [FileUtils getCacheDirectory];
    if(!cacheDirectory)
        return nil;
    NSString *typeDirectory;
    switch (type) {
        case LocalFileTypeLog:
            typeDirectory = @"logs/";
            break;
            
        case LocalFileTypeDatabase:
            typeDirectory = @"dbs/";
            break;
            
        case LocalFileTypeUserPortrait:
            typeDirectory = @"portraits/";
            break;
            
        case LocalFileTypeUserAlbum:
            typeDirectory = @"albums/";
            break;
            
        case LocalFileTypeMessageAttachment:
            typeDirectory = @"attachments/";
            break;
            
        case LocalFileTypeQunLogo:
            typeDirectory = @"qunlogo/";
            break;
            
        case LocalFileTypeQunAttachment:
            typeDirectory = @"qun_attachments/";
            break;
            
        case LocalFileTypeKaraOKMusic:
            typeDirectory = @"music/";
            break;
            
        case LocalFileTypeKaraOKLyric:
            typeDirectory = @"lyric/";
            break;
            
        case LocalFileTypeTempFile:
            typeDirectory = @"temporary/";
            break;
            
        case LocalFileTypeSingerPhoto:
            typeDirectory = @"singer_photoes/";
            break;
    
        default:
            break;
    }
    if(!typeDirectory)
        return nil;
    return [cacheDirectory stringByAppendingString:typeDirectory];
}

+ (NSString *)getPublicDatabaseName
{
    NSString *dbDirectory = [FileUtils getLocalDirectory:LocalFileTypeDatabase];
    if(dbDirectory)
    {
        return [dbDirectory stringByAppendingString:@"public.db"];
    }
    else
    {
        return nil;
    }
}

+ (NSString *)getPrivateDatabaseName:(NSNumber *)uid
{
    NSString *dbDirectory = [FileUtils getLocalDirectory:LocalFileTypeDatabase];
    if(dbDirectory)
    {
        return [dbDirectory stringByAppendingFormat:@"%@.db",uid];
    }
    else
    {
        return nil;
    }
}

+ (NSString *)getLocalFileName:(LocalFileType)type byUrl:(NSString *)url
{
    if(LocalFileTypeUserAlbum == type)
        return nil;
    NSString *directory = [FileUtils getLocalDirectory:type];
    if(!directory)
        return nil;
    NSString *fileName = [FileUtils parseFileNameFromUrl:url];
    if(LocalFileTypeUserPortrait == type)
    {
        fileName = [FileUtils getUserPortraitFileName:fileName];
    }
    if([fileName length] < 1)
        return nil;
    return [directory stringByAppendingString:fileName];
}

+(int)getIntFromChar:(unichar)c
{
    int v = c;
    if ( v >= '0' && v <='9' ) {
        v -= '0';
    } else if( v >= 'a' && v <= 'f' ) {
        v -= 'a';
        v += 10;
    } else if ( v >='A' && v <= 'F' ) {
        v -= 'A';
        v += 10;
    }
    return v;
}


+ (NSString *)calculateRemoteUrlFromFile:(NSString *)filePath mediaType:(NSString *)mediaType
{
    int serverCount = 8;
    NSString* fileMd5 = [HashUtils fileMd5HexString:filePath];
    int serverIndex = [FileUtils getIntFromChar:[fileMd5 characterAtIndex:31]] % serverCount;
    
    NSString *srvUrl = [NSString stringWithFormat:@"imscreenshot%d.yy.duowan.com",serverIndex+1];
    return [NSString stringWithFormat:@"http://%c.dx%@:80%@_%c%c/%c%c/%c%c/%@",
            [fileMd5 characterAtIndex:30],srvUrl, mediaType,
            [fileMd5 characterAtIndex:28],
            [fileMd5 characterAtIndex:29],
            [fileMd5 characterAtIndex:26],
            [fileMd5 characterAtIndex:27],
            [fileMd5 characterAtIndex:24],
            [fileMd5 characterAtIndex:25],
            [FileUtils parseFileNameFromUrl:filePath]];
}

+ (NSString *)calculateRemoteImageUrlFromFile:(NSString *)filePath
{
    return [FileUtils calculateRemoteUrlFromFile:filePath mediaType:@"/upl"];
}

+ (NSString *)calculateRemoteAudioUrlFromFile:(NSString *)filePath
{
    return [FileUtils calculateRemoteUrlFromFile:filePath mediaType:@"/snd"];
}

+ (NSString *)getTempFileName:(NSString *)extName
{
    NSString *directory = [FileUtils getLocalDirectory:LocalFileTypeTempFile];
    if (!directory)
        return nil;
    
    NSString *fileName;
    do {
        fileName = [NSString stringWithFormat:@"%@%u%@", directory, arc4random(), (extName ? extName : @"")];
        if ([[NSFileManager defaultManager] fileExistsAtPath:fileName])
            fileName = nil;
    } while (!fileName);
    
    return fileName;
}

+ (BOOL)moveFile:(NSString *)oldFileName to:(NSString *)newFileName
{
    NSError *error;
    if(![[NSFileManager defaultManager] moveItemAtPath:oldFileName toPath:newFileName error:&error])
    {
        GTMLoggerError(@"Failed to move file %@ to %@, error:%@",oldFileName, newFileName, error);
        return NO;
    }
    return YES;
}

+ (BOOL)removeFile:(NSString *)filepath
{
    NSError *error;
    if(![[NSFileManager defaultManager] removeItemAtPath:filepath error:&error])
    {
        GTMLoggerError(@"Failed to remove file %@, error:%@",filepath,error);
        return NO;
    }
    return YES;
}

+ (NSArray *)getFilenamelistOfType:(NSString *)type fromDirPath:(NSString *)dirPath
{
    NSMutableArray *filenamelist = [NSMutableArray array];
    NSArray *tmplist = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:dirPath error:nil];
    
    for (NSString *filename in tmplist) {
        NSString *fullpath = [dirPath stringByAppendingPathComponent:filename];
        if ([FileUtils isFileExists:fullpath]) {
            if ([[filename pathExtension] isEqualToString:type]) {
                [filenamelist  addObject:filename];
            }
        }
    }
    
    return filenamelist;
}

+ (BOOL)archiveFiles:(NSArray *)filePaths toPath:(NSString *)archivePath withArchiveName:(NSString *)name
{
    NSAssert(filePaths != nil, @"archiveFils must not NULL");
    NSAssert(archivePath != nil, @"archivePath must not NULL");
    NSAssert(name != nil, @"archive zip name must not NULL");
    
    ZipArchive *archiver = [[ZipArchive alloc] init];
    NSString *archiveFile = [archivePath stringByAppendingPathComponent:name];
    [archiver CreateZipFile2:archiveFile];
    BOOL isDir = NO;
    for(NSString *path in filePaths) {
        if([[NSFileManager defaultManager] fileExistsAtPath:path isDirectory:&isDir] && !isDir) {
            [archiver addFileToZip:path newname:[path lastPathComponent]];
        }
    }
    BOOL success = [archiver CloseZipFile2];
    return success;
}

@end
