https://www.cnblogs.com/zy1987/p/4616063.html

KVC和KVO都属于键值编程而且底层实现机制都是isa-swizzing

#### KVC概述

- KVC是Key Value Coding的简称。它是一种可以通过字符串的名字（key）来访问类属性的机制。而不是通过调用Setter、Getter方法访问。
- 关键方法定义在 NSKeyValueCodingProtocol
- KVC支持类对象和内建基本数据类型。

#### KVC使用

- 获取值  

  valueForKey: 传入NSString属性的名字。  

  valueForKeyPath: 属性的路径，xx.xx  

  valueForUndefinedKey 默认实现是抛出异常，可重写这个函数做错误处理

- 修改值  

  setValue:forKey:  

  setValue:forKeyPath:  

  setValue:forUnderfinedKey:  

  setNilValueForKey: 对非类对象属性设置nil时调用，默认抛出异常。

#### KVC键值查找

##### 搜索单值成员

- setValue:forKey:搜索方式

  ```
  1、首先搜索setKey:方法。（key指成员变量名，首字母大写）
  2、上面的setter方法没找到，如果类方法accessInstanceVariablesDirectly（是否直接访问成员变量）返回YES。那么按 _key，_isKey，key，iskey的顺序搜索成员名。（NSKeyValueCodingCatogery中实现的类方法，默认实现为返回YES）
  3、如果没有找到成员变量，调用setValue:forUnderfinedKey:
  ```

- valueForKey:的搜索方式

  ```
  1、首先按getKey，key，isKey的顺序查找getter方法，找到直接调用。如果是BOOL、int等内建值类型，会做NSNumber的转换。
  2、上面的getter没找到，查找countOfKey、objectInKeyAtindex、KeyAtindexes格式的方法。如果countOfKey和另外两个方法中的一个找到，那么就会返回一个可以响应NSArray所有方法的代理集合的NSArray消息方法。
  3、还没找到，查找countOfKey、enumeratorOfKey、memberOfKey格式的方法。如果这三个方法都找到，那么就返回一个可以响应NSSet所有方法的代理集合。
  4、还是没找到，如果类方法accessInstanceVariablesDirectly返回YES。那么按 _key，_isKey，key，iskey的顺序搜索成员名。
  5、再没找到，调用valueForUndefinedKey。
  ```

#### KVC实现分析

  KVC运用了isa-swizzing技术。isa-swizzing就是类型混合指针机制。KVC通过isa-swizzing实现其内部查找定位。isa指针（is kind of 的意思）指向维护分发表的对象的类，该分发表实际上包含了指向实现类中的方法的指针和其他数据。

比如说如下的一行KVC代码：

```
[site setValue:@"sitename" forKey:@"name"];

//会被编译器处理成
SEL sel = sel_get_uid(setValue:forKey);
IMP method = objc_msg_loopup(site->isa,sel);
method(site,sel,@"sitename",@"name");
```

每个类都有一张方法表，是一个hash表，值是函数指针IMP，SEL的名称就是查表时所用的键。  
SEL数据类型：查找方法表时所用的键。定义成char*，实质上可以理解成int值。  
IMP数据类型：他其实就是一个编译器内部实现时候的函数指针。当Objective-C编译器去处理实现一个方法的时候，就会指向一个IMP对象，这个对象是C语言表述的类型。

**KVC的内部机制：**  
一个对象在调用setValue的时候进行了如下操作：

- （1）根据方法名找到运行方法的时候需要的环境参数
- （2）他会从自己的isa指针结合环境参数，找到具体的方法实现接口。
- （3）再直接查找得来的具体的实现方法

问：通过健值编码技术，是否会违背面向对象的编程思想？
如果知道一个类的内部某个私有变量时，在外面可以通过key来访问或操作的
