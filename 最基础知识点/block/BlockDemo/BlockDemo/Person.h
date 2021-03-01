//
//  Person.h
//  BlockDemo
//

//  Created by MaBiao on 2021/2/27.


#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface Person : NSObject


@property(nonatomic ,strong)NSString *name;

@property(nonatomic ,copy)void(^block)(void);

- (void)personTest;
@end

NS_ASSUME_NONNULL_END
