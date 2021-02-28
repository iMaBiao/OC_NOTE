//
//  Cat.m
//  ClassDemo
//
//  Created by MaBiao on 2021/2/10.
//

#import "Cat.h"
#import <objc/runtime.h>

@implementation Cat

+ (void)load
{
    Method runMethod = class_getInstanceMethod([Cat class], @selector(run));
    Method eatMethod = class_getInstanceMethod([Cat class], @selector(eat));
//    method_exchangeImplementations(runMethod, eatMethod);

    class_replaceMethod([Cat class], @selector(run), method_getImplementation(eatMethod), "v");
}
- (void)run
{
    NSLog(@"%s",__func__);
    
}
- (void)eat
{
    NSLog(@"%s",__func__);
}

@end
