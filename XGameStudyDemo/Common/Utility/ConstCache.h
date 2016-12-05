//
//  ConstCache.h
//  XGameStudyDemo
//
//  Created by JohnnyChen on 16/12/5.
//  Copyright © 2016年 YY.Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef id(^ConstCacheNewObject)(id key);

@interface CacheObject : NSObject
@property id key;
@property id value;
@property int flag;
@end

@interface CacheResult : NSObject
@property id value;
@property BOOL isNew;
@property CacheObject* cache;
@end

/**
 * Const Cache, a key will get global unique object
 */

@interface ConstCache : NSObject

@property BOOL autoNewObject;

- (CacheResult*)cacheResultForKey:(id)key autoCreate:(BOOL)autoCreate;

- (id)objectForKey:(id)key;
- (id)objectForKey:(id)key autoCreate:(BOOL)autoCreate;

- (BOOL)contains:(id)key;
- (void)remove:(id)key;
- (void)clear;

+ (id)constCacheWithName:(NSString*)name andCCNewObject:(ConstCacheNewObject)ccNewObject;
@end
