//
//  OtherUsageController.m
//  ThreadDemo
//
//  Created by teilt on 2019/1/14.
//  Copyright © 2019 teilt. All rights reserved.
//

#import "OtherUsageController.h"

@interface OtherUsageController ()

@end

@implementation OtherUsageController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    
    //   栅栏函数
//        [self barrier];
    
    //延迟函数
    //    [self after];
    
    //    执行一次的函数
    //    [self once];
    
    //    遍历函数
    //    [self apply];
    
    //队列组
    //监听
    //    [self groupNotify];
    //等待
    //    [self groupWait];
    
    //    [self groupEnterAndLeave];
    
    //    线程同步
    //    [self semaphoreSync];
    
    
    [self multipleRequest];
}

//测试dispatch_group_enter dispatch_group_leave
- (void)multipleRequest
{
    dispatch_group_t group =  dispatch_group_create();
//    dispatch_queue_t queue = dispatch_queue_create("haha", DISPATCH_QUEUE_CONCURRENT);
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_group_enter(group);
    dispatch_async(queue, ^{
        NSLog(@"%s 音频开始 ",__func__);
        dispatch_async(queue, ^{
            dispatch_group_leave(group);
            sleep(1.0);
            NSLog(@"%s 音频成功 ",__func__);
        });
    });

    dispatch_group_enter(group);
    dispatch_async( queue, ^{
        NSLog(@"%s 图片开始 ",__func__);
        dispatch_async(queue, ^{
            dispatch_group_leave(group);
            sleep(1.0);
            NSLog(@"%s 图片成功 ",__func__);
        });
    });
    
    dispatch_group_enter(group);
    dispatch_async(queue, ^{
        NSLog(@"%s 视频开始 ",__func__);
        dispatch_async(queue, ^{
            dispatch_group_leave(group);
            sleep(1.0);
            NSLog(@"%s 视频开始 ",__func__);
        });
    });
    
    dispatch_group_notify(group, queue, ^{
        NSLog(@"%s 开始汇总",__func__);
        dispatch_async(queue, ^{
            NSLog(@"%s 汇总成功",__func__);
        });
    });

    NSLog(@"%s end",__func__);
}

//测试dispatch_group_notify
- (void)multipleRequest4
{
    dispatch_group_t group =  dispatch_group_create();
    dispatch_queue_t queue = dispatch_queue_create("haha", DISPATCH_QUEUE_CONCURRENT);
    dispatch_group_async(group, queue, ^{
        NSLog(@"%s 音频开始 ",__func__);
        dispatch_async(queue, ^{
            sleep(1.0);
            NSLog(@"%s 音频成功 ",__func__);
        });
    });

    
    dispatch_group_async(group, queue, ^{
        NSLog(@"%s 图片开始 ",__func__);
        dispatch_async(queue, ^{
            sleep(1.0);
            NSLog(@"%s 图片成功 ",__func__);
        });
    });
    
    dispatch_group_async(group, queue, ^{
        NSLog(@"%s 视频开始 ",__func__);
        dispatch_async(queue, ^{
            sleep(1.0);
            NSLog(@"%s 视频开始 ",__func__);
        });
    });
    
    dispatch_group_notify(group, queue, ^{
        NSLog(@"%s 开始汇总",__func__);
        dispatch_async(queue, ^{
            NSLog(@"%s 汇总成功",__func__);
        });
    });

    NSLog(@"%s end",__func__);
}

//测试dispatch_group_wait
- (void)multipleRequest3
{
    dispatch_group_t group =  dispatch_group_create();
    dispatch_queue_t queue = dispatch_queue_create("haha", DISPATCH_QUEUE_CONCURRENT);
    dispatch_group_async(group, queue, ^{
        NSLog(@"%s 音频开始 ",__func__);
        dispatch_async(queue, ^{
            sleep(1.0);
            NSLog(@"%s 音频成功 ",__func__);
        });
    });

    
    dispatch_group_async(group, queue, ^{
        NSLog(@"%s 图片开始 ",__func__);
        dispatch_async(queue, ^{
            sleep(1.0);
            NSLog(@"%s 图片成功 ",__func__);
        });
    });
    
    dispatch_group_async(group, queue, ^{
        NSLog(@"%s 视频开始 ",__func__);
        dispatch_async(queue, ^{
            sleep(1.0);
            NSLog(@"%s 视频开始 ",__func__);
        });
    });
    
    // 等待上面的任务全部完成后，会往下继续执行（会阻塞当前线程）
    dispatch_group_wait(group, DISPATCH_TIME_FOREVER);
    
    NSLog(@"%s 开始汇总",__func__);
    dispatch_async(queue, ^{
        NSLog(@"%s 汇总成功",__func__);
    });
    NSLog(@"%s end",__func__);
}
//测试信号量
- (void)multipleRequest2
{
    dispatch_queue_t queue = dispatch_queue_create("haha", DISPATCH_QUEUE_CONCURRENT);
    
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(1);
    
    dispatch_async(queue, ^{
        NSLog(@"%s 音频开始 ",__func__);
        dispatch_async(queue, ^{
            dispatch_semaphore_signal(semaphore);
            sleep(1.0);
            NSLog(@"%s 音频成功 ",__func__);
        });
    });
    
    dispatch_async(queue, ^{
        NSLog(@"%s 图片开始 ",__func__);
        dispatch_async(queue, ^{
            dispatch_semaphore_signal(semaphore);
            sleep(1.0);
            NSLog(@"%s 图片成功 ",__func__);
        });
    });
    
    dispatch_async(queue, ^{
        NSLog(@"%s 视频开始 ",__func__);
        dispatch_async(queue, ^{
            dispatch_semaphore_signal(semaphore);
            sleep(1.0);
            NSLog(@"%s 视频开始 ",__func__);
        });
    });
    
    dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
    
    dispatch_barrier_async(queue, ^{
        NSLog(@"%s 开始汇总",__func__);
    });
    dispatch_async(queue, ^{
        NSLog(@"%s 汇总成功",__func__);
    });
    NSLog(@"%s end",__func__);
}
//测试栅栏函数
- (void)multipleRequest1
{
    dispatch_queue_t queue = dispatch_queue_create("haha", DISPATCH_QUEUE_CONCURRENT);
    
    dispatch_async(queue, ^{
        NSLog(@"%s 音频开始 ",__func__);
        dispatch_async(queue, ^{
            sleep(1.0);
            NSLog(@"%s 音频成功 ",__func__);
        });
    });
    
    dispatch_async(queue, ^{
        NSLog(@"%s 图片开始 ",__func__);
        dispatch_async(queue, ^{
            sleep(1.0);
            NSLog(@"%s 图片成功 ",__func__);
        });
    });
    
    dispatch_async(queue, ^{
        NSLog(@"%s 视频开始 ",__func__);
        dispatch_async(queue, ^{
            sleep(1.0);
            NSLog(@"%s 视频开始 ",__func__);
        });
    });
    
    dispatch_barrier_async(queue, ^{
        NSLog(@"%s 开始汇总",__func__);
    });
    dispatch_async(queue, ^{
        NSLog(@"%s 汇总成功",__func__);
    });
    
}

#pragma mark - method
//    线程同步
- (void)semaphoreSync
{
    NSLog(@"currentThread---%@",[NSThread currentThread]);  // 打印当前线程
    NSLog(@"semaphore---begin");
    
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    
    __block int number = 0;
    dispatch_async(queue, ^{//开启一个异步线程
        [NSThread sleepForTimeInterval:2];              // 模拟耗时操作
        NSLog(@"1---%@",[NSThread currentThread]);      // 打印当前线程
        
        number = 100;
        
        dispatch_semaphore_signal(semaphore);
    });
    
    dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
    
    NSLog(@"semaphore---end,number = %zd",number);
}


- (void)groupEnterAndLeave
{
    NSLog(@"currentThread---%@",[NSThread currentThread]);  // 打印当前线程
    NSLog(@"group---begin");
    
    dispatch_group_t group = dispatch_group_create();
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    
    dispatch_group_enter(group);
    dispatch_async(queue, ^{
        for (int i = 0; i < 2; ++i) {
            [NSThread sleepForTimeInterval:2];  // 模拟耗时操作
            NSLog(@" 1 --- %@",[NSThread currentThread]);
        }
        dispatch_group_leave(group);
    });
    
    dispatch_group_enter(group);
    dispatch_async(queue, ^{
        for (int i = 0; i < 2; ++i) {
            [NSThread sleepForTimeInterval:2];  // 模拟耗时操作
            NSLog(@" 2 --- %@",[NSThread currentThread]);
        }
        dispatch_group_leave(group);
    });
    
    dispatch_group_notify(group, dispatch_get_main_queue(), ^{
        // 等前面的异步操作都执行完毕后，回到主线程.
        for (int i = 0; i < 2; ++i) {
            [NSThread sleepForTimeInterval:2];  // 模拟耗时操作
            NSLog(@" 3 --- %@",[NSThread currentThread]);
        }
        NSLog(@"group---end");
    });
}
- (void)groupWait
{
    NSLog(@"currentThread---%@",[NSThread currentThread]);  // 打印当前线程
    NSLog(@"group---begin");
    
    dispatch_group_t group = dispatch_group_create();
    
    dispatch_group_async(group, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        for (int i = 0; i < 2; ++i) {
            [NSThread sleepForTimeInterval:2];  // 模拟耗时操作
            NSLog(@" 1 --- %@",[NSThread currentThread]);
        }
    });
    
    dispatch_group_async(group, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        for (int i = 0; i < 2; ++i) {
            [NSThread sleepForTimeInterval:2];  // 模拟耗时操作
            NSLog(@" 2 --- %@",[NSThread currentThread]);
        }
    });
    
    // 等待上面的任务全部完成后，会往下继续执行（会阻塞当前线程）
    dispatch_group_wait(group, DISPATCH_TIME_FOREVER);
    NSLog(@"group---end");
}

//监听其他执行完
- (void)groupNotify
{
    NSLog(@"currentThread---%@",[NSThread currentThread]);  // 打印当前线程
    NSLog(@"group---begin");
    
    //创建一个队列组
    dispatch_group_t group = dispatch_group_create();
    
    //往队列组中添加任务1
    dispatch_group_async(group, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        for (int i = 0; i < 2; ++i) {
            [NSThread sleepForTimeInterval:2];  // 模拟耗时操作
            NSLog(@" 1 --- %@",[NSThread currentThread]);
        }
    });
    
    //往队列组中添加任务2
    dispatch_group_async(group, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        for (int i = 0; i < 2; ++i) {
            [NSThread sleepForTimeInterval:2];  // 模拟耗时操作
            NSLog(@" 2 --- %@",[NSThread currentThread]);
        }
    });
    
    // 等前面的异步任务1、任务2都执行完毕后，回到主线程执行下边任务
    dispatch_group_notify(group, dispatch_get_main_queue(), ^{
        for (int i = 0; i < 2; ++i) {
            [NSThread sleepForTimeInterval:2];  // 模拟耗时操作
            NSLog(@" 3 --- %@",[NSThread currentThread]);
        }
        NSLog(@"group---end");
    });
}

//    遍历函数
- (void)apply
{
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    
    NSLog(@"apply---begin");
    dispatch_apply(6, queue, ^(size_t index) {
        NSLog(@"%zd---%@",index, [NSThread currentThread]);
        
    });
    NSLog(@"apply---end");
}

//执行一次的函数
- (void)once
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        // 只执行1次的代码(这里面默认是线程安全的)
    });
}

//延迟函数
- (void)after
{
    NSLog(@"currentThread---%@",[NSThread currentThread]);  // 打印当前线程
    NSLog(@"asyncMain---begin");
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        // 2.0秒后异步追加任务代码到主队列，并开始执行
        NSLog(@"after---%@",[NSThread currentThread]);  // 打印当前线程
    });
}

//   栅栏函数
- (void)barrier
{
    //创建一个并发队列
    dispatch_queue_t queue = dispatch_queue_create("com.ibiaoma.gcdDemo", DISPATCH_QUEUE_CONCURRENT);
    
//    dispatch_queue_t queue = dispatch_get_global_queue(0, 0);
    
    //任务1
    dispatch_async(queue, ^{
        for (int i = 0; i < 2; ++i) {
            [NSThread sleepForTimeInterval:2];  // 模拟耗时操作
            NSLog(@" 1 --- %@",[NSThread currentThread]);
        }
    });
    //任务2
    dispatch_async(queue, ^{
        for (int i = 0; i < 2; ++i) {
            [NSThread sleepForTimeInterval:2];  // 模拟耗时操作
            NSLog(@" 2 --- %@",[NSThread currentThread]);
        }
    });
    
    //添加栅栏
    dispatch_barrier_async(queue, ^{
        for (int i = 0; i < 2; ++i) {
            [NSThread sleepForTimeInterval:2];  // 模拟耗时操作
            NSLog(@" barrier --- %@",[NSThread currentThread]);
        }
    });
    
    //任务3
    dispatch_async(queue, ^{
        for (int i = 0; i < 2; ++i) {
            [NSThread sleepForTimeInterval:2];  // 模拟耗时操作
            NSLog(@" 3 --- %@",[NSThread currentThread]);
        }
    });
    //任务4
    dispatch_async(queue, ^{
        for (int i = 0; i < 2; ++i) {
            [NSThread sleepForTimeInterval:2];  // 模拟耗时操作
            NSLog(@" 4 --- %@",[NSThread currentThread]);
        }
    });
    
}

@end
