//
//  DThreadBus.h
//  XGameStudyDemo
//
//  Created by JohnnyChen on 16/11/13.
//  Copyright © 2016年 YY.Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

// 线程索引
typedef enum : NSUInteger
{
    ThreadWhatEver,
    ThreadMain,
    ThreadIO,
    ThreadNet,
    ThreadDb,
    ThreadWorking,
    ThreadBack,
    ThreadMedia,
    
    ThreadMax,
    
} DEnumThread;

@interface DThreadBus : NSObject

- (void) startup;

- (void) post:(dispatch_block_t)block to:(int)thread;

- (void) post:(dispatch_block_t)block to:(int)thread delayed:(NSTimeInterval)delay;

- (void) post:(dispatch_block_t)block to:(int)thread atTime:(NSTimeInterval)uptime;

- (void) callsafe:(dispatch_block_t)block inThread:(int)thread;

- (void) setQueue:(dispatch_queue_t)queue toThread:(int)thread;

- (dispatch_queue_t) queueOf:(int)thread;

+ (instancetype)sharedInstance;

@end
