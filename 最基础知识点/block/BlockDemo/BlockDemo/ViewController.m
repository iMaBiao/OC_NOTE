//
//  ViewController.m
//  BlockDemo
//
//  Created by teilt on 2019/2/28.
//  Copyright © 2019 teilt. All rights reserved.
//

#import "ViewController.h"

#import "Person.h"


@interface ViewController ()
@property(nonatomic ,strong)NSString *name;
@end

@implementation ViewController
static int c = 10;

typedef void (^Block)(void);

extern void _objc_autoreleasePoolPrint(void);

- (void)viewDidLoad {
    [super viewDidLoad];

    
//    Person *p = [[Person alloc]init];
       
//    NSLog(@"%@", [NSRunLoop mainRunLoop]);
    

//    @autoreleasepool {
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            NSLog(@"%s 子线程begin",__func__);
//            Person *p = [[Person alloc]init];
            __autoreleasing NSObject *a = [NSObject new];

//            _objc_autoreleasePoolPrint();
    //        NSLog(@"%s %@",__func__,[NSRunLoop currentRunLoop]);
            NSLog(@"%s 子线程end",__func__);
        });
//    }
    
    NSLog(@"%s",__func__);
    
    

//    auto int a = 10;
//    static int b = 11;
//    void(^block)(void) = ^{
//        NSLog(@"hello, a = %d, b = %d", a,b);
//    };
//    a = 1;
//    b = 2;
//    block();
  
    
    
//    void(^block1)(void) = ^{
//        NSLog(@"没有访问变量");
//    };
//    block1();
//    NSLog(@"%@",[block1 class]);
//
//
//    auto int a = 10;
//    void(^block2)(void) = ^{
//        NSLog(@"访问auto变量, a = %d,", a);
//    };
//    block2();
//    NSLog(@"%@",[block2 class]);
//
//    NSLog(@"%@",[[block2 copy] class]);
    
    
//    Block block;
//    {
//        Person *p = [[Person alloc]init];
//        block = ^{
//            NSLog(@"%s p= %@",__func__,p);
//        };
//
////        [p release];
//    }
//
//    block();
//    NSLog(@"%s ",__func__);
//
    
    
     __block int age = 10;
    
    void(^block)(void) = ^{
        NSLog(@"%s age = %d",__func__,age);
    };
    block();
    age = 20;
    NSLog(@"%s 最后age = %d",__func__,age);

}
//- (void)viewWillAppear:(BOOL)animated
//{
//    [super viewWillAppear:animated];
//    NSLog(@"%s", __func__);
//}
//- (void)viewDidAppear:(BOOL)animated
//{
//    [super viewDidAppear:animated];
//    NSLog(@"%s", __func__);
//}

//- (void)viewDidLoad {
//    [super viewDidLoad];
//    // Do any additional setup after loading the view, typically from a nib.
//
//    int age = 10;
//
//    void(^block)(int, int) =  ^(int a,int b){
//        NSLog(@"%s age = %d",__func__,age);
//        NSLog(@"%s this is a block",__func__);
//    };
//
//    block(10,20);
//}

/**
 
 xcrun  -sdk  iphoneos  clang  -arch  arm64  -rewrite-objc ViewController.m

 
 int age = 10;

 void(*block)(int, int) = ((void (*)(int, int))&__ViewController__viewDidLoad_block_impl_0((void *)__ViewController__viewDidLoad_block_func_0, &__ViewController__viewDidLoad_block_desc_0_DATA, age));

 ((void (*)(__block_impl *, int, int))((__block_impl *)block)->FuncPtr)((__block_impl *)block, 10, 20);
 
 
 
 struct __ViewController__viewDidLoad_block_impl_0 {
   struct __block_impl impl;
   struct __ViewController__viewDidLoad_block_desc_0* Desc;
   int age;
   __ViewController__viewDidLoad_block_impl_0(void *fp, struct __ViewController__viewDidLoad_block_desc_0 *desc, int _age, int flags=0) : age(_age) {
     impl.isa = &_NSConcreteStackBlock;
     impl.Flags = flags;
     impl.FuncPtr = fp;
     Desc = desc;
   }
 };
 
 struct __block_impl {
   void *isa;
   int Flags;
   int Reserved;
   void *FuncPtr;
 };
 
 static struct __ViewController__viewDidLoad_block_desc_0 {
   size_t reserved;
   size_t Block_size;
 } 
 */


@end
