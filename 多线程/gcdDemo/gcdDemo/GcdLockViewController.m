//
//  GcdLockViewController.m
//  gcdDemo
//
//  Created by teilt on 2019/1/14.
//  Copyright © 2019 teilt. All rights reserved.
//

/*
 场景：总共有50张火车票，有两个售卖火车票的窗口，一个是北京火车票售卖窗口，另一个是上海火车票售卖窗口。两个窗口同时售卖火车票，卖完为止。
 */
#import "GcdLockViewController.h"

@interface GcdLockViewController ()
{
    dispatch_semaphore_t semaphoreLock;
}

//剩余票数
@property(nonatomic ,assign) int ticketSurplusCount;

@end

@implementation GcdLockViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self initTicketStatusNotSave];
    
}

#pragma mark - method

- (void)initTicketStatusNotSave
{
    NSLog(@"currentThread---%@",[NSThread currentThread]);  // 打印当前线程
    NSLog(@"semaphore---begin");
    
    self.ticketSurplusCount = 10;
    
    semaphoreLock = dispatch_semaphore_create(1);
    
    dispatch_queue_t queue1 = dispatch_queue_create("com.ibiaoma.gcdDemo", DISPATCH_QUEUE_SERIAL);
    
    dispatch_queue_t queue2 = dispatch_queue_create("com.ibiaoma.gcdDemo", DISPATCH_QUEUE_SERIAL);
    
    __weak typeof(self) weakSelf = self;
    
    dispatch_async(queue1, ^{
        [weakSelf saleTicketNotSave];
    });
    dispatch_async(queue2, ^{
        [weakSelf saleTicketNotSave];
    });
}

// 不加锁
- (void)saleTicketNotSave
{
    while (1) {
        if (self.ticketSurplusCount > 0) {
            self.ticketSurplusCount--;
            NSLog(@"%@", [NSString stringWithFormat:@"剩余票数：%d 窗口：%@", self.ticketSurplusCount, [NSThread currentThread]]);
            [NSThread sleepForTimeInterval:0.2];
        }else{
            NSLog(@"所有火车票均已售完");
            break;
        }
    }
}

//加锁
- (void)saleTicketSafe
{
    while (1) {
        
        dispatch_semaphore_wait(semaphoreLock, DISPATCH_TIME_FOREVER);
        
        if (self.ticketSurplusCount > 0) {
            self.ticketSurplusCount--;
            NSLog(@"%@", [NSString stringWithFormat:@"剩余票数：%d 窗口：%@", self.ticketSurplusCount, [NSThread currentThread]]);
            [NSThread sleepForTimeInterval:0.2];
        }else{
            NSLog(@"所有火车票均已售完");
            break;
        }
        
        dispatch_semaphore_signal(semaphoreLock);
    }
}

@end
