//
//  DModuleCenter.m
//  XGameStudyDemo
//
//  Created by JohnnyChen on 16/12/5.
//  Copyright © 2016年 YY.Inc. All rights reserved.
//

#import "DModuleCenter.h"
#import "DMacro.h"

static NSArray* modules;
static int gState;

@implementation DModuleCenter

#undef Def_Event
#undef Def_Module
#undef Def_Const
#undef Def_ConstWithKey
#undef Def_ConstValue
#define Def_Event(e)
#define Def_Module(m) [[NSMutableArray alloc] init],
#define Def_Const(c)
#define Def_ConstWithKey(c, k)
#define Def_ConstValue(c, v)

+ (void)setup
{
    gState = 0;
    modules = [[NSArray alloc] initWithObjects:
#include "DDef.inl.h"
               nil];
}

+ (id)module:(DEModule)kind withIdx:(NSUInteger)idx
{
    __CHECK_ASSERT_RET(kind < modules.count, nil);
    NSMutableArray *slots = [modules objectAtIndex:(int)(kind)];
    __CHECK_ASSERT_RET(idx < slots.count, nil);
    return [slots objectAtIndex:idx];
}

+ (void)addModule:(DModule *)module withKind:(DEModule)kind
{
    __CHECK_ASSERT(kind < modules.count);
    NSMutableArray *slots = [modules objectAtIndex:(int)(kind)];
    [slots addObject:module];
}

+ (int)mcState
{
    return gState;
}

+ (void)setMCState:(int)mc
{
    gState = mc;
}

@end
