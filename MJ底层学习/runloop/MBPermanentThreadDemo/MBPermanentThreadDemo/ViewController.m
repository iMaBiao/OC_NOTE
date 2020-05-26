//
//  ViewController.m
//  MBPermanentThreadDemo
//
//  Created by GoSun on 2020/5/26.
//  Copyright © 2020 GoSun. All rights reserved.
//

#import "ViewController.h"
#import "MBPermanentThread.h"
@interface ViewController ()
@property(nonatomic ,strong)MBPermanentThread *thread;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.thread = [[MBPermanentThread alloc]init];
    [self.thread run];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [self.thread excuteTaskBlock:^{
         NSLog(@"%s 执行任务",__func__);
      }];
}


@end
