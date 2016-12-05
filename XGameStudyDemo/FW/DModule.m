//
//  DModule.m
//  XGameStudyDemo
//
//  Created by JohnnyChen on 16/12/5.
//  Copyright © 2016年 YY.Inc. All rights reserved.
//

#import "DModule.h"
#import "DNotification.h"

@implementation DModule

- (void)dealloc
{
    [DNotification removeObserver:self];
}

@end
