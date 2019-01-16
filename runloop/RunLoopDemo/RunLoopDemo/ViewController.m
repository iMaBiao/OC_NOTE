//
//  ViewController.m
//  RunLoopDemo
//
//  Created by teilt on 2019/1/16.
//  Copyright © 2019 teilt. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@property (strong, nonatomic) NSThread *thread;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeContactAdd];
    [self.view addSubview:btn];
    btn.center = self.view.center;
    [btn addTarget:self action:@selector(btnClick) forControlEvents:UIControlEventTouchUpInside];
    
//    [self showDemo1];
    
//    [self showDemo2];
    
    [self showDemo4];
    

}
- (void)run2
{
    NSLog(@"%s run2", __FUNCTION__);
}
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [self performSelector:@selector(run1) onThread:self.thread withObject:nil waitUntilDone:NO];
}

- (void)run1
{
    // 这里写任务
    NSLog(@"run1---%@",[NSThread currentThread]);
    [[NSRunLoop currentRunLoop]addPort:[NSPort port] forMode:NSDefaultRunLoopMode];
    [[NSRunLoop currentRunLoop] run];
    
    // 测试是否开启了RunLoop，如果开启RunLoop，则来不了这里，因为RunLoop开启了循环。
    NSLog(@"-------------");
    
}
- (void)showDemo4
{
    // 创建线程，并调用run1方法执行任务
    self.thread = [[NSThread alloc] initWithTarget:self selector:@selector(run1) object:nil];
    [self.thread start];
}

//用来展示CFRunLoopObserverRef使用
- (void)showDemo2
{
   // 创建观察者
    CFRunLoopObserverRef observer = CFRunLoopObserverCreateWithHandler(CFAllocatorGetDefault(), kCFRunLoopAllActivities, YES, 0, ^(CFRunLoopObserverRef observer, CFRunLoopActivity activity) {
        NSLog(@"监听到RunLoop发生改变---%zd",activity);
    });
    
    // 添加观察者到当前RunLoop中
    CFRunLoopAddObserver(CFRunLoopGetCurrent(), observer, kCFRunLoopDefaultMode);
    
    // 释放observer
    CFRelease(observer);
}


- (void)btnClick
{
    NSLog(@"%s ", __FUNCTION__);
}

// 用来展示CFRunLoopModeRef和CFRunLoopTimerRef的结合使用
- (void)showDemo1
{
    NSTimer *timer = [NSTimer timerWithTimeInterval:2.0 target:self selector:@selector(run) userInfo:nil repeats:YES];
    
// 将定时器添加到当前RunLoop的NSDefaultRunLoopMode下,一旦RunLoop进入其他模式，定时器timer就不工作了
    [[NSRunLoop currentRunLoop] addTimer:timer forMode:NSDefaultRunLoopMode];
    
// 将定时器添加到当前RunLoop的UITrackingRunLoopMode下，只在拖动情况下工作
//    [[NSRunLoop currentRunLoop] addTimer:timer forMode:UITrackingRunLoopMode];
// 将定时器添加到当前RunLoop的NSRunLoopCommonModes下，定时器就会跑在被标记为Common Modes的模式下
//    [[NSRunLoop currentRunLoop] addTimer:timer forMode:NSRunLoopCommonModes];

// 调用了scheduledTimer返回的定时器，已经自动被加入到了RunLoop的NSDefaultRunLoopMode模式下
    [NSTimer scheduledTimerWithTimeInterval:2.0 target:self selector:@selector(run) userInfo:nil repeats:YES];
}

- (void)run
{
    NSLog(@"%s run %@", __FUNCTION__,[NSThread currentThread]);
}

@end
