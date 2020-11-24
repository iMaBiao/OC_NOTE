//
//  ViewController.m
//  RunLoopDemo
//
//  Created by GoSun on 2019/12/2.
//  Copyright © 2019 ibiaoma. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    dispatch_queue_t queue = dispatch_get_global_queue(0, 0);
    dispatch_async(queue, ^{
        NSLog(@"1");
        
        [self performSelector:@selector(test) withObject:nil afterDelay:.0];
//
        [[NSRunLoop currentRunLoop]addPort:[[NSPort alloc]init] forMode:NSDefaultRunLoopMode];
//        [[NSRunLoop currentRunLoop]runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
        
        NSLog(@"3");
    });
    
}

- (void)test
{
    NSLog(@"2");
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    NSThread *thread = [[NSThread alloc]initWithBlock:^{
       NSLog(@"1");
    }];
    [thread start];
    [self performSelector:@selector(text) onThread:thread withObject:nil waitUntilDone:YES];
}
@end
