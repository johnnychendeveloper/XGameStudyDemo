//
//  DNotification.m
//  XGameStudyDemo
//
//  Created by JohnnyChen on 16/11/13.
//  Copyright © 2016年 YY.Inc. All rights reserved.
//

#import "DNotification.h"

static NSArray* events;

@implementation DNotification

#undef Def_Module
#undef Def_Notification
#undef Def_NotificationEx
#undef Def_Const
#undef Def_ConstWithKey
#undef Def_ConstValue

#define Def_Notification(e) [[DNotification alloc] initWithName:@#e withIdx:KN_##e],
#define Def_NotificationEx(e,thread) [[DNotification alloc] initWithName:@#e withIdx:KN_##e andThread:thread],
#define Def_Module(m)
#define Def_Const(c)
#define Def_ConstWithKey(c,k)
#define Def_ConstValue(c,v)


+ (void)setup
{
    events = [[NSArray alloc] initWithObjects:
#include "DDef.inl.h" 
              nil];
}

+ (DNotification *)id2Event:(DENotification)idx
{
    return [events objectAtIndex:idx];
}

- (id)initWithName:(NSString *)name withIdx:(DENotification)idx
{
    self = [super init];
    if(self)
    {
        self.name = name;
        self.idx = idx;
        self.thread = DNotifyThreadMain;
    }
    return self;
}

- (id)initWithName:(NSString *)name withIdx:(DENotification)idx andThread:(int)thread
{
    self = [super init];
    if(self)
    {
        self.name = name;
        self.idx = idx;
        self.thread = thread;
    }
    return self;
}

+ (void)addObserver:(id)observer selector:(SEL)aSelector name:(DENotification)notification object:(id)anObject
{
    DNotification *notify = [DNotification id2Event:notification];
    [[NSNotificationCenter defaultCenter] addObserver:observer selector:aSelector name:notify.name object:anObject];
}

+ (void)postNotification:(DENotification)notification
{
    DNotification *notify = [DNotification id2Event:notification];
    [DNotification postnotification:notify withObject:nil userInfo:nil];
}

+ (void)postNotificationName:(DENotification)notification object:(id)anObject
{
    DNotification *notify = [DNotification id2Event:notification];
    [DNotification postnotification:notify withObject:anObject userInfo:nil];
}

+ (void)postNotificationName:(DENotification)notification object:(id)anObject userInfo:(NSDictionary *)aUserInfo
{
    DNotification *notify = [DNotification id2Event:notification];
    [DNotification postnotification:notify withObject:anObject userInfo:aUserInfo];
}



+ (void)postnotification:(DNotification*)notify withObject:(id)anObject userInfo:(NSDictionary*)aUserInfo
{
    [[DThreadBus sharedInstance] callsafe:^{
        NSLog(@"post notification in thread:%@",[NSThread currentThread]);
        [[NSNotificationCenter defaultCenter] postNotificationName:notify.name object:anObject userInfo:aUserInfo];
    } inThread:notify.thread];
}


+ (void)removeObserver:(id)observer
{
    @try {
        [[NSNotificationCenter defaultCenter] removeObserver:observer];
    } @catch (NSException *exception) {
    } @finally {
    }
}

+ (void)removeObserver:(id)observer name:(DENotification)notification object:(id)anObject
{
    DNotification *notify = [DNotification id2Event:notification];
    [[NSNotificationCenter defaultCenter] removeObserver:observer name:notify.name object:anObject];
}
@end

@interface DNotificationAutoKeeper()
@property (weak) id target;
@end

@implementation DNotificationAutoKeeper

+ (id)initWithTarget:(id)target
{
    DNotificationAutoKeeper *keeper = [[DNotificationAutoKeeper alloc] init];
    keeper.target = target;
    return keeper;
}

- (void)dealloc
{
    if(self.target)
    {
        [DNotification removeObserver:self.target];
    }
}

@end





