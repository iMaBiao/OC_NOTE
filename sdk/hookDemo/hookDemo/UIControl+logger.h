//
//  UIControl+logger.h
//  hookDemo
//
//  Created by MaBiao on 2021/2/28.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIControl (logger)

- (void)hook_sendAction:(SEL)action to:(id)target forEvent:(UIEvent *)event;

- (void)insertToSendAction:(SEL)action to:(id)target forEvent:(UIEvent *)event;
@end

NS_ASSUME_NONNULL_END
