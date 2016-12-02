//
//  MySocketServe.h
//  XGameStudyDemo
//
//  Created by JohnnyChen on 16/11/28.
//  Copyright © 2016年 YY.Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CocoaAsyncSocket/GCDAsyncSocket.h>

@interface MySocketServe : NSObject

@property(nonatomic,strong,readonly) GCDAsyncSocket *socket;
@property(nonatomic,copy,readonly) NSString *socketHost;
@property(nonatomic,assign,readonly) uint16_t socketPort;

+ (instancetype)shareSocket;

- (void)connected:(NSString*)host onPort:(uint16_t)port error:(NSError*)error;

- (void)disConnected;

- (void)writeData:(NSData*)data withTimeout:(NSTimeInterval)timeout tag:(long)tag;

- (void)readDataToData:(NSData*)data withTimeout:(NSTimeInterval)timeout tag:(long)tag;

@end
