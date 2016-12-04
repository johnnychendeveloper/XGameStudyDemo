//
//  DWCloudSnapShot.h
//  dwcloud
//
//  Created by rannger on 14-10-8.
//  Copyright (c) 2014年 rannger. All rights reserved.
//

#import <Foundation/Foundation.h>


typedef void(^CreateSnapShotSuccess)(NSString* snapShot);
typedef void(^CreateSnapShotFailed)(NSError* error);

@interface DWCloudSnapShot : NSObject
{
    NSString* _fileName;
    CreateSnapShotSuccess _success;
    CreateSnapShotFailed _failed;
}

@property (nonatomic,copy) NSString* fileName;
@property (nonatomic,strong) CreateSnapShotSuccess success;
@property (nonatomic,strong) CreateSnapShotFailed failed;

- (void)go;
@end
