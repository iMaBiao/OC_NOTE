#### objc_msgSend执行流程

OC中的方法调用，其实都是转化为`objc_msgSend`函数的调用，

`objc_msgSend`的执行流程可以分为3大阶段

- 1、消息发送
- 2、动态方法解析
- 3、消息转发

##### 1、消息发送

![](img/objc_megSend01.png)

```
1、首先判断消息接受者receiver是否为nil，如果为nil直接退出消息发送

2、如果存在消息接受者receiverClass，首先在消息接受者receiverClass的cache中查找方法，如果找到方法，直接调用。如果找不到，往下进行

3、没有在消息接受者receiverClass的cache中找到方法，则从receiverClass的class_rw_t中查找方法，如果找到方法，执行方法，并把该方法缓存到receiverClass的cache中；如果没有找到，往下进行

4、没有在receiverClass中找到方法，则通过superClass指针找到superClass，也是现在缓存中查找，如果找到，执行方法，并把该方法缓存到receiverClass的cache中；如果没有找到，往下进行

5、没有在消息接受者superClass的cache中找到方法，则从superClass的class_rw_t中查找方法，如果找到方法，执行方法，并把该方法缓存到receiverClass的cache中；如果没有找到，重复4、5步骤。如果找不到了superClass了，往下进行

6、如果在最底层的superClass也找不到该方法，则要转到动态方法解析

补充：
1、如果是从class_rw_t中查找方法时：
    已经排序的，二分查找
    没有排序的，遍历查找

2、receiver通过isa指针找到receiverClass
   receiverClass通过superclass指针找到superClass
```

消息发送流程是我们平时最经常使用的流程，其他的像`动态方法解析`和`消息转发`其实是补救措施。

#### 2、动态方法解析

![](img/objc_msgSend02.png)

- 开发者可以实现以下方法，来动态添加方法实现
  
  - +resolveInstanceMethod:
  - +resolveClassMethod:

- 动态解析过后，会重新走“消息发送”的流程，从receiverClass的cache中查找方法这一步开始执行

如果一个类，只有方法的声明，没有方法的实现，会出现最常见错误：`unrecognized selector sent to instance 0x100559b60`

**动态方法解析1**

动态方法解析需要调用`resolveInstanceMethod`或者`resolveClassMethod`一个对应实例方法，一个对应类方法。

以`resolveInstanceMethod`为例

```
- (void)other{
    NSLog(@"%s",__func__);
}

+ (BOOL)resolveInstanceMethod:(SEL)sel{
    if (sel == @selector(test)) {
        //获取其他方法
        Method method = class_getInstanceMethod(self, @selector(other));
        //动态添加test的方法
        class_addMethod(self, sel,method_getImplementation(method),  method_getTypeEncoding(method));
    }

    return [super resolveInstanceMethod:sel];
}
@end
```

**动态方法解析2**

用method_t验证

```
struct method_t {
    SEL sel;
    char *types;
    IMP imp;
};

+ (BOOL)resolveInstanceMethod:(SEL)sel{

    if (sel == @selector(test)) {
        //获取其他方法
        struct method_t *method = (struct method_t*)class_getInstanceMethod(self, @selector(other));
        //动态添加test的方法
        class_addMethod(self, sel, method->imp, method->types);
        return  YES;
    }
    return [super resolveInstanceMethod:sel];
}
```

**动态方法解析3**

用C语言验证

```
void c_other(id self, SEL _cmd)
{
    NSLog(@"c_other - %@ - %@", self, NSStringFromSelector(_cmd));
}

+ (BOOL)resolveInstanceMethod:(SEL)sel{

    if (sel == @selector(test)) {

        class_addMethod(self, sel, (IMP)c_other, "v16@0:8");
        return YES;
    }

    return [super resolveInstanceMethod:sel];
}
```

#### 3、消息转发

如果方法一个方法在`消息发送阶段`没有找到相关方法，也没有进行`动态方法解析`，这个时候就会走到消息转发阶段了。

![](img/objc_msgSend03.png)

- 调用`forwardingTargetForSelector`，返回值不为nil时，会调用`objc_msgSend(返回值, SEL)`
- 调用`methodSignatureForSelector`,返回值不为nil，调用`forwardInvocation:`方法；返回值为nil时，调用`doesNotRecognizeSelector:`方法
- 开发者可以在forwardInvocation:方法中自定义任何逻辑
- 以上方法都有对象方法、类方法2个版本（前面可以是加号+，也可以是减号-）

**forwardingTargetForSelector**

```
@interface Person : NSObject
- (void)test;
@end


@interface Student : NSObject
- (void)test;
@end

#import "Student.h"
@implementation Student
- (void)test{
    NSLog(@"%s",__func__);
}
@end

#import "Person.h"
main(){
    Person *p = [[Person alloc]init];
    [p test];
}
```

调用person的test方法，由于未实现，就会报错：`unrecognized selector sent to instance 0x100747a50`

此时在Person.m中添加这个方法

```
- (id)forwardingTargetForSelector:(SEL)aSelector{
    if (aSelector == @selector(test)) {
        return [[Student alloc]init];
    }
    return nil;
}

调用forwardingTargetForSelector，返回值不为nil时，会调用objc_msgSend(返回值, SEL)，结果就是调用了objc_msgSend(Student,test)
```

**methodSignatureForSelector（方法签名）**

当`forwardingTargetForSelector`返回值为nil，或者都没有调用该方法的时候，系统会调用`methodSignatureForSelector`方法。

调用`methodSignatureForSelector`,返回值不为nil，调用`forwardInvocation:`方法；返回值为nil时，调用`doesNotRecognizeSelector:`方法

```
对于方法签名的生成方式

1、[NSMethodSignature signatureWithObjCTypes:"i@:i"]
2、[[[Student alloc]init] methodSignatureForSelector:aSelector];

实现方法签名以后我们还要实现forwardInvocation方法，当调用person的test的方法的时候，就会走到这个方法中
```

NSInvocation封装了一个方法调用，包括：方法调用者、方法名、方法参数

- anInvocation.target 方法调用者
- anInvocation.selector 方法名
- [anInvocation getArgument:NULL atIndex:0]

```
- (void)forwardInvocation:(NSInvocation *)anInvocation
{
    anInvocation.target = [[Student alloc]init];
    [anInvocation invoke];
}
```



补充：

一个完整的方法执行流程

![](img/方法执行流程.png)