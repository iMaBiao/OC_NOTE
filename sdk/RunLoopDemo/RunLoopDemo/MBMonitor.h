//
//  MBMonitor.h
//  RunLoopDemo
//
//  Created by GoSun on 2021/2/19.
//  Copyright © 2021 ibiaoma. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface MBMonitor : NSObject

+ (instancetype)shareInstance;

- (void)beginMonitor; //开始监视卡顿
- (void)endMonitor;   //停止监视卡顿

@end

NS_ASSUME_NONNULL_END
