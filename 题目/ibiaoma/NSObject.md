### NSObject



##### 1、[[NSObject alloc] init] 时，底层怎么做的？而new做了什么 ?

```objective-c
alloc ==> _objc_rootAlloc	==> callAlloc	==> _objc_rootAllocWithZone	==> _class_createInstanceFromZone
在_class_createInstanceFromZone中，先计算所需的空间大小，再向系统申请空间（为了保持内存对齐，最小16个字节），然后返回空间的地址，将isa与类关联，因为isa指针指向类对象。
```

```
init 直接返回了 obj 没有做其他操作,一般会让开发者重写，在里面做一些初始化操作
```

```objective-c
new 中调用 callAlloc方法，同alloc init
```



##### 2、一个NSObject对象占用多少内存？

>系统分配了16个字节给NSObject，但实际上只需要8个字节（供isa指针使用）
>
>因为NSObject的实例对象中只有一个isa指针



##### 3、objc_getClass 与 object_getClass的区别？

```objective-c
objc_getClass(const char * _Nonnull name)
参数为字符串，返回对应的类对象


Class object_getClass(id obj)
{
    if (obj) return obj->getIsa();
    else return Nil;
}
参数为对象类型，返回对象的isa指针指向的类对象或元类对象
```



##### 4、- （Class）class    、 +（Class)class区别 ？

**都返回类对象**

```objective-c
- (Class)class {
    return object_getClass(self);
}
返回类对象，因为调用者是实例对象，所以通过object_getClass返回类对象

  
+ (Class)class {
    return self;
}
返回类对象，因为调用者就是类，所以是类对象, 

Class objectClass = [[[NSObject class]class]class];
而且无论调用多少次class方法，都返回类对象  
```



##### 5、isa指针如何指向的？存储了哪些信息？如何优化的？

>简单来说：实例对象的isa指针指向类对象，类对象的isa指针指向元类对象，元类对象的isa指针指向基类的元类对象。
>
>严格来说是不对的，
>
>应该说在`arm64架构`之前，isa就是一个普通的指针，存储着`Class`、 `Meta-Class` 对象的内存地址；
>
>但是从`arm64`之后，对`isa`进行了优化，变成了一个`共用体（union）`结构，还使用`位域`来存放跟多的信息；
>
>arm64架构之前，isa指针存放着类对象或元类对象的地址值，但arm64架构之后，isa不是直接指向类对象或元类对象，而是通过与ISA_MASK进行与运算得到类对象或元类对象的地址值。
>
>
>
>共用体内大致存储了 ： 
>
>nonpointer：0，代表普通的指针，存储着Class、Meta-Class对象的内存地址；1，代表优化过，使用位域存储更多的信息；
>
>​	has_assoc：是否有设置过关联对象，如果没有，释放时会更快；
>
>​	shiftcls：存储着Class、Meta-Class对象的内存地址信息；
>
>​	extra_rc：里面存储的值是引用计数器
>
>​	weakly_referenced：是否有被弱引用指向过，如果没有，释放时会更快；
>
>​	has_cxx_dtor：是否有C++的析构函数（.cxx_destruct），如果没有，释放时会更快
>
>​	等等
>
>优化就是：使用共用体结构，利用位域技术存放更多信息。



##### 6、类对象、元类对象区别？

>实例对象的isa指针指向类对象，类对象的isa指针指向元类对象，元类对象的isa指针指向基类的元类对象。
>
>类对象与元类对象都是Class结构；
>
>Class结构包含着： isa指针，superClass指针，类的属性信息，类的对象方法信息，类的协议信息，类的成员信息，方法缓存，实例对象占用的空间等。
>
>不过类对象与元类对象只有部分有值，如：类对象没有类方法，只有对象方法等，元类对象有类方法，没有对象方法，没有属性、成员变量等。
>
>成员变量的具体值，存放着实例对象中。



##### 7、superClass指针指向什么？

>类对象的superClass指针指向父类的类对象，元类对象的superClass指针父类的元类对象；
>
>基类的类对象superClass指针指向nil（没有父类） , 基类的元类对象superClass指针指向基类的类对象；