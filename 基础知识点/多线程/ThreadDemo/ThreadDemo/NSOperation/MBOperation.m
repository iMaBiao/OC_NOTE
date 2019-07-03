//
//  MBOperation.m
//  ThreadDemo
//
//  Created by teilt on 2019/1/15.
//  Copyright © 2019 teilt. All rights reserved.
//

#import "MBOperation.h"

@implementation MBOperation

- (void)main
{
    if (!self.isCancelled) {
        for (int i = 0; i < 2; i++) {
            [NSThread sleepForTimeInterval:2];
            NSLog(@"1---%@", [NSThread currentThread]);
        }
    }
}

@end
