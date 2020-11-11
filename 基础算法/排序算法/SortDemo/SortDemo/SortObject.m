//
//  SortObject.m
//  SortDemo
//
//  Created by GoSun on 2020/4/28.
//  Copyright © 2020 GoSun. All rights reserved.
//

#import "SortObject.h"

@implementation SortObject

///插入排序
- (void)insertionSort:(NSMutableArray *)array
{
    for (NSUInteger begin = 1; begin < array.count-1; begin++) {
        NSNumber *current = array[begin];
        
        while ([array[begin]intValue] - [array[begin-1]intValue] < 0) {
            NSNumber *temp = array[begin];
            array[begin] = array[begin-1];
            array[begin-1] = temp;
            begin--;
        }
        
    }
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
        NSNumber *temp = array[maxIndex];
        array[maxIndex] = array[end];
        array[end] = temp;
    }
    
    NSLog(@"%s-- %@",__func__,array);
}


///冒泡排序3
- (void)bubbleSort3:(NSMutableArray *)array
{
    //记录大值的索引，大值后面的元素就不需要再遍历了；针对有序的数组效率较高
    for (NSUInteger end = array.count-1; end>0; end--) {
        NSUInteger sortIndex = 1;
        for (int begin = 1; begin<= end; begin++) {
            if ([array[begin]intValue] < [array[begin-1] intValue]) {
                NSNumber *temp = array[begin];
                array[begin] = array[begin-1];
                array[begin-1] = temp;
                sortIndex = begin;
            }
        }
        sortIndex = end;
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
                NSNumber *temp = array[begin];
                array[begin] = array[begin-1];
                array[begin-1] = temp;
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

///冒泡排序1
- (void)bubbleSort1:(NSMutableArray *)array
{
    for (NSUInteger end = array.count-1; end > 0; end--) {
        for (int begin = 1; begin <= end; begin++) {
            if ([array[begin] intValue] < [array[begin-1] intValue]) {
                NSNumber *temp = array[begin];
                array[begin] = array[begin-1];
                array[begin-1] = temp;
            }
        }
    }
    NSLog(@"%s-- %@",__func__,array);
}



@end
