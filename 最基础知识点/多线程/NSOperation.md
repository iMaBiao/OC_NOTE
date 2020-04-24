##### NSOperation

[iOS 多线程：『NSOperation、NSOperationQueue』详尽总结](https://bujige.net/blog/iOS-Complete-learning-NSOperation.html)

#### 1、 NSOperation、NSOperationQueue 简介

NSOperation、NSOperationQueue 是苹果提供给我们的一套多线程解决方案。实际上 NSOperation、NSOperationQueue 是基于 GCD 更高一层的封装，完全面向对象。但是比 GCD 更简单易用、代码可读性也更高。

**为什么要使用 NSOperation、NSOperationQueue？**

1. 可添加完成的代码块，在操作完成后执行。
2. 添加操作之间的依赖关系，方便的控制执行顺序。
3. 设定操作执行的优先级。
4. 可以很方便的取消一个操作的执行。
5. 使用 KVO 观察对操作执行状态的更改：isExecuteing、isFinished、isCancelled。

NSOperation是一个抽象类，实际开发中需要使用其子类NSInvocationOperation、NSBlockOperation。首先创建一个NSOperationQueue，再建多个NSOperation实例（设置好要处理的任务、operation的属性和依赖关系等），然后再将这些operation放到这个queue中，线程就会被依次启动。

#### 2. NSOperation、NSOperationQueue 操作和操作队列

既然是基于 GCD 的更高一层的封装。那么，GCD 中的一些概念同样适用于 NSOperation、NSOperationQueue。在 NSOperation、NSOperationQueue 中也有类似的**任务（操作）**和**队列（操作队列）**的概念。

- **操作（Operation）：**
  - 执行操作的意思，换句话说就是你在线程中执行的那段代码。
  - 在 GCD 中是放在 block 中的。在 NSOperation 中，我们使用 NSOperation 子类**NSInvocationOperation**、**NSBlockOperation**，或者**自定义子类**来封装操作。
- **操作队列（Operation Queues）：**
  - 这里的队列指操作队列，即用来存放操作的队列。不同于 GCD 中的调度队列 FIFO（先进先出）的原则。NSOperationQueue 对于添加到队列中的操作，首先进入准备就绪的状态（就绪状态取决于操作之间的依赖关系），然后进入就绪状态的操作的**开始执行顺序**（非结束执行顺序）由操作之间相对的优先级决定（优先级是操作对象自身的属性）。
  - 操作队列通过设置**最大并发操作数（maxConcurrentOperationCount）**来控制并发、串行。
  - NSOperationQueue 为我们提供了两种不同类型的队列：主队列和自定义队列。主队列运行在主线程之上，而自定义队列在后台执行。

#### 3. NSOperation、NSOperationQueue 使用步骤

NSOperation 需要配合 NSOperationQueue 来实现多线程。因为默认情况下，NSOperation 单独使用时系统同步执行操作，配合 NSOperationQueue 我们能更好的实现异步执行。

NSOperation 实现多线程的使用步骤分为三步：

1. 创建操作：先将需要执行的操作封装到一个 NSOperation 对象中。
2. 创建队列：创建 NSOperationQueue 对象。
3. 将操作加入到队列中：将 NSOperation 对象添加到 NSOperationQueue 对象中。

之后呢，系统就会自动将 NSOperationQueue 中的 NSOperation 取出来，在新线程中执行操作。

#### 4. NSOperation 和 NSOperationQueue 基本使用

##### 4.1 创建操作

NSOperation 是个抽象类，不能用来封装操作。我们只有使用它的子类来封装操作。我们有三种方式来封装操作。

1. 使用子类 NSInvocationOperation
2. 使用子类 NSBlockOperation
3. 自定义继承自 NSOperation 的子类，通过实现内部相应的方法来封装操作。

在不使用 NSOperationQueue，单独使用 NSOperation 的情况下系统同步执行操作，下面我们学习以下操作的三种创建方式。

###### 4.1.1 使用子类`NSInvocationOperation`

```
 - (void)invocationOperation
{
//    创建一个调用操作
    NSInvocationOperation *invocatioinOperation = [[NSInvocationOperation alloc]initWithTarget:self selector:@selector(loadImage) object:nil];
    [invocatioinOperation start];
}

- (void)loadImage
{
    NSLog(@"currentThread---%@",[NSThread currentThread]);
}

打印：
currentThread---<NSThread: 0x600000075bc0>{number = 1, name = main}

可以看到：在没有使用 NSOperationQueue、在主线程中单独使用使用子类 NSInvocationOperation 执行一个操作的情况下，操作是在当前线程执行的，并没有开启新线程。

但如果在其他线程中执行操作，则打印结果为其他线程。

可以看出：在其他线程中单独使用子类 NSInvocationOperation，操作是在当前调用的其他线程执行的，并没有开启新线程。
```

###### 4.1.2 使用子类`NSBlockOperation`

```
- (void)blockOperation
{
    NSBlockOperation *blockOperation = [NSBlockOperation blockOperationWithBlock:^{
        [self loadImage];
    }];

    [blockOperation start];
}
打印：
currentThread---<NSThread: 0x600000068540>{number = 1, name = main}
```

可以看出：在没有使用 NSOperationQueue、在主线程中单独使用 NSBlockOperation 执行一个操作的情况下，操作是在当前线程执行的，并没有开启新线程。

和上边 NSInvocationOperation 使用一样。因为代码是在主线程中调用的，所以打印结果为主线程。如果在其他线程中执行操作，则打印结果为其他线程。

如果用 addExecutionBlock: 添加多个任务：

```
- (void)useBlockOperationAddExecutionBlock
{
    NSBlockOperation *blockOperation = [NSBlockOperation blockOperationWithBlock:^{
        for (int i = 0; i < 2; i++) {
            [NSThread sleepForTimeInterval:2]; // 模拟耗时操作
            NSLog(@"1---%@", [NSThread currentThread]); // 打印当前线程
        }
    }];

    [blockOperation addExecutionBlock:^{
        for (int i = 0; i < 2; i++) {
            [NSThread sleepForTimeInterval:2]; // 模拟耗时操作
            NSLog(@"2---%@", [NSThread currentThread]); // 打印当前线程
        }
    }];

    [blockOperation addExecutionBlock:^{
        for (int i = 0; i < 2; i++) {
            [NSThread sleepForTimeInterval:2]; // 模拟耗时操作
            NSLog(@"3---%@", [NSThread currentThread]); // 打印当前线程
        }
    }];

    [blockOperation addExecutionBlock:^{
        for (int i = 0; i < 2; i++) {
            [NSThread sleepForTimeInterval:2]; // 模拟耗时操作
            NSLog(@"4---%@", [NSThread currentThread]); // 打印当前线程
        }
    }];

    [blockOperation start];
}

打印：
2---<NSThread: 0x60400026f880>{number = 4, name = (null)}
4---<NSThread: 0x600000274600>{number = 5, name = (null)}
3---<NSThread: 0x600000274540>{number = 3, name = (null)}
1---<NSThread: 0x6040000659c0>{number = 1, name = main}
2---<NSThread: 0x60400026f880>{number = 4, name = (null)}
3---<NSThread: 0x600000274540>{number = 3, name = (null)}
1---<NSThread: 0x6040000659c0>{number = 1, name = main}
4---<NSThread: 0x600000274600>{number = 5, name = (null)}
```

可以看出：使用子类 `NSBlockOperation`，并调用方法 `AddExecutionBlock:` 的情况下，`blockOperationWithBlock:`方法中的操作 和 `addExecutionBlock:` 中的操作是在不同的线程中异步执行的。而且，这次执行结果中 `blockOperationWithBlock:`方法中的操作也不是在当前线程（主线程）中执行的。从而印证了`blockOperationWithBlock:` 中的操作也可能会在其他线程（非当前线程）中执行。

一般情况下，如果一个 NSBlockOperation 对象封装了多个操作。NSBlockOperation 是否开启新线程，取决于操作的个数。如果添加的操作的个数多，就会自动开启新线程。当然开启的线程数是由系统来决定的。

###### 4.1.3 使用自定义继承自 NSOperation 的子类

如果使用子类 NSInvocationOperation、NSBlockOperation 不能满足日常需求，我们可以使用自定义继承自 NSOperation 的子类。可以通过重写`main`或者`start`方法 来定义自己的 NSOperation 对象。重写`main`方法比较简单，我们不需要管理操作的状态属性`isExecuting`和`isFinished`。当`main`执行完返回的时候，这个操作就结束了。

```
#import "MBOperation.h"

@implementation MBOperation

- (void)main
{
    if (!self.isCancelled) {
        for (int i = 0; i < 2; i++) {
            [NSThread sleepForTimeInterval:2];
            NSLog(@"1---%@", [NSThread currentThread]);
        }
    }
}
@end

使用

- (void)userCustomOperation
{
    MBOperation *op = [[MBOperation alloc]init];
    [op start];
}

打印：
1---<NSThread: 0x60400006d080>{number = 1, name = main}
1---<NSThread: 0x60400006d080>{number = 1, name = main}
```

- 可以看出：在没有使用 NSOperationQueue、在主线程单独使用自定义继承自 NSOperation 的子类的情况下，是在主线程执行操作，并没有开启新线程。

##### 4.2 创建队列

NSOperationQueue 一共有两种队列：主队列、自定义队列。其中自定义队列同时包含了串行、并发功能。下边是主队列、自定义队列的基本创建方法和特点。

主队列

- 凡是添加到主队列中的操作，都会放到主线程中执行。

// 主队列获取方法  
NSOperationQueue *queue = [NSOperationQueue mainQueue];

自定义队列（非主队列）

- 添加到这种队列中的操作，就会自动放到子线程中执行。
- 同时包含了：串行、并发功能。

// 自定义队列创建方法  
NSOperationQueue *queue = [[NSOperationQueue alloc] init];

##### 4.3 将操作加入到队列中

`- (void)addOperation:(NSOperation *)op;`

- 需要先创建操作，再将创建好的操作加入到创建好的队列中去。

```
- (void)addOperationToQueue
{
//    创建队列
    NSOperationQueue *queue = [[NSOperationQueue alloc]init];

//    创建操作
    NSInvocationOperation *op1 = [[NSInvocationOperation alloc]initWithTarget:self selector:@selector(task1) object:nil];
    NSInvocationOperation *op2 = [[NSInvocationOperation alloc]initWithTarget:self selector:@selector(task2) object:nil];

    NSBlockOperation *op3 = [NSBlockOperation blockOperationWithBlock:^{
        for (int i = 0; i < 2; i++) {
            [NSThread sleepForTimeInterval:2]; // 模拟耗时操作
            NSLog(@"3---%@", [NSThread currentThread]); // 打印当前线程
        }
    }];
    [op3 addExecutionBlock:^{
        for (int i = 0; i < 2; i++) {
            [NSThread sleepForTimeInterval:2]; // 模拟耗时操作
            NSLog(@"4---%@", [NSThread currentThread]); // 打印当前线程
        }
    }];

    [queue addOperation:op1];
    [queue addOperation:op2];
    [queue addOperation:op3];
}

打印：
2---<NSThread: 0x60400046c000>{number = 3, name = (null)}
3---<NSThread: 0x60400046df80>{number = 5, name = (null)}
1---<NSThread: 0x600000274000>{number = 4, name = (null)}
4---<NSThread: 0x60400046e100>{number = 6, name = (null)}
4---<NSThread: 0x60400046e100>{number = 6, name = (null)}
1---<NSThread: 0x600000274000>{number = 4, name = (null)}
3---<NSThread: 0x60400046df80>{number = 5, name = (null)}
2---<NSThread: 0x60400046c000>{number = 3, name = (null)}

可以看出：使用 NSOperation 子类创建操作，并使用 addOperation: 将操作加入到操作队列后能够开启新线程，进行并发执行。
```

`- (void)addOperationWithBlock:(void (^)(void))block;`

- 无需先创建操作，在 block 中添加操作，直接将包含操作的 block 加入到队列中。

```
- (void)addOperationWithBlockToQueue
{
    NSOperationQueue *queue = [[NSOperationQueue alloc]init];

    [queue addOperationWithBlock:^{
        for (int i = 0; i < 2; i++) {
            [NSThread sleepForTimeInterval:2]; // 模拟耗时操作
            NSLog(@"1---%@", [NSThread currentThread]); // 打印当前线程
        }
    }];

    [queue addOperationWithBlock:^{
        for (int i = 0; i < 2; i++) {
            [NSThread sleepForTimeInterval:2]; // 模拟耗时操作
            NSLog(@"2---%@", [NSThread currentThread]); // 打印当前线程
        }
    }];

    [queue addOperationWithBlock:^{
        for (int i = 0; i < 2; i++) {
            [NSThread sleepForTimeInterval:2]; // 模拟耗时操作
            NSLog(@"3---%@", [NSThread currentThread]); // 打印当前线程
        }
    }];
}

打印：
2---<NSThread: 0x604000465680>{number = 5, name = (null)}
3---<NSThread: 0x604000465600>{number = 4, name = (null)}
1---<NSThread: 0x600000077f40>{number = 3, name = (null)}
3---<NSThread: 0x604000465600>{number = 4, name = (null)}
1---<NSThread: 0x600000077f40>{number = 3, name = (null)}
2---<NSThread: 0x604000465680>{number = 5, name = (null)}

可以看出：使用 addOperationWithBlock: 将操作加入到操作队列后能够开启新线程，进行并发执行。
```

#### 5. NSOperationQueue 控制串行执行、并发执行

这里有个关键属性`maxConcurrentOperationCount`，叫做**最大并发操作数**。用来控制一个特定队列中可以有多少个操作同时参与并发执行。

注意：这里`maxConcurrentOperationCount`控制的不是并发线程的数量，而是一个队列中同时能并发执行的最大操作数。而且一个操作也并非只能在一个线程中运行。

最大并发操作数：`maxConcurrentOperationCount`

- `maxConcurrentOperationCount`默认情况下为-1，表示不进行限制，可进行并发执行。
- `maxConcurrentOperationCount`为1时，队列为串行队列。只能串行执行。
- `maxConcurrentOperationCount`大于1时，队列为并发队列。操作并发执行，当然这个值不应超过系统限制，即使自己设置一个很大的值，系统也会自动调整为 min{自己设定的值，系统设定的默认最大值}。

```
    NSOperationQueue *queue = [[NSOperationQueue alloc]init];

    // 设置最大并发操作数
    queue.maxConcurrentOperationCount = 1; // 串行队列
    // queue.maxConcurrentOperationCount = 2; // 并发队列
    // queue.maxConcurrentOperationCount = 8; // 并发队列


    [queue addOperationWithBlock:^{
        for (int i = 0; i < 2; i++) {
            [NSThread sleepForTimeInterval:2]; // 模拟耗时操作
            NSLog(@"1---%@", [NSThread currentThread]); // 打印当前线程
        }
    }];

    [queue addOperationWithBlock:^{
        for (int i = 0; i < 2; i++) {
            [NSThread sleepForTimeInterval:2]; // 模拟耗时操作
            NSLog(@"2---%@", [NSThread currentThread]); // 打印当前线程
        }
    }];

    [queue addOperationWithBlock:^{
        for (int i = 0; i < 2; i++) {
            [NSThread sleepForTimeInterval:2]; // 模拟耗时操作
            NSLog(@"3---%@", [NSThread currentThread]); // 打印当前线程
        }
    }];


打印：
 queue.maxConcurrentOperationCount = 1;
1---<NSThread: 0x60400027ba40>{number = 3, name = (null)}
1---<NSThread: 0x60400027ba40>{number = 3, name = (null)}
2---<NSThread: 0x600000276a00>{number = 4, name = (null)}
2---<NSThread: 0x600000276a00>{number = 4, name = (null)}
3---<NSThread: 0x60400027ba40>{number = 3, name = (null)}
3---<NSThread: 0x60400027ba40>{number = 3, name = (null)}


queue.maxConcurrentOperationCount = 2;
2---<NSThread: 0x60000026eec0>{number = 3, name = (null)}
1---<NSThread: 0x60000026f200>{number = 4, name = (null)}
1---<NSThread: 0x60000026f200>{number = 4, name = (null)}
2---<NSThread: 0x60000026eec0>{number = 3, name = (null)}
3---<NSThread: 0x6040004683c0>{number = 5, name = (null)}
3---<NSThread: 0x6040004683c0>{number = 5, name = (null)}


queue.maxConcurrentOperationCount = 8;
3---<NSThread: 0x604000475040>{number = 4, name = (null)}
2---<NSThread: 0x60000027d600>{number = 3, name = (null)}
1---<NSThread: 0x604000475180>{number = 5, name = (null)}
1---<NSThread: 0x604000475180>{number = 5, name = (null)}
3---<NSThread: 0x604000475040>{number = 4, name = (null)}
2---<NSThread: 0x60000027d600>{number = 3, name = (null)}
```

- 可以看出：当最大并发操作数为1时，操作是按顺序串行执行的，并且一个操作完成之后，下一个操作才开始执行。当最大操作并发数为2时，操作是并发执行的，可以同时执行两个操作。而开启线程数量是由系统决定的，不需要我们来管理。

#### 6、 NSOperation中的依赖

NSOperation、NSOperationQueue 最吸引人的地方是它能添加操作之间的依赖关系。通过操作依赖，我们可以很方便的控制操作之间的执行先后顺序。NSOperation 提供了3个接口供我们管理和查看依赖。

- `- (void)addDependency:(NSOperation *)op;`添加依赖，使当前操作依赖于操作 op 的完成。
- `- (void)removeDependency:(NSOperation *)op;`移除依赖，取消当前操作对操作 op 的依赖。
- `@property (readonly, copy) NSArray<NSOperation *> *dependencies;`在当前操作开始执行之前完成执行的所有操作对象数组。

```
- (void)addDependency
{
    NSOperationQueue *queue = [[NSOperationQueue alloc]init];

    NSBlockOperation *op1 = [NSBlockOperation blockOperationWithBlock:^{
        for (int i = 0; i < 2; i++) {
            [NSThread sleepForTimeInterval:2]; // 模拟耗时操作
            NSLog(@"1---%@", [NSThread currentThread]); // 打印当前线程
        }
    }];

    NSBlockOperation *op2 = [NSBlockOperation blockOperationWithBlock:^{
        for (int i = 0; i < 2; i++) {
            [NSThread sleepForTimeInterval:2]; // 模拟耗时操作
            NSLog(@"2---%@", [NSThread currentThread]); // 打印当前线程
        }
    }];

    // 让op2 依赖于 op1，则先执行op1，在执行op2
    [op2 addDependency:op1];

    [queue addOperation:op1];
    [queue addOperation:op2];
}

打印：
1---<NSThread: 0x60000027a180>{number = 3, name = (null)}
1---<NSThread: 0x60000027a180>{number = 3, name = (null)}
2---<NSThread: 0x60000027a780>{number = 4, name = (null)}
2---<NSThread: 0x60000027a780>{number = 4, name = (null)}

可以看到：通过添加操作依赖，无论运行几次，其结果都是 op1 先执行，op2 后执行。
```

#### 7. NSOperation 优先级

NSOperation 提供了`queuePriority`（优先级）属性，`queuePriority`属性适用于同一操作队列中的操作，不适用于不同操作队列中的操作。默认情况下，所有新创建的操作对象优先级都是`NSOperationQueuePriorityNormal`。但是我们可以通过`setQueuePriority:`方法来改变当前操作在同一队列中的执行优先级。

```
// 优先级的取值
typedef NS_ENUM(NSInteger, NSOperationQueuePriority) {
    NSOperationQueuePriorityVeryLow = -8L,
    NSOperationQueuePriorityLow = -4L,
    NSOperationQueuePriorityNormal = 0,
    NSOperationQueuePriorityHigh = 4,
    NSOperationQueuePriorityVeryHigh = 8
};
```

**那么，什么样的操作才是进入就绪状态的操作呢？**

- 当一个操作的所有依赖都已经完成时，操作对象通常会进入准备就绪状态，等待执行。

举个例子，现在有4个优先级都是`NSOperationQueuePriorityNormal`（默认级别）的操作：op1，op2，op3，op4。其中 op3 依赖于 op2，op2 依赖于 op1，即 op3 -> op2 -> op1。现在将这4个操作添加到队列中并发执行。

- 因为 op1 和 op4 都没有需要依赖的操作，所以在 op1，op4 执行之前，就是出于准备就绪状态的操作。
- 而 op3 和 op2 都有依赖的操作（op3 依赖于 op2，op2 依赖于 op1），所以 op3 和 op2 都不是准备就绪状态下的操作。

理解了进入就绪状态的操作，那么我们就理解了`queuePriority`属性的作用对象。

- `queuePriority`属性决定了**进入准备就绪状态下的操作**之间的开始执行顺序。并且，优先级不能取代依赖关系。
- 如果一个队列中既包含高优先级操作，又包含低优先级操作，并且两个操作都已经准备就绪，那么队列先执行高优先级操作。比如上例中，如果 op1 和 op4 是不同优先级的操作，那么就会先执行优先级高的操作。
- 如果，一个队列中既包含了准备就绪状态的操作，又包含了未准备就绪的操作，未准备就绪的操作优先级比准备就绪的操作优先级高。那么，虽然准备就绪的操作优先级低，也会优先执行。优先级不能取代依赖关系。如果要控制操作间的启动顺序，则必须使用依赖关系。

补充：

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
