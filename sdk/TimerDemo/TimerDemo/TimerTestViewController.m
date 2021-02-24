//
//  TimerTestViewController.m
//  TimerDemo
//
//  Created by GoSun on 2021/2/24.
//

#import "TimerTestViewController.h"
#import "MBTimer.h"
@interface TimerTestViewController ()
@property(nonatomic ,strong)NSTimer *timer1;

@property(nonatomic ,strong)CADisplayLink *timer2;

@property(nonatomic ,strong)dispatch_source_t timer3;

@property (copy, nonatomic) NSString *task;

@end

@implementation TimerTestViewController




- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.view.backgroundColor = [UIColor whiteColor];

//    self.task = [MBTimer execTask:^{
//        NSLog(@"%s ",__func__);
//    } start:0.5 interval:1.0 repeats:YES async:NO];
    
    self.task = [MBTimer execTask:self selector:@selector(timerTest) start:0.5 interval:1.0 repeats:YES async:NO];
    
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [MBTimer cancelTask:self.task];
}

void gcdtimerTest()
{
    NSLog(@"%s ",__func__);
}

- (void)gcdTimer
{
    self.timer3 = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, dispatch_get_global_queue(0, 0));
    
    /// 参数： 1 定时器  2 任务开始时间   3任务的间隔  4可接受的误差时间，设置0即不允许出现误差
    dispatch_source_set_timer(self.timer3, DISPATCH_TIME_NOW, 1.0*NSEC_PER_SEC, 0.0*NSEC_PER_SEC);
    
    dispatch_source_set_event_handler(self.timer3, ^{
        NSLog(@"%s <##>",__func__);
    });
    
//    dispatch_source_set_event_handler_f(self.timer3, gcdtimerTest);

//    dispatch_resume(self.timer3);
}

/// 采用selector方式创建定时器
- (void)timerWithSelector
{
    self.timer1 = [NSTimer timerWithTimeInterval:1.0 target:self selector:@selector(timerTest) userInfo:nil repeats:YES];
    [[NSRunLoop currentRunLoop]addTimer:self.timer1 forMode:NSDefaultRunLoopMode];
    
//    self.timer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(timerTest) userInfo:nil repeats:YES];
}

/// 采用block方式创建定时器
- (void)timerWithBlock
{
    self.timer1 = [NSTimer scheduledTimerWithTimeInterval:1.0 repeats:YES block:^(NSTimer * _Nonnull timer) {
        NSLog(@"%s block ",__func__);
    }];

//    self.timer1 = [NSTimer timerWithTimeInterval:1.0 repeats:YES block:^(NSTimer * _Nonnull timer) {
//        NSLog(@"%s block ",__func__);
//    }];
//    [[NSRunLoop currentRunLoop]addTimer:self.timer1 forMode:NSDefaultRunLoopMode];
}

/// 采用CADisplayLink方式创建定时器
- (void)cadisplaylinkDemo
{
    self.timer2 = [CADisplayLink displayLinkWithTarget:self selector:@selector(timerTest)];
    self.timer2.preferredFramesPerSecond = 1;
    [self.timer2 addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    
}

- (void)timerTest
{
    NSLog(@"%s ",__func__);
}
- (void)dealloc
{
    [self.timer1 invalidate];
    
//    dispatch_suspend(self.timer3);
    
    NSLog(@"%s ",__func__);
}

@end
