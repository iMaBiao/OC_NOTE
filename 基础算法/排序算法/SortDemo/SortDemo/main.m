//
//  main.m
//  SortDemo
//
//  Created by GoSun on 2020/4/28.
//  Copyright © 2020 GoSun. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SortObject.h"
int main(int argc, const char * argv[]) {
    @autoreleasepool {
        

        NSMutableArray *array = [NSMutableArray arrayWithObjects:@(3),@(1),@(2),@(9),@(7),@(4),@(0),@(5),@(9),@(8), nil];
        SortObject *sortObj = [[SortObject alloc]init];
        
        //冒泡
//        [sortObj bubbleSort1:array];
//        [sortObj bubbleSort2:array];
        
        //选择
        [sortObj selectionSort:array];
        
    }
    return 0;
}


