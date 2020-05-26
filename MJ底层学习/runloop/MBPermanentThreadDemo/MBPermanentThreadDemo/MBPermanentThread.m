//
//  MBPermanentThread.m
//  MBPermanentThreadDemo
//
//  Created by GoSun on 2020/5/26.
//  Copyright © 2020 GoSun. All rights reserved.
//

#import "MBPermanentThread.h"

@interface MBPermanentThread()

@property(nonatomic ,strong)NSThread *innerThread;
@property(nonatomic ,assign, getter=isStopped)BOOL stopped;

@end

@implementation MBPermanentThread


- (instancetype)init
{
    if (self = [super init]) {
        
        self.stopped = NO;
        
        __weak typeof(self)weakSelf = self;
        self.innerThread = [[NSThread alloc]initWithBlock:^{
            
            [[NSRunLoop currentRunLoop]addPort:[[NSPort alloc]init] forMode:NSDefaultRunLoopMode];
            
            while (weakSelf && !weakSelf.stopped) {
                [[NSRunLoop currentRunLoop]runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
            }
        }];
    }
    return self;
}


- (void)run
{
    if (!self.innerThread) {
        return;
    }
    
    [self.innerThread start];
}


- (void)excuteTaskBlock:(MBPermanentThreadTask)task;
{
    if (!self.innerThread || !task) {
        return;
    }
    
    [self performSelector:@selector(__excuteTaskBlock:) onThread:self.innerThread withObject:task waitUntilDone:NO];
}


- (void)stop
{
    if (!self.innerThread) {
        return;
    }
    
    [self performSelector:@selector(__stop) onThread:self.innerThread withObject:nil waitUntilDone:YES];
}

#pragma mark - private method

- (void)__excuteTaskBlock:(MBPermanentThreadTask)task
{
    task();
}

- (void)__stop
{
    self.stopped = YES;
    CFRunLoopStop(CFRunLoopGetCurrent());
    self.innerThread = nil;
}

- (void)dealloc
{
    NSLog(@"%s ",__func__);
}

@end
