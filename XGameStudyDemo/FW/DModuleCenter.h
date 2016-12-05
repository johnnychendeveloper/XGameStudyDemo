//
//  DModuleCenter.h
//  XGameStudyDemo
//
//  Created by JohnnyChen on 16/12/5.
//  Copyright © 2016年 YY.Inc. All rights reserved.
//

#import "DModule.h"
#import "DProtocol.h"

@interface DModuleCenter : DModule
+ (void)setup;
+ (id)module:(DEModule)kind withIdx:(NSUInteger)idx;
+ (void)addModule:(DModule*)module withKind:(DEModule)kind;

+ (int)mcState;
+ (void)setMCState:(int)mc;
@end
