//
//  M_Object.h
//  KVO_Demo
//
//  Created by teilt on 2019/1/3.
//  Copyright © 2019 teilt. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface M_Object : NSObject

@property(nonatomic ,assign) int count;

- (void)increaseCount;

@end

NS_ASSUME_NONNULL_END
