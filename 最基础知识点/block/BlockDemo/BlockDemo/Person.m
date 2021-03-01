//
//  Person.m
//  BlockDemo
//

//  Created by MaBiao on 2021/2/27.


#import "Person.h"

@implementation Person


- (void)personTest
{
//    __weak typeof(self) weakSelf = self;
//    __unsafe_unretained id weakSelf = self;
//    self.block = ^{
//        NSLog(@"%p",weakSelf);
//    };
    
    __block id weakSelf = self;
    self.block = ^{
        printf("%p",weakSelf);
        weakSelf = nil;
    };

    self.block();
    
}

- (void)dealloc
{
    [super dealloc];
    NSLog(@"%s ",__func__);
}
@end
