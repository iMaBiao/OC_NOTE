//
//  Person.h
//  BitDemo
//
//  Created by GoSun on 2019/11/26.
//  Copyright © 2019 ibiaoma. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface Person : NSObject
/**
 普通写法
 @property(nonatomic ,assign)BOOL tall;
 @property(nonatomic ,assign)BOOL rich;
 @property(nonatomic ,assign)BOOL handsome;
 */

- (void)setTall:(BOOL)tall;
- (BOOL)tall;

- (void)setRich:(BOOL)rich;
- (BOOL)rich;

- (void)setHandsome:(BOOL)handsome;
- (BOOL)handsome;




@end

NS_ASSUME_NONNULL_END




