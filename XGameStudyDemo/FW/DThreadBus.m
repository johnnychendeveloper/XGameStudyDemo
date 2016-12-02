//
//  DThreadBus.m
//  XGameStudyDemo
//
//  Created by JohnnyChen on 16/11/13.
//  Copyright © 2016年 YY.Inc. All rights reserved.
//

#import "DThreadBus.h"

@interface DThreadBus()
{
    dispatch_queue_t _queues[ThreadMax];
    NSLock *_lock;
}

@end

@implementation DThreadBus

- (void)startup
{
    _queues[ThreadMain] = dispatch_get_main_queue();
    _queues[ThreadWhatEver] = dispatch_queue_create("ThreadBus-whatEver", NULL);
    _queues[ThreadIO] = dispatch_queue_create("ThreadBus-IO", NULL);
    _queues[ThreadNet] = dispatch_queue_create("ThreadBus-Net", NULL);
    _queues[ThreadDb] = dispatch_queue_create("ThreadBus-Db", NULL);
    _queues[ThreadBack] = dispatch_queue_create("ThreadBus-Back", NULL);
    _queues[ThreadWorking] = dispatch_queue_create("ThreadBus-working", NULL);
    _queues[ThreadMedia] = dispatch_queue_create("ThreadBus-media", NULL);
    
    _lock = [[NSLock alloc] init];
    
}

- (void)setQueue:(dispatch_queue_t)queue toThread:(int)thread
{
    [_lock lock];
    _queues[thread] = queue;
    [_lock unlock];
}

- (dispatch_queue_t)queueOf:(int)thread
{
    [_lock lock];
    dispatch_queue_t queue = _queues[thread];
    [_lock unlock];
    return queue;
}

- (void)post:(dispatch_block_t)block to:(int)thread
{
    dispatch_queue_t queue = _queues[thread];
    
    //the sync way will cause dead-block easily
    dispatch_async(queue, block);
}

- (void)post:(dispatch_block_t)block to:(int)thread delayed:(NSTimeInterval)delay
{
    dispatch_queue_t queue = _queues[thread];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delay*NSEC_PER_SEC)), queue, block);
}

- (void)post:(dispatch_block_t)block to:(int)thread atTime:(NSTimeInterval)uptime
{
    dispatch_queue_t queue = _queues[thread];
    dispatch_after((int64_t)(uptime*NSEC_PER_SEC), queue, block);
}

- (void)callsafe:(dispatch_block_t)block inThread:(int)thread
{
    // whatever
    if(thread == ThreadWhatEver)
    {
        block();
        return;
    }
    
    dispatch_queue_t queue = [self queueOf:thread];
    
    //main thread
    if(thread == ThreadMain && [NSThread isMainThread])
    {
        block();
        return;
    }
    
    dispatch_async(queue, block);
}

+ (instancetype)sharedInstance
{
    static dispatch_once_t once;
    static DThreadBus *sharedInstance;
    dispatch_once(&once, ^{
        sharedInstance = [DThreadBus new];
        [sharedInstance startup];
    });
    return sharedInstance;
}

@end
