#### dataSource与delegate区别？



引用：https://www.jianshu.com/p/849339dee9b9

 在我们日常开发中，系统提供给我们的诸多UI控件并不能完全满足我们在项目中的需要，这个时候为了提高开发效率，常用的做法就是封装出满足于需求的控件。不知读者有没有观察总结过，但凡是稍微复杂的控件都离不开两个基本因素1.逻辑 2.数据。这两点就是我们今天的主角**delegate**和**dataSource**所要承担的工作。



 这里我们先以**UITableView**举例，来看看**delegate**和**dataSource**都干了些什么。（只列举部分来做说明）

​    **1. UITableViewDelegate：**

​    **//**某行被点击后，**tableView**询问代理者要执行什么操作

​    \- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath;

​     **2. UITableViewDataSource：**

​    //告诉**tableView**在某个section有多少行

​     \- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section;

​	//告诉**tableView**在某个indexPath的cell对象是什么

​     \- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath;



  通过观察我们不难发现

  delegate 是将视图内的数据和操作等传递到外部。 

  dataSource 是外部将数据传递到控件内，为控件提供必要的数据源。

  他们本质上其实都是代理模式，并无不同，之所以加已区分，是为了使编码更加清晰。





####  **那么说了这么多，到底有什么用呢？**

​     一开始笔者就说过，封装是为了提高开发效率，是为了造好一个轮子后可以随处使用。所以在封装的时候一个必然不能忽视的现实问题就是：我们封装的控件内部绝对不能有业务代码逻辑！！！它一定是个存粹的存在！但是要如何使封装控件和我们的项目发生点关系呢？这个时候就该**delegate**和**dataSource**登场了。

   很多时候我们想要编码一个控件时，可能思绪很乱，难以下手。这个时候我提供一个思考方式以作参考。

   第一步：这个控件需要显示哪些数据？哪些东西是灵活性很大，会在具体场景中定制的？那么将这些工作交给**dataSource** 。这个时候我们就可以写出**dataSource**的协议方法了。

​    第二步：我们需要这个控件如何处理业务逻辑和业务数据？那么将这些工作交给**delegate。**这个时候我们就可以写出**delegate**的协议方法了**。**

   第三步：剩下的已经和业务无关了，我们只要存粹的去完成这个控件，并在恰当的时机调用协议方法就可以了。其实不光光是自己动手编程，在使用别人的控件时我们也可以顺着这个思路去学习如何使用。

   这种编码思想在业界还有个高大上的名字，你或许听过，叫面向接口编程。





官方文档：https://developer.apple.com/library/archive/documentation/General/Conceptual/DevPedia-CocoaCore/Delegation.html

##### Data Source

A data source is almost identical to a delegate. The difference is in the relationship with the delegating object. Instead of being delegated control of the user interface, a data source is delegated control of data. The delegating object, typically a view object such as a table view, holds a reference to its data source and occasionally asks it for the data it should display. A data source, like a delegate, must adopt a protocol and implement at minimum the required methods of that protocol. Data sources are responsible for managing the memory of the model objects they give to the delegating view.

```
数据源几乎与委托相同。区别在于与委托对象的关系。数据源不是被委派控制用户界面，而是被委派控制数据。委托对象，通常是一个视图对象，例如表视图，保存对其数据源的引用，偶尔会向它请求应该显示的数据。像委托一样，数据源必须采用一种协议，并至少实现该协议所需的方法。数据源负责管理它们提供给委派视图的模型对象的内存。
```

