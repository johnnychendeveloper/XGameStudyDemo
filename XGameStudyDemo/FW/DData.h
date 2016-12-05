//
//  DData.h
//  XGameStudyDemo
//
//  Created by JohnnyChen on 16/12/5.
//  Copyright © 2016年 YY.Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
//#import "MessageTypes.h"
//#import "UserTypes.h"
#import <Reachability.h>
#import "ConstCache.h"
#import <CoreLocation/CoreLocation.h>

@class JDb;

@interface CachedAudioInfo : NSObject
@property NSString* hashs;
@property long state;
@end

#define __CCacheName(i) @ #i
#define __CCacheIdx(i) ECache_Index_##i
#define __CCache(i) [DDataCache cache:__CCacheIdx(i)]
enum ECacheIndex
{
    __CCacheIdx(None),
    __CCacheIdx(CachedAudioInfo),
    __CCacheIdx(Max)
};

@interface DDataCache : NSObject
+ (void)setup;
+ (ConstCache*)cache:(int)idx;
@end


//////////////////////////////////////////////////////////////
@interface DData : NSObject
@end

/************************** App Module ***********************/
@interface DAppData : DData
@property BOOL loadFinished;       //加载是否结束
@property BOOL inbackground;
@end

/************************** App Module ***********************/
@interface DDataCenterData : DData
@property JDb* db;
@property JDb* appDb;
@end











