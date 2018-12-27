类- Class

```
类本身也是一个对象，是个Class类型的对象，简称类对象
类 == 类对象
利用Class 创建 Person 类对象
利用 Person 类对象，创建 Person 类型的对象

获取内存中的类对象
1、通过类的某个对象 class方法
Class  c  =  [ p  class ]
2、通过类的class方法
Class  c  =  [ Person  class ]

类的加载
1、先加载父类，再加载子类(先调用父类的 + load 方法，再调用子 类的 +load 方法
2、在类的加载时候，
自动调用 +（void) load；方法
再调用 +(void ) initialize方法
当程序启动时，就会加载项目中的所有的类和分类，而且加载后会调用每个类和分类的 + load 方法，只会调用一次。
当第一次使用某个类时，就会调用当前类的 +initialize 方法
```
