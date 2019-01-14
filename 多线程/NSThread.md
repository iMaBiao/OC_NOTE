##### NSThread

https://juejin.im/post/5c3321cb518825260a7dc6af



NSThread是对pthread的封装



NSThread是轻量级的多线程开发，优点是我们可以直接实例化一个NSThread对象并直接操作这个线程对象，但是使用NSThread需要自己管理线程生命周期。iOS开发过程中，NSThread最常用到的方法就是 **NSThread currentThread**获取当前线程，其他常用属性及方法如下：

```
// 线程字典
@property (readonly, retain) NSMutableDictionary *threadDictionary;
// 线程名称
@property (nullable, copy) NSString *name;
// 优先级
@property double threadPriority ; 
// 是否为主线程
@property (readonly) BOOL isMainThread
// 读取线程状态
@property (readonly, getter=isExecuting) BOOL executing;
@property (readonly, getter=isFinished) BOOL finished;
@property (readonly, getter=isCancelled) BOOL cancelled;

// 直接将操作添加到线程中并启动
+ (void)detachNewThreadSelector:(SEL)selector toTarget:(id)target withObject:(id)argument

// 创建一个线程对象
- (instancetype)initWithTarget:(id)target selector:(SEL)selector object:(id)argument 

// 启动
- (void)start;

// 撤销
- (void)cancel;

// 退出
+ (void)exit;

// 休眠
+ (void)sleepForTimeInterval:(NSTimeInterval)ti;


实现了在特定线程上执行任务的功能，该分类也定义在NSThread.h中：

// 在主线程上执行一个方法
- (void)performSelectorOnMainThread:(SEL)aSelector withObject:(nullable id)arg waitUntilDone:(BOOL)wait;

// 在指定的线程上执行一个方法，需要用户创建一个线程对象
- (void)performSelector:(SEL)aSelector onThread:(NSThread *)thr withObject:(nullable id)arg waitUntilDone:(BOOL)wait;

// 在后台执行一个操作，本质就是重新创建一个线程执行当前方法
- (void)performSelectorInBackground:(SEL)aSelector withObject:(nullable id)arg;
```



#### 多种方式创建线程

```
//动态创建线程
-(void)dynamicCreateThread{
    NSThread *thread = [[NSThread alloc] initWithTarget:self selector:@selector(loadImageSource:) object:imgUrl];
    thread.threadPriority = 1;// 设置线程的优先级(0.0 - 1.0，1.0最高级)
    [thread start];
}

//静态创建线程
-(void)staticCreateThread{
    [NSThread detachNewThreadSelector:@selector(loadImageSource:) toTarget:self withObject:imgUrl];
}

//隐式创建线程
-(void)implicitCreateThread{
    [self performSelectorInBackground:@selector(loadImageSource:) withObject:imgUrl];
}

```



##### 关于NSThread线程状态的说明

NSThread类型的对象可以获取到线程的三种状态属性isExecuting（正在执行）、isFinished（已经完成）、isCancellled（已经撤销），其中撤销状态是可以在代码中调用线程的cancel方法手动设置的（在主线程中并不能真正停止当前线程）。isFinished属性标志着当前线程上的任务是否执行完成，cancel一个线程只是撤销当前线程上任务的执行，监测到isFinished = YES或调用cancel方法都不能代表立即退出了这个线程，而调用类方法exit方法才可立即退出当前线程。



补充：

- 更新UI需回到主线程中操作；
- 线程处于就绪状态时会处于等待状态，不一定立即执行；
- 区分线程三种状态的不同，尤其是撤销和退出两种状态的不同；
- 在线程死亡之后，再次点击屏幕尝试重新开启线程，则程序会挂；
- NSThread可以设置对象的优先级thread.threadPriority，threadPriority取值范围是0到1；
- NSThread并没有提供设置线程间的依赖关系的方法，也就不能单纯通过NSThread来设置任务处理的先后顺序，但是我们可以通过设置NSThread的休眠或优先级来尽量优化任务处理的先后顺序;
- 在自己试验的工程中，虽然NSThread实例的数量理论上不受限制，但是正常的处理过程中需要控制线程的数量。


