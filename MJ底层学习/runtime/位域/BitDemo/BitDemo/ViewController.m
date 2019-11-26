//
//  ViewController.m
//  BitDemo
//
//  Created by GoSun on 2019/11/26.
//  Copyright © 2019 ibiaoma. All rights reserved.
//

#import "ViewController.h"
#import "Person.h"
#import <objc/runtime.h>
@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    Person *p = [[Person alloc]init];
    p.tall = NO;
    p.rich = YES;
    p.handsome = NO;
    
    NSLog(@"%s char占%d字节",__func__,sizeof(char));
    //1个字节8位 即 0b00000001,其中的0、1 称为1位
    NSLog(@"%s Person占%ld字节",__func__,class_getInstanceSize([Person class]));
    
    NSLog(@"%s p.tall = %d , p.rich = %d, p.handsome = %d",__func__,p.tall,p.rich,p.handsome);
    
}


@end
