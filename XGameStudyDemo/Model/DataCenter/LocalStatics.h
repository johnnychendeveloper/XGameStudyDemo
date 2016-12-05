//
//  LocalStatics.h
//  XGameStudyDemo
//
//  Created by JohnnyChen on 16/12/3.
//  Copyright © 2016年 YY.Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString* const kTag_SigWrite;
extern NSString* const kTag_SigRead;

@class DayDayUp;

typedef NS_ENUM(NSUInteger,NetWay)
{
    NetWay_2G3G,
    NetWay_Wifi,
};

typedef NS_ENUM(NSUInteger,OpWay)
{
    OpWay_Read,
    OpWay_Write,
};

@interface StaticsOne : NSObject
@property DayDayUp *day;
@property NetWay net;
@property OpWay op;
- (id)initWithNetWay:(NetWay)net opWay:(OpWay)op;
@end


@interface LocalStatics : NSObject

- (void)addReadSize:(long)size tag:(NSString*)tag;
- (void)addWriteSize:(long)size tag:(NSString*)tag;
+ (instancetype)sharedInstance;
@end
