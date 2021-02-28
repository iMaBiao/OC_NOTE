//
//  Person.h
//  ClassDemo
//
//  Created by MaBiao on 2021/2/12.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface Person : NSObject

//- (void)testInstanceMethod;

- (void)testMethod;

@property (nonatomic, strong, nullable) NSString *firstName;
@property (nonatomic, strong, nullable) NSString *lastName;

@end

NS_ASSUME_NONNULL_END
