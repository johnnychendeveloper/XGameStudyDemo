//
//  FileUtils.h
//  XGameStudyDemo
//
//  Created by JohnnyChen on 16/11/23.
//  Copyright © 2016年 YY.Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum{
    LocalFileTypeUnknown = 0,
    
    LocalFileTypeLog,
    LocalFileTypeDatabase,
    LocalFileTypeQunLogo,
    LocalFileTypeQunAttachment,
    LocalFileTypeUserPortrait,
    LocalFileTypeUserAlbum,
    LocalFileTypeMessageAttachment,
    LocalFileTypeKaraOKMusic,
    LocalFileTypeKaraOKLyric,
    LocalFileTypeTempFile,
    LocalFileTypeSingerPhoto
}LocalFileType;

@interface FileUtils : NSObject

+ (BOOL)isFileExists:(NSString *)filePath;

+ (NSString *)parseFileNameFromUrl:(NSString *)url;
+ (NSString *)getLocalDirectory:(LocalFileType)type;

+ (NSString *)getPublicDatabaseName;
+ (NSString *)getPrivateDatabaseName:(NSNumber*)uid;

+ (NSString *)getLocalFileName:(LocalFileType)type byUrl:(NSString *)url;

+ (NSString *)calculateRemoteImageUrlFromFile:(NSString *)filePath;
+ (NSString *)calculateRemoteAudioUrlFromFile:(NSString *)filePath;

+ (NSString *)getTempFileName:(NSString *)extName;

+ (NSArray *)getFilenameListOfType:(NSString *)type fromDirPath:(NSString *)dirPath;

+ (BOOL)archiveFiles:(NSArray *)filePaths toPath:(NSString *)archivePath withArchiveName:(NSString *)name;

+ (BOOL)moveFile:(NSString *)oldFileName to:(NSString *)newFileName;
+ (BOOL)removeFile:(NSString *)filepath;

@end
