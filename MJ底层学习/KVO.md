

#### iOS用什么方式实现一个对象的KVO?(KVO的本质是什么)

```
   1、 利用runtimeAPI动态生成一个子类（NSKVONotifying_XXX）,并且让instance对象的isa指向这个全新的子类
   2、当修改instance对象的属性时，会调用Foundation的 _NSSetXXXValueAndNotify函数
   在函数内会调用以下三个方法
     1 willChangeValueForKey:

     2 父类原来的setter
     
     3 didChangeValueForKey:  内部会触发（Obrserve)的监听方法：
    observeValueForKeyPath: ofObject: change: context:
```



#### 如何手动触发KVO?

手动调用willChangeValueForKe:   和  didChangeValueForKey: 




