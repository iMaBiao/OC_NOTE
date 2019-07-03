//
//  UserCenter.m
//  ThreadDemo
//
//  Created by teilt on 2019/1/14.
//  Copyright © 2019 teilt. All rights reserved.
//

#import "UserCenter.h"

@interface UserCenter()
{
    //   定义一个并发队列
    dispatch_queue_t concurrent_queue;
    
    //    用户数据中心，可能多个线程需要访问数据
    NSMutableDictionary *userCenterDic;
}
@end


@implementation UserCenter

- (instancetype)init
{
    self = [super init];
    if (self) {
        //        创建一个并发队列
        concurrent_queue = dispatch_queue_create("read_write_queue", DISPATCH_QUEUE_CONCURRENT);
        //        创建数据容器
        userCenterDic = [NSMutableDictionary dictionary];
    }
    return self;
}

// 读操作
- (id)objectForKey:(NSString *)key
{
    __block id obj;
    //    同步读取指定数据
    dispatch_sync(concurrent_queue, ^{
        obj = [userCenterDic objectForKey:key];
    });
    return obj;
}

//写操作
- (void)setObject:(id)obj forKey:(NSString *)key
{
    //    异步栅栏调用设置数据
    dispatch_barrier_async(concurrent_queue, ^{
        [userCenterDic setObject:obj forKey:key];
    });
}

@end
