## 如何扩大view的响应范围



##### 1、原来一般都是在上边添加一个范围更大的按钮，这样确实能够实现效果，但是每次都这样写会很low。



##### 2、继承与UIButton，重写下面的方法：

```objective-c
- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent*)event {
    CGRect bounds = self.bounds;
    //扩大原热区直径至26，可以暴露个接口，用来设置需要扩大的半径。
    CGFloat widthDelta = 26;
    CGFloat heightDelta = 26;
    bounds = CGRectInset(bounds, -0.5 * widthDelta, -0.5 * heightDelta);
    return CGRectContainsPoint(bounds, point);
}
```



##### 3、重写方法 `- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event`



```objective-c
//最简单的扩展矩形范围
- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    CGRect rectRange = CGRectInset(self.bounds, -30.0, -30.0);
    if (CGRectContainsPoint(rectRange, point)){
        return self;
    }else{
        return nil;
    }
    return self;
}

```



```objective-c
// 如果需要我们将点击区域规定在圆形范围内，我们可以这样做：

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event{
    [super hitTest:point withEvent:event];
    
    CGPoint center = CGPointMake(self.bounds.size.width/2, self.bounds.size.height/2);
    
   //当然这个半径也可以扩大
    CGFloat raidus = self.frame.size.height >= self.frame.size.width ?self.frame.size.width/2 :self.frame.size.width/2;
    
   //传入中心点 实时点击点 与半径判断 点击点是否在半径区域内
    BOOL pointInRound =[self touchPointInsideCircle:center radius:raidus targetPoint:point];
    if (pointInRound){
        return self;
    }else{
        return nil;
    }
}

//用来判断 圆形点击区域
- (BOOL)touchPointInsideCircle:(CGPoint)center radius:(CGFloat)radius targetPoint:(CGPoint)point {
    CGFloat dist = sqrtf((point.x - center.x) * (point.x - center.x) +
                         (point.y - center.y) * (point.y - center.y));
    return (dist <= radius);
}
```



------------

#### 通过分类来扩展

```objective-c
//这个方法就是传个你点击的点 然后你去判断这个点是否在视图上

@interface UIView (ChangeScope)

- (void)changeViewScope:(UIEdgeInsets)changeInsets;

@end
  
  
#import "UIView+ChangeScope.h"
#import <objc/runtime.h>

@implementation UIView (ChangeScope)

static char *changeScopeKey;

- (void)setChangeScope:(NSString *)changeScope
{
    objc_setAssociatedObject(self, &changeScopeKey, changeScope, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (NSString *)changeScope
{
    return objc_getAssociatedObject(self, &changeScopeKey);
}

- (void)changeViewScope:(UIEdgeInsets)changeInsets
{
     self.changeScope = NSStringFromUIEdgeInsets(changeInsets);
}

- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event
{
     UIEdgeInsets changeInsets = UIEdgeInsetsFromString(self.changeScope);
      if (changeInsets.left != 0 || changeInsets.top != 0 || changeInsets.right != 0 || changeInsets.bottom != 0) {
          CGRect myBounds = self.bounds;
          myBounds.origin.x = myBounds.origin.x + changeInsets.left;
          myBounds.origin.y = myBounds.origin.y + changeInsets.top;
          myBounds.size.width = myBounds.size.width - changeInsets.left - changeInsets.right;
          myBounds.size.height = myBounds.size.height - changeInsets.top - changeInsets.bottom;
         return CGRectContainsPoint(myBounds, point);
      } else {
        return CGRectContainsPoint(self.bounds,point);
     }
}
@end
```

