##### GCD其他用法

##### 6.1 GCD 栅栏方法：dispatch_barrier_async

我们有时需要异步执行两组操作，而且第一组操作执行完之后，才能开始执行第二组操作。

这样我们就需要一个相当于 `栅栏` 一样的一个方法将两组异步执行的操作组给分割起来，当然这里的操作组里可以包含一个或多个任务。这就需要用到`dispatch_barrier_async` 方法在两个操作组间形成栅栏。  

`dispatch_barrier_async` 方法会等待前边追加到并发队列中的任务全部执行完毕之后，再将指定的任务追加到该异步队列中。然后在 `dispatch_barrier_async` 方法追加的任务执行完毕之后，异步队列才恢复为一般动作，接着追加任务到该异步队列并开始执行。具体如下图所示：

```
/**
 * 栅栏方法 dispatch_barrier_async
 */
- (void)barrier {
    dispatch_queue_t queue = dispatch_queue_create("net.bujige.testQueue", DISPATCH_QUEUE_CONCURRENT);

    dispatch_async(queue, ^{
        // 追加任务 1
        [NSThread sleepForTimeInterval:2]; // 模拟耗时操作
        NSLog(@"1---%@",[NSThread currentThread]);  // 打印当前线程
    });
    dispatch_async(queue, ^{
        // 追加任务 2
        [NSThread sleepForTimeInterval:2];  // 模拟耗时操作
        NSLog(@"2---%@",[NSThread currentThread]); //打印当前线程
    });

    dispatch_barrier_async(queue, ^{
        // 追加任务 barrier
        [NSThread sleepForTimeInterval:2];  // 模拟耗时操作
        NSLog(@"barrier---%@",[NSThread currentThread]);//打印当线程
    });

    dispatch_async(queue, ^{
        // 追加任务 3
        [NSThread sleepForTimeInterval:2];// 模拟耗时操作
        NSLog(@"3---%@",[NSThread currentThread]);// 打印当前线程
    });
    dispatch_async(queue, ^{
        // 追加任务 4
        [NSThread sleepForTimeInterval:2]; // 模拟耗时操作
        NSLog(@"4---%@",[NSThread currentThread]);// 打印当前线程
    });
}

打印：
[17648:4262933] 1—-{number = 3, name = (null)}
[17648:4262932] 2—-{number = 4, name = (null)}
[17648:4262933] barrier—-{number = 3, name = (null)}
[17648:4262932] 4—-{number = 4, name = (null)}
[17648:4262933] 3—-{number = 3, name = (null)}
```

```
在 dispatch_barrier_async 执行结果中可以看出：

在执行完栅栏前面的操作之后，才执行栅栏操作，最后再执行栅栏后边的操作。
```

##### 6.2 GCD 延时执行方法：dispatch_after

```
dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        // 2.0 秒后异步追加任务代码到主队列，并开始执行
        NSLog(@"after---%@",[NSThread currentThread]);  
    });
```

##### 6.3 GCD 一次性代码（只执行一次）：dispatch_once

我们在创建单例、或者有整个程序运行过程中只执行一次的代码时，我们就用到了 GCD 的 `dispatch_once` 方法。

使用 `dispatch_once` 方法能保证某段代码在程序运行过程中只被执行 1 次，并且即使在多线程的环境下，`dispatch_once` 也可以保证线程安全。

```
- (void)once {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        // 只执行 1 次的代码（这里面默认是线程安全的）
    });
}
```

##### 6.4 GCD 快速迭代方法：dispatch_apply

通常我们会用 for 循环遍历，但是 GCD 给我们提供了快速迭代的方法 `dispatch_apply`。

`dispatch_apply` 按照指定的次数将指定的任务追加到指定的队列中，并等待全部队列执行结束。

如果是在串行队列中使用  `dispatch_apply`，那么就和 for 循环一样，按顺序同步执行。但是这样就体现不出快速迭代的意义了。

我们可以利用并发队列进行异步执行。比如说遍历 0~5 这 6 个数字，for 循环的做法是每次取出一个元素，逐个遍历。`dispatch_apply`  可以 在多个线程中同时（异步）遍历多个数字。

还有一点，无论是在串行队列，还是并发队列中，dispatch_apply 都会等待全部任务执行完毕，这点就像是同步操作，也像是队列组中的 `dispatch_group_wait`方法。

```
- (void)apply {
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);

    NSLog(@"apply---begin");
    dispatch_apply(6, queue, ^(size_t index) {
        NSLog(@"%zd---%@",index, [NSThread currentThread]);
    });
    NSLog(@"apply---end");
}

打印：
[17771:4285619] apply—-begin
[17771:4285619] 0—-{number = 1, name = main}
[17771:4285722] 1—-{number = 3, name = (null)}
[17771:4285720] 3—-{number = 5, name = (null)}
[17771:4285721] 2—-{number = 7, name = (null)}
[17771:4285719] 4—-{number = 6, name = (null)}
[17771:4285728] 5—-{number = 4, name = (null)}
[17771:4285619] apply—-end

因为是在并发队列中异步执行任务，所以各个任务的执行时间长短不定，最后结束顺序也不定。但是 apply---end 一定在最后执行。这是因为 dispatch_apply 方法会等待全部任务执行完毕。
```

##### 6.5 GCD 队列组：dispatch_group

有时候我们会有这样的需求：分别异步执行2个耗时任务，然后当2个耗时任务都执行完毕后再回到主线程执行任务。这时候我们可以用到 GCD 的队列组。

- 调用队列组的  `dispatch_group_async`  先把任务放到队列中，然后将队列放入队列组中。或者使用队列组的  `dispatch_group_enter`、`dispatch_group_leave`  组合来实现  `dispatch_group_async`。

- 调用队列组的  `dispatch_group_notify`  回到指定线程执行任务。或者使用  `dispatch_group_wait`  回到当前线程继续向下执行（会阻塞当前线程）。

##### 

##### 6.5.1 dispatch_group_notify

监听 group 中任务的完成状态，当所有的任务都执行完成后，追加任务到 group 中，并执行任务

```
- (void)groupNotify {
    NSLog(@"currentThread---%@",[NSThread currentThread]);  
    NSLog(@"group---begin");

    dispatch_group_t group =  dispatch_group_create();

    dispatch_group_async(group, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        // 追加任务 1
        [NSThread sleepForTimeInterval:2];  // 模拟耗时操作
        NSLog(@"1---%@",[NSThread currentThread]); // 打印当前线程
    });

    dispatch_group_async(group, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        // 追加任务 2
        [NSThread sleepForTimeInterval:2];  // 模拟耗时操作
        NSLog(@"2---%@",[NSThread currentThread]); // 打印当前线程
    });

    dispatch_group_notify(group, dispatch_get_main_queue(), ^{
        // 等前面的异步任务 1、任务 2 都执行完毕后，回到主线程执行下边任务
        [NSThread sleepForTimeInterval:2]; // 模拟耗时操作
        NSLog(@"3---%@",[NSThread currentThread]); // 打印当前线程

        NSLog(@"group---end");
    });
}

打印：
[17813:4293874] currentThread—-{number = 1, name = main}
[17813:4293874] group—-begin
[17813:4294048] 2—-{number = 4, name = (null)}
[17813:4294053] 1—-{number = 3, name = (null)}
[17813:4293874] 3—-{number = 1, name = main}
[17813:4293874] group—-end

从 dispatch_group_notify 相关代码运行输出结果可以看出：
当所有任务都执行完成之后，才执行 dispatch_group_notify 相关 block 中的任务。
```

##### 6.5.2 dispatch_group_wait

暂停当前线程（阻塞当前线程），等待指定的 group 中的任务执行完成后，才会往下继续执行。

```
- (void)groupWait {
    NSLog(@"currentThread---%@",[NSThread currentThread]); 
    NSLog(@"group---begin");

    dispatch_group_t group =  dispatch_group_create();

    dispatch_group_async(group, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        // 追加任务 1
        [NSThread sleepForTimeInterval:2];  // 模拟耗时操作
        NSLog(@"1---%@",[NSThread currentThread]); // 打印当前线程
    });

    dispatch_group_async(group, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        // 追加任务 2
        [NSThread sleepForTimeInterval:2];  // 模拟耗时操作
        NSLog(@"2---%@",[NSThread currentThread]); // 打印当前线程
    });

    // 等待上面的任务全部完成后，会往下继续执行（会阻塞当前线程）
    dispatch_group_wait(group, DISPATCH_TIME_FOREVER);

    NSLog(@"group---end");

}

打印：
[17844:4299926] currentThread—-{number = 1, name = main}
[17844:4299926] group—-begin
[17844:4300046] 2—-{number = 4, name = (null)}
[17844:4300043] 1—-{number = 3, name = (null)}
[17844:4299926] group—-end

从 dispatch_group_wait 相关代码运行输出结果可以看出：
当所有任务执行完成之后，才执行 dispatch_group_wait 之后的操作。但是，使用dispatch_group_wait 会阻塞当前线程。
```

##### 6.5.3 dispatch_group_enter、dispatch_group_leave

- `dispatch_group_enter`  标志着一个任务追加到 group，执行一次，相当于 group 中未执行完毕任务数 +1
- `dispatch_group_leave`  标志着一个任务离开了 group，执行一次，相当于 group 中未执行完毕任务数 -1。
- 当 group 中未执行完毕任务数为0的时候，才会使  `dispatch_group_wait`  解除阻塞，以及执行追加到  `dispatch_group_notify`  中的任务。

```
- (void)groupEnterAndLeave {
    NSLog(@"currentThread---%@",[NSThread currentThread]);  
    NSLog(@"group---begin");

    dispatch_group_t group = dispatch_group_create();
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_group_enter(group);
    dispatch_async(queue, ^{
        // 追加任务 1
        [NSThread sleepForTimeInterval:2];  // 模拟耗时操作
        NSLog(@"1---%@",[NSThread currentThread]); // 打印当前线程

        dispatch_group_leave(group);
    });

    dispatch_group_enter(group);
    dispatch_async(queue, ^{
        // 追加任务 2
        [NSThread sleepForTimeInterval:2]; // 模拟耗时操作
        NSLog(@"2---%@",[NSThread currentThread]);// 打印当前线程

        dispatch_group_leave(group);
    });

    dispatch_group_notify(group, dispatch_get_main_queue(), ^{
        // 等前面的异步操作都执行完毕后，回到主线程.
        [NSThread sleepForTimeInterval:2];   // 模拟耗时操作
        NSLog(@"3---%@",[NSThread currentThread]);// 打印当前线程

        NSLog(@"group---end");
    });
}

打印：
[17924:4314716] currentThread—-{number = 1, name = main}
[17924:4314716] group—-begin
[17924:4314816] 2—-{number = 3, name = (null)}
[17924:4314808] 1—-{number = 4, name = (null)}
[17924:4314716] 3—-{number = 1, name = main}
[17924:4314716] group—-end

从 dispatch_group_enter、dispatch_group_leave 相关代码运行结果中可以看出：当所有任务执行完成之后，才执行 dispatch_group_notify 中的任务。这里的dispatch_group_enter、dispatch_group_leave 组合，其实等同于dispatch_group_async。
```

##### 6.6 GCD 信号量：dispatch_semaphore

GCD 中的信号量是指 **Dispatch Semaphore**，是持有计数的信号。

类似于过高速路收费站的栏杆。可以通过时，打开栏杆，不可以通过时，关闭栏杆。在 **Dispatch Semaphore** 中，使用计数来完成这个功能，计数小于 0 时等待，不可通过。计数为 0 或大于 0 时，计数减 1 且不等待，可通过。

**Dispatch Semaphore**  提供了三个方法：

- `dispatch_semaphore_create`：创建一个 Semaphore 并初始化信号的总量
- `dispatch_semaphore_signal`：发送一个信号，让信号总量加 1
- `dispatch_semaphore_wait`：可以使总信号量减 1，信号总量小于 0 时就会一直等待（阻塞所在线程），否则就可以正常执行。

注意：信号量的使用前提是：想清楚你需要处理哪个线程等待（阻塞），又要哪个线程继续执行，然后使用信号量。

Dispatch Semaphore 在实际开发中主要用于：

- 保持线程同步，将异步执行任务转换为同步执行任务
- 保证线程安全，为线程加锁
