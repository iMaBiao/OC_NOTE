//
//  Person.m
//  ClassDemo
//
//  Created by MaBiao on 2021/2/12.
//

#import "Person.h"
#import <objc/runtime.h>
#import "Student.h"

@implementation Person

//- (id)forwardingTargetForSelector:(SEL)aSelector
//{
//    if (aSelector == @selector(testMethod)) {
//        return [[Student alloc]init];
//    }
//    return nil;
//}
- (void)test:(int)i
{
    NSLog(@"%s i= %d",__func__,i);
}
- (NSMethodSignature *)methodSignatureForSelector:(SEL)aSelector
{
    NSLog(@"%s ",__func__);
//    NSMethodSignature *signature =  [[[Student alloc]init] methodSignatureForSelector:@selector(testMethod)];
//    return signature;
    return [NSMethodSignature signatureWithObjCTypes:"i@"];
}

- (void)forwardInvocation:(NSInvocation *)anInvocation
{
    NSLog(@"%s ",__func__);
    anInvocation.target = [[Student alloc]init];
    [anInvocation invoke];
    
}


//+ (BOOL)resolveInstanceMethod:(SEL)sel
//{
//    if (sel == @selector(testInstanceMethod)) {
//        
//        Method method = class_getInstanceMethod(self, @selector(realInstaceMethod));
//        //动态添加realInstanceMethod方法
//        class_addMethod(self, sel, method_getImplementation(method), method_getTypeEncoding(method));
//    }
//    return [super resolveInstanceMethod:sel];
//}
//
//- (void)realInstaceMethod
//{
//    NSLog(@"%s",__func__);
//}

@end
