### NSOperationQueue其他用法

#### NSOperationQueue 控制串行执行、并发执行

这里有个关键属性 `maxConcurrentOperationCount`，叫做**最大并发操作数**。用来控制一个特定队列中可以有多少个操作同时参与并发执行。

注意：这里 `maxConcurrentOperationCount` 控制的不是并发线程的数量，而是一个队列中同时能并发执行的最大操作数。而且一个操作也并非只能在一个线程中运行。

最大并发操作数：`maxConcurrentOperationCount`

- `maxConcurrentOperationCount` 默认情况下为-1，表示不进行限制，可进行并发执行。
- `maxConcurrentOperationCount` 为1时，队列为串行队列。只能串行执行。
- `maxConcurrentOperationCount` 大于1时，队列为并发队列。操作并发执行，当然这个值不应超过系统限制，即使自己设置一个很大的值，系统也会自动调整为 min{自己设定的值，系统设定的默认最大值}。

```objective-c
/**
 * 设置 MaxConcurrentOperationCount（最大并发操作数）
 */
- (void)setMaxConcurrentOperationCount {

    // 1.创建队列
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];

    // 2.设置最大并发操作数
    queue.maxConcurrentOperationCount = 1; // 串行队列
// queue.maxConcurrentOperationCount = 2; // 并发队列
// queue.maxConcurrentOperationCount = 8; // 并发队列

    // 3.添加操作
    [queue addOperationWithBlock:^{
        for (int i = 0; i < 2; i++) {
            [NSThread sleepForTimeInterval:2]; // 模拟耗时操作
            NSLog(@"1---%@", [NSThread currentThread]);//打印当前线程
        }
    }];
    [queue addOperationWithBlock:^{
        for (int i = 0; i < 2; i++) {
            [NSThread sleepForTimeInterval:2]; // 模拟耗时操作
            NSLog(@"2---%@", [NSThread currentThread]);//打印当前线程
        }
    }];
    [queue addOperationWithBlock:^{
        for (int i = 0; i < 2; i++) {
            [NSThread sleepForTimeInterval:2]; // 模拟耗时操作
            NSLog(@"3---%@", [NSThread currentThread]);//打印当前线程
        }
    }];
    [queue addOperationWithBlock:^{
        for (int i = 0; i < 2; i++) {
            [NSThread sleepForTimeInterval:2]; // 模拟耗时操作
            NSLog(@"4---%@", [NSThread currentThread]);//打印当前线程
        }
    }];
}

打印：

最大并发操作数为1 输出结果：
1---{number = 3,name = (null)}
1---{number = 3,name = (null)}
2---{number = 4,name = (null)}
2---{number = 4,name = (null)}
3---{number = 3,name = (null)}
3---{number = 3,name = (null)}
4---{number = 4,name = (null)}
4---{number = 4,name = (null)}

最大并发操作数为2 输出结果：
1---{number = 3,name = (null)}
2---{number = 4,name = (null)}
2---{number = 4,name = (null)}
1---{number = 3,name = (null)}
4---{number = 5,name = (null)}
3---{number = 6,name = (null)}
4---{number = 5,name = (null)}
3---{number = 6,name = (null)}
```

**可以看出：当最大并发操作数为1时，操作是按顺序串行执行的，并且一个操作完成之后，下一个操作才开始执行。当最大操作并发数为2时，操作是并发执行的，可以同时执行两个操作。而开启线程数量是由系统决定的，不需要我们来管理。**

### NSOperation 操作依赖

通过操作依赖，我们可以很方便的控制操作之间的执行先后顺序。NSOperation 提供了3个接口供我们管理和查看依赖。

- `- (void)addDependency:(NSOperation *)op;` 添加依赖，使当前操作依赖于操作 op 的完成。
- `- (void)removeDependency:(NSOperation *)op;` 移除依赖，取消当前操作对操作 op 的依赖。
- `@property (readonly, copy) NSArray<NSOperation *> *dependencies;` 在当前操作开始执行之前完成执行的所有操作对象数组。

```objective-c
/**
 * 操作依赖
 * 使用方法：addDependency:
 */
- (void)addDependency {

    // 1.创建队列
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];

    // 2.创建操作
    NSBlockOperation *op1 = [NSBlockOperation blockOperationWithBlock:^{
        for (int i = 0; i < 2; i++) {
            [NSThread sleepForTimeInterval:2]; // 模拟耗时操作
            NSLog(@"1---%@", [NSThread currentThread]);//打印当前线程
        }
    }];
    NSBlockOperation *op2 = [NSBlockOperation blockOperationWithBlock:^{
        for (int i = 0; i < 2; i++) {
            [NSThread sleepForTimeInterval:2]; // 模拟耗时操作
            NSLog(@"2---%@", [NSThread currentThread]);//打印当前线程
        }
    }];

    // 3.添加依赖
    [op2 addDependency:op1]; // 让op2 依赖于 op1，则先执行op1，在执行op2

    // 4.添加操作到队列中
    [queue addOperation:op1];
    [queue addOperation:op2];
}

打印：
1---{number = 3,name = (null)}
1---{number = 3,name = (null)}
2---{number = 4,name = (null)}
2---{number = 4,name = (null)}
```

**可以看到：通过添加操作依赖，无论运行几次，其结果都是 op1 先执行，op2 后执行。**

### NSOperation 优先级

NSOperation 提供了`queuePriority`（优先级）属性，`queuePriority`属性适用于同一操作队列中的操作，不适用于不同操作队列中的操作。默认情况下，所有新创建的操作对象优先级都是`NSOperationQueuePriorityNormal`。但是我们可以通过`setQueuePriority:`方法来改变当前操作在同一队列中的执行优先级。

```
// 优先级的取值
typedef NS_ENUM(NSInteger, NSOperationQueuePriority) {
    NSOperationQueuePriorityVeryLow = -8L,
    NSOperationQueuePriorityLow = -4L,
    NSOperationQueuePriorityNormal = 0,
    NSOperationQueuePriorityHigh = 4,
    NSOperationQueuePriorityVeryHigh = 8
}
```

**对于添加到队列中的操作，首先进入准备就绪的状态（就绪状态取决于操作之间的依赖关系），然后进入就绪状态的操作的**开始执行顺序**（非结束执行顺序）由操作之间相对的优先级决定（优先级是操作对象自身的属性）。**

**那么，什么样的操作才是进入就绪状态的操作呢？**

- 当一个操作的所有依赖都已经完成时，操作对象通常会进入准备就绪状态，等待执行。

举个例子，现在有4个优先级都是 `NSOperationQueuePriorityNormal`（默认级别）的操作：op1，op2，op3，op4。其中 op3 依赖于 op2，op2 依赖于 op1，即 op3 -> op2 -> op1。现在将这4个操作添加到队列中并发执行。

- 因为 op1 和 op4 都没有需要依赖的操作，所以在 op1，op4 执行之前，就是出于准备就绪状态的操作。
- 而 op3 和 op2 都有依赖的操作，所以 op3 和 op2 都不是准备就绪状态下的操作。

理解了进入就绪状态的操作，那么我们就理解了`queuePriority` 属性的作用对象。

- `queuePriority` 属性决定了**进入准备就绪状态下的操作**之间的开始执行顺序。并且，优先级不能取代依赖关系。
- 如果一个队列中既包含高优先级操作，又包含低优先级操作，并且两个操作都已经准备就绪，那么队列先执行高优先级操作。比如上例中，如果 op1 和 op4 是不同优先级的操作，那么就会先执行优先级高的操作。
- 如果，一个队列中既包含了准备就绪状态的操作，又包含了未准备就绪的操作，未准备就绪的操作优先级比准备就绪的操作优先级高。那么，虽然准备就绪的操作优先级低，也会优先执行。优先级不能取代依赖关系。如果要控制操作间的启动顺序，则必须使用依赖关系。

#### NSOperation、NSOperationQueue 线程间的通信

```objective-c
/**
 * 线程间通信
 */
- (void)communication {

    // 1.创建队列
    NSOperationQueue *queue = [[NSOperationQueue alloc]init];

    // 2.添加操作
    [queue addOperationWithBlock:^{
        // 异步进行耗时操作
        for (int i = 0; i < 2; i++) {
            [NSThread sleepForTimeInterval:2]; // 模拟耗时操作
            NSLog(@"1---%@", [NSThread currentThread]);//打印当前线程
        }

        // 回到主线程
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            // 进行一些 UI 刷新等操作
            for (int i = 0; i < 2; i++) {
                [NSThread sleepForTimeInterval:2]; // 模拟耗时操作
                NSLog(@"2---%@", [NSThread currentThread]);//打印当前线程
            }
        }];
    }];
}

打印：
1---{number = 3,name = (null)}
1---{number = 3,name = (null)}
2---{number = 1,name = main}
2---{number = 1,name = main}
```

#### NSOperation、NSOperationQueue 线程同步和线程安全

- **线程安全**：如果你的代码所在的进程中有多个线程在同时运行，而这些线程可能会同时运行这段代码。如果每次运行结果和单线程运行的结果是一样的，而且其他的变量的值也和预期的是一样的，就是线程安全的。  
  
  若每个线程中对全局变量、静态变量只有读操作，而无写操作，一般来说，这个全局变量是线程安全的；若有多个线程同时执行写操作（更改变量），一般都需要考虑线程同步，否则的话就可能影响线程安全。

- **线程同步**：可理解为线程 A 和 线程 B 一块配合，A 执行到一定程度时要依靠线程 B 的某个结果，于是停下来，示意 B 运行；B 依言执行，再将结果给 A；A 再继续操作。

##### NSOperation、NSOperationQueue 线程安全

线程安全解决方案：可以给线程加锁，在一个线程执行该操作的时候，不允许其他线程进行操作。

iOS 实现线程加锁有很多种方式。@synchronized、 NSLock、NSRecursiveLock、NSCondition、NSConditionLock、pthread_mutex、dispatch_semaphore、OSSpinLock、atomic(property) set/ge等等各种方式。

这里我们使用 NSLock 对象来解决线程同步问题。NSLock 对象可以通过进入锁时调用 lock 方法，解锁时调用 unlock 方法来保证线程安全。

```objective-c
/**
 * 线程安全：使用 NSLock 加锁
 * 初始化火车票数量、卖票窗口(线程安全)、并开始卖票
 */

- (void)initTicketStatusSave {
    NSLog(@"currentThread---%@",[NSThread currentThread]);//打印当前线程

    self.ticketSurplusCount = 50;

    self.lock = [[NSLock alloc] init];  // 初始化 NSLock 对象

    // 1.创建 queue1,queue1 代表北京火车票售卖窗口
    NSOperationQueue *queue1 = [[NSOperationQueue alloc] init];
    queue1.maxConcurrentOperationCount = 1;

    // 2.创建 queue2,queue2 代表上海火车票售卖窗口
    NSOperationQueue *queue2 = [[NSOperationQueue alloc] init];
    queue2.maxConcurrentOperationCount = 1;

    // 3.创建卖票操作 op1
    __weak typeof(self) weakSelf = self;
    NSBlockOperation *op1 = [NSBlockOperation blockOperationWithBlock:^{
        [weakSelf saleTicketSafe];
    }];

    // 4.创建卖票操作 op2
    NSBlockOperation *op2 = [NSBlockOperation blockOperationWithBlock:^{
        [weakSelf saleTicketSafe];
    }];

    // 5.添加操作，开始卖票
    [queue1 addOperation:op1];
    [queue2 addOperation:op2];
}

/**
 * 售卖火车票(线程安全)
 */
- (void)saleTicketSafe {
    while (1) {

        // 加锁
        [self.lock lock];

        if (self.ticketSurplusCount > 0) {
            //如果还有票，继续售卖
            self.ticketSurplusCount--;
            NSLog(@"%@", [NSString stringWithFormat:@"剩余票数:%d 窗口:%@", self.ticketSurplusCount, [NSThread currentThread]]);
            [NSThread sleepForTimeInterval:0.2];
        }

        // 解锁
        [self.lock unlock];

        if (self.ticketSurplusCount <= 0) {
            NSLog(@"所有火车票均已售完");
            break;
        }
    }
}

打印：
[18116:4348091] currentThread—-{number = 1, name = main}
[18116:4348159] 剩余票数：49 窗口：{number = 3, name = (null)}
[18116:4348157] 剩余票数：48 窗口：{number = 4, name = (null)}
[18116:4348159] 剩余票数：47 窗口：{number = 3, name = (null)}
…
[18116:4348157] 剩余票数：2 窗口：{number = 4, name = (null)}
[18116:4348159] 剩余票数：1 窗口：{number = 3, name = (null)}
[18116:4348157] 剩余票数：0 窗口：{number = 4, name = (null)}
[18116:4348159] 所有火车票均已售完
[18116:4348157] 所有火车票均已售完
```

**可以看出：在考虑了线程安全，使用 NSLock 加锁、解锁机制的情况下，得到的票数是正确的，没有出现混乱的情况。我们也就解决了多个线程同步的问题。**

#### NSOperation、NSOperationQueue 常用属性和方法归纳

##### NSOperation 常用属性和方法

1. 取消操作方法
   - `- (void)cancel;`  可取消操作，实质是标记 isCancelled 状态。
2. 判断操作状态方法
   - `- (BOOL)isFinished;`  判断操作是否已经结束。
   - `- (BOOL)isCancelled;`  判断操作是否已经标记为取消。
   - `- (BOOL)isExecuting;`  判断操作是否正在在运行。
   - `- (BOOL)isReady;`  判断操作是否处于准备就绪状态，这个值和操作的依赖关系相关。
3. 操作同步
   - `- (void)waitUntilFinished;`  阻塞当前线程，直到该操作结束。可用于线程执行顺序的同步。
   - `- (void)setCompletionBlock:(void (^)(void))block;`  `completionBlock`  会在当前操作执行完毕时执行 completionBlock。
   - `- (void)addDependency:(NSOperation *)op;`  添加依赖，使当前操作依赖于操作 op 的完成。
   - `- (void)removeDependency:(NSOperation *)op;`  移除依赖，取消当前操作对操作 op 的依赖。
   - `@property (readonly, copy) NSArray<NSOperation *> *dependencies;`  在当前操作开始执行之前完成执行的所有操作对象数组。

##### NSOperationQueue 常用属性和方法

1. 取消/暂停/恢复操作
   - `- (void)cancelAllOperations;`  可以取消队列的所有操作。
   - `- (BOOL)isSuspended;`  判断队列是否处于暂停状态。 YES 为暂停状态，NO 为恢复状态。
   - `- (void)setSuspended:(BOOL)b;`  可设置操作的暂停和恢复，YES 代表暂停队列，NO 代表恢复队列。
2. 操作同步
   - `- (void)waitUntilAllOperationsAreFinished;`  阻塞当前线程，直到队列中的操作全部执行完毕。
3. 添加/获取操作`
   - `- (void)addOperationWithBlock:(void (^)(void))block;`  向队列中添加一个 NSBlockOperation 类型操作对象。
   - `- (void)addOperations:(NSArray *)ops waitUntilFinished:(BOOL)wait;`  向队列中添加操作数组，wait 标志是否阻塞当前线程直到所有操作结束
   - `- (NSArray *)operations;`  当前在队列中的操作数组（某个操作执行结束后会自动从这个数组清除）。
   - `- (NSUInteger)operationCount;`  当前队列中的操作数。
4. 获取队列
   - `+ (id)currentQueue;`  获取当前队列，如果当前线程不是在 NSOperationQueue 上运行则返回 nil。
   - `+ (id)mainQueue;`  获取主队列。

注意：

1. 这里的暂停和取消（包括操作的取消和队列的取消）并不代表可以将当前的操作立即取消，而是当当前的操作执行完毕之后不再执行新的操作。

2. 暂停和取消的区别就在于：暂停操作之后还可以恢复操作，继续向下执行；而取消操作之后，所有的操作就清空了，无法再接着执行剩下的操作。
