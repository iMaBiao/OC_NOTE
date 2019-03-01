//
//  ViewController.m
//  BlockDemo
//
//  Created by teilt on 2019/2/28.
//  Copyright © 2019 teilt. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
//    int age = 10;
//    void(^block)(int ,int) = ^(int a, int b){
//        NSLog(@"this is block,a = %d,b = %d",a,b);
//        NSLog(@"this is block,age = %d",age);
//    };
//    age = 20;
//    block(3,5);
    
    
    auto int a = 10;
    static int b = 11;
    void(^block)(void) = ^{
        NSLog(@"hello, a = %d, b = %d", a,b);
    };
    a = 1;
    b = 2;
    block();

}



@end
