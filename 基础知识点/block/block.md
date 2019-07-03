#### block

https://juejin.im/post/5b0181e15188254270643e88



http://www.cocoachina.com/ios/20180628/23965.html



原理

```
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    int age = 10;
    void(^block)(int ,int) = ^(int a, int b){
        NSLog(@"this is block,a = %d,b = %d",a,b);
        NSLog(@"this is block,age = %d",age);
    };
    block(3,5);
}

使用命令行将代码转化为c++查看其内部结构
xcrun -sdk iphoneos clang -arch arm64 -rewrite-objc ViewController.m


static void _I_ViewController_viewDidLoad(ViewController * self, SEL _cmd) {
    ((void (*)(__rw_objc_super *, SEL))(void *)objc_msgSendSuper)((__rw_objc_super){(id)self, (id)class_getSuperclass(objc_getClass("ViewController"))}, sel_registerName("viewDidLoad"));


    int age = 10;
    void(*block)(int ,int) = ((void (*)(int, int))&__ViewController__viewDidLoad_block_impl_0((void *)__ViewController__viewDidLoad_block_func_0, &__ViewController__viewDidLoad_block_desc_0_DATA, age));
    ((void (*)(__block_impl *, int, int))((__block_impl *)block)->FuncPtr)((__block_impl *)block, 3, 5);
}


上述定义代码中，可以发现，block定义中调用了__ViewController__viewDidLoad_block_impl_0函数，并且将__ViewController__viewDidLoad_block_impl_0函数的地址赋值给了block。那么我们来看一下__ViewController__viewDidLoad_block_impl_0函数内部结构。

```

__ViewController__viewDidLoad_block_impl_0结构体内有一个同名构造函数__ViewController__viewDidLoad_block_impl_0，构造函数中对一些变量进行了赋值最终会返回一个结构体。

那么也就是说最终将一个__ViewController__viewDidLoad_block_impl_0结构体的地址赋值给了block变量



__ViewController__viewDidLoad_block_impl_0结构体内可以发现__ViewController__viewDidLoad_block_impl_0构造函数中传入了四个参数。**(void *)__ViewController__viewDidLoad_block_func_0**、***&__ViewController__viewDidLoad_block_desc_0_DATA**、**age**、**flags**。其中flage有默认值，也就说flage参数在调用的时候可以省略不传。而最后的 age(_age)则表示传入的_age参数会自动赋值给age成员，相当于age = _age。



#### **(void *)__ViewController__viewDidLoad_block_func_0**

在__ViewController__viewDidLoad_block_func_0函数中首先取出block中age的值，紧接着可以看到两个熟悉的NSLog，可以发现这两段代码恰恰是我们在block块中写下的代码。 那么__ViewController__viewDidLoad_block_func_0函数中其实存储着我们block中写下的代码。而__ViewController__viewDidLoad_block_impl_0函数中传入的是(void *)___ViewController__viewDidLoad_block_func_0，也就说将我们写在block块中的代码封装成__ViewController__viewDidLoad_block_func_0函数，并将__ViewController__viewDidLoad_block_func_0函数的地址传入了__ViewController__viewDidLoad_block_impl_0的构造函数中保存在结构体内。

```
static void __ViewController__viewDidLoad_block_func_0(struct __ViewController__viewDidLoad_block_impl_0 *__cself, int a, int b) {
  int age = __cself->age; // bound by copy

        NSLog((NSString *)&__NSConstantStringImpl__var_folders_87_s1knmjp55613dp75p__rjk380000gp_T_ViewController_05c5dc_mi_0,a,b);
        NSLog((NSString *)&__NSConstantStringImpl__var_folders_87_s1knmjp55613dp75p__rjk380000gp_T_ViewController_05c5dc_mi_1,age);
    }
```

#### &__ViewController__viewDidLoad_block_desc_0_DATA

```
static struct __ViewController__viewDidLoad_block_desc_0 {
  size_t reserved;
  size_t Block_size;
}
```

我们可以看到__ViewController__viewDidLoad_block_desc_0中存储着两个参数，reserved和Block_size，并且reserved赋值为0而Block_size则存储着___ViewController__viewDidLoad_block_impl_0的占用空间大小。最终将__ViewController__viewDidLoad_block_desc_0结构体的地址传入__ViewController__viewDidLoad_block_func_0中赋值给Desc。

### age

age也就是我们定义的局部变量。因为在block块中使用到age局部变量，所以在block声明的时候这里才会将age作为参数传入，也就说block会捕获age，如果没有在block中使用age，这里将只会传入(void *)__ViewController__viewDidLoad_block_func_0，&__ViewController__viewDidLoad_block_desc_0两个参数。



```
- (void)viewDidLoad {
    [super viewDidLoad];    
    int age = 10;
    void(^block)(int ,int) = ^(int a, int b){
        NSLog(@"this is block,a = %d,b = %d",a,b);
        NSLog(@"this is block,age = %d",age);
    };
    age = 20;
    block(3,5);
}

打印：
BlockDemo[8445:373812] this is block,a = 3,b = 5
BlockDemo[8445:373812] this is block,age = 10

因为block在定义的之后已经将age的值传入存储在___ViewController__viewDidLoad_block_impl_0结构体中并在调用的时候将age从block中取出来使用，因此在block定义之后对局部变量进行改变是无法被block捕获的。
```



#### 看看___ViewController__viewDidLoad_block_impl_0结构体

```
struct __ViewController__viewDidLoad_block_impl_0 {
 struct __block_impl impl;
 struct __ViewController__viewDidLoad_block_desc_0* Desc;
 int age;
 __ViewController__viewDidLoad_block_impl_0(void *fp, struct __ViewController__viewDidLoad_block_desc_0 *desc, int _age, int flags=0) : age(_age) {
 impl.isa = &_NSConcreteStackBlock;
 impl.Flags = flags;
 impl.FuncPtr = fp;    //block内代码地址快
 Desc = desc;          //存储block对象占用内存大小
 }
};
```

首先我们看一下__block_impl第一个变量就是__block_impl结构体。 来到__block_impl结构体内部

```
struct __block_impl {
  void *isa;
  int Flags;
  int Reserved;
  void *FuncPtr;
};
```

我们可以发现__block_impl结构体内部就有一个isa指针。因此可以证明block本质上就是一个oc对象。而在构造函数中将函数中传入的值分别存储在__main_block_impl_0结构体实例中，最终将结构体的地址赋值给block。



接着通过上面对___ViewController__viewDidLoad_block_impl_0结构体构造函数三个参数的分析我们可以得出结论：

**1. __block_impl结构体中isa指针存储着&_NSConcreteStackBlock地址，可以暂时理解为其类对象地址，block就是_NSConcreteStackBlock类型的。**

**2. block代码块中的代码被封装成__ViewController__viewDidLoad_block_func_0函数，FuncPtr则存储着__ViewController__viewDidLoad_block_func_0函数的地址。**

**3. Desc指向__ViewController__viewDidLoad_block_desc_0结构体对象，其中存储___ViewController__viewDidLoad_block_impl_0结构体所占用的内存。**



### 调用block执行内部代码

```
((void (*)(__block_impl *, int, int))((__block_impl *)block)->FuncPtr)((__block_impl *)block, 3, 5);
```

通过上述代码可以发现调用block是通过block找到FunPtr直接调用，通过上面分析我们知道block指向的是___ViewController__viewDidLoad_block_impl_0类型结构体，但是我们发现___ViewController__viewDidLoad_block_impl_0结构体中并不直接就可以找到FunPtr，而FunPtr是存储在__block_impl中的，为什么block可以直接调用__block_impl中的FunPtr呢？

重新查看上述源代码可以发现，(__block_impl *)block将block强制转化为__block_impl类型的，因为__block_impl是___ViewController__viewDidLoad_block_impl_0结构体的第一个成员，相当于将__block_impl结构体的成员直接拿出来放在__main_block_impl_0中，那么也就说明__block_impl的[内存地址](https://www.baidu.com/s?wd=%E5%86%85%E5%AD%98%E5%9C%B0%E5%9D%80&tn=24004469_oem_dg&rsv_dl=gh_pl_sl_csd)就是___ViewController__viewDidLoad_block_impl_0结构体的内存地址开头。所以可以转化成功。并找到FunPtr成员。

上面我们知道，FunPtr中存储着通过代码块封装的函数地址，那么调用此函数，也就是会执行代码块中的代码。并且回头查看__ViewController__viewDidLoad_block_func_0函数，可以发现第一个参数就是___ViewController__viewDidLoad_block_impl_0类型的指针。也就是说将block传入__ViewController__viewDidLoad_block_func_0函数中，便于重中取出block捕获的值。



## 总结

![](https://user-gold-cdn.xitu.io/2018/5/20/1637de343b05ffaa?imageView2/0/w/1280/h/960/ignore-error/1)



block底层的数据结构也可以通过一张图来展示

![](https://user-gold-cdn.xitu.io/2018/5/20/1637de34fb2db0ee?imageView2/0/w/1280/h/960/ignore-error/1)







## block的变量捕获

为了保证block内部能够正常访问外部的变量，block有一个变量捕获机制。



#### 局部变量

##### auto变量

上述代码中我们已经了解过block对age变量的捕获。 auto自动变量，离开作用域就销毁，通常局部变量前面自动添加auto关键字。自动变量会捕获到block内部，也就是说block内部会专门新增加一个参数来存储变量的值。 auto只存在于局部变量中，访问方式为值传递，通过上述对age参数的解释我们也可以确定确实是值传递。

##### static变量

static 修饰的变量为指针传递，同样会被block捕获。

```
    auto int a = 10;
    static int b = 11;
    void(^block)(void) = ^{
        NSLog(@"hello, a = %d, b = %d", a,b);
    };
    a = 1;
    b = 2;
    block();

打印：
 hello, a = 10, b = 2
 
// block中a的值没有被改变而b的值随外部变化而变化。
```

重新生成c++代码看一下内部结构中两个参数的区别。



a,b两个变量都有捕获到block内部。但是a传入的是值，而b传入的则是地址。

因为自动变量可能会销毁，block在执行的时候有可能自动变量已经被销毁了，那么此时如果再去访问被销毁的地址肯定会发生坏内存访问，因此对于自动变量一定是值传递而不可能是指针传递了。而静态变量不会被销毁，所以完全可以传递地址。而因为传递的是值得地址，所以在block调用之前修改地址中保存的值，block中的地址是不会变得。所以值会随之改变。



#### 全局变量

我们同样以代码的方式看一下block是否捕获全局变量

```
int a = 10;
static int b = 11;
int main(int argc, const char * argv[]) {
    @autoreleasepool {
        void(^block)(void) = ^{
            NSLog(@"hello, a = %d, b = %d", a,b);
        };
        a = 1;
        b = 2;
        block();
    }
    return 0;
}
// log hello, a = 1, b = 2
```

__main_block_imp_0并没有添加任何变量，因此block不需要捕获全局变量，因为全局变量无论在哪里都可以访问。



**局部变量因为跨函数访问所以需要捕获，全局变量在哪里都可以访问 ，所以不用捕获。**



![blockçåéæè·](https://user-gold-cdn.xitu.io/2018/5/20/1637de344d83a2f8?imageView2/0/w/1280/h/960/ignore-error/1)



**总结：局部变量都会被block捕获，自动变量是值捕获，静态变量为地址捕获。全局变量则不会被block捕获**



#### 以下代码中block是否会捕获变量呢

```
@implementation Person
- (void)test
{
    void(^block)(void) = ^{
        NSLog(@"%@",self);
    };
    block();
}
- (instancetype)initWithName:(NSString *)name
{
    if (self = [super init]) {
        self.name = name;
    }
    return self;
}
+ (void) test2
{
    NSLog(@"类方法test2");
}
@end
```

![](https://user-gold-cdn.xitu.io/2018/5/20/1637de349fc932f5?imageView2/0/w/1280/h/960/ignore-error/1)

self同样被block捕获，接着我们找到test方法可以发现，test方法默认传递了两个参数self和_cmd。而类方法test2也同样默认传递了类对象self和方法选择器_cmd。

![](https://user-gold-cdn.xitu.io/2018/5/20/1637de349091a972?imageView2/0/w/1280/h/960/ignore-error/1)

不论对象方法还是类方法都会默认将self作为参数传递给方法内部，既然是作为参数传入，那么self肯定是局部变量。上面讲到局部变量肯定会被block捕获。



如果在block中使用成员变量或者调用实例的属性会有什么不同的结果。

```
- (void)test
{
    void(^block)(void) = ^{
        NSLog(@"%@",self.name);
        NSLog(@"%@",_name);
    };
    block();
}
```

![](https://user-gold-cdn.xitu.io/2018/5/20/1637de34a164f7be?imageView2/0/w/1280/h/960/ignore-error/1)



上图中可以发现，即使block中使用的是实例对象的属性，block中捕获的仍然是实例对象，并通过实例对象通过不同的方式去获取使用到的属性。





## block的类型

```
 // __NSGlobalBlock__ : __NSGlobalBlock : NSBlock : NSObject
        void (^block)(void) = ^{
            NSLog(@"Hello");
        };
        
        NSLog(@"%@", [block class]);
        NSLog(@"%@", [[block class] superclass]);
        NSLog(@"%@", [[[block class] superclass] superclass]);
        NSLog(@"%@", [[[[block class] superclass] superclass] superclass]);
```

![block](https://user-gold-cdn.xitu.io/2018/5/20/1637de34b42a03d3?imageView2/0/w/1280/h/960/ignore-error/1)

从上述打印内容可以看出block最终都是继承自NSBlock类型，而NSBlock继承于NSObjcet。那么block其中的isa指针其实是来自NSObject中的。这也更加印证了block的本质其实就是OC对象。



#### block的3种类型

1. __NSGlobalBlock__ （ _NSConcreteGlobalBlock ）

2. __NSStackBlock__ （ _NSConcreteStackBlock ）

3. __NSMallocBlock__ （ _NSConcreteMallocBlock ）

```
int main(int argc, const char * argv[]) {
    @autoreleasepool {
        // 1. 内部没有调用外部变量的block
        void (^block1)(void) = ^{
            NSLog(@"Hello");
        };
        // 2. 内部调用外部变量的block
        int a = 10;
        void (^block2)(void) = ^{
            NSLog(@"Hello - %d",a);
        };
       // 3. 直接调用的block的class
        NSLog(@"%@ %@ %@", [block1 class], [block2 class], [^{
            NSLog(@"%d",a);
        } class]);
    }
    return 0;
}
```

![block](https://user-gold-cdn.xitu.io/2018/5/20/1637de34a72eb3b8?imageView2/0/w/1280/h/960/ignore-error/1)



### block在内存中的存储

![](https://user-gold-cdn.xitu.io/2018/5/20/1637de34c0579805?imageView2/0/w/1280/h/960/ignore-error/1)



上图中可以发现，根据block的类型不同，block存放在不同的区域中。 

数据段中的`__NSGlobalBlock__`直到程序结束才会被回收，不过我们很少使用到`__NSGlobalBlock__`类型的block，因为这样使用block并没有什么意义。

`__NSStackBlock__`类型的block存放在栈中，我们知道栈中的内存由系统自动分配和释放，作用域执行完毕之后就会被立即释放，而在相同的作用域中定义block并且调用block似乎也多此一举。

`__NSMallocBlock__`是在平时编码过程中最常使用到的。存放在堆中需要我们自己进行内存管理。

![block](https://user-gold-cdn.xitu.io/2018/5/20/1637de34b6966052?imageView2/0/w/1280/h/960/ignore-error/1)



没有访问auto变量的block是`__NSGlobalBlock__`类型的，存放在数据段中。 

访问了auto变量的block是`__NSStackBlock__`类型的，存放在栈中。

__NSStackBlock__`类型的block调用copy成为`__NSMallocBlock__`类型并被复制存放在堆中。



其他类型的block调用copy会改变block类型吗？

![](https://user-gold-cdn.xitu.io/2018/5/20/1637de351bcee494?imageView2/0/w/1280/h/960/ignore-error/1)

所以在平时开发过程中MRC环境下经常需要使用copy来保存block，将栈上的block拷贝到堆中，即使栈上的block被销毁，堆上的block也不会被销毁，需要我们自己调用release操作来销毁。而在ARC环境下系统会自动调用copy操作，使block不会被销毁。



### ARC帮我们做了什么

在ARC环境下，编译器会根据情况自动将栈上的block进行一次copy操作，将block复制到堆上

**什么情况下ARC会自动将block进行一次copy操作？**以下代码都在ARC环境下执行。

##### 1. block作为函数返回值时

```
typedef void (^Block)(void);
Block myblock()
{
    int a = 10;
    // 上文提到过，block中访问了auto变量，此时block类型应为__NSStackBlock__
    Block block = ^{
        NSLog(@"---------%d", a);
    };
    return block;
}
int main(int argc, const char * argv[]) {
    @autoreleasepool {
        Block block = myblock();
        block();
       // 打印block类型为 __NSMallocBlock__
        NSLog(@"%@",[block class]);
    }
    return 0;
 }
```

**如果在block中访问了auto变量时，block的类型为`__NSStackBlock__`，上面打印内容发现blcok为`__NSMallocBlock__`类型的，并且可以正常打印出a的值，说明block内存并没有被销毁。**

**block进行copy操作会转化为`__NSMallocBlock__`类型，来讲block复制到堆中，那么说明ARC在 block作为函数返回值时会自动帮助我们对block进行copy操作，以保存block，并在适当的地方进行release操作。**



##### 2. 将block赋值给__strong指针时

block被强指针引用时，ARC也会自动对block进行一次copy操作

```

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        // block内没有访问auto变量
        Block block = ^{
            NSLog(@"block---------");
        };
        NSLog(@"%@",[block class]);
        int a = 10;
        // block内访问了auto变量，但没有赋值给__strong指针
        NSLog(@"%@",[^{
            NSLog(@"block1---------%d", a);
        } class]);
        // block赋值给__strong指针
        Block block2 = ^{
          NSLog(@"block2---------%d", a);
        };
        NSLog(@"%@",[block1 class]);
    }
    return 0;
}
```

![](https://user-gold-cdn.xitu.io/2018/5/20/1637de354325f7d7?imageView2/0/w/1280/h/960/ignore-error/1)



##### 3. block作为Cocoa API中方法名含有usingBlock的方法参数时

例如：遍历数组的block方法，将block作为参数的时候。

```
NSArray *array = @[];
[array enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            
}];
```

##### 4. block作为GCD API的方法参数时

例如：GDC的一次性函数或延迟执行的函数，执行完block操作之后系统才会对block进行release操作。

```
static dispatch_once_t onceToken;
dispatch_once(&onceToken, ^{
            
});        
dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            
});
```


