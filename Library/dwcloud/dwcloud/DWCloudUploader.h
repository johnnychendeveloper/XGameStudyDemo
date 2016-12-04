//
//  DWCloudUploader.h
//  dwcloud
//
//  Created by rannger on 14-9-24.
//  Copyright (c) 2014年 rannger. All rights reserved.
//

#import <Foundation/Foundation.h> 


typedef void(^UploadFail)(NSError*);
typedef void(^UploadSuccess)(NSString* fileUrl);
typedef void(^UploadProgress)(float);
typedef NSTimeInterval(^GetUploadTimeBLock)(void);

@interface DWCloudUploader : NSObject
{
    NSString* _filePath;
    NSString* _space;
    UploadFail _uploadFail;
    UploadSuccess _uploadSuccess;
    UploadProgress _uploadProgress;
}

@property (nonatomic,copy) NSString* filePath;
@property (nonatomic,copy) NSString* space;
@property (nonatomic,strong) UploadFail uploadFail;
@property (nonatomic,strong) UploadSuccess uploadSuccess;
@property (nonatomic,strong) UploadProgress uploadProgress;
@property (nonatomic,strong) GetUploadTimeBLock getUploadTimeBLock;
- (void)go;
- (void)uplodeWithFileName:(NSString *)name;
@end
