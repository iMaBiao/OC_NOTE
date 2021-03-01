//
//  UIButton+zone.m
//  ButtonZone
//
//  Created by GoSun on 2021/3/1.
//

#import "UIButton+zone.h"
#import <objc/runtime.h>

static char topNameKey;
static char rightNameKey;
static char bottomNameKey;
static char leftNameKey;

@implementation UIButton (zone)
// MARK: - 第一种方式
//- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event
//{
//    CGRect bounds = self.bounds;
//    CGFloat widthDelta = 100.0 - bounds.size.width;
//    CGFloat heightDelta = 100.0 - bounds.size.height;
//    bounds = CGRectInset(bounds, -0.5 * widthDelta, -0.5 * heightDelta);
//    return CGRectContainsPoint(bounds, point);
//}


// MARK: - 第二种方式 更加精确 上左下右各个方向都能设置，而且是不同的值

#pragma mark- 利用 **runtime** 具体的设置内边距
// 设置可点击范围到按钮上、右、下、左的距离
-(void)setEnlargeEdgeWithTop:(CGFloat)top right:(CGFloat)right bottom:(CGFloat)bottom left:(CGFloat)left
{
    objc_setAssociatedObject(self, &topNameKey, [NSNumber numberWithFloat:top], OBJC_ASSOCIATION_COPY_NONATOMIC);
    objc_setAssociatedObject(self, &rightNameKey, [NSNumber numberWithFloat:right], OBJC_ASSOCIATION_COPY_NONATOMIC);
    objc_setAssociatedObject(self, &bottomNameKey, [NSNumber numberWithFloat:bottom], OBJC_ASSOCIATION_COPY_NONATOMIC);
    objc_setAssociatedObject(self, &leftNameKey, [NSNumber numberWithFloat:left], OBJC_ASSOCIATION_COPY_NONATOMIC);

}

- (CGRect)enlargedRect
{
    NSNumber *topEdge=objc_getAssociatedObject(self, &topNameKey);
    NSNumber *rightEdge=objc_getAssociatedObject(self, &rightNameKey);
    NSNumber *bottomEdge=objc_getAssociatedObject(self, &bottomNameKey);
    NSNumber *leftEdge=objc_getAssociatedObject(self, &leftNameKey);
    if(topEdge && rightEdge && bottomEdge && leftEdge){
        return CGRectMake(self.bounds.origin.x-leftEdge.floatValue,
                          self.bounds.origin.y-topEdge.floatValue,
                          self.bounds.size.width+leftEdge.floatValue+rightEdge.floatValue,
                          self.bounds.size.height+topEdge.floatValue+bottomEdge.floatValue);
    }else{
        return self.bounds;
    }
}

// 设置可点击范围到按钮上、右、下、左的距离
- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event
{
    CGRect rect=[self enlargedRect];
    if(CGRectEqualToRect(rect, self.bounds)){
        return [super pointInside:point withEvent:event];
    }
    return CGRectContainsPoint(rect, point)?YES:NO;
}

@end
