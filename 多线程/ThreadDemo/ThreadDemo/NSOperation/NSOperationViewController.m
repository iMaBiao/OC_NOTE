//
//  NSOperationViewController.m
//  ThreadDemo
//
//  Created by teilt on 2019/1/14.
//  Copyright © 2019 teilt. All rights reserved.
//

#import "NSOperationViewController.h"

@interface NSOperationViewController ()

@end

@implementation NSOperationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
//    [self invocationOperation];
    
    [self blockOperation];
}

- (void)blockOperation
{
    NSOperationQueue *operationQueue = [[NSOperationQueue alloc]init];
    operationQueue.maxConcurrentOperationCount = 5;
    
    //第1种：直接使用操队列添加操作
//    [operationQueue addOperationWithBlock:^{
//         [self loadImage];
//    }];
    
    //第2种：创建操作块添加到队列
    NSBlockOperation *blockOperation = [NSBlockOperation blockOperationWithBlock:^{
        [self loadImage];
    }];
    [operationQueue addOperation:blockOperation];
}

- (void)invocationOperation
{
//    创建一个调用操作
    NSInvocationOperation *invocatioinOperation = [[NSInvocationOperation alloc]initWithTarget:self selector:@selector(loadImage) object:nil];
    
    //创建完NSInvocationOperation对象并不会调用，它由一个start方法启动操作，但是注意如果直接调用start方法，则此操作会在主线程中调用，一般不会这么操作,而是添加到NSOperationQueue中
//    [invocatioinOperation start];
    
    //创建操作队列
    NSOperationQueue *operationQueue = [[NSOperationQueue alloc]init];
    //注意添加到操作队后，队列会开启一个线程执行此操作
    [operationQueue addOperation:invocatioinOperation];
}

- (void)loadImage
{
    NSLog(@"currentThread---%@",[NSThread currentThread]);
}
@end
