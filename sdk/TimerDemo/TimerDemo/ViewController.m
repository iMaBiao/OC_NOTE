//
//  ViewController.m
//  TimerDemo
//
//  Created by GoSun on 2021/2/24.
//

#import "ViewController.h"
#import "TimerTestViewController.h"
@interface ViewController ()



@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.frame = CGRectMake(100, 200, 200, 50);
    btn.backgroundColor = [UIColor orangeColor];
    [btn addTarget:self action:@selector(pushTimerVC) forControlEvents:UIControlEventTouchUpInside];
    [btn setTitle:@"push Timer VC" forState:UIControlStateNormal];
    [self.view addSubview:btn];
}

- (void)pushTimerVC
{
    TimerTestViewController *vc = [[TimerTestViewController alloc]init];
    [self.navigationController pushViewController:vc animated:YES];
}
@end
