//
//  ViewController.m
//  ButtonZone
//
//  Created by GoSun on 2021/3/1.
//

#import "ViewController.h"
#import "UIButton+zone.h"
@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor whiteColor];
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.frame = CGRectMake(200, 200, 40, 40);
    [self.view addSubview:btn];
    [btn addTarget:self action:@selector(btnClick) forControlEvents:UIControlEventTouchUpInside];
    btn.backgroundColor = [UIColor orangeColor];
    
    [btn setEnlargeEdgeWithTop:20 right:20 bottom:20 left:30];


}

- (void)btnClick
{
    NSLog(@"%s ",__func__);
}
@end
