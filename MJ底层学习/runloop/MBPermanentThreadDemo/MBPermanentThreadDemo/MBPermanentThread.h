//
//  MBPermanentThread.h
//  MBPermanentThreadDemo
//
//  Created by GoSun on 2020/5/26.
//  Copyright © 2020 GoSun. All rights reserved.
//  持久线程

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef void (^MBPermanentThreadTask)(void);

@interface MBPermanentThread : NSObject

///开启线程
- (void)run;

///在当前线程执行一个任务
- (void)excuteTaskBlock:(MBPermanentThreadTask)task;

///结束线程
- (void)stop;

@end

NS_ASSUME_NONNULL_END
