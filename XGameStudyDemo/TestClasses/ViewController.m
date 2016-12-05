//
//  ViewController.m
//  XGameStudyDemo
//
//  Created by JohnnyChen on 16/11/13.
//  Copyright © 2016年 YY.Inc. All rights reserved.
//

#import "ViewController.h"
#import "DNotification.h"
#import "CalculateTest.h"
#import "MySocketServe.h"
#import <Masonry/Masonry.h>
#import "OtherViewController.h"

@interface ViewController ()<NSStreamDelegate>
{
    NSInputStream *_input_s;
    NSOutputStream *_output_s;
}

@property(nonatomic,strong) UIButton *button;

@property(nonatomic,strong) UIButton *connectBtn;

@property(nonatomic,strong) UITableView *tableView;

@property(nonatomic,strong) NSTimer *testTimer;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    [DNotification setup];
    
    self.button = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.button setTitle:@"send data" forState:UIControlStateNormal];
    self.button.backgroundColor = [UIColor grayColor];
    [self.view addSubview:self.button];
    self.button.frame = CGRectMake(100, 200, 100, 40);
    [self.button addTarget:self action:@selector(sendData) forControlEvents:UIControlEventTouchUpInside];
    
    self.connectBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.connectBtn setTitle:@"connect to server" forState:UIControlStateNormal];
    self.connectBtn.backgroundColor = [UIColor grayColor];
    [self.view addSubview:self.connectBtn];
    [self.connectBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(self.view.mas_centerX);
        make.centerY.mas_equalTo(self.view.mas_centerY);
    }];
    [self.connectBtn addTarget:self action:@selector(connectToServer:) forControlEvents:UIControlEventTouchUpInside];
    
    self.tableView = [[UITableView alloc] init];
    [self.view addSubview:self.tableView];
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(self.view.bounds.size.width, 200));
        make.bottom.mas_equalTo(self.view.mas_bottom);
    }];
    
    //test timer
    //NSTimer *testTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(timeoutfire) userInfo:nil repeats:YES];
    
    /*self.testTimer = [NSTimer timerWithTimeInterval:1 target:self selector:@selector(timeoutfire) userInfo:nil repeats:YES];
    [[NSRunLoop currentRunLoop] addTimer:self.testTimer forMode:NSRunLoopCommonModes];*/
    /*dispatch_async(dispatch_get_global_queue(0, 0), ^{
        NSTimer *testTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(timeoutfire) userInfo:nil repeats:YES];
        [[NSRunLoop currentRunLoop] run];
    });*/
    
    
    //建立连接
    //[self setupConnection];
    
    //Test code
    NSLog(@"sum result:%ld",[CalculateTest sumNum1:1 num2:2]);
    
}

- (void)dealloc
{
    [self.testTimer invalidate];
    NSLog(@"viewcontroller dealloc...");
}

- (void)timeoutfire
{
    static int count = 0;
    count++;
    NSLog(@"time out fire:%d",count);
}

- (void)connectToServer:(id)sender
{
    /*GTMLoggerDebug(@"try to connect to server...");
    NSError *error;
    [[MySocketServe shareSocket] connected:@"127.0.0.1" onPort:1235 error:error];*/
    
    OtherViewController *otherVC = [[OtherViewController alloc] init];
    [self.navigationController pushViewController:otherVC animated:YES];
}

- (void)setupConnection
{
    NSString *host = @"127.0.0.1";
    int port = 1234;
    CFReadStreamRef read_s;
    CFWriteStreamRef write_s;
    CFStreamCreatePairWithSocketToHost(NULL, (__bridge CFStringRef)host, port, &read_s, &write_s);
    
    _input_s = (__bridge NSInputStream*)(read_s);
    _output_s = (__bridge NSOutputStream*)(write_s);
    _input_s.delegate = _output_s.delegate = self;
    
    //把输入输出流添加到主运行循环，否则代理可能不工作
    [_input_s scheduleInRunLoop:[NSRunLoop mainRunLoop] forMode:NSDefaultRunLoopMode];
    [_output_s scheduleInRunLoop:[NSRunLoop mainRunLoop] forMode:NSDefaultRunLoopMode];
    
    //打开输入输出流
    [_input_s open];
    [_output_s open];
}

- (void)readData
{
    //建立一个缓冲区，可放1024字节
    uint8_t buf[1024];
    NSInteger len = [_input_s read:buf maxLength:sizeof(buf)];
    //把字节数组转化为字符串
    NSData *data = [NSData dataWithBytes:buf length:len];
    NSString *msg = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    
    NSLog(@"receive data:%@",msg);
}

- (void)sendData
{
    NSInteger writeNumberBytes = 0;
    NSLog(@"write %ld bytes.",writeNumberBytes);
    NSString *loginStr = @"iam:johnnychen";
    NSData *data = [loginStr dataUsingEncoding:NSUTF8StringEncoding];
    
    writeNumberBytes = [_output_s write:data.bytes maxLength:data.length];
    NSLog(@"write %ld bytes.",writeNumberBytes);
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - NSStreamDelegate

- (void)stream:(NSStream *)aStream handleEvent:(NSStreamEvent)eventCode
{
    switch (eventCode) {
        case NSStreamEventEndEncountered:  //连接结束
            NSLog(@"关闭输入输出流");
            [_input_s close];
            [_output_s close];
            [_input_s removeFromRunLoop:[NSRunLoop mainRunLoop] forMode:NSDefaultRunLoopMode];
            [_output_s removeFromRunLoop:[NSRunLoop mainRunLoop] forMode:NSDefaultRunLoopMode];
            break;
            
        case NSStreamEventErrorOccurred://连接出错
            NSLog(@"连接出错");
            break;
            
        case NSStreamEventHasBytesAvailable://有字节可读
            NSLog(@"有字节可读");
            [self readData];
            break;
            
        case NSStreamEventNone://无事件
            break;
            
        case NSStreamEventOpenCompleted://连接打开完成
            NSLog(@"打开完成");
            //[self sendData];
            break;
            
        case NSStreamEventHasSpaceAvailable://可以发送字节
            NSLog(@"可以发送字节");
            //[self sendData];
            break;
            
            
        default:
            break;
    }
}


@end
