#### runtime问题

[iOS 模式详解](https://juejin.im/post/593f77085c497d006ba389f0)

##### 1、能否向编译后得到的类中增加实例变量?能否向运行时创建的类中添加实例变量?

```
不能向编译后得到的类中增加实例变量;

能向运行时创建的类中添加实例变量;

解释如下：

因为编译后的类已经注册在 runtime 中，类结构体中的 objc_ivar_list 实例变量的链表 和 instance_size 实例变量的内存大小已经确定，同时runtime 会调用 class_setIvarLayout 或 class_setWeakIvarLayout 来处理 strong weak 引用。所以不能向存在的类中添加实例变量;

运行时创建的类是可以添加实例变量，调用 class_addIvar 函数。但是得在调用 objc_allocateClassPair 之后，objc_registerClassPair 之前，原因同上。
```

##### 2、  _objc_msgForward函数是做什么的？直接调用它将会发生什么？

```
_objc_msgForward是IMP类型，用于消息转发的：当向一个对象发送一条消息，但它并没有实现的时候，_objc_msgForward会尝试做消息转发
直接调用_objc_msgForward是非常危险
的事，这是把双刃刀，如果用不好会直接导致程序Crash，但是如果用得好，能做很多非常酷的事。
```

##### 3、runtime 如何实现 weak 属性

```
首先要搞清楚weak属性的特点
weak策略表明该属性定义了一种“非拥有关系” (nonowning relationship)。为这种属性设置新值时，设置方法既不保留新值，也不释放旧值。此特质同assign类似;然而在属性所指的对象遭到摧毁时，属性值也会清空(nil out)

那么runtime如何实现weak变量的自动置nil？

runtime对注册的类，会进行布局，会将 weak 对象放入一个 hash 表中。用 weak 指向的对象内存地址作为 key，当此对象的引用计数为0的时候会调用对象的 dealloc 方法，假设 weak 指向的对象内存地址是a，那么就会以a为key，在这个 weak hash表中搜索，找到所有以a为key的 weak 对象，从而设置为 nil。

weak属性需要在dealloc中置nil么
在ARC环境无论是强指针还是弱指针都无需在 dealloc 设置为 nil ， ARC 会自动帮我们处理
即便是编译器不帮我们做这些，weak也不需要在dealloc中置nil
在属性所指的对象遭到摧毁时，属性值也会清空

objc// 模拟下weak的setter方法，大致如下- (void)setObject:(NSObject *)object{ objc_setAssociatedObject(self, "object", object, OBJC_ASSOCIATION_ASSIGN); [object cyl_runAtDealloc:^{ _object = nil; }];}
```

##### 4、runtime怎么添加属性、方法等

```
ivar表示成员变量
class_addIvar
class_addMethod
class_addProperty
class_addProtocol
class_replaceProperty
```

##### 5、 runtime如何通过selector找到对应的IMP地址？（分别考虑类方法和实例方法）

> - 每一个类对象中都一个对象方法列表（对象方法缓存）
>   
>   > - 类方法列表是存放在类对象中isa指针指向的元类对象中（类方法缓存）
>   > >   > - 方法列表中每个方法结构体中记录着方法的名称,方法实现,以及参数类型，其实selector本质就是方法名称,通过这个方法名称就可以在方法列表中找到对应的方法实现.
>   > >   > - 当我们发送一个消息给一个NSObject对象时，这条消息会在对象的类对象方法列表里查找
>   > >   > - 当我们发送一个消息给一个类时，这条消息会在类的Meta Class对象的方法列表里查找*

##### 6、 使用runtime Associate方法关联的对象，需要在主对象dealloc的时候释放么？

```
无论在MRC下还是ARC下均不需要被关联的对象在生命周期内要比对象本身释放的晚很多，它们会在被 NSObject -dealloc 调用的object_dispose()方法中释放

补充：对象的内存销毁时间表，分四个步骤
1、调用 -release ：引用计数变为零
* 对象正在被销毁，生命周期即将结束. 
* 不能再有新的 __weak 弱引用，否则将指向 nil.
* 调用 [self dealloc]

2、 父类调用 -dealloc 
* 继承关系中最直接继承的父类再调用 -dealloc 
* 如果是 MRC 代码 则会手动释放实例变量们（iVars）
* 继承关系中每一层的父类 都再调用 -dealloc

3、NSObject 调 -dealloc 
* 只做一件事：调用 Objective-C runtime 中object_dispose() 方法

4. 调用 object_dispose()
* 为 C++ 的实例变量们（iVars）调用 destructors
* 为 ARC 状态下的 实例变量们（iVars） 调用 -release 
* 解除所有使用 runtime Associate方法关联的对象 
* 解除所有 __weak 引用 
* 调用 free()
```

##### 7、简述下Objective-C中调用方法的过程（runtime）

```
Objective-C是动态语言，每个方法在运行时会被动态转为消息发送，即：objc_msgSend(receiver, selector)，整个过程介绍如下：
objc在向一个对象发送消息时，runtime库会根据对象的isa指针找到该对象实际所属的类
然后在该类中的方法列表以及其父类方法列表中寻找方法运行
如果，在最顶层的父类（一般也就NSObject）中依然找不到相应的方法时，程序在运行时会挂掉并抛出异常unrecognized selector sent to XXX
但是在这之前，objc的运行时会给出三次拯救程序崩溃的机会，这三次拯救程序奔溃的说明见问题《什么时候会报unrecognized selector的异常》中的说明
补充说明：Runtime 铸就了Objective-C 是动态语言的特性，使得C语言具备了面向对象的特性，在程序运行期创建，检查，修改类、对象及其对应的方法，这些操作都可以使用runtime中的对应方法实现。
```

##### 8、 什么是method swizzling（俗称黑魔法）

```
简单说就是进行方法交换
在Objective-C中调用一个方法，其实是向一个对象发送消息，查找消息的唯一依据是selector的名字。利用Objective-C的动态特性，可以实现在运行时偷换selector对应的方法实现，达到给方法挂钩的目的
每个类都有一个方法列表，存放着方法的名字和方法实现的映射关系，selector的本质其实就是方法名，IMP有点类似函数指针，指向具体的Method实现，通过selector就可以找到对应的IMP

交换方法的几种实现方式
利用 method_exchangeImplementations 交换两个方法的实现
利用 class_replaceMethod 替换方法的实现
利用 method_setImplementation 来直接设置某个方法的IMP
```

9、对象如何找到对应的方法去调用

```
先缓存（hash查找）、再类方法列表（排序好的-二分查找），再父类

// 方法保存到什么地方?对象方法保存到类中,类方法保存到元类(meta class)，每一个类都有方法列表methodList
//明确去哪个类中调用，通过isa指针

1.根据对象的isa去对应的类查找方法,isa:判断去哪个类查找对应的方法 指向方法调用的类
2.根据传入的方法编号SEL，里面有个哈希列表，在列表中找到对应方法Method(方法名)
3.根据方法名(函数入口)找到函数实现，函数实现在方法区
```
