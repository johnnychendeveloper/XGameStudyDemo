//
//  LogExt.h
//  XGameStudyDemo
//
//  Created by JohnnyChen on 16/11/23.
//  Copyright © 2016年 YY.Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LogExt : NSObject

+ (void)prepareForLogging;
+ (NSString*)loggingFilePath;
+ (NSString*)logFolder;
@end
