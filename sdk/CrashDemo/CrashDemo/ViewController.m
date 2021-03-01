//
//  ViewController.m
//  CrashDemo
//
//  Created by GoSun on 2021/3/1.
//

#import "ViewController.h"

@interface ViewController ()

@property(nonatomic ,copy)NSMutableArray *testArray;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    
//    NSLog(@"%s %d",__func__,[self.testArray isKindOfClass:[NSMutableArray class]]);
    
//    [self.testArray addObject:@4];
    NSMutableArray* array = [NSMutableArray arrayWithObjects:@1, @2, @3, nil];
    self.testArray = array;
    [self.testArray addObject:@5];
//    NSLog(@"%s %d",__func__,[array isKindOfClass:[NSMutableArray class]]);
//    NSLog(@"%s %d",__func__,[self.testArray isKindOfClass:[NSMutableArray class]]);
    
}
//- (void)setTestArray:(NSMutableArray *)testArray
//{
////    NSLog(@"%s %d",__func__,[testArray isKindOfClass:[NSMutableArray class]]);//1
////    NSLog(@"%s %d",__func__,[_testArray isKindOfClass:[NSMutableArray class]]);//0
//    
//    if (testArray) {
//        _testArray = testArray;
//    }
//    
////    NSLog(@"%s %d",__func__,[testArray isKindOfClass:[NSMutableArray class]]);//1
////    NSLog(@"%s %d",__func__,[_testArray isKindOfClass:[NSMutableArray class]]);//0
//}


//- (NSMethodSignature *)methodSignatureForSelector:(SEL)aSelector
//{
//    if ([self respondsToSelector:aSelector]) {
//        // 已实现不做处理return [self methodSignatureForSelector:aSelector];
//    }return [NSMethodSignature signatureWithObjCTypes:"v@:"];
//}
//- (void)forwardInvocation:(NSInvocation *)anInvocation
//{
//    NSLog(@"在 %@ 类中, 调用了没有实现的实例方法: %@ ",NSStringFromClass([self class]),NSStringFromSelector(anInvocation.selector));
//}
//+ (NSMethodSignature *)methodSignatureForSelector:(SEL)aSelector
//{
//    if ([self respondsToSelector:aSelector]) {
//        // 已实现不做处理return [self methodSignatureForSelector:aSelector];
//    }
//    return [NSMethodSignature signatureWithObjCTypes:"v@:"];
//}
//+ (void)forwardInvocation:(NSInvocation *)anInvocation
//{
//    NSLog(@"在 %@ 类中, 调用了没有实现的类方法: %@ ",NSStringFromClass([self class]),NSStringFromSelector(anInvocation.selector));
//}

@end
