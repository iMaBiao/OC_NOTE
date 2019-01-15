KVC（ 键值编码 ）实现

```
1.KVC是基于runtime机制实现的
2、可以访问私有成员变量、可以间接修改私有变量的值
[object setValue:@"134567" forKey:@"uid"];
就会被编译器处理成:
// 首先找到对应sel
SEL sel = sel_get_uid("setValue:forKey:");
// 根据object->isa找到sel对应的IMP实现指针
IMP method = objc_msg_lookup (object->isa,sel);
// 调用指针完成KVC赋值
method(object, sel, @"134567", @"uid");
KVC键值查找原理
setValue:forKey:搜索方式
1、首先搜索setKey:方法.(key指成员变量名, 首字母大写)
2、上面的setter方法没找到, 如果类方法accessInstanceVariablesDirectly返回YES. 那么按 _key, _isKey，key, iskey的顺序搜索成员名。(这个类方法是NSKeyValueCodingCatogery中实现的类方法, 默认实现为返回YES)
3、如果没有找到成员变量, 调用setValue:forUnderfinedKey:

valueForKey:的搜索方式
1、首先按getKey, key, isKey的顺序查找getter方法, 找到直接调用. 如果是BOOL、int等内建值类型, 会做NSNumber的转换.
2、上面的getter没找到, 查找countOfKey, objectInKeyAtindex, KeyAtindexes格式的方法. 如果countOfKey和另外两个方法中的一个找到, 那么就会返回一个可以响应NSArray所有方法的代理集合的NSArray消息方法.
3、还没找到, 查找countOfKey, enumeratorOfKey, memberOfKey格式的方法. 如果这三个方法都找到, 那么就返回一个可以响应NSSet所有方法的代理集合.
4、还是没找到, 如果类方法accessInstanceVariablesDirectly返回YES. 那么按 _key, _isKey, key, iskey的顺序搜索成员名.
5、再没找到, 调用valueForUndefinedKey.
```



[黑幕背后的Autorelease](http://blog.sunnyxx.com/2014/10/15/behind-autorelease/)

[Objective-C Autorelease Pool 的实现原理](http://blog.leichunfeng.com/blog/2015/05/31/objective-c-autorelease-pool-implementation-principle/#jtss-tsina)





说一下autoreleasePool的实现原理

```
autoreleasePool是一个延时release的机制， 在自动释放池被销毁或耗尽时，会向池中的所有对象发送release消息，释放所有autorelease对象。
ARC下，我们使用@autoreleasepool{}来使用一个自动释放池
AutoreleasePool并没有单独的结构，而是由若干个AutoreleasePoolPage作为结点以双向链表的形式组合而成。整个链表以堆栈的形式运作。
1、每一个指针代表一个加入到释放池的对象 或者是哨兵对象，哨兵对象是在 @autoreleasepool{} 构建的时候插入的
2、当自动释放池 pop的时候，所有哨兵对象之后的对象都会release
3、链表会在一个Page空间占满时进行增加，一个AutoreleasePoolPage的空间被占满时，会新建一个AutoreleasePoolPage对象，连接链表，后来的autorelease对象在新的page加入。
主线程：
主线程runloop中注册了两个Observer，回调都是 _wrapRunLoopWithAutoreleasePoolHandler()。
第一个oberver监听 当从休眠状态即将进入loop的时候 ，这个时候，构建自动释放池
第二个oberver监听 当准备进入休眠状态的时候，调用 objc_autoreleasePoolPop() 和 _objc_autoreleasePoolPush() 释放旧的池并创建新池
子线程：
runloop默认不开启，不会自动创建自动释放池，在需要使用自动释放池的时候，需要我们手动创建、添加自动释放池，此时如果所有的异步代码都写在自动释放池中，也可以理解为当子线程销毁的时候，自动释放池释放
```



说一下简单工厂模式，工厂模式以及抽象工厂模式？

```
简单工厂模式：根据外部信息就可以决定创建对象，所有产品都通过工厂判断就创建，体系结构很明显，缺点就是集中了所有的产品创建逻辑，耦合太重。
工厂模式：产品的各自创建逻辑下发到各自的工厂类中，一定程度达到解耦合。 多态性，产品构建逻辑可以具体到对应的产品工厂类中，更加清晰。 当我需要新产品的时候，只需要添加一个新的产品工厂，实现抽象工厂的产品产出方法，产出对应的产品。不影响客户逻辑。
抽象工厂模式：当有多个产品线，需要多个工厂分别生产不同的产品线产品，这个时候我们抽象出工厂逻辑，产品也抽象出产品类型，工厂抽象类只需要构建返回抽象产品的方法即可，更深程度的解耦。具体的什么工厂产什么产品逻辑下发到实际工厂实现。 即使添加新产品也不影响抽象工厂和抽象产品的逻辑。
```

遇到tableView卡顿嘛？会造成卡顿的原因大致有哪些？

```
可能造成tableView卡顿的原因有：
1.最常用的就是cell的重用， 注册重用标识符
如果不重用cell时，每当一个cell显示到屏幕上时，就会重新创建一个新的cell
如果有很多数据的时候，就会堆积很多cell。
如果重用cell，为cell创建一个ID，每当需要显示cell 的时候，都会先去缓冲池中寻找可循环利用的cell，如果没有再重新创建cell
2.避免cell的重新布局
cell的布局填充等操作 比较耗时，一般创建时就布局好
如可以将cell单独放到一个自定义类，初始化时就布局好
3.提前计算并缓存cell的属性及内容
当我们创建cell的数据源方法时，编译器并不是先创建cell 再定cell的高度
而是先根据内容一次确定每一个cell的高度，高度确定后，再创建要显示的cell，滚动时，每当cell进入凭虚都会计算高度，提前估算高度告诉编译器，编译器知道高度后，紧接着就会创建cell，这时再调用高度的具体计算方法，这样可以方式浪费时间去计算显示以外的cell
4.减少cell中控件的数量
尽量使cell得布局大致相同，不同风格的cell可以使用不用的重用标识符，初始化时添加控件，
不适用的可以先隐藏
5.不要使用ClearColor，无背景色，透明度也不要设置为0
渲染耗时比较长
6.使用局部更新
如果只是更新某组的话，使用reloadSection进行局部更
7.加载网络数据，下载图片，使用异步加载，并缓存
8.少使用addView 给cell动态添加view
9.按需加载cell，cell滚动很快时，只加载范围内的cell
10.不要实现无用的代理方法，tableView只遵守两个协议
11.缓存行高：estimatedHeightForRow不能和HeightForRow里面的layoutIfNeed同时存在，这两者同时存在才会出现“窜动”的bug。所以我的建议是：只要是固定行高就写预估行高来减少行高调用次数提升性能。如果是动态行高就不要写预估方法了，用一个行高的缓存字典来减少代码的调用次数即可
12.不要做多余的绘制工作。在实现drawRect:的时候，它的rect参数就是需要绘制的区域，这个区域之外的不需要进行绘制。例如上例中，就可以用CGRectIntersectsRect、CGRectIntersection或CGRectContainsRect判断是否需要绘制image和text，然后再调用绘制方法。
13.预渲染图像。当新的图像出现时，仍然会有短暂的停顿现象。解决的办法就是在bitmap context里先将其画一遍，导出成UIImage对象，然后再绘制到屏幕；
14.使用正确的数据结构来存储数据。
```

说一下UITableViewCell的卡顿你是怎么优化的？

```
一般简单的UITableViewCell都不会卡顿，TableView本身有Cell重用机制，但一些复杂的自适应高度的cell比较容易产生卡顿。
1、避免cell的过多重新布局，差别太大的cell之间不要选择重用。
2、提前计算并缓存cell的高度，内容
3、尽量减少动态添加View的操作
4、减少所有对主线程有影响的无意义操作
5、cell中的图片加载用异步加载，缓存等
6、局部更新cell
7、减少不必要的渲染时间，比如少用透明色之类的
```

请解释以下keywords的区别： assign vs weak,  _block vs  _weak

```
weak和assign都是引用计数不变，两个的差别在于，weak用于object type，就是指针类型，而assign用于简单的数据类型，如int BOOL 等。
assign看起来跟weak一样，其实不能混用的，assign的变量在释放后并不设置为nil（和weak不同），当你再去引用时候就会发生错误，崩溃，EXC_BAD_ACCESS.
assign 可以修饰对象么？ 可以修饰，编译器不会报错，但是访问过程中对象容易野指针
__block 用于标记需要在block内部修改的变量，__weak 用于防止引用循环
```

使用atomic一定是线程安全的吗？

```
atomic只能保证操作也就是存取属性的时候的存取方法是线程安全的，并不能保证整个对象就是线程安全的。
比如NSMutableArray 设置值得时候是线程安全的，但是通过objectAtIndex访问的时候就不再是线程安全的了。还是需要锁来保证线程的安全。
```



描述一个你遇到过的retain cycle例子

```
VC中一个强引用block里面使用self
代理使用强引用
sqllite多线程抢写入操作
```

+(void)load;  +(void)initialize; 有什么用处？方法分别在什么时候调用的?

```
+(void)load;
当类对象被引入项目时, runtime 会向每一个类对象发送 load 消息。
load 方法会在每一个类甚至分类被引入时仅调用一次,调用的顺序：父类优先于子类, 子类优先于分类。
由于 load 方法会在类被 import 时调用一次,而这时往往是改变类的行为的最佳时机，在这里可以使用例如 method swizlling 来修改原有的方法。
load 方法不会被类自动继承。
+(void)initialize;
也是在第一次使用这个类的时候会调用这个方法，也就是说 initialize 也是懒加载

总结：
在 Objective-C 中，runtime 会自动调用每个类的这两个方法
1.+load 会在类初始加载时调用
2.+initialize 会在第一次调用类的类方法或实例方法之前被调用
这两个方法是可选的，且只有在实现了它们时才会被调用
两者的共同点：两个方法都只会被调用一次

```



如何高性能的给UIImageView加个圆角？

```
如何高性能的给 UIImageView 加个圆角?
不好的解决方案：使用下面的方式会强制Core Animation提前渲染屏幕的离屏绘制, 而离屏绘制就会给性能带来负面影响，会有卡顿的现象出现。
self.view.layer.cornerRadius = 5.0f;
self.view.layer.masksToBounds = YES;
正确的解决方案：使用绘图技术
- (UIImage *)circleImage {
    // NO代表透明
    UIGraphicsBeginImageContextWithOptions(self.size, NO, 0.0);
    // 获得上下文
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    // 添加一个圆
    CGRect rect = CGRectMake(0, 0, self.size.width, self.size.height);
    CGContextAddEllipseInRect(ctx, rect);
    // 裁剪
    CGContextClip(ctx);
    // 将图片画上去
    [self drawInRect:rect];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    // 关闭上下文
    UIGraphicsEndImageContext();
    return image;
}
还有一种方案：使用了贝塞尔曲线"切割"个这个图片, 给UIImageView 添加了的圆角，其实也是通过绘图技术来实现的。
UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 100, 100)];
imageView.center = CGPointMake(200, 300);
UIImage *anotherImage = [UIImage imageNamed:@"image"];
UIGraphicsBeginImageContextWithOptions(imageView.bounds.size, NO, 1.0);
[[UIBezierPath bezierPathWithRoundedRect:imageView.bounds
                       cornerRadius:50] addClip];
[anotherImage drawInRect:imageView.bounds];
imageView.image = UIGraphicsGetImageFromCurrentImageContext();
UIGraphicsEndImageContext();
[self.view addSubview:imageView];
```



说一下静态库和动态库之间的区别

```
静态库 
.a 、.framework 结尾
是一个已经编译好了的集合，使用的时候连接器会把静态库合并到可执行文件中。
动态库  
.tbd 或 .framework结尾
编译过程不会被链接到目标代码中, 只会将动态库头文件添加到目标app的可执行文件，程序运行的时候被添加在独立于app的内存区域。
```



通过[UIImage imageNamed:]生成的对象什么时候被释放？

```
这种图片加载方式带有图片缓存的功能，使用这种方式加载图片后，图片会自动加入系统缓存中，并不会立即释放到内存。一些资源使程序中经常使用的图片资源，
使用这种方式会加快程序的运行减少IO操作，但对于项目中只用到一次的图片，如果采用这种方案加载，会增导致程序的内存使用增加。
非缓存的加载方式
(UIImage *)imageWithContentsOfFile:(NSString *)path
(UIImage *):(NSData *)data
```



项目中网络层如何做安全处理?

```
1、尽量使用https
https可以过滤掉大部分的安全问题。https在证书申请，服务器配置，性能优化，客户端配置上都需要投入精力，所以缺乏安全意识的开发人员容易跳过https，或者拖到以后遇到问题再优化。https除了性能优化麻烦一些以外其他都比想象中的简单，如果没精力优化性能，至少在注册登录模块需要启用https，这部分业务对性能要求比较低。
2、不要传输明文密码
不知道现在还有多少app后台是明文存储密码的。无论客户端，server还是网络传输都要避免明文密码，要使用hash值。客户端不要做任何密码相关的存储，hash值也不行。存储token进行下一次的认证，而且token需要设置有效期，使用refresh token去申请新的token。
3、Post并不比Get安全
事实上，Post和Get一样不安全，都是明文。参数放在QueryString或者Body没任何安全上的差别。在Http的环境下，使用Post或者Get都需要做加密和签名处理。
4、不要使用301跳转
301跳转很容易被Http劫持攻击。移动端http使用301比桌面端更危险，用户看不到浏览器地址，无法察觉到被重定向到了其他地址。如果一定要使用，确保跳转发生在https的环境下，而且https做了证书绑定校验。
5、http请求都带上MAC
所有客户端发出的请求，无论是查询还是写操作，都带上MAC（Message Authentication
Code）。MAC不但能保证请求没有被篡改（Integrity），还能保证请求确实来自你的合法客户端（Signing）。当然前提是你客户端的key没有被泄漏，如何保证客户端key的安全是另一个话题。MAC值的计算可以简单的处理为hash（request
params＋key）。带上MAC之后，服务器就可以过滤掉绝大部分的非法请求。MAC虽然带有签名的功能，和RSA证书的电子签名方式却不一样，原因是MAC签名和签名验证使用的是同一个key，而RSA是使用私钥签名，公钥验证，MAC的签名并不具备法律效应。
6、http请求使用临时密钥
高延迟的网络环境下，不经优化https的体验确实会明显不如http。在不具备https条件或对网络性能要求较高且缺乏https优化经验的场景下，http的流量也应该使用AES进行加密。AES的密钥可以由客户端来临时生成，不过这个临时的AES
key需要使用服务器的公钥进行加密，确保只有自己的服务器才能解开这个请求的信息，当然服务器的response也需要使用同样的AES
key进行加密。由于http的应用场景都是由客户端发起，服务器响应，所以这种由客户端单方生成密钥的方式可以一定程度上便捷的保证通信安全。
7、AES使用CBC模式
不要使用ECB模式，记得设置初始化向量，每个block加密之前要和上个block的秘文进行运算。
```



说一下你对架构的理解？ 技术架构如何搭建？

```
设计一个架构 需要考虑多个层次
1、代码风格、例如 代码整齐，一个类不能干两个事情，目录设定要清晰一眼就知道是干什么的，不要设置什么common module之类的目录，面向协议开发，瘦Controller啊等
2、规范业务块的分层，例如 MVC 或者 MVVM，统一的业务处理分层，让业务代码更清晰，耦合性也低
3、基础层的定义， 开发帮助库，例如 网络库，数据持久化库，路由库，要求易于扩展、易于测试，易于理解，让开发小伙伴上手快，接口方法设定要灵活，减少开发小伙伴的使用成本
4、组件化，一个架构本身也需要良好的封装，合理的组件化可以让功能更清晰，耦合性也更低，
大的组件化就是项目层级，把不常改动的基础库沉底，比如放pod中，经常扩展的内容放在工程里面，独立的业务块可以通过工程的方式依赖
小的组件化就是UI方面，统一封装管理UI轮子，避免一个东西出现很多份的情况
```


