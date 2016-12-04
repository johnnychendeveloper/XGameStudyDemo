//
//  dwcloudTests.m
//  dwcloudTests
//
//  Created by rannger on 14-9-24.
//  Copyright (c) 2014年 rannger. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "dwcloud.h"
#import <UIKit/UIKit.h>

@interface dwcloudTests : XCTestCase
{
    DWCloudUploader* uploader;
}
@end

NSString* AK = @"ak_mqc";
NSString* SK = @"b505d0fb8fa9e96e3abf202ad2c03b19b022281e";
NSString* BUCKET_NAME = @"more";

@implementation dwcloudTests

- (void)setUp
{
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
    [DWCloudUtil registerWithAccessKey:AK SecretKey:SK];
    [DWCloudUtil setBucketName:BUCKET_NAME];
}

- (void)tearDown
{
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}


- (void)testSnapShot
{
    DWCloudSnapShot* s=[[DWCloudSnapShot alloc] init];
    s.fileName=@"VID_20141009_093024.mp4";
    XCTestExpectation *expectation = [self expectationWithDescription:@"testSnapShot"];
    s.success=^(NSString* fileUrl)
    {
        NSURL* url=[NSURL URLWithString:fileUrl];
        NSData* data=[NSData dataWithContentsOfURL:url];
        UIImage* image=[UIImage imageWithData:data];
        NSLog(@"%@",url);
        XCTAssert(image);
        [expectation fulfill];
    };
    
    s.failed=^(NSError* error)
    {
        XCTFail(@"faile reson:%@",error);
    };
    [s go];
    
    [self waitForExpectationsWithTimeout:30 handler:^(NSError *error) {
        if(error)
        {
            XCTFail(@"Expectation Failed with error: %@ %@", error,error.userInfo);
        }
    }];
}

- (void)testExample
{
    NSURL* url=[NSURL URLWithString:@"http://www.linuxeden.com/upimg/allimg/140925/1-140925142149.jpg"];
    NSData *data=[NSData dataWithContentsOfURL:url];
    NSString* filePath=[NSTemporaryDirectory() stringByAppendingPathComponent:@"1-140925142149.jpg"];
    BOOL writeSuccess=[data writeToFile:filePath atomically:YES];
    XCTAssert(writeSuccess);
    
    uploader=[[DWCloudUploader alloc] init];
    uploader.filePath=filePath;
    XCTestExpectation *expectation = [self expectationWithDescription:@"Testing Async Method Works!"];
    [uploader setUploadSuccess:^(NSString* fileUrl){
        NSURL* url=[NSURL URLWithString:[DWCloudUtil photoZoomWithURL:fileUrl width:320 height:480]];
        ;
        NSData* data=[NSData dataWithContentsOfURL:url];
        UIImage* image=[UIImage imageWithData:data];
        NSLog(@"%f,%f",image.size.width,image.size.height);
        XCTAssert(image);
        [expectation fulfill];
    }];
    
    [uploader setUploadFail:^(NSError* error) {
        XCTFail(@"faile reson:%@",error);
    }];
    [uploader go];
    
    [self waitForExpectationsWithTimeout:30 handler:^(NSError *error) {
        if(error)
        {
            XCTFail(@"Expectation Failed with error: %@ %@", error,error.userInfo);
        }
    }];
    
    
}

@end
