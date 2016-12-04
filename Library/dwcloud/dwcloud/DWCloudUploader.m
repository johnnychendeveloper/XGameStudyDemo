//
//  DWCloudUploader.m
//  dwcloud
//
//  Created by rannger on 14-9-24.
//  Copyright (c) 2014年 rannger. All rights reserved.
//

#import "DWCloudUploader.h"
#import "ASIHTTPRequest.h"
#import "ASINetworkQueue.h"
#import "ASIFormDataRequest.h"
#import "DWCloudUtil.h"
#import "MD5.h"

static NSString* KC_QiniuAudio =@"dwgaga-audio";
static NSString* KC_QiniuImage =@"dwgaga-image";
static NSString* KC_QiniuVideo =@"dwgaga-video";

@interface DWCloudUploader ()
{
    ASINetworkQueue* _queue;
    ASIHTTPRequest* _request;
    NSString* _fileName;
}
@property (nonatomic,strong) ASINetworkQueue* queue;
@property (nonatomic,strong) ASIHTTPRequest* request;
@property (nonatomic,copy) NSString* fileName;
@end

const NSInteger PACK_SIZE = 2 * 1024 * 1024;

@implementation DWCloudUploader
@synthesize filePath=_filePath;
@synthesize space=_space;
@synthesize fileName=_fileName;
@synthesize queue=_queue;
@synthesize request=_request;
@synthesize uploadFail=_uploadFail;
@synthesize uploadSuccess=_uploadSuccess;
@synthesize uploadProgress=_uploadProgress;
- (void)dealloc
{
    [self.request clearDelegatesAndCancel];
    [self.queue cancelAllOperations];
    self.queue=nil;
}

- (id)init
{
    self = [super init];
    if (self) {
        _queue=[[ASINetworkQueue alloc] init];
    }
    
    return self;
}

- (void)go
{
    NSData* data=[NSData dataWithContentsOfFile:self.filePath];
    self.fileName=[data MD5];
    [self uploadInit];
}

- (void)uplodeWithFileName:(NSString *)name
{
    self.fileName = name;
    [self uploadInit];
}

#pragma mark -
- (void)uploadInit
{
    NSURL* url=[NSURL URLWithString:[NSString stringWithFormat:@"/%@?uploads",self.fileName] relativeToURL:[NSURL URLWithString:[DWCloudUtil uploadURLString]]];
    ASIFormDataRequest* request=[[ASIFormDataRequest alloc] initWithURL:url];
    
    NSDateFormatter* formatter=[[NSDateFormatter alloc] init];
    [formatter setTimeZone:[NSTimeZone timeZoneWithName:@"GMT"]];
    [formatter setDateFormat:@"E,dd MMM YYYY,HH:mm:ss"];
    NSString* dateString=[[formatter stringFromDate:[NSDate date]] stringByAppendingString:@" GTM"];
    NSString* authorization=nil;
    authorization=[DWCloudUtil getAuthorizationWithMethodName:@"POST" fileName:self.fileName overdueSecond:0];
    NSArray* imageType=@[@"g3fax",@"gif",@"ief",@"jpeg",@"tiff",@"png",@"jpg"];
    NSArray* audioType = @[@"aac"];
    NSArray* videoType = @[@"mp4"];
    NSString* contentType=@"application/force-download";
    if ([imageType containsObject:[self.fileName pathExtension]]||[self.space isEqualToString:KC_QiniuImage]) {
        contentType=[NSString stringWithFormat:@"image/%@",[self.fileName pathExtension]];
    } else if ([audioType containsObject:[self.fileName pathExtension]]||[self.space isEqualToString:KC_QiniuAudio]) {
        contentType = @"audio/aac";
    } else if ([videoType containsObject:[self.fileName pathExtension]]||[self.space isEqualToString:KC_QiniuVideo]) {
        contentType = @"video/mp4";
    }
    NSMutableDictionary* header=[NSMutableDictionary dictionaryWithObjectsAndKeys:
                                 authorization,@"Authorization",
                                 contentType,@"Content-type",
                                 dateString,@"Date",nil];
    [request setRequestHeaders:header];
    
    __weak DWCloudUploader* weakSelf=self;
    [request setCompletionBlock:^{
        NSData* data=[weakSelf.request responseData];
        NSDictionary* res=[NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
//        NSString* str=[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
//        NSLog(@"%@",str);
        if (res==nil) {
            weakSelf.uploadFail(nil);
            return ;
        }
        NSString* uploadid=[res objectForKey:@"uploadid"];
        NSString* zone=[res objectForKey:@"zone"];
        [weakSelf uploadWithUploadID:uploadid zone:zone];
    }];
    
    [request setFailedBlock:^{
//        NSLog(@"%@ %@",weakSelf.request.error,weakSelf.request.error.userInfo);
        weakSelf.uploadFail(weakSelf.request.error);
    }];
    self.request=request;
    [self.request startAsynchronous];
}

- (void)uploadWithUploadID:(NSString*)uploadId zone:(NSString*)zone
{
    NSData* fileData=[NSData dataWithContentsOfFile:self.filePath];
    NSUInteger byteRemained=[fileData length];
    NSInteger loc=0;
    int index=0;
    
    [self.queue setDelegate:self];
    [self.queue setUploadProgressDelegate:self];
    [self.queue setQueueDidFinishSelector:@selector(uploadQueueCompleted:)];
    [self.queue setRequestDidFailSelector:@selector(uploadRequestFailed:)];
    [self.queue setRequestDidFinishSelector:@selector(uploadRequestFinish:)];
    
    NSMutableArray* array=[NSMutableArray arrayWithCapacity:10];
    __weak DWCloudUploader* weakSelf=self;
    while (0 != byteRemained) {
        const NSInteger m=MIN(byteRemained, PACK_SIZE);
        NSData* dataSending=[fileData subdataWithRange:NSMakeRange(loc, m)];
        
        NSURL* url=[NSURL URLWithString:[NSString stringWithFormat:@"/%@?&partnumber=%d&uploadid=%@",self.fileName,index,uploadId] relativeToURL:[NSURL URLWithString:[@"http://" stringByAppendingString:zone]]];
        ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
        [request setRequestMethod:@"PUT"];
        
        NSDateFormatter* formatter=[[NSDateFormatter alloc] init];
        [formatter setTimeZone:[NSTimeZone timeZoneWithName:@"GMT"]];
        [formatter setDateFormat:@"E,dd MMM YYYY,HH:mm:ss"];
        NSString* dateString=[[formatter stringFromDate:[NSDate date]] stringByAppendingString:@" GMT"];
        if (self.getUploadTimeBLock != nil) {
            const NSTimeInterval timeInterval = self.getUploadTimeBLock();
            NSDate* date = [NSDate dateWithTimeIntervalSince1970:timeInterval];
            dateString=[[formatter stringFromDate:date] stringByAppendingString:@" GMT"];
        }
        
        
        NSString* authorization=nil;
        authorization=[DWCloudUtil getAuthorizationWithMethodName:@"PUT" fileName:weakSelf.fileName overdueSecond:0];
        NSMutableData* data = [NSMutableData dataWithData:dataSending];
        NSMutableDictionary* header=[NSMutableDictionary dictionaryWithObjectsAndKeys:
                                     authorization,@"Authorization",
                                     dateString,@"Date",
                                     [NSString stringWithFormat:@"%zi",[data length]],@"Content-Length",
                                     nil];
        
        [request setRequestHeaders:header];
        
        [request setPostBody:data];

        loc+=m;
        byteRemained-=m;
        index++;
        

        [self.queue addOperation:request];
        if ([array count]!=0) {
            [request addDependency:[array lastObject]];
        }
        [array addObject:request];
    }
    self.queue.userInfo=[NSDictionary dictionaryWithObjectsAndKeys:
                         uploadId,@"uploadId",
                         zone,@"zone",
                         @([array count]),@"count" ,nil];
    [self.queue go];
}

- (void)uploadFinish
{
    NSDictionary* userInfo=self.queue.userInfo;
    NSString* zone=[userInfo objectForKey:@"zone"];
    NSString* uploadId=[userInfo objectForKey:@"uploadId"];
    
    NSURL* url=[NSURL URLWithString:[NSString stringWithFormat:@"/%@?uploadid=%@",self.fileName,uploadId] relativeToURL:[NSURL URLWithString:[@"http://" stringByAppendingString:zone]]];
    ASIFormDataRequest* request=[[ASIFormDataRequest alloc] initWithURL:url];
    
    NSDateFormatter* formatter=[[NSDateFormatter alloc] init];
    [formatter setTimeZone:[NSTimeZone timeZoneWithName:@"GMT"]];
    [formatter setDateFormat:@"E,dd MMM YYYY,HH:mm:ss"];
    NSString* dateString=[[formatter stringFromDate:[NSDate date]] stringByAppendingString:@" GMT"];
    
    if (self.getUploadTimeBLock != nil) {
        const NSTimeInterval timeInterval = self.getUploadTimeBLock();
        NSDate* date = [NSDate dateWithTimeIntervalSince1970:timeInterval];
        dateString=[[formatter stringFromDate:date] stringByAppendingString:@" GMT"];
    }
    
    NSString* authorization=nil;
    authorization=[DWCloudUtil getAuthorizationWithMethodName:@"POST" fileName:self.fileName overdueSecond:0];
    NSArray* imageType=@[@"g3fax",@"gif",@"ief",@"jpeg",@"tiff",@"png",@"jpg"];
    NSArray* audioType = @[@"aac"];
    NSArray* videoType = @[@"mp4"];
    NSString* contentType=@"application/force-download";
    if ([imageType containsObject:[self.fileName pathExtension]]||[self.space isEqualToString:KC_QiniuImage]) {
        contentType=[NSString stringWithFormat:@"image/%@",[self.fileName pathExtension]];
    } else if ([audioType containsObject:[self.fileName pathExtension]]||[self.space isEqualToString:KC_QiniuAudio]) {
        contentType = @"audio/aac";
    } else if ([videoType containsObject:[self.fileName pathExtension]]||[self.space isEqualToString:KC_QiniuVideo]) {
        contentType = @"video/mp4";
    }
    NSDictionary* param=[NSDictionary dictionaryWithObjectsAndKeys:userInfo[@"count"],@"partcount",nil];
    NSMutableData* data=[NSMutableData dataWithData:[NSJSONSerialization dataWithJSONObject:param options:kNilOptions error:nil]];
    
    NSMutableDictionary* header=[NSMutableDictionary dictionaryWithObjectsAndKeys:
                                 authorization,@"Authorization",
                                 contentType,@"Content-type",
                                 dateString,@"Date",
                                 [NSString stringWithFormat:@"%zi",[data length]],@"Content-Length",
                                 nil];
    [request setRequestHeaders:header];
    
    
    [request setPostBody:data];
    
    __weak DWCloudUploader* weakSelf=self;
    [request setCompletionBlock:^{
        if (200==weakSelf.request.responseStatusCode) {
            if (weakSelf.uploadSuccess) {
                NSString* fileUrl=self.fileName;
                weakSelf.uploadSuccess(fileUrl);
            }
        }
        else
        {
            if (weakSelf.uploadFail) {
                weakSelf.uploadFail(weakSelf.request.error);
            }
        }
    }];
    
    [request setFailedBlock:^{
        if (weakSelf.uploadFail) {
            weakSelf.uploadFail(weakSelf.request.error);
        }
//        NSLog(@"%@",weakSelf.request.responseString);
    }];
    self.request=request;
    [self.request startAsynchronous];
}

#pragma mark -
- (void)uploadQueueCompleted:(ASINetworkQueue*)queue
{
    [self uploadFinish];
}

- (void)uploadRequestFailed:(ASIHTTPRequest*)request
{
//    NSLog(@"failed----%@,%zi,%@",request.error,request.responseStatusCode,request.responseStatusMessage);
}

- (void)uploadRequestFinish:(ASIHTTPRequest*)request
{
//    NSLog(@"success----%@ %@",request.url,request.responseString);
}

- (void)setProgress:(float)progress
{
    if (self.uploadProgress) {
        self.uploadProgress(progress);
    }
}

@end
