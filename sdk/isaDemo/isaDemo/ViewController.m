//
//  ViewController.m
//  isaDemo
//
//  Created by GoSun on 2021/2/2.
//

#import "ViewController.h"
#import <objc/runtime.h>

@interface  Cat : NSObject
//{
//    @public
//    NSString *_name;
//    int _age;
//}
- (void)eat;
+ (void)run;
@end

@implementation Cat

@end

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    
    Cat *cat = [[Cat alloc]init];
    [cat eat];
    [Cat run];
    
//    //添加弱引用
//    __weak Cat *weakCat = cat;
//    weakCat = nil;
//    //添加关联对象
//    objc_setAssociatedObject(cat, "like", @"mouse", OBJC_ASSOCIATION_COPY_NONATOMIC);
//    objc_setAssociatedObject(cat, @"eat", nil, OBJC_ASSOCIATION_COPY_NONATOMIC);
//    NSLog(@"cat = %p",cat);
//
//    NSLog(@"Cat = %p",[Cat class]);

    
}


@end
