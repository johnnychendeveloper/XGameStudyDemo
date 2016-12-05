//
//  OtherViewController.m
//  XGameStudyDemo
//
//  Created by JohnnyChen on 16/12/2.
//  Copyright © 2016年 YY.Inc. All rights reserved.
//

#import "OtherViewController.h"

@interface OtherViewController ()
@property(nonatomic,strong) NSTimer *testTimer;
@property(nonatomic,strong) UIButton *testButton;
@end

@implementation OtherViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    /*self.testTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(timeoutfire) userInfo:nil repeats:YES];*/
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        self.testTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(timeoutfire) userInfo:nil repeats:YES];
        [[NSRunLoop currentRunLoop] run];
    });
    
    self.testButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.testButton.frame = CGRectMake(100, 100, 100, 20);
    [self.view addSubview:self.testButton];
    [self.testButton addTarget:self action:@selector(testButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.testButton setBackgroundColor:[UIColor grayColor]];
}

- (void) testButtonClicked:(id)sender
{
    NSLog(@"button clicked...");
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self.testTimer invalidate];
}

- (void)timeoutfire
{
    static int counter = 0;
    counter++;
    NSLog(@"time out: %d",counter);
    [self.testButton setTitle:[NSString stringWithFormat:@"%d",counter] forState:UIControlStateNormal];
}

- (void)dealloc
{
    NSLog(@"dealloc...");
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
