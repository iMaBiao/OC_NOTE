### 给分类添加属性（对象关联）

##### 给一个类声明属性，其实本质就是给这个类添加关联，并不是直接把这个值的内存空间添加到类存空间。

对象关联允许开发者对已经存在的类在 Category 中添加自定义的属性：

```
OBJC_EXPORT void
objc_setAssociatedObject(id _Nonnull object, const void * _Nonnull key,
                         id _Nullable value, objc_AssociationPolicy policy)
    OBJC_AVAILABLE(10.6, 3.1, 9.0, 1.0, 2.0); 

·object 是源对象

·key 是关联的键，objc_getAssociatedObject 方法通过不同的 key 即可取出对应的被关联对象

·value 是被关联的对象

·policy 是一个枚举值，表示关联对象的行为，从命名就能看出各个枚举值的含义

typedef OBJC_ENUM(uintptr_t, objc_AssociationPolicy) {
    OBJC_ASSOCIATION_ASSIGN = 0,           /**< Specifies a weak reference to the associated object. */
    OBJC_ASSOCIATION_RETAIN_NONATOMIC = 1, /**< Specifies a strong reference to the associated object. 
                                            *   The association is not made atomically. */
    OBJC_ASSOCIATION_COPY_NONATOMIC = 3,   /**< Specifies that the associated object is copied. 
                                            *   The association is not made atomically. */
    OBJC_ASSOCIATION_RETAIN = 01401,       /**< Specifies a strong reference to the associated object.
                                            *   The association is made atomically. */
    OBJC_ASSOCIATION_COPY = 01403          /**< Specifies that the associated object is copied.
                                            *   The association is made atomically. */
};
```

#### 要取出被关联的对象使用 objc_getAssociatedObject 方法即可，要删除一个被关联的对象，使用 objc_setAssociatedObject 方法将对应的 key 设置成 nil 即可：

```
objc_setAssociatedObject(self, associatedKey, nil, OBJC_ASSOCIATION_COPY_NONATOMIC);
```

##### objc_removeAssociatedObjects 方法将会移除源对象中所有的关联对象.

简单使用

eg1:

```

@interface NSObject (Property)
@property (nonatomic,strong) NSString *name;
@end


// 定义关联的key
static const char *key = "name";

@implementation NSObject (Property)

- (NSString *)name
{
    // 根据关联的key，获取关联的值。
    return objc_getAssociatedObject(self, key);
}

- (void)setName:(NSString *)name
{
    // 第一个参数：给哪个对象添加关联
    // 第二个参数：关联的key，通过这个key获取
    // 第三个参数：关联的value
    // 第四个参数:关联的策略
    objc_setAssociatedObject(self, key, name, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}
@end

使用：
    // 给系统NSObject类动态添加属性name
    NSObject *objc = [[NSObject alloc] init];
    objc.name = @"小码哥";
    NSLog(@"%@",objc.name);
```

eg 2:

假如我们要给 UIButton 添加一个监听单击事件的 block 属性，新建 UIButton 的 Category，文件如下

```
#import <UIKit/UIKit.h>

typedef void(^clickBlock)(void);

@interface UIButton (ClickBlock)

@property (nonatomic,copy) clickBlock click;

@end


#import "UIButton+ClickBlock.h"
#import <objc/runtime.h>
static const void *associatedKey = "associatedKey";
@implementation UIButton (ClickBlock)

//Category中的属性，只会生成setter和getter方法，不会生成成员变量
- (void)setClick:(clickBlock)click{

    objc_setAssociatedObject(self, associatedKey, click, OBJC_ASSOCIATION_COPY_NONATOMIC);

    [self removeTarget:self action:@selector(buttonClick) forControlEvents:UIControlEventTouchUpInside];

    if (click) {
        [self addTarget:self action:@selector(buttonClick) forControlEvents:UIControlEventTouchUpInside];
    }
}

- (clickBlock)click{
    return objc_getAssociatedObject(self, associatedKey);
}

- (void)buttonClick{
    if (self.click) {
        self.click();
    }
}
@end


使用
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.frame = self.view.bounds;
    [self.view addSubview:btn];
    btn.click = ^{
        NSLog(@"%s btn-clickBlock",__FUNCTION__);
    };
```
