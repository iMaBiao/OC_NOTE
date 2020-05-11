### Dispatch_once



开发中经常使用dispatch_once来创建单例

```objective-c
+ (id)instance
{
    static dispatch_once_t onceToken = 0;
    __strong static GSNetWork *instance = nil;
    _dispatch_once(&onceToken, ^{
        instance = [[self alloc] init];
    });   
    return instance;
}
```



通过查阅头文件，我们很容易知道 dispatch_once_t 就是 long 型

```objective-c
typedef intptr_t dispatch_once_t;


typedef __darwin_intptr_t       intptr_t;


typedef long                    __darwin_intptr_t;
```

静态变量在程序运行期间只被初始化一次，然后其在下一次被访问时，其值都是上次的值，其在除了这个初始化方法以外的任何地方都不能直接修改这两个变量的值。这是单例只被初始化一次的前提。



然后就是最神秘的 dispatch_once 函数了，如何才能保证，两个同时调用这个方法的进程，只执行一次这个函数的block块呢？

```objective-c
#ifdef __BLOCKS__
API_AVAILABLE(macos(10.6), ios(4.0))
DISPATCH_EXPORT DISPATCH_NONNULL_ALL DISPATCH_NOTHROW
DISPATCH_SWIFT3_UNAVAILABLE("Use lazily initialized globals instead")
void
dispatch_once(dispatch_once_t *predicate,
		DISPATCH_NOESCAPE dispatch_block_t block);

#if DISPATCH_ONCE_INLINE_FASTPATH
DISPATCH_INLINE DISPATCH_ALWAYS_INLINE DISPATCH_NONNULL_ALL DISPATCH_NOTHROW
DISPATCH_SWIFT3_UNAVAILABLE("Use lazily initialized globals instead")
void
_dispatch_once(dispatch_once_t *predicate,
		DISPATCH_NOESCAPE dispatch_block_t block)
{
	if (DISPATCH_EXPECT(*predicate, ~0l) != ~0l) {
		dispatch_once(predicate, block);
	} else {
		dispatch_compiler_barrier();
	}
	DISPATCH_COMPILER_CAN_ASSUME(*predicate == ~0l);
}
#undef dispatch_once
#define dispatch_once _dispatch_once
#endif
#endif // DISPATCH_ONCE_INLINE_FASTPATH
```

先声明了 dispatch_once 函数，下面又实现了 _dispatch_once 函数。

真实情况下应该是：用户调用  dispatch_once 函数，实际上调用的是 _dispatch_once 函数；而真正的 dispatch_once 函数是在 _dispatch_once 内调用的。

通过分析 _dispatch_once 函数，除了 DISPATCH_EXPECT 这个方法外，别的都很正常，那么就看下这个东西是个啥。（完全新手可能不懂 ~0l 是啥，这个意思长整型0按位取反，其实就是长整型的-1）。

```objective-c
#if __GNUC__
#define DISPATCH_EXPECT(x, v) __builtin_expect((x), (v))
#define dispatch_compiler_barrier()  __asm__ __volatile__("" ::: "memory")
#else
#define DISPATCH_EXPECT(x, v) (x)
#define dispatch_compiler_barrier()  do { } while (0)
#endif
```

`#define DISPATCH_EXPECT(x, v) (x)` 但是这个的意思很明显，就是如果没有定义__GNUC__的话 DISPATCH_EXPECT(x, v) 就是第一个参数 (x)。

对于 `__builtin_expect `，就是告诉编译器，它的第一个参数的值，**在very very very很大的情况下**，都会是第二个参数。



**现在回到 _dispatch_once 函数，再看它的意思： DISPATCH_EXPECT(*predicate, ~0l)  就是说，*predicate 很可能是 ~0l ，而当  DISPATCH_EXPECT(*predicate, ~0l)  不是 ~0! 时 才调用真正的 dispatch_once 函数。**



细分析之，第一次运行，predicate的值是默认值0，按照逻辑，如果有两个进程同时运行到 dispatch_once 方法时，这个两个进程获取到的 predicate 值都是0，那么最终两个进程都会调用 最原始那个 dispatch_once 函数！！！

在我看来，头文件里列出的内容，并不是 dispatch_once 实现多线程保护的逻辑，而是编译优化逻辑。也就是告诉编译器，在调用 dispatch_once 时，绝大部分情况不用调用原始的 dispatch_once ，而是直接运行后续的内容。

所以真正的实现的多线程保护逻辑，苹果并没有展示给我们，封装在原始的 dispatch_once 函数的实现里，里面应该有关于进程锁类似的机制，保证某段代码在即使有多个线程同时访问时，只有一个线程被执行。既然真正的逻辑并没有展示，那就没有深究下去了，苹果说这个函数是只能被执行一次，我们使用就是了。

那么在这里，我其实也可以猜测，predicate的数值，肯定在block运行后被更改为 ~0l ，即 -1，可以用下面的代码测试一下。

```objective-c
+ (instancetype)defaultObject{
    static SharedObject *sharedObject = nil;
    static dispatch_once_t predicate;
    NSLog(@"在dispatch_once前：%ld", predicate);
    dispatch_once(&predicate, ^{
	 NSLog(@"在dispatch_once中：%ld", predicate);
         sharedObject = [[SharedObject alloc] init]; 
    });
    NSLog(@"在dispatch_once后：%ld", predicate);
    return sharedObject;
}
```

```objective-c
在dispatch_once前：0
在dispatch_once中：140734607350288
在dispatch_once后：-1
```



摘录：

https://blog.csdn.net/mlibai/article/details/46945331

https://blog.csdn.net/u014600626/article/details/102862777

https://www.jianshu.com/p/a2ccd67295af





### dispatch_once死锁