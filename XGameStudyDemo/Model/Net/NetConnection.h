//
//  NetConnection.h
//  XGameStudyDemo
//
//  Created by JohnnyChen on 16/12/3.
//  Copyright © 2016年 YY.Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NetDelegate.h"

@class GagaProtocol;

@interface NetConnection : NSObject
@property (nonatomic,strong) NSString *connectedHost;
@property (nonatomic) UInt16 connectedPort;
@property (weak,nonatomic) id<NetConnectionDelegate> delegate;
@property double timeout;

+ (uint32_t)clientVersion;

- (id)initWithDelegate:(id<NetConnectionDelegate>)delegate;
- (BOOL)connectTo:(NSString*)host onPort:(int)port;
- (BOOL)connectTo:(NSString*)host onPort:(int)port withFallbackIps:(NSArray*)fallbacks;
- (void)disconnect;
- (BOOL)writeProto:(GagaProtocol*)proto;
- (void)readOneProto;
- (void)setRc4Key:(NSData*)key;
- (void)setGzip:(BOOL)gzip;

@end
