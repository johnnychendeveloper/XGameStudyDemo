//
//  MySocketServe.m
//  XGameStudyDemo
//
//  Created by JohnnyChen on 16/11/28.
//  Copyright © 2016年 YY.Inc. All rights reserved.
//

#import "MySocketServe.h"

@interface MySocketServe()<GCDAsyncSocketDelegate>

@property(nonatomic,strong,readwrite) GCDAsyncSocket *socket;
@property(nonatomic,copy,readwrite) NSString *socketHost;
@property(nonatomic,assign,readwrite) uint16_t socketPort;
@property(nonatomic,strong) NSTimer *longConnectTimer;

@end

@implementation MySocketServe

+ (instancetype)shareSocket
{
    static dispatch_once_t onceToken;
    static MySocketServe *socket;
    dispatch_once(&onceToken, ^{
        socket = [[MySocketServe alloc] init];
    });
    return socket;
}

- (instancetype)init
{
    self = [super init];
    if(self)
    {
        self.socket = [[GCDAsyncSocket alloc] initWithDelegate:self delegateQueue:dispatch_get_global_queue(0, 0)];
    }
    return self;
}

- (void)connected:(NSString *)host onPort:(uint16_t)port error:(NSError *)error
{
    self.socketHost = host;
    self.socketPort = port;
    //必须确认在断开连接的情况下，进行连接
    if(self.socket.isDisconnected)
    {
        [self.socket connectToHost:self.socketHost onPort:self.socketPort error:&error];
    }
    else
    {
        [self.socket disconnect];
        [self.socket connectToHost:self.socketHost onPort:self.socketPort error:&error];
    }
}

- (void)longConnectToSocket
{
    //根据服务器要求发送固定格式的数据，假设为指令@"longConnect",但是一般不会是这么简单的指令
    NSString *longConnect = @"longConnect\r\n";
    NSData *dataStream = [longConnect dataUsingEncoding:NSUTF8StringEncoding];
    [self.socket writeData:dataStream withTimeout:-1 tag:0];
}

- (void)disConnected
{
    [self.socket disconnect];
}

- (void)writeData:(NSData *)data withTimeout:(NSTimeInterval)timeout tag:(long)tag
{
    [self.socket writeData:data withTimeout:-1 tag:100];
}

- (void)readDataToData:(NSData *)data withTimeout:(NSTimeInterval)timeout tag:(long)tag
{
    [self.socket readDataToData:data withTimeout:-1 tag:100];
}

#pragma mark - GCDAsyncSocketDelegate

//连接成功
- (void)socket:(GCDAsyncSocket *)sock didConnectToHost:(NSString *)host port:(uint16_t)port
{
    //每隔特定时间向服务器发送心跳包
    //在longConnectToSocket方法中进行长连接需要向服务器发送特定信息
    self.longConnectTimer = [NSTimer timerWithTimeInterval:5 target:self selector:@selector(longConnectToSocket) userInfo:nil repeats:YES];
    [[NSRunLoop currentRunLoop] addTimer:self.longConnectTimer forMode:NSRunLoopCommonModes];
    
    GTMLoggerDebug(@"didConnectToHost successfully.");
}

//断开之后重新连接
- (void)socketDidDisconnect:(GCDAsyncSocket *)sock withError:(NSError *)err
{
    //todo
}

- (void)socket:(GCDAsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag
{
    NSString *dataString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    
    NSLog(@"读取到的消息:%@",dataString);
}

- (void)socket:(GCDAsyncSocket *)sock didWriteDataWithTag:(long)tag
{
    NSLog(@"didWriteDataWithTag:%ld",tag);
}





@end
