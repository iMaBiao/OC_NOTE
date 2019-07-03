1、block分几种？分别是怎么样产生的？block的实质是什么？

```
在内存角度来看，block分为 全局 、栈 和 堆 三种类型，
有强引用的block就属于堆内存block, 
只用到外部局部变量、成员属性变量、没有强指针引用的block属于栈block
只引用全局变量或静态变量的block，生命周期和程序生命周期一样的block就是全局block
block的实质是一个对象，一个结构体
```

2、__block修饰的变量为什么能在block里面能改变其值？

```
__block修饰符标记后，block就会访问标记变量本身内存地址，而未标记对象则访问截获拷贝后的变量的内存地址
```

3、block应该用copy关键字还是strong关键字？

```
block 使用 copy 是从 MRC 遗留下来的“传统”
在 MRC 中,方法内部的 block 是在栈区的,使用 copy 可以把它放到堆区。
在 ARC 中写不写都行
对于 block 使用 copy 还是 strong 效果是一样的，但写上 copy 也无伤大雅，还能时刻提醒我们：编译器自动对 block 进行了 copy 操作。如果不写 copy ，该类的调用者有可能会忘记或者根本不知道“编译器会自动对 block 进行了 copy 操作”，他们有可能会在调用之前自行拷贝属性值。这种操作多余而低效。
```

4、@property 的本质是什么？

```
@property = ivar + getter + setter;
“属性” (property)有两大概念：ivar（实例变量）、getter+setter（存取方法）
“属性” (property)作为 Objective-C 的一项特性，主要的作用就在于封装对象中的数据。 Objective-C 对象通常会把其所需要的数据保存为各种实例变量。实例变量一般通过“存取方法”(access method)来访问。其中，“获取方法” (getter)用于读取变量值，而“设置方法” (setter)用于写入变量值。
```

5、ivar、getter、setter 是如何生成并添加到类中的

```
引申一个问题：@synthesize 和 @dynamic 分别有什么作用？

完成属性（@property）定义后，编译器会自动编写访问这些属性所需的方法，此过程叫做“自动合成”(autosynthesis)。
我们也可以在类的实现代码里通过 @synthesize 语法来指定实例变量的名字。
@synthesize lastName = _myLastName;
或者通过 @dynamic 告诉编译器：属性的 setter 与 getter 方法由用户自己实现，不自动生成。
@property有两个对应的词，
一个是@synthesize（合成实例变量），一个是@dynamic。
如果@synthesize和@dynamic都没有写，那么默认的就是 @synthesize var = _var;
// 在类的实现代码里通过 @synthesize 语法可以来指定实例变量的名字。(@synthesize var = _newVar;)
1. @synthesize 的语义是如果你没有手动实现setter方法和getter方法，那么编译器会自动为你加上这两个方法。
2. @dynamic 告诉编译器，属性的setter与getter方法由用户自己实现，不自动生成（如，@dynamic var）。
```

6、用@property声明的 NSString / NSArray / NSDictionary 经常使用 copy 关键字，为什么？如果改用strong关键字，可能造成什么问题？

```
用 @property 声明 NSString、NSArray、NSDictionary 经常使用 copy 关键字，是因为他们有对应的可变类型：NSMutableString、NSMutableArray、NSMutableDictionary，他们之间可能进行赋值操作（就是把可变的赋值给不可变的），为确保对象中的字符串值不会无意间变动，应该在设置新属性值时拷贝一份。
1. 因为父类指针可以指向子类对象,使用 copy 的目的是为了让本对象的属性不受外界影响,使用 copy 无论给我传入是一个可变对象还是不可对象,我本身持有的就是一个不可变的副本。
2. 如果我们使用是 strong ,那么这个属性就有可能指向一个可变对象,如果这个可变对象在外部被修改了,那么会影响该属性。
//总结：使用copy的目的是，防止把可变类型的对象赋值给不可变类型的对象时，可变类型对象的值发送变化会无意间篡改不可变类型对象原来的值。

这里还有一个引申问题：
NSMutableArray 如果用 copy修饰了会出现什么问题?
Terminating app due to uncaught exception 'NSInvalidArgumentException', reason: '-[__NSArray0 addObject:]: unrecognized selector sent to instance 0x600000a100c0'
由于使用的是copy属性，本身的可变属性默认有一个不可变的拷贝 NSArray ，所以我们用这个可变数组去添加元素的时候，找不到对应方法而发生crash。
```

7、浅拷贝和深拷贝的区别？

```
浅拷贝（copy）：只复制指向对象的指针，而不复制引用对象本身。
深拷贝（mutableCopy）：复制引用对象本身。内存中存在了两份独立对象本身，当修改A时，A_copy不变。
只有对不可变对象进行copy操作是指针复制（浅复制），其它情况都是内容复制（深复制）
```

8、如何让自己的类用copy修饰符

```
若想令自己所写的对象具有拷贝功能，则需实现 NSCopying 协议。如果自定义的对象分为可变版本与不可变版本，那么就要同时实现 NSCopying 与 NSMutableCopying 协议。
具体步骤：
    1. 需声明该类遵从 NSCopying 协议
    2. 实现 NSCopying 协议的方法。
        // 该协议只有一个方法: 
        - (id)copyWithZone:(NSZone *)zone;
        // 注意：使用 copy 修饰符，调用的是copy方法，其实真正需要实现的是 “copyWithZone” 方法。
```

9、ViewController生命周期

```
按照执行顺序排列：
1. initWithCoder：通过nib文件初始化时触发。
2. awakeFromNib：nib文件被加载的时候，会发生一个awakeFromNib的消息到nib文件中的每个对象。     
//如果不是nib初始化 上面两个换成 initWithNibName:bundle:
3. loadView：开始加载视图控制器自带的view。
4. viewDidLoad：视图控制器的view被加载完成。  
5. viewWillAppear：视图控制器的view将要显示在window上。
6. updateViewConstraints：视图控制器的view开始更新AutoLayout约束。
7. viewWillLayoutSubviews：视图控制器的view将要更新内容视图的位置。
8. viewDidLayoutSubviews：视图控制器的view已经更新视图的位置。
9. viewDidAppear：视图控制器的view已经展示到window上。 
10. viewWillDisappear：视图控制器的view将要从window上消失。
11. viewDidDisappear：视图控制器的view已经从window上消失。
```

10、OC的反射机制

```
1). class反射
    通过类名的字符串形式实例化对象。
        Class class = NSClassFromString(@"student"); 
        Student *stu = [[class alloc] init];
    将类名变为字符串。
        Class class =[Student class];
        NSString *className = NSStringFromClass(class);
2). SEL的反射
    通过方法的字符串形式实例化方法。
        SEL selector = NSSelectorFromString(@"setName");  
        [stu performSelector:selector withObject:@"Mike"];
    将方法变成字符串。
        NSStringFromSelector(@selector*(setName:));
```

11、self 和 super

```
self 是类的隐藏参数，指向当前调用方法的这个类的实例。
super是一个Magic Keyword，它本质是一个编译器标示符，和self是指向的同一个消息接收者。
不同的是：super会告诉编译器，调用class这个方法时，要去父类的方法，而不是本类里的。
```

12、id 和 NSObject＊的区别

```
id是一个 objc_object 结构体指针，定义是
typedef struct objc_object *id
id可以理解为指向对象的指针。所有oc的对象 id都可以指向，编译器不会做类型检查，id调用任何存在的方法都不会在编译阶段报错，当然如果这个id指向的对象没有这个方法，该崩溃还是会崩溃的。
NSObject *指向的必须是NSObject的子类，调用的也只能是NSObjec里面的方法否则就要做强制类型转换。
不是所有的OC对象都是NSObject的子类，还有一些继承自NSProxy。NSObject *可指向的类型是id的子集。


引申： id 和 instancetype 的区别
instancetype的作用，就是使那些非关联返回类型的方法返回所在类的类型！
相同点：
都可以作为方法的返回类型
不同点：
instancetype可以返回和方法所在类相同类型的对象，id只能返回未知类型的对象
instancetype只能作为返回值，不能像id那样作为参数
```

13、NSDictionary的实现原理是什么？

```
一：字典原理
NSDictionary（字典）是使用hash表来实现key和value之间的映射和存储的
方法：- (void)setObject:(id)anObject forKey:(id)aKey;
Objective-C中的字典NSDictionary底层其实是一个哈希表


引申：字典的查询工作原理
字典的工作原理 ？怎100w个中是怎么快速去取value？
```

14、你们的App是如何处理本地数据安全的（比如用户名的密码）？

```
本地尽量不存储用户隐私数据、敏感信息
使用如AES256加密算法对数据进行安全加密后再存入SQLite中
或者数据库整体加密
存放在keychain里面
向Keychain中存储数据时，不要使用kSecAttrAccessibleAlways，而是使用更安全的kSecAttrAccessibleWhenUnlocked或kSecAttrAccessibleWhenUnlockedThisDeviceOnly选项。 
AES  DES
```

15、遇到过BAD_ACCESS的错误吗？你是怎样调试的？

```
90%的错误来源在于对一个已经释放的对象进行release操作, 或者说对一个访问不到的地址进行访问，可能是由于些变量已经被回收了，亦可能是由于使用栈内存的基本类型的数据赋值给了id类型的变量。

例如：
id x_id = [self performSelector:@selector(returnInt)];

- (int)returnInt { return 5; }
上面通过id去接受int返回值，int是存放在栈里面的，堆内存地址如何找得到，自然就是 EXC_BAD_ACCESS。
```
