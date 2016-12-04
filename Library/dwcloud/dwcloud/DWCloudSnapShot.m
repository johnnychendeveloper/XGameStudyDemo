//
//  DWCloudSnapShot.m
//  dwcloud
//
//  Created by rannger on 14-10-8.
//  Copyright (c) 2014年 rannger. All rights reserved.
//

#import "DWCloudSnapShot.h"
#import "ASIFormDataRequest.h"
#import "DWCloudUtil.h"

@interface DWCloudSnapShot ()
{
    ASIFormDataRequest* _request;
}
@property (nonatomic,strong) ASIFormDataRequest* request;
@end

@implementation DWCloudSnapShot
@synthesize fileName=_fileName;
@synthesize request=_request;
@synthesize success=_success;
@synthesize failed=_failed;

- (void)dealloc
{
    self.request.completionBlock=nil;
    self.request.failedBlock=nil;
    [self.request cancel];
    
}

- (void)go
{
    [self createSnapShot];
}

- (void)createSnapShot
{
    NSString* urlStr=@"http://vod.yy.com/jobs";
    NSMutableDictionary* param=[NSMutableDictionary dictionaryWithDictionary:@{
                                                                     @"cmd":@"snapshot",
                                                                     //        @"input":
                                                                     //        @{
                                                                     //            @"filename":@"a.mp4",
                                                                     //        },
                                                                     @"pipelineid":@"82651888138944824",
                                                                     @"composition":@[],
                                                                     @"snapshot":@{
                                                                             @"pattern":@"once",
                                                                             }
                                                                     }];
    [param setObject:@{@"filename":self.fileName} forKey:@"input"];

    
    ASIFormDataRequest* request=[[ASIFormDataRequest alloc] initWithURL:[NSURL URLWithString:urlStr]];
    
    NSMutableData* data=[NSMutableData dataWithData:[NSJSONSerialization dataWithJSONObject:param options:kNilOptions error:nil]];
    __weak DWCloudSnapShot* weakSelf=self;
    [request setPostBody:data];
    [request setCompletionBlock:^{
        NSData* data=[weakSelf.request responseData];
        NSDictionary* res=[NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
        NSLog(@"%@",res);
        NSURL* u=[NSURL URLWithString:[[[self.fileName stringByDeletingPathExtension] stringByAppendingString:@"_0"] stringByAppendingPathExtension:@"jpg"] relativeToURL:[NSURL URLWithString:[DWCloudUtil photoServiceURLString]]];
        NSString* urlStr=[u absoluteString];
        weakSelf.success(urlStr);
    }];
    [request setFailedBlock:^{
        weakSelf.failed(weakSelf.request.error);
    }];
    
    self.request=request;
    [self.request startAsynchronous];
}
@end
