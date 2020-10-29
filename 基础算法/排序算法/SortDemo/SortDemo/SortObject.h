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
- (void)bubbleSort1:(NSArray *)array;
- (void)bubbleSort2:(NSArray *)array;
///选择排序
- (void)selectionSort:(NSArray *)array;

@end

NS_ASSUME_NONNULL_END
