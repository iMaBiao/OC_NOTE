//
//  MultipleRequestController.m
//  ThreadDemo
//
//  Created by GoSun on 2021/2/23.
//  Copyright © 2021 teilt. All rights reserved.
//

#import "MultipleRequestController.h"

@interface MultipleRequestController ()

@end

@implementation MultipleRequestController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    //测试栅栏函数
//    [self test_dispatch_barrier_async];
    
    //测试信号量
//    [self test_dispatch_semaphore];       //成功
    
//    [self test_dispatch_group_wait];
    
//    [self test_dispatch_group_notify];
    
//    [self test_dispatch_group_enter];       //成功
    
//    [self test_operationQueue];
    
//    [self test_blockOperation];         //成功
    
}


- (void)test_blockOperation
{
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    queue.maxConcurrentOperationCount = 3; // 并发队列
    
    NSBlockOperation *op1 = [NSBlockOperation blockOperationWithBlock:^{
        dispatch_semaphore_t sema = dispatch_semaphore_create(0);
        [self httpRequestTest:@"音频请求" wihtBlock:^(NSString *name) {
            dispatch_semaphore_signal(sema);
        }];
        dispatch_semaphore_wait(sema, DISPATCH_TIME_FOREVER);
    }];
    
    NSBlockOperation *op2 = [NSBlockOperation blockOperationWithBlock:^{
        dispatch_semaphore_t sema = dispatch_semaphore_create(0);
        [self httpRequestTest:@"图片请求" wihtBlock:^(NSString *name) {
            dispatch_semaphore_signal(sema);
        }];
        dispatch_semaphore_wait(sema, DISPATCH_TIME_FOREVER);
    }];
    
    NSBlockOperation *op3 = [NSBlockOperation blockOperationWithBlock:^{
        dispatch_semaphore_t sema = dispatch_semaphore_create(0);
        [self httpRequestTest:@"视频请求" wihtBlock:^(NSString *name) {
            dispatch_semaphore_signal(sema);
        }];
        dispatch_semaphore_wait(sema, DISPATCH_TIME_FOREVER);
    }];
    
    NSBlockOperation *op4 = [NSBlockOperation blockOperationWithBlock:^{
        NSLog(@"%s 开始汇总",__func__);
        dispatch_async(dispatch_get_main_queue(), ^{
            NSLog(@"%s 汇总成功",__func__);
        });
    }];
    
    //添加依赖
    // 3.添加依赖
    [op4 addDependency:op1];
    [op4 addDependency:op2];
    [op4 addDependency:op3];
    
    // 4.添加操作到队列中
    [queue addOperation:op1];
    [queue addOperation:op2];
    [queue addOperation:op3];
    [queue addOperation:op4];
    

    /**
     请求开始 name = 音频请求 currentThread = <NSThread: 0x283ac6d00>{number = 3, name = (null)}
     请求开始 name = 图片请求 currentThread = <NSThread: 0x283ac3080>{number = 6, name = (null)}
     请求开始 name = 视频请求 currentThread = <NSThread: 0x283ac3ac0>{number = 7, name = (null)}
     _block_invoke 请求结束 name = 音频请求 currentThread = <NSThread: 0x283ad6ac0>{number = 9, name = (null)}
     _block_invoke 请求结束 name = 视频请求 currentThread = <NSThread: 0x283ad6ac0>{number = 9, name = (null)}
     _block_invoke 请求结束 name = 图片请求 currentThread = <NSThread: 0x283ad6ac0>{number = 9, name = (null)}
     _block_invoke_5 开始汇总
     _block_invoke_6 汇总成功
     
     */
    
}

- (void)test_operationQueue
{
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    queue.maxConcurrentOperationCount = 3; // 并发队列
    
    // 3.添加操作
    [queue addOperationWithBlock:^{
        [self httpRequestTest:@"音频请求" wihtBlock:^(NSString *name) {
        
        }];
    }];
    [queue addOperationWithBlock:^{
        [self httpRequestTest:@"图片请求" wihtBlock:^(NSString *name) {
            
        }];
    }];
    [queue addOperationWithBlock:^{
        [self httpRequestTest:@"视频请求" wihtBlock:^(NSString *name) {
        }];
    }];

    NSLog(@"%s 开始汇总",__func__);
    [queue addOperationWithBlock:^{
        dispatch_async(dispatch_get_main_queue(), ^{
            NSLog(@"%s 汇总成功",__func__);
        });
    }];

    
    /**
     
     开始汇总
     请求开始 name = 音频请求 currentThread = <NSThread: 0x2822e93c0>{number = 5, name = (null)}
     请求开始 name = 图片请求 currentThread = <NSThread: 0x28229f600>{number = 6, name = (null)}
     请求开始 name = 视频请求 currentThread = <NSThread: 0x2822e0cc0>{number = 7, name = (null)}
     _block_invoke_5 汇总成功
     _block_invoke 请求结束 name = 图片请求 currentThread = <NSThread: 0x28228ad40>{number = 8, name = (null)}
     _block_invoke 请求结束 name = 视频请求 currentThread = <NSThread: 0x28228ad40>{number = 8, name = (null)}
     _block_invoke 请求结束 name = 音频请求 currentThread = <NSThread: 0x2822e93c0>{number = 5, name = (null)}
     
     */
}

//测试dispatch_group_enter dispatch_group_leave
- (void)test_dispatch_group_enter
{
    dispatch_group_t group =  dispatch_group_create();
    dispatch_queue_t queue = dispatch_queue_create("haha", DISPATCH_QUEUE_CONCURRENT);
//    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_group_enter(group);
    dispatch_async(queue, ^{
        [self httpRequestTest:@"音频请求" wihtBlock:^(NSString *name) {
            dispatch_group_leave(group);
        }];
    });

    dispatch_group_enter(group);
    dispatch_async( queue, ^{
        [self httpRequestTest:@"图片请求" wihtBlock:^(NSString *name) {
            dispatch_group_leave(group);
        }];
    });
    
    dispatch_group_enter(group);
    dispatch_async(queue, ^{
        [self httpRequestTest:@"视频请求" wihtBlock:^(NSString *name) {
            dispatch_group_leave(group);
        }];
    });
    
    dispatch_group_notify(group, queue, ^{
        NSLog(@"%s 开始汇总",__func__);
        dispatch_async(queue, ^{
            NSLog(@"%s 汇总成功",__func__);
        });
    });

    NSLog(@"%s end",__func__);
    
    /**
     
     请求开始 name = 音频请求 currentThread = <NSThread: 0x281ad6780>{number = 4, name = (null)}
     请求开始 name = 图片请求 currentThread = <NSThread: 0x281ad5b80>{number = 5, name = (null)}
     end
     请求开始 name = 视频请求 currentThread = <NSThread: 0x281ada140>{number = 6, name = (null)}
     _block_invoke 请求结束 name = 音频请求 currentThread = <NSThread: 0x281ad5b80>{number = 5, name = (null)}
     _block_invoke 请求结束 name = 图片请求 currentThread = <NSThread: 0x281ac9280>{number = 8, name = (null)}
     _block_invoke 请求结束 name = 视频请求 currentThread = <NSThread: 0x281ad7a80>{number = 3, name = (null)}
     _block_invoke_5 开始汇总
     _block_invoke_6 汇总成功
     
     */
}

//测试dispatch_group_notify
- (void)test_dispatch_group_notify
{
    dispatch_group_t group =  dispatch_group_create();
    dispatch_queue_t queue = dispatch_queue_create("haha", DISPATCH_QUEUE_CONCURRENT);
    dispatch_group_async(group, queue, ^{
        [self httpRequestTest:@"音频请求" wihtBlock:^(NSString *name) {
            
        }];
    });

    dispatch_group_async(group, queue, ^{
        [self httpRequestTest:@"图片请求" wihtBlock:^(NSString *name) {
            
        }];
    });
    
    dispatch_group_async(group, queue, ^{
        [self httpRequestTest:@"视频请求" wihtBlock:^(NSString *name) {
            
        }];
    });
    
    dispatch_group_notify(group, queue, ^{
        NSLog(@"%s 开始汇总",__func__);
        dispatch_async(queue, ^{
            NSLog(@"%s 汇总成功",__func__);
        });
    });

    NSLog(@"%s end",__func__);
    /**
     
     end
     请求开始 name = 音频请求 currentThread = <NSThread: 0x281575080>{number = 4, name = (null)}
     请求开始 name = 图片请求 currentThread = <NSThread: 0x28157e5c0>{number = 6, name = (null)}
     请求开始 name = 视频请求 currentThread = <NSThread: 0x28157e9c0>{number = 7, name = (null)}
    _block_invoke_7 开始汇总
    _block_invoke_8 汇总成功
    _block_invoke 请求结束 name = 音频请求 currentThread = <NSThread: 0x28150f640>{number = 5, name = (null)}
    _block_invoke 请求结束 name = 图片请求 currentThread = <NSThread: 0x28150f640>{number = 5, name = (null)}
    _block_invoke 请求结束 name = 视频请求 currentThread = <NSThread: 0x28150f640>{number = 5, name = (null)}
     */
}

//测试dispatch_group_wait
- (void)test_dispatch_group_wait
{
    dispatch_group_t group =  dispatch_group_create();
    dispatch_queue_t queue = dispatch_queue_create("haha", DISPATCH_QUEUE_CONCURRENT);
    dispatch_group_async(group, queue, ^{
        [self httpRequestTest:@"音频请求" wihtBlock:^(NSString *name) {
            
        }];
    });
    
    dispatch_group_async(group, queue, ^{
        [self httpRequestTest:@"图片请求" wihtBlock:^(NSString *name) {
            
        }];
    });
    
    dispatch_group_async(group, queue, ^{
        [self httpRequestTest:@"视频请求" wihtBlock:^(NSString *name) {
            
        }];
    });
    
    // 等待上面的任务全部完成后，会往下继续执行（会阻塞当前线程）
    dispatch_group_wait(group, DISPATCH_TIME_FOREVER);
    
    NSLog(@"%s 开始汇总",__func__);
    dispatch_async(queue, ^{
        NSLog(@"%s 汇总成功",__func__);
    });
    NSLog(@"%s end",__func__);
    /**
     
     
     请求开始 name = 音频请求 currentThread = <NSThread: 0x282dac100>{number = 3, name = (null)}
     请求开始 name = 图片请求 currentThread = <NSThread: 0x282dac140>{number = 4, name = (null)}
     请求开始 name = 视频请求 currentThread = <NSThread: 0x282daf6c0>{number = 6, name = (null)}
      开始汇总
      end
     _block_invoke_4 汇总成功
     _block_invoke 请求结束 name = 音频请求 currentThread = <NSThread: 0x282d89b00>{number = 8, name = (null)}
     _block_invoke 请求结束 name = 视频请求 currentThread = <NSThread: 0x282dd6600>{number = 5, name = (null)}
     _block_invoke 请求结束 name = 图片请求 currentThread = <NSThread: 0x282dd6600>{number = 5, name = (null)}
     
     */
}
//测试信号量
- (void)test_dispatch_semaphore
{
    dispatch_queue_t queue = dispatch_queue_create("haha", DISPATCH_QUEUE_CONCURRENT);
    
    dispatch_semaphore_t semaphore1 = dispatch_semaphore_create(0);
    [self httpRequestTest:@"音频请求" wihtBlock:^(NSString *name) {
        dispatch_semaphore_signal(semaphore1);
    }];
    
    dispatch_semaphore_t semaphore2 = dispatch_semaphore_create(0);
    [self httpRequestTest:@"图片请求" wihtBlock:^(NSString *name) {
        dispatch_semaphore_signal(semaphore2);
    }];

    
    dispatch_semaphore_t semaphore3 = dispatch_semaphore_create(0);
    [self httpRequestTest:@"视频请求" wihtBlock:^(NSString *name) {
        dispatch_semaphore_signal(semaphore3);
    }];
    
    dispatch_semaphore_wait(semaphore1, DISPATCH_TIME_FOREVER);
    dispatch_semaphore_wait(semaphore2, DISPATCH_TIME_FOREVER);
    dispatch_semaphore_wait(semaphore3, DISPATCH_TIME_FOREVER);
    dispatch_async(queue, ^{
        NSLog(@"%s 汇总成功",__func__);
    });
    NSLog(@"%s end",__func__);
    
    /**
     
     请求开始 name = 音频请求 currentThread = <NSThread: 0x2800810c0>{number = 1, name = main}
     请求开始 name = 图片请求 currentThread = <NSThread: 0x2800810c0>{number = 1, name = main}
     请求开始 name = 视频请求 currentThread = <NSThread: 0x2800810c0>{number = 1, name = main}
     _block_invoke 请求结束 name = 音频请求 currentThread = <NSThread: 0x2800bff00>{number = 3, name = (null)}
     _block_invoke 请求结束 name = 图片请求 currentThread = <NSThread: 0x2800d7c00>{number = 6, name = (null)}
     _block_invoke 请求结束 name = 视频请求 currentThread = <NSThread: 0x2800d7c00>{number = 6, name = (null)}
      end
     _block_invoke_4 汇总成功
     */
}
//测试栅栏函数
- (void)test_dispatch_barrier_async
{
    dispatch_queue_t queue = dispatch_queue_create("haha", DISPATCH_QUEUE_CONCURRENT);
    
    dispatch_async(queue, ^{
        [self httpRequestTest:@"音频请求" wihtBlock:^(NSString *name) {
            
        }];
    });
    
    dispatch_async(queue, ^{
        [self httpRequestTest:@"图片请求" wihtBlock:^(NSString *name) {
            
        }];
    });
    
    dispatch_async(queue, ^{
        [self httpRequestTest:@"视频请求" wihtBlock:^(NSString *name) {
            
        }];
    });
    
    dispatch_barrier_async(queue, ^{
        NSLog(@"%s 开始汇总",__func__);
    });
    dispatch_async(queue, ^{
        NSLog(@"%s 汇总成功",__func__);
    });
    
    /**
     打印结果：
     请求开始 name = 音频请求 currentThread = <NSThread: 0x281858cc0>{number = 6, name = (null)}
     请求开始 name = 图片请求 currentThread = <NSThread: 0x281852800>{number = 4, name = (null)}
     请求开始 name = 视频请求 currentThread = <NSThread: 0x281852ec0>{number = 3, name = (null)}
     _block_invoke_4 开始汇总
     _block_invoke_5 汇总成功
     _block_invoke 请求结束 name = 音频请求 currentThread = <NSThread: 0x281870c40>{number = 7, name = (null)}
     _block_invoke 请求结束 name = 图片请求 currentThread = <NSThread: 0x281870c40>{number = 7, name = (null)}
     _block_invoke 请求结束 name = 视频请求 currentThread = <NSThread: 0x281858cc0>{number = 6, name = (null)}
     */
}


/// 向网络请求数据
- (void)httpRequestTest:(NSString *)name wihtBlock:(void(^)(NSString *name))block
{
    NSLog(@"%s 请求开始 name = %@ currentThread = %@",__func__,name,[NSThread currentThread]);
    // 1.创建url
    NSString *urlString = @"https://app.gosungs.com/test/dev/independent/game_point/address";

    urlString = [urlString stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    NSURL *url = [NSURL URLWithString:urlString];
    
    // 2.创建请求 并：设置缓存策略为每次都从网络加载 超时时间30秒
    NSURLRequest *request = [NSURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:30];

    // 3.采用苹果提供的共享session
    NSURLSession *sharedSession = [NSURLSession sharedSession];
    
    // 4.由系统直接返回一个dataTask任务
    NSURLSessionDataTask *dataTask = [sharedSession dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        // 网络请求完成之后就会执行，NSURLSession自动实现多线程

        NSLog(@"%s 请求结束 name = %@ currentThread = %@",__func__,name,[NSThread currentThread]);
        if (block) {
            block(name);
        }
        
        if (data && (error == nil)) {
            // 网络访问成功
//            NSLog(@"data=%@",[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
        } else {
            // 网络访问失败
//            NSLog(@"error=%@",error);
        }
    }];
    
    // 5.每一个任务默认都是挂起的，需要调用 resume 方法
    [dataTask resume];
}

@end
