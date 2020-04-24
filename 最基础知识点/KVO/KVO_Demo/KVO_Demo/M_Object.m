//
//  M_Object.m
//  KVO_Demo
//
//  Created by teilt on 2019/1/3.
//  Copyright © 2019 teilt. All rights reserved.
//

#import "M_Object.h"

@implementation M_Object

- (instancetype)init
{
    if (self = [super init]) {
        _count = 0;
    }
    return self;
}

- (void)increaseCount
{
    //加上这两句，就是会触发KVO
//    [self willChangeValueForKey:@"count"];
    _count += 1;
//    [self didChangeValueForKey:@"count"];
}

@end
