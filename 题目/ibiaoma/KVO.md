##### 1、KVO本质？怎么手动触发？

利用runtime的动态特性，生成一个全新的子类，并且让实例对象的isa指针指向这个全新的类

当属性被修改时（即调用setter方法时），在新类中调用_NSSetIntValueAndNotify 函数，在这个函数中会调用以下三个方法

`willChangeValueForKey:`

父类中的setter方法

`didChangeValueForKey:`

最后在`didChangeValueForKey:`里面调用`observeValueForKeyPath`方法来达到监听的效果



###### 手动触发：

主动调用 `willChangeValueForKey:  ` 与 `didChangeValueForKey:` 即可。



##### 2、如何自己实现一套KVO ?

自己创建一个类，继承原来的类，类名为：`NSKVONotifying_XXX`

重写setter方法，在setter方法里面调用`willChangeValueForKey:` 、 父类中的setter方法、 `didChangeValueForKey:`   ，并且在`didChangeValueForKey:`中调用`observeValueForKeyPath`方法；

重写 class方法，dealloc方法，_isKVO方法。

能简单达到监听效果，但肯定会省略了部分逻辑。



##### 3、直接修改成员变量会触发KVO吗？

不会，因为他不走setter方法。



##### 4、不移除KVO监听，会发生什么？

- 不移除会造成内存泄漏
- 但是多次重复移除会崩溃。系统为了实现KVO，为NSObject添加了一个名为NSKeyValueObserverRegistration的Category，KVO的add和remove的实现都在里面。在移除的时候，系统会判断当前KVO的key是否已经被移除，如果已经被移除，则主动抛出一个NSException的异常