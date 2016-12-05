//
//  DData.m
//  XGameStudyDemo
//
//  Created by JohnnyChen on 16/12/5.
//  Copyright © 2016年 YY.Inc. All rights reserved.
//

#import "DData.h"

@implementation CachedAudioInfo
@end

static ConstCache* _allCache[__CCacheIdx(Max)];

@implementation DDataCache

+ (void)setup
{
    _allCache[__CCacheIdx(CachedAudioInfo)] = [ConstCache constCacheWithName:@"AudioInfo" andCCNewObject:^id(id key) {
        CachedAudioInfo* info = [[CachedAudioInfo alloc] init];
        info.hashs = key;
        return info;
    }];
}

+ (ConstCache*)cache:(int)idx
{
    return _allCache[idx];
}

@end

@implementation DData
@end

@implementation DAppData
@end
