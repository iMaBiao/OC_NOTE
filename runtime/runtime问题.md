#### runtime问题



1、能否向编译后得到的类中增加实例变量?能否向运行时创建的类中添加实例变量?

```
不能向编译后得到的类中增加实例变量;

能向运行时创建的类中添加实例变量;

解释如下：

因为编译后的类已经注册在 runtime 中，类结构体中的 objc_ivar_list 实例变量的链表 和 instance_size 实例变量的内存大小已经确定，同时runtime 会调用 class_setIvarLayout 或 class_setWeakIvarLayout 来处理 strong weak 引用。所以不能向存在的类中添加实例变量;

运行时创建的类是可以添加实例变量，调用 class_addIvar 函数。但是得在调用 objc_allocateClassPair 之后，objc_registerClassPair 之前，原因同上。
```




