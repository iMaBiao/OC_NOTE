//
//  NSThreadViewController.m
//  ThreadDemo
//
//  Created by teilt on 2019/1/14.
//  Copyright © 2019 teilt. All rights reserved.
//

#import "NSThreadViewController.h"

@interface NSThreadViewController ()

@end

@implementation NSThreadViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}


#pragma mark - 多线程下载图片
- (void)loadImageWithMultiThread {
    
    ////1. 对象方法
    //NSThread *thread = [[NSThread alloc] initWithTarget:self selector:@selector(loadImage) object:nil];
    //[thread start];
    
    //2. 类方法
    [NSThread detachNewThreadSelector:@selector(downloadImg) toTarget:self withObject:nil];
}

#pragma mark - 加载图片
- (void)downloadImg {
    // 请求数据
    NSURL *url = [NSURL URLWithString:@"https://store.storeimages.cdn-apple.com/8756/as-images.apple.com/is/image/AppleInc/aos/published/images/a/pp/apple/products/apple-products-section1-one-holiday-201811?wid=2560&hei=1046&fmt=jpeg&qlt=95&op_usm=0.5,0.5&.v=1540576114151"];
    NSData *data = [NSData dataWithContentsOfURL:url];
    
    // 回到主线程更新UI
    [self performSelectorOnMainThread:@selector(updateImg:) withObject:data waitUntilDone:YES];
}

#pragma mark - 将图片显示到界面
- (void)updateImg:(NSData *)imageData {

    UIImage *image = [UIImage imageWithData:imageData];
//   ...
}

@end
