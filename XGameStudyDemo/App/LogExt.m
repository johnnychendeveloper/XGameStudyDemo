//
//  LogExt.m
//  XGameStudyDemo
//
//  Created by JohnnyChen on 16/11/23.
//  Copyright © 2016年 YY.Inc. All rights reserved.
//

#import "LogExt.h"
#import "fileutils.h"
#import <fcntl.h>
#import <pthread.h>

#pragma mark - DailyLogWriter

@interface DailyLogWriter : NSObject<GTMLogWriter>
{
    NSFileHandle *_fileHandle;
    dispatch_queue_t _logQueue;
}

- (id)initWithFilePath:(NSString *)filePath;

@end

@implementation DailyLogWriter

- (id)initWithFilePath:(NSString *)filePath
{
    self = [super init];
    if(self)
    {
        _logQueue = dispatch_queue_create("com.yy.mobile.log", DISPATCH_QUEUE_SERIAL);
        int fd = -1;
        if(filePath)
        {
            NSLog(@"log file name is:%@",filePath);
            int flags = O_WRONLY | O_APPEND | O_CREAT;
            fd = open([filePath fileSystemRepresentation], flags, S_IRUSR|S_IWUSR);
        }
        if(fd != -1)
        {
            _fileHandle = [[NSFileHandle alloc] initWithFileDescriptor:fd closeOnDealloc:YES];
        }
    }
    return self;
}

- (void)dealloc
{
    
}

- (void)logMessage:(NSString *)msg level:(GTMLoggerLevel)level
{
    dispatch_async(_logQueue, ^{
        @try {
            NSString *line = [NSString stringWithFormat:@"%@\n",msg];
            [_fileHandle writeData:[line dataUsingEncoding:NSUTF8StringEncoding]];
        }
        @catch (id e) {
            // Ignored
        }
    });
}


@end


#pragma mark - DailyLogFormatter

@interface DailyLogFormatter : GTMLogBasicFormatter
{
@private
    NSDateFormatter *_dateFormatter;

}
@end

@implementation DailyLogFormatter

- (instancetype)init
{
    if((self = [super init]))
    {
        _dateFormatter = [[NSDateFormatter alloc] init];
        [_dateFormatter setFormatterBehavior:NSDateFormatterBehavior10_4];
        [_dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss.SSS"];
    }
    return self;
}

- (NSString *)stringForFunc:(NSString *)func withFormat:(NSString *)fmt valist:(va_list)args level:(GTMLoggerLevel)level
{
    NSString *tstamp = nil;
    @synchronized (_dateFormatter) {
        tstamp = [_dateFormatter stringFromDate:[NSDate date]];
    }
    return [NSString stringWithFormat:@"%@ [%p] [%d] %@",
            tstamp, pthread_self(), level,
            [super stringForFunc:func withFormat:fmt valist:args level:level]];

}
@end

static NSString *logFilePath = nil;

#pragma mark - LogExt



@implementation LogExt

+ (NSString *)logFolder
{
    NSString *path = [FileUtils getLocalDirectory:LocalFileTypeLog];
    [[NSFileManager defaultManager] createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:nil];
    return path;
}

+ (NSString *)logFileName
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setFormatterBehavior:NSDateFormatterBehavior10_4];
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    NSString *fileName = [NSString stringWithFormat:@"%@.log",[dateFormatter stringFromDate:[NSDate date]]];
    return fileName;
}

+ (void)prepareForLogging
{
    GTMLogger* logger = [GTMLogger sharedLogger];
    DailyLogFormatter* logFormatter = [[DailyLogFormatter alloc] init];
    [logger setFormatter:logFormatter];
    
    id stdoutWriter = [NSFileHandle fileHandleWithStandardOutput];
    logFilePath = [NSString stringWithFormat:@"%@%@", [LogExt logFolder], [LogExt logFileName]];
    DailyLogWriter *writer = [[DailyLogWriter alloc] initWithFilePath:logFilePath];
    NSArray* logWriters = @[ stdoutWriter, writer ];
    [logger setWriter:logWriters];
    
    GTMLoggerLevel logLevel = kGTMLoggerLevelDebug;
#ifdef DEBUG
    logLevel = kGTMLoggerLevelDebug;
#else
    logLevel = kGTMLoggerLevelInfo;
#endif
    GTMLogMininumLevelFilter* filter = [[GTMLogMininumLevelFilter alloc] initWithMinimumLevel:logLevel];
    [logger setFilter:filter];
    
    //prepareForLogging is called when app is in start-up pharse, to avoid slow start-up pharse,
    //putting cleanLogFiles to aysnc call in main thread
    dispatch_async(dispatch_get_main_queue(), ^{
        [LogExt cleanLogFiles];
    });

}

+ (NSString *)loggingFilePath
{
    return logFilePath;
}

+(void)cleanLogFiles
{
    NSError* error= nil;
    NSString* logFolder = [LogExt logFolder];
    NSArray* logFiles = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:logFolder error:&error];
    if (logFiles == nil) {
        GTMLoggerError(@"error happened when clearnLogFiles:%@", error);
        return;
    }
#ifdef DEBUG
    NSDate* date =[[NSDate date] dateByAddingTimeInterval:-7*24*60*60];
#else
    NSDate* date =[[NSDate date] dateByAddingTimeInterval:-2*24*60*60];
#endif
    for (NSString *logFile in logFiles) {
        NSString *logFilePath = [logFolder stringByAppendingPathComponent:logFile];
        NSDictionary *fileAttr = [[NSFileManager defaultManager] attributesOfItemAtPath:logFilePath error:&error];
        if (fileAttr) {
            NSDate *creationDate = [fileAttr valueForKey:NSFileCreationDate];
            if ([creationDate compare:date] == NSOrderedAscending) {
                GTMLoggerDebug(@"%@ will be deleted", logFile);
                [[NSFileManager defaultManager] removeItemAtPath:logFilePath error:&error];
                GTMLoggerDebug(@"%@ was deleted, error number is %ld", logFilePath, (long)error.code);
            }
        }
    }
}


@end














