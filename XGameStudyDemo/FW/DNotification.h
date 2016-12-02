//
//  DNotification.h
//  XGameStudyDemo
//
//  Created by JohnnyChen on 16/11/13.
//  Copyright © 2016年 YY.Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DDef.h"
#import "DThreadBus.h"

//control the notify thread
#define DNotifyThreadWhatever ThreadWhatEver
#define DNotifyThreadMain ThreadMain
#define DNotifyThreadBackground ThreadBack

// notification
@interface DNotification : NSObject

@property(nonatomic) NSString *name;
@property(nonatomic) DENotification idx;    //uint64_t
@property(nonatomic) int thread;

+ (void) setup;
+ (DNotification* const)id2Event:(DENotification) idx;

+ (void)addObserver:(id)observer selector:(SEL)aSelector name:(DENotification)notification object:(id)anObject;

+ (void)postNotification:(DENotification) notification;
+ (void)postNotificationName:(DENotification) notification object:(id)anObject;
+ (void)postNotificationName:(DENotification) notification object:(id)anObject userInfo:(NSDictionary *)aUserInfo;

+ (void)removeObserver:(id)observer;
+ (void)removeObserver:(id)observer name:(DENotification) notification object:(id)anObject;

- (id)initWithName:(NSString*)name withIdx:(DENotification)idx;
- (id)initWithName:(NSString*)name withIdx:(DENotification)idx andThread:(int)thread;

@end

//自动释放 Notification
@interface DNotificationAutoKeeper : NSObject
+ (id)initWithTarget:(id)target;
@end
