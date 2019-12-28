##### iOS中的常见多线程方案



![](img/pic1.png)



##### 1.NSThread

NSThread 是苹果官方提供的，使用起来比 pthread 更加面向对象，简单易用，可以直接操作线程对象。不过也需要需要程序员自己管理线程的生命周期(主要是创建)，我们在开发的过程中偶尔使用 NSThread。

比如我们会经常调用[NSThread currentThread]来显示当前的进程信息

```
NSThread的创建与运行

//使用target对象的selector作为线程的任务执行体，该selector方法最多可以接收一个参数，该参数即为argument
- (instancetype)initWithTarget:(id)target selector:(SEL)selector object:(nullable id)argument;


//使用block作为线程的任务执行体
- (instancetype)initWithBlock:(void (^)(void))block;

/*
类方法，返回值为void
使用一个block作为线程的执行体，并直接启动线程
上面的实例方法返回NSThread对象需要手动调用start方法来启动线程执行任务
*/
+ (void)detachNewThreadWithBlock:(void (^)(void))block;


/*
类方法，返回值为void
使用target对象的selector作为线程的任务执行体，该selector方法最多接收一个参数，该参数即为argument
同样的，该方法创建完县城后会自动启动线程不需要手动触发
*/
+ (void)detachNewThreadSelector:(SEL)selector toTarget:(id)target withObject:(nullable id)argument;
```

###### 

###### 常见API

```
// 获得主线程
+ (NSThread *)mainThread;    

// 判断是否为主线程(对象方法)
- (BOOL)isMainThread;

// 判断是否为主线程(类方法)
+ (BOOL)isMainThread;    

// 获得当前线程
NSThread *current = [NSThread currentThread];

// 线程的名字——setter方法
- (void)setName:(NSString *)n;    

// 线程的名字——getter方法
- (NSString *)name;
```



```
线程状态控制方法

// 线程进入就绪状态 -> 运行状态。当线程任务执行完毕，自动进入死亡状态
- (void)start;

// 线程进入阻塞状态
+ (void)sleepUntilDate:(NSDate *)date;
+ (void)sleepForTimeInterval:(NSTimeInterval)ti;

//强制停止线程  线程进入死亡状态
+ (void)exit;
```


