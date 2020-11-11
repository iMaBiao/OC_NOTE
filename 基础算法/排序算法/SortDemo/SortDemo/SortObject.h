//
//  SortObject.h
//  SortDemo
//
//  Created by GoSun on 2020/4/28.
//  Copyright © 2020 GoSun. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface SortObject : NSObject

///冒泡排序
- (void)bubbleSort1:(NSMutableArray *)array;
- (void)bubbleSort2:(NSMutableArray *)array;
- (void)bubbleSort3:(NSMutableArray *)array;
///选择排序
- (void)selectionSort:(NSMutableArray *)array;
///插入排序
- (void)insertionSort:(NSMutableArray *)array;

@end

NS_ASSUME_NONNULL_END
