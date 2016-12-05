//
//  NetDelegate.h
//  XGameStudyDemo
//
//  Created by JohnnyChen on 16/12/3.
//  Copyright © 2016年 YY.Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@class GagaProtocol;
@class NetConnection;
@class NetDataChannel;

@protocol NetClientDelegate <NSObject>
- (void)onProto:(GagaProtocol*)protocol;
- (void)onException:(int)reason details:(NSString*)description;
@end

@protocol NetChannelDelegate <NSObject>
- (void)onProto:(GagaProtocol*)protocol;
- (void)onException:(int)reason details:(NSString*)description;

@optional
- (void)onConnected:(NetDataChannel*)channel;
- (void)onDisconnected:(NetDataChannel*)channel;
@end

@protocol NetConnectionDelegate <NSObject>
- (void)onProto:(NetConnection*)connection withProto:(GagaProtocol*)protocol;
- (void)onException:(NetConnection*)connection withReason:(int)aReason withDetails:(NSString*)description;
- (void)onConnected:(NetConnection*)connection;
- (void)onDisconnected:(NetConnection*)connection;

- (void)onData:(NetConnection*)connection withData:(NSData*)data withTag:(long)tag;
@end