//
//  Cat.h
//  ClassDemo
//
//  Created by MaBiao on 2021/2/10.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface Cat : NSObject
{
    @public
    NSString *_name;
    int _age;
}

- (void)run;
- (void)eat;

@end

NS_ASSUME_NONNULL_END
