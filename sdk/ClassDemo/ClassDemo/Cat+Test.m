//
//  Cat+Test.m
//  ClassDemo
//
//  Created by MaBiao on 2021/2/10.
//

#import "Cat+Test.h"
#import <objc/runtime.h>

@implementation Cat (Test)

- (void)setName:(NSString *)name
{
    objc_setAssociatedObject(self, @selector(name), name, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (NSString *)name
{
    return  objc_getAssociatedObject(self, _cmd);
}
@end
