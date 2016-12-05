//
//  ConstCache.m
//  XGameStudyDemo
//
//  Created by JohnnyChen on 16/12/5.
//  Copyright © 2016年 YY.Inc. All rights reserved.
//

#import "ConstCache.h"

@implementation CacheObject
@end

@implementation CacheResult
@end

@interface ConstCache()
{
    NSString *_name;
    //NSCache is thread safe,but it can be flushed at any time to preserve memory
    //If you want a more persistant cache,you should use a dictionary.
    NSMutableDictionary *_cache;
    NSLock *_cacheLock;
    ConstCacheNewObject _ccNewObject;
}

@end

@implementation ConstCache
- (CacheResult *)cacheResultForKey:(id)key autoCreate:(BOOL)autoCreate
{
    CacheResult *result = [CacheResult new];
    result.isNew = NO;
    
    [_cacheLock lock];
    CacheObject* obj = [_cache objectForKey:key];
    
    if(obj == nil && autoCreate)
    {
        obj = [[CacheObject alloc] init];
        obj.key = key;
        obj.value = _ccNewObject(key);
        obj.flag = 0;
        [_cache setObject:obj forKey:key];
        
        result.isNew = YES;
    }
    result.value = obj.value;
    result.cache = obj;
    [_cacheLock unlock];
    return result;
}

- (id)objectForKey:(id)key
{
    return [self objectForKey:key autoCreate:self.autoNewObject];
}

- (id)objectForKey:(id)key autoCreate:(BOOL)autoCreate
{
    return [self cacheResultForKey:key autoCreate:autoCreate].value;
}

- (BOOL)contains:(id)key
{
    [_cacheLock lock];
    BOOL contains = [_cache objectForKey:key] != nil;
    [_cacheLock unlock];
    return contains;
}

- (void)remove:(id)key
{
    [_cacheLock lock];
    [_cache removeObjectForKey:key];
    [_cacheLock unlock];
}

- (void)clear
{
    [_cacheLock lock];
    [_cache removeAllObjects];
    [_cacheLock unlock];
}

- (id)initWithName:(NSString*)name andCCNewObject:(ConstCacheNewObject)ccNewObject
{
    if(self = [super init])
    {
        _name = name;
        _ccNewObject = ccNewObject;
        _cache = [[NSMutableDictionary alloc] init];
        _cacheLock = [NSLock new];
        
        self.autoNewObject = YES;
    }
    return self;
}

+ (id)constCacheWithName:(NSString *)name andCCNewObject:(ConstCacheNewObject)ccNewObject
{
    ConstCache *cache = [[ConstCache alloc] initWithName:name andCCNewObject:ccNewObject];
    return cache;
}

@end
