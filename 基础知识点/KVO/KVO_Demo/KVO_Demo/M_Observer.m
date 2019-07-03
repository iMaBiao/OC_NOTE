//
//  M_Observer.m
//  KVO_Demo
//
//  Created by teilt on 2019/1/3.
//  Copyright © 2019 teilt. All rights reserved.
//

#import "M_Observer.h"
#import "M_Object.h"
@implementation M_Observer

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context
{
    //如果监听的类是 M_Observer 且keyPath是count
    if ([object isKindOfClass:[M_Object class]] && [keyPath isEqualToString:@"count"]) {
        
        NSString *newValue = [change valueForKey:NSKeyValueChangeNewKey];
        NSLog(@"newValue = %@",newValue);
    }
}

@end
