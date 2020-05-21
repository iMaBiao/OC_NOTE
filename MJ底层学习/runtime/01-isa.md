#### 01-isa

实例对象的`isa`指向类对象，类对象的`isa`指向元类对象

严格来说是不对的，

应该说在`arm64架构`之前，isa就是一个普通的指针，存储着`Class`、 `Meta-Class` 对象的内存地址；

但是从`arm64`之后，对`isa`进行了优化，变成了一个`共用体（union）`结构，还使用`位域`来存放跟多的信息。

```objective-c
union isa_t {
    Class cls;
    uintptr_t bits;
    struct {
         uintptr_t nonpointer : 1;
         uintptr_t has_assoc : 1;
         uintptr_t has_cxx_dtor : 1;
         uintptr_t shiftcls : 33; 
         uintptr_t magic : 6;
         uintptr_t weakly_referenced : 1;
         uintptr_t deallocating : 1;
         uintptr_t has_sidetable_rc : 1;
         uintptr_t extra_rc : 19;
         # define RC_ONE (1ULL<<45)
         # define RC_HALF (1ULL<<18)
    };
};
```

- 1、nonpointer：0，代表普通的指针，存储着Class、Meta-Class对象的内存地址；1，代表优化过，使用位域存储更多的信息
- 2、has_assoc：是否有设置过关联对象，如果没有，释放时会更快
- 3、has_cxx_dtor：是否有C++的析构函数（.cxx_destruct），如果没有，释放时会更快
- 4、shiftcls：存储着Class、Meta-Class对象的内存地址信息
- 5、magic：用于在调试时分辨对象是否未完成初始化
- 6、weakly_referenced：是否有被弱引用指向过，如果没有，释放时会更快
- 7、deallocating：对象是否正在释放
- 8、extra_rc：里面存储的值是引用计数器
- 9、has_sidetable_rc：引用计数器是否过大无法存储在isa中；如果为1，那么引用计数会存储在一个叫SideTable的类的属性中
