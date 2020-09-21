#### iOS用什么方式实现一个对象的KVO?(KVO的本质是什么)

```objective-c
   1、 利用runtimeAPI动态生成一个子类（NSKVONotifying_XXX）,并且让instance对象的isa指向这个全新的子类
   2、当修改instance对象的属性时，会调用Foundation的 _NSSetXXXValueAndNotify函数（_NSSetIntValueAndNotify、_NSSetDoubleValueAndNotify）
   在函数内会调用以下三个方法
     1 willChangeValueForKey:

     2 父类原来的setter方法

     3 didChangeValueForKey:  内部会触发（Obrserve)的监听方法：
    observeValueForKeyPath: ofObject: change: context:
```

#### 如何手动触发KVO?

手动调用willChangeValueForKe:   和  didChangeValueForKey: 



**直接修改成员变量会触发KVO吗** 

不会触发KVO，因为`KVO的本质就是监听对象有没有调用被监听属性对应的setter方法`，直接修改成员变量，是在内存中修改的，不走`set`方法



**不移除KVO监听，会发生什么**

- 不移除会造成内存泄漏
- 但是多次重复移除会崩溃。系统为了实现KVO，为NSObject添加了一个名为NSKeyValueObserverRegistration的Category，KVO的add和remove的实现都在里面。在移除的时候，系统会判断当前KVO的key是否已经被移除，如果已经被移除，则主动抛出一个NSException的异常



##### 只调用`didChangeValueForKey`方法可以触发KVO方法？

其实是不能的，因为`willChangeValueForKey:` 记录旧的值，如果不记录旧的值，那就没有改变一说了



##### 打印一下`Person`和`NSKVONotifying_Person`内部方法都变成了什么?

```objective-c
//打印一下方法名
- (void)printMethodNamesOfClass:(Class)cls
{
	unsigned int count;
	// 获得方法数组
	Method *methodList = class_copyMethodList(cls, &count);

	// 存储方法名
	NSMutableString *methodNames = [NSMutableString string];

	// 遍历所有的方法
	for (int i = 0; i < count; i++) {
	// 获得方法
	Method method = methodList[i];
	// 获得方法名
	NSString *methodName = NSStringFromSelector(method_getName(method));
	// 拼接方法名
	[methodNames appendString:methodName];
	[methodNames appendString:@", "];
}

// 释放
free(methodList);

// 打印方法名
NSLog(@"%@ %@", cls, methodNames);
}
```

```
Person中
	setAge:
	age:

NSKVONotifying_Person中：
	setAge:
	class
	dealloc
	_isKVO
```

