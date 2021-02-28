//
//  Person.m
//  BlockDemo
//
//  Created by MaBiao on 2021/2/27.
//  Copyright © 2021 teilt. All rights reserved.
//

#import "Person.h"

@implementation Person
- (void)dealloc
{
    [super dealloc];
    NSLog(@"%s ",__func__);
}
@end
