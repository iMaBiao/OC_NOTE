//
//  ViewController.m
//  gcdDemo
//
//  Created by teilt on 2019/1/10.
//  Copyright © 2019 teilt. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    
//    同步 、 并发
//    [self syncConcurrent];
    
//    异步 、并发
//    [self asyncConcurrent];
    
//    同步、 串行
//    [self syncSerial];
    
//    异步、串行
//    [self asyncSerial];
    
//    同步、主队列（死锁）
//    [self syncMain];
    
//    异步、主队列
//    [self asyncMain];
    

    //  其他线程中调用同步执行 + 主队列
    // 使用 NSThread 的 detachNewThreadSelector 方法会创建线程，并自动启动线程执行selector 任务
//    [NSThread detachNewThreadSelector:@selector(syncMain) toTarget:self withObject:nil];

}


#pragma mark - method
//    异步、主队列
- (void)asyncMain
{
    NSLog(@"currentThread---%@",[NSThread currentThread]);  // 打印当前线程
    NSLog(@"asyncConcurrent---begin");
    //获取主队列
    dispatch_queue_t queue = dispatch_get_main_queue();
    //创建异步线程1
    dispatch_async(queue, ^{
        for (int i = 0; i < 2; ++i) {
            [NSThread sleepForTimeInterval:2];  // 模拟耗时操作
            NSLog(@"1 --- %@", [NSThread currentThread]);
        }
    });
    //创建异步线程2
    dispatch_async(queue, ^{
        for (int i = 0; i < 2; ++i) {
            [NSThread sleepForTimeInterval:2];  // 模拟耗时操作
            NSLog(@"2 --- %@", [NSThread currentThread]);
        }
    });
    //创建异步线程3
    dispatch_async(queue, ^{
        for (int i = 0; i < 2; ++i) {
            [NSThread sleepForTimeInterval:2];  // 模拟耗时操作
            NSLog(@"3 --- %@", [NSThread currentThread]);
        }
    });
    NSLog(@"syncConcurrent---end");
}
//    同步、主队列（死锁）
- (void)syncMain
{
    NSLog(@"currentThread---%@",[NSThread currentThread]);  // 打印当前线程
    NSLog(@"asyncConcurrent---begin");
    
    //获取主队列
    dispatch_queue_t queue = dispatch_get_main_queue();
    //创建同步线程1
    dispatch_sync(queue, ^{
        for (int i = 0; i < 2; ++i) {
            [NSThread sleepForTimeInterval:2];  // 模拟耗时操作
            NSLog(@"1 --- %@", [NSThread currentThread]);
        }
    });
    //创建同步线程2
    dispatch_sync(queue, ^{
        for (int i = 0; i < 2; ++i) {
            [NSThread sleepForTimeInterval:2];  // 模拟耗时操作
            NSLog(@"2 --- %@", [NSThread currentThread]);
        }
    });
    //创建同步线程3
    dispatch_sync(queue, ^{
        for (int i = 0; i < 2; ++i) {
            [NSThread sleepForTimeInterval:2];  // 模拟耗时操作
            NSLog(@"3 --- %@", [NSThread currentThread]);
        }
    });
    NSLog(@"syncConcurrent---end");
}

//    异步、串行
- (void)asyncSerial
{
    NSLog(@"currentThread---%@",[NSThread currentThread]);  // 打印当前线程
    NSLog(@"asyncConcurrent---begin");
    
    //创建一个串行队列
    dispatch_queue_t queue = dispatch_queue_create("com.ibiaoma.gcdDemo", DISPATCH_QUEUE_SERIAL);
    
    //创建一个异步线程1
    dispatch_async(queue, ^{
        for (int i = 0; i < 2; ++i) {
            [NSThread sleepForTimeInterval:2];  // 模拟耗时操作
            NSLog(@"1 --- %@", [NSThread currentThread]);
        }
    });
    //创建一个异步线程2
    dispatch_async(queue, ^{
        for (int i = 0; i < 2; ++i) {
            [NSThread sleepForTimeInterval:2];  // 模拟耗时操作
            NSLog(@"2 --- %@", [NSThread currentThread]);
        }
    });
    //创建一个异步线程3
    dispatch_async(queue, ^{
        for (int i = 0; i < 2; ++i) {
            [NSThread sleepForTimeInterval:2];  // 模拟耗时操作
            NSLog(@"3 --- %@", [NSThread currentThread]);
        }
    });
    NSLog(@"syncConcurrent---end");
}

//    同步、 串行
- (void)syncSerial
{
    NSLog(@"currentThread---%@",[NSThread currentThread]);  // 打印当前线程
    NSLog(@"asyncConcurrent---begin");
    
    //创建一个串行队列
    dispatch_queue_t queue = dispatch_queue_create("com.ibiaoma.gcdDemo", DISPATCH_QUEUE_SERIAL);
    
    //创建同步线程1
    dispatch_sync(queue, ^{
        for (int i = 0; i < 2; ++i) {
            [NSThread sleepForTimeInterval:2];  // 模拟耗时操作
            NSLog(@"1 --- %@", [NSThread currentThread]);
        }
    });
    //创建同步线程2
    dispatch_sync(queue, ^{
        for (int i = 0; i < 2; ++i) {
            [NSThread sleepForTimeInterval:2];  // 模拟耗时操作
            NSLog(@"2 --- %@", [NSThread currentThread]);
        }
    });
    //创建同步线程3
    dispatch_sync(queue, ^{
        for (int i = 0; i < 2; ++i) {
            [NSThread sleepForTimeInterval:2];  // 模拟耗时操作
            NSLog(@"3 --- %@", [NSThread currentThread]);
        }
    });
    NSLog(@"syncConcurrent---end");
}

//    异步 、并发
- (void)asyncConcurrent
{
    NSLog(@"currentThread---%@",[NSThread currentThread]);  // 打印当前线程
    NSLog(@"asyncConcurrent---begin");
    
    //    创建一个并发队列
    dispatch_queue_t queue = dispatch_queue_create("com.ibiaoma.gcdDemo", DISPATCH_QUEUE_SERIAL);
    
    // 创建异步线程1
    dispatch_async(queue, ^{
        for (int i = 0; i < 2; ++i) {
            [NSThread sleepForTimeInterval:2];  // 模拟耗时操作
            NSLog(@"1 --- %@", [NSThread currentThread]);
        }
    });
    
    // 创建异步线程2
    dispatch_async(queue, ^{
        for (int i = 0; i < 2; ++i) {
            [NSThread sleepForTimeInterval:2];  // 模拟耗时操作
            NSLog(@" 2 --- %@",[NSThread currentThread]);
        }
    });
    
    // 创建异步线程3
    dispatch_async(queue, ^{
        for (int i = 0; i < 2; ++i) {
            [NSThread sleepForTimeInterval:2];  // 模拟耗时操作
            NSLog(@" 3 --- %@",[NSThread currentThread]);
        }
    });
    
    NSLog(@"syncConcurrent---end");
}

//    同步 、并发
- (void)syncConcurrent
{
    NSLog(@"currentThread---%@",[NSThread currentThread]);  // 打印当前线程
    NSLog(@"syncConcurrent---begin");
    
    
    //    创建一个并发队列
    dispatch_queue_t queue = dispatch_queue_create("com.ibiaoma.gcdDemo", DISPATCH_QUEUE_CONCURRENT);
    
    //创建同步线程1
    dispatch_sync(queue, ^{
        for (int i = 0; i < 2; ++i) {
            [NSThread sleepForTimeInterval:2];  // 模拟耗时操作
            NSLog(@" 1 --- %@",[NSThread currentThread]);
        }
    });
    
    //创建同步线程2
    dispatch_sync(queue, ^{
        for (int i = 0; i < 2; ++i) {
            [NSThread sleepForTimeInterval:2];  // 模拟耗时操作
            NSLog(@" 2 --- %@",[NSThread currentThread]);
        }
    });
    
    //创建同步线程3
    dispatch_sync(queue, ^{
        for (int i = 0; i < 2; ++i) {
            [NSThread sleepForTimeInterval:2];  // 模拟耗时操作
            NSLog(@" 3 --- %@",[NSThread currentThread]);
        }
    });
  
    NSLog(@"syncConcurrent---end");
}



@end
