//
//  SortObject.m
//  SortDemo
//
//  Created by GoSun on 2020/4/28.
//  Copyright © 2020 GoSun. All rights reserved.
//

#import "SortObject.h"

@implementation SortObject

///冒泡排序1
- (void)bubbleSort1:(NSMutableArray *)array
{
    for (NSUInteger end = array.count-1; end > 0; end--) {
        for (int begin = 1; begin <= end; begin++) {
            if ([array[begin] intValue] < [array[begin-1] intValue]) {
                int temp = [array[begin] intValue];
                array[begin] = array[begin-1];
                array[begin-1] = @(temp);
            }
        }
    }
    NSLog(@"%s-- %@",__func__,array);
}
///冒泡排序2
- (void)bubbleSort2:(NSMutableArray *)array
{
    for (NSUInteger end = array.count-1; end > 0; end--) {
        BOOL isSorted = YES;
        for (int begin = 1; begin <= end; begin++) {
            if ([array[begin] intValue] < [array[begin-1] intValue]) {
                int temp = [array[begin] intValue];
                array[begin] = array[begin-1];
                array[begin-1] = @(temp);
                //增加标记，如果排好序的，就直接退出循环,减少循环次数
                isSorted = NO;
            }
        }
        if (isSorted) {
            break;
        }
    }
    NSLog(@"%s-- %@",__func__,array);
}


///选择排序
- (void)selectionSort:(NSMutableArray *)array
{
    for (NSUInteger end = array.count-1; end > 0; end--) {
        NSInteger maxIndex = 0;
        for (int begin = 1; begin <= end; begin++) {
            if ([array[maxIndex] intValue] <= [array[begin] intValue]) {
                //循环遍历，找出最大值的索引
                maxIndex = begin;
            }
        }
        //将最大值的索引与最后面位置的元素交换
        int temp = [array[maxIndex] intValue];
        array[maxIndex] = array[end];
        array[end] = @(temp);
    }
    
    NSLog(@"%s-- %@",__func__,array);
}


@end
