##### NSOperation



**为什么要使用 NSOperation、NSOperationQueue？**

1. 可添加完成的代码块，在操作完成后执行。
2. 添加操作之间的依赖关系，方便的控制执行顺序。
3. 设定操作执行的优先级。
4. 可以很方便的取消一个操作的执行。
5. 使用 KVO 观察对操作执行状态的更改：isExecuteing、isFinished、isCancelled。



NSOperation是一个抽象类，实际开发中需要使用其子类NSInvocationOperation、NSBlockOperation。首先创建一个NSOperationQueue，再建多个NSOperation实例（设置好要处理的任务、operation的属性和依赖关系等），然后再将这些operation放到这个queue中，线程就会被依次启动。



##### NSOperation

```
//// NSOperation
@property (readonly, getter=isCancelled) BOOL cancelled;
@property (readonly, getter=isExecuting) BOOL executing;
@property (readonly, getter=isFinished) BOOL finished;
@property (readonly, getter=isReady) BOOL ready;

@property NSOperationQueuePriority queuePriority;
@property (readonly, copy) NSArray<NSOperation *> *dependencies;

@property (nullable, copy) NSString *name;
@property (nullable, copy) void (^completionBlock)(void);

- (void)start;
- (void)main;
- (void)cancel;

- (void)addDependency:(NSOperation *)op;
- (void)removeDependency:(NSOperation *)op;

- (void)waitUntilFinished;
```



##### NSInvocationOperation

```
@interface NSInvocationOperation : NSOperation {
@private
    id _inv;
    id _exception;
    void *_reserved2;
}

- (nullable instancetype)initWithTarget:(id)target selector:(SEL)sel object:(nullable id)arg;
- (instancetype)initWithInvocation:(NSInvocation *)inv NS_DESIGNATED_INITIALIZER;

@property (readonly, retain) NSInvocation *invocation;

@property (nullable, readonly, retain) id result;
```

```
示例：
//    创建一个调用操作
    NSInvocationOperation *invocatioinOperation = [[NSInvocationOperation alloc]initWithTarget:self selector:@selector(loadImage) object:nil];
    
    //创建完NSInvocationOperation对象并不会调用，它由一个start方法启动操作，但是注意如果直接调用start方法，则此操作会在主线程中调用，一般不会这么操作,而是添加到NSOperationQueue中
    //[invocatioinOperation start];
    
    //创建操作队列
    NSOperationQueue *operationQueue = [[NSOperationQueue alloc]init];
    //注意添加到操作队后，队列会开启一个线程执行此操作
    [operationQueue addOperation:invocatioinOperation];
```



#### NSBlockOperation

```
    NSOperationQueue *operationQueue = [[NSOperationQueue alloc]init];
    operationQueue.maxConcurrentOperationCount = 5;
    
    //第1种方式：直接使用操队列添加操作
//    [operationQueue addOperationWithBlock:^{
//         [self loadImage];
//    }];
    
    //第2种：创建操作块添加到队列
    NSBlockOperation *blockOperation = [NSBlockOperation blockOperationWithBlock:^{
        [self loadImage];
    }];
    [operationQueue addOperation:blockOperation];
    
打印：
currentThread---<NSThread: 0x60000007f9c0>{number = 3, name = (null)}
    
```

#### NSOperation中的依赖





#### 关于自定义封装NSOperation

我们用到的很多三方库都自定义封装NSOperation，如MKNetworkOperation、SDWebImage等。自定义封装抽象类NSOperation只需要重写其中的main或start方法，在多线程执行任务的过程中需要注意线程安全问题，我们还可以通过KVO监听isCancelled、isExecuting、isFinished等属性，确切的回调当前任务的状态





补充：

1. NSOperationQueue的maxConcurrentOperationCount一般设置在5个以内，数量过多可能会有性能问题。maxConcurrentOperationCount为1时，队列中的任务串行执行，maxConcurrentOperationCount大于1时，队列中的任务并发执行;
2. 不同的NSOperation实例之间可以设置依赖关系，不同queue的NSOperation之间也可以创建依赖关系 ，但是要注意不要“循环依赖”；
3. NSOperation实例之间设置依赖关系应该在加入队列之前；
4. 在没有使用 NSOperationQueue时，在主线程中单独使用 NSBlockOperation 执行（start）一个操作的情况下，操作是在当前线程执行的，并没有开启新线程，在其他线程中也一样；
5. NSOperationQueue可以直接获取mainQueue，更新界面UI应该在mainQueue中进行；
6. 区别自定义封装NSOperation时，重写main或start方法的不同；
7. 自定义封装NSOperation时需要我们完全重载start，在start方法里面，我们还要查看isCanceled属性，确保start一个operation前，task是没有被取消的。如果我们自定义了dependency，我们还需要发送isReady的KVO通知。


