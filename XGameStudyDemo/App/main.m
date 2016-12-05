//
//  main.m
//  XGameStudyDemo
//
//  Created by JohnnyChen on 16/11/13.
//  Copyright © 2016年 YY.Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"

int main(int argc, char * argv[]) {
    @autoreleasepool {
        NSLog(@"main thread...");
        return UIApplicationMain(argc, argv, nil, NSStringFromClass([AppDelegate class]));
    }
}
