#### NSOperation

[https://bujige.net/blog/iOS-Complete-learning-NSOperation.html](https://bujige.net/blog/iOS-Complete-learning-NSOperation.html)

NSOperation、NSOperationQueue 是苹果提供给我们的一套多线程解决方案。实际上 NSOperation、NSOperationQueue 是基于 GCD 更高一层的封装，完全面向对象

好处

- 1、可添加完成的代码块，在操作完成后执行
- 2、添加操作之间的依赖关系，方便的控制执行顺序
- 3、设定操作执行的优先级
- 4、可以很方便的取消一个操作的执行
- 5、使用 KVO 观察对操作执行状态的更改：isExecuteing、isFinished、isCancelled

既然是基于 GCD 的更高一层的封装。那么，GCD 中的一些概念同样适用于 NSOperation、NSOperationQueue。在 NSOperation、NSOperationQueue 中也有类似的任务（操作）和队列（操作队列）的概念

**操作（Operation）**

- 1、执行操作的意思，换句话说就是你在线程中执行的那段代码
- 2、在  `GCD` 中是放在  `block`  中的。在  `NSOperation`  中，我们使用 NSOperation 子类  `NSInvocationOperation`、`NSBlockOperation`，或者自定义子类来封装操作

**操作队列（Operation Queues）**

- 1、这里的队列指操作队列，即用来存放操作的队列。不同于 GCD 中的调度队列 FIFO（先进先出）的原则。NSOperationQueue 对于添加到队列中的操作，首先进入准备就绪的状态（就绪状态取决于操作之间的依赖关系），然后进入就绪状态的操作的开始执行顺序（非结束执行顺序）由操作之间相对的优先级决定（优先级是操作对象自身的属性）。
- 2、操作队列通过设置最大并发操作数（maxConcurrentOperationCount）来控制并发、串行
- 3、NSOperationQueue 为我们提供了两种不同类型的队列：主队列和自定义队列。主队列运行在主线程之上，而自定义队列在后台执行

##### 常用API

**NSOperation常用属性和方法**

- 1、开始取消操作
  
  - `- (void)start`：对于并发Operation需要重写该方法，也可以不把operation加入到队列中，手动触发执行，与调用普通方法一样
  - `- (void)main`：非并发Operation需要重写该方法
  - `- (void)cancel`：可取消操作，实质是标记 isCancelled 状态

- 2、判断操作状态方法
  
  - `- (BOOL)isFinished;`  判断操作是否已经结束
  - `- (BOOL)isCancelled`  判断操作是否已经标记为取消
  - `- (BOOL)isExecuting;`判断操作是否正在在运行
  - `- (BOOL)isReady;`判断操作是否处于准备就绪状态，这个值和操作的依赖关系相关。

- 3、操作同步
  
  - `- (void)waitUntilFinished;`阻塞当前线程，直到该操作结束。可用于线程执行顺序的同步
  - `- (void)setCompletionBlock:(void (^)(void))block;`  会在当前操作执行完毕时执行 completionBlock
  - `- (void)addDependency:(NSOperation *)op;`  添加依赖，使当前操作依赖于操作 op 的完成
  - `- (void)removeDependency:(NSOperation *)op;`  移除依赖，取消当前操作对操作 op 的依赖。
  - `@property (readonly, copy) NSArray<NSOperation *> *dependencies;`  在当前操作开始执行之前完成执行的所有操作对象数组。

**NSOperationQueue 常用属性和方法**

- 1、取消/暂停/恢复操作
  
  - `- (void)cancelAllOperations;`  可以取消队列的所有操作
  - `- (BOOL)isSuspended;`  判断队列是否处于暂停状态。 YES 为暂停状态，NO 为恢复状态
  - `- (void)setSuspended:(BOOL)b;`  可设置操作的暂停和恢复，YES 代表暂停队列，NO 代表恢复队列

- 2、操作同步
  
  - `- (void)waitUntilAllOperationsAreFinished;`  阻塞当前线程，直到队列中的操作全部执行完毕。

- 3、添加/获取操作
  
  - `- (void)addOperationWithBlock:(void (^)(void))block;`  向队列中添加一个 NSBlockOperation 类型操作对象
  - `- (void)addOperations:(NSArray *)ops waitUntilFinished:(BOOL)wait;`向队列中添加操作数组，wait 标志是否阻塞当前线程直到所有操作结束
  - `- (NSArray *)operations;`  当前在队列中的操作数组（某个操作执行结束后会自动从这个数组清除）
  - `- (NSUInteger)operationCount;`  当前队列中的操作数

- 4、获取队列
  
  - `+ (id)currentQueue;`  获取当前队列，如果当前线程不是在 NSOperationQueue 上运行则返回 nil。
  - `+ (id)mainQueue;`  获取主队列。

##### NSOperation 和 NSOperationQueue 基本使用

#### 1、创建操作

NSOperation 是个抽象类，不能用来封装操作。我们只有使用它的子类来封装操作。我们有三种方式来封装操作。

1. 使用子类 NSInvocationOperation
2. 使用子类 NSBlockOperation
3. 自定义继承自 NSOperation 的子类，通过实现内部相应的方法来封装操作。

在不使用 NSOperationQueue，单独使用 NSOperation 的情况下系统同步执行操作，下面我们学习以下操作的三种创建方式。

###### 使用子类  `NSInvocationOperation`

```
/**
 * 使用子类 NSInvocationOperation
 */
- (void)useInvocationOperation {

    // 1.创建 NSInvocationOperation 对象
    NSInvocationOperation *op = [[NSInvocationOperation alloc] initWithTarget:self selector:@selector(task1) object:nil];

    // 2.调用 start 方法开始执行操作
    [op start];
}

- (void)task1 {
    for (int i = 0; i < 2; i++) {
        [NSThread sleepForTimeInterval:2]; // 模拟耗时操作
        NSLog(@"1---%@", [NSThread currentThread]); // 打印当前线程
    }
}

打印：
1---<NSThread: 0x61800006ac40>{number = 1,name = main}
1---<NSThread: 0x61800006ac40>{number = 1,name = main}
```

**可以看到：在没有使用 NSOperationQueue、在主线程中单独使用使用子类 NSInvocationOperation 执行一个操作的情况下，操作是在当前线程执行的，并没有开启新线程。**

##### 如果在其他线程中执行操作，则打印结果为其他线程。

```
// 在其他线程使用子类 NSInvocationOperation
[NSThread detachNewThreadSelector:@selector(useInvocationOperation) toTarget:self withObject:nil];

打印：
1---<NSThread: 0x61800006ac40>{number = 3,name = (null)}
1---<NSThread: 0x61800006ac40>{number = 3,name = (null)}
```

**可以看到：在其他线程中单独使用子类 NSInvocationOperation，操作是在当前调用的其他线程执行的，并没有开启新线程。**

##### 使用子类  `NSBlockOperation`

```
/**
 * 使用子类 NSBlockOperation
 */
- (void)useBlockOperation {

    // 1.创建 NSBlockOperation 对象
    NSBlockOperation *op = [NSBlockOperation blockOperationWithBlock:^{
        for (int i = 0; i < 2; i++) {
            [NSThread sleepForTimeInterval:2]; // 模拟耗时操作
            NSLog(@"1---%@", [NSThread currentThread]);//打印当前线程
        }
    }];

    // 2.调用 start 方法开始执行操作
    [op start];
}

打印：
1---<NSThread: 0x61800006ac40>{number = 1,name = main}
1---<NSThread: 0x61800006ac40>{number = 1,name = main}
```

**可以看到：在没有使用 NSOperationQueue、在主线程中单独使用 NSBlockOperation 执行一个操作的情况下，操作是在当前线程执行的，并没有开启新线程。**

注意：和上边 NSInvocationOperation 使用一样。因为代码是在主线程中调用的，所以打印结果为主线程。如果在其他线程中执行操作，则打印结果为其他线程。

但是，NSBlockOperation 还提供了一个方法 `addExecutionBlock:`，通过 `addExecutionBlock:` 就可以为 NSBlockOperation 添加额外的操作。这些操作（包括 blockOperationWithBlock 中的操作）可以在不同的线程中同时（并发）执行。只有当所有相关的操作已经完成执行时，才视为完成。

如果添加的操作多的话，`blockOperationWithBlock:` 中的操作也可能会在其他线程（非当前线程）中执行，这是由系统决定的，并不是说添加到 `blockOperationWithBlock:` 中的操作一定会在当前线程中执行。（可以使用 `addExecutionBlock:` 多添加几个操作试试）。

```
/**
 * 使用子类 NSBlockOperation
 * 调用方法 AddExecutionBlock:
 */
- (void)useBlockOperationAddExecutionBlock {

    // 1.创建 NSBlockOperation 对象
    NSBlockOperation *op = [NSBlockOperation blockOperationWithBlock:^{
        for (int i = 0; i < 2; i++) {
            [NSThread sleepForTimeInterval:2]; // 模拟耗时操作
            NSLog(@"1---%@", [NSThread currentThread]);//打印当前线程
        }
    }];

    // 2.添加额外的操作
    [op addExecutionBlock:^{
        for (int i = 0; i < 2; i++) {
            [NSThread sleepForTimeInterval:2]; // 模拟耗时操作
            NSLog(@"2---%@", [NSThread currentThread]);//打印当前线程
        }
    }];
    [op addExecutionBlock:^{
        for (int i = 0; i < 2; i++) {
            [NSThread sleepForTimeInterval:2]; // 模拟耗时操作
            NSLog(@"3---%@", [NSThread currentThread]);//打印当前线程
        }
    }];
    [op addExecutionBlock:^{
        for (int i = 0; i < 2; i++) {
            [NSThread sleepForTimeInterval:2]; // 模拟耗时操作
            NSLog(@"4---%@", [NSThread currentThread]);//打印当前线程
        }
    }];
    [op addExecutionBlock:^{
        for (int i = 0; i < 2; i++) {
            [NSThread sleepForTimeInterval:2]; // 模拟耗时操作
            NSLog(@"5---%@", [NSThread currentThread]);//打印当前线程
        }
    }];
    [op addExecutionBlock:^{
        for (int i = 0; i < 2; i++) {
            [NSThread sleepForTimeInterval:2]; // 模拟耗时操作
            NSLog(@"6---%@", [NSThread currentThread]);//打印当前线程
        }
    }];
    [op addExecutionBlock:^{
        for (int i = 0; i < 2; i++) {
            [NSThread sleepForTimeInterval:2]; // 模拟耗时操作
            NSLog(@"7---%@", [NSThread currentThread]);//打印当前线程
        }
    }];
    [op addExecutionBlock:^{
        for (int i = 0; i < 2; i++) {
            [NSThread sleepForTimeInterval:2]; // 模拟耗时操作
            NSLog(@"8---%@", [NSThread currentThread]);//打印当前线程
        }
    }];

    // 3.调用 start 方法开始执行操作
    [op start];
}

打印：
8---<NSThread: 0x61800006ac40>{number = 9,name = (null)}
5---<NSThread: 0x61800006ac40>{number = 6,name = (null)}
6---<NSThread: 0x61800006ac40>{number = 8,name = (null)}
1---<NSThread: 0x61800006ac40>{number = 3,name = (null)}
3---<NSThread: 0x61800006ac40>{number = 1,name = main}
2---<NSThread: 0x61800006ac40>{number = 5,name = (null)}
4---<NSThread: 0x61800006ac40>{number = 4,name = (null)}
7---<NSThread: 0x61800006ac40>{number = 7,name = (null)}
3---<NSThread: 0x61800006ac40>{number = 1,name = main}
1---<NSThread: 0x61800006ac40>{number = 3,name = (null)}
2---<NSThread: 0x61800006ac40>{number = 5,name = (null)}
8---<NSThread: 0x61800006ac40>{number = 9,name = (null)}
6---<NSThread: 0x61800006ac40>{number = 8,name = (null)}
5---<NSThread: 0x61800006ac40>{number = 6,name = (null)}
4---<NSThread: 0x61800006ac40>{number = 4,name = (null)}
7---<NSThread: 0x61800006ac40>{number = 7,name = (null)}
```

**可以看出：使用子类 `NSBlockOperation`，并调用方法 `AddExecutionBlock:` 的情况下，`blockOperationWithBlock:`方法中的操作 和 `addExecutionBlock:` 中的操作是在不同的线程中异步执行的。而且，这次执行结果中 `blockOperationWithBlock:`方法中的操作也不是在当前线程（主线程）中执行的。从而印证了`blockOperationWithBlock:` 中的操作也可能会在其他线程（非当前线程）中执行。**

一般情况下，如果一个 NSBlockOperation 对象封装了多个操作。NSBlockOperation 是否开启新线程，取决于操作的个数。如果添加的操作的个数多，就会自动开启新线程。当然开启的线程数是由系统来决定的。

##### 使用自定义继承自 NSOperation 的子类

如果使用子类 NSInvocationOperation、NSBlockOperation 不能满足日常需求，我们可以使用自定义继承自 NSOperation 的子类。

可以通过重写 `main` 或者 `start` 方法 来定义自己的 NSOperation 对象。

重写`main`方法比较简单，我们不需要管理操作的状态属性 `isExecuting` 和 `isFinished`。当 `main` 执行完返回的时候，这个操作就结束了。

```
先定义一个继承自 NSOperation 的子类，重写main方法。

#import <Foundation/Foundation.h>

@interface YSCOperation : NSOperation

@end

#import "YSCOperation.h"
@implementation YSCOperation

- (void)main {
    if (!self.isCancelled) {
        for (int i = 0; i < 2; i++) {
            [NSThread sleepForTimeInterval:2];
            NSLog(@"1---%@", [NSThread currentThread]);
        }
    }
}
@end
```

```
然后使用的时候导入头文件YSCOperation.h。
/**
 * 使用自定义继承自 NSOperation 的子类
 */
- (void)useCustomOperation {
    // 1.创建 YSCOperation 对象
    YSCOperation *op = [[YSCOperation alloc] init];
    // 2.调用 start 方法开始执行操作
    [op start];
}

打印：
1---<NSThread: 0x61800006ac40>{number = 1,name = main}
1---<NSThread: 0x61800006ac40>{number = 1,name = main}
```

**可以看出：在没有使用 NSOperationQueue、在主线程单独使用自定义继承自 NSOperation 的子类的情况下，是在主线程执行操作，并没有开启新线程。**

#### 2、创建队列

NSOperationQueue 一共有两种队列：主队列、自定义队列。其中自定义队列同时包含了串行、并发功能。下边是主队列、自定义队列的基本创建方法和特点。

主队列

- 凡是添加到主队列中的操作，都会放到主线程中执行。
  
  ```
  / 主队列获取方法
  NSOperationQueue *queue = [NSOperationQueue mainQueue];
  ```

自定义队列（非主队列）

- 添加到这种队列中的操作，就会自动放到子线程中执行。

- 同时包含了：串行、并发功能。
  
  ```
  // 自定义队列创建方法
  NSOperationQueue *queue = [[NSOperationQueue alloc] init];
  ```

#### 3、将操作加入到队列中

`- (void)addOperation:(NSOperation *)op;`

- 需要先创建操作，再将创建好的操作加入到创建好的队列中去。

```
/*** 使用 addOperation: 将操作加入到操作队列中 */
- (void)addOperationToQueue {

    // 1.创建队列
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];

    // 2.创建操作
    // 使用 NSInvocationOperation 创建操作1
    NSInvocationOperation *op1 = [[NSInvocationOperation alloc] initWithTarget:self selector:@selector(task1) object:nil];

    // 使用 NSInvocationOperation 创建操作2
    NSInvocationOperation *op2 = [[NSInvocationOperation alloc] initWithTarget:self selector:@selector(task2) object:nil];

    // 使用 NSBlockOperation 创建操作3
    NSBlockOperation *op3 = [NSBlockOperation blockOperationWithBlock:^{
        for (int i = 0; i < 2; i++) {
            [NSThread sleepForTimeInterval:2]; // 模拟耗时操作
            NSLog(@"3---%@", [NSThread currentThread]);//打印当前线程
        }
    }];
    [op3 addExecutionBlock:^{
        for (int i = 0; i < 2; i++) {
            [NSThread sleepForTimeInterval:2]; // 模拟耗时操作
            NSLog(@"4---%@", [NSThread currentThread]);//打印当前线程
        }
    }];

    // 3.使用 addOperation: 添加所有操作到队列中
    [queue addOperation:op1]; // [op1 start]
    [queue addOperation:op2]; // [op2 start]
    [queue addOperation:op3]; // [op3 start]
}

打印：
4---<NSThread: 0x61800006ac40>{number = 6,name = (null)}
2---<NSThread: 0x61800006ac40>{number = 3,name = (null)}
1---<NSThread: 0x61800006ac40>{number = 5,name = (null)}
3---<NSThread: 0x61800006ac40>{number = 4,name = (null)}
1---<NSThread: 0x61800006ac40>{number = 5,name = (null)}
2---<NSThread: 0x61800006ac40>{number = 3,name = (null)}
3---<NSThread: 0x61800006ac40>{number = 4,name = (null)}
4---<NSThread: 0x61800006ac40>{number = 6,name = (null)}
```

**可以看出：使用 NSOperation 子类创建操作，并使用 `addOperation:` 将操作加入到操作队列后能够开启新线程，进行并发执行。**

`- (void)addOperationWithBlock:(void (^)(void))block;`

- 无需先创建操作，在 block 中添加操作，直接将包含操作的 block 加入到队列中。

```
/**
 * 使用 addOperationWithBlock: 将操作加入到操作队列中
 */

- (void)addOperationWithBlockToQueue {
    // 1.创建队列
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];

    // 2.使用 addOperationWithBlock: 添加操作到队列中
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
}

打印：
2---<NSThread: 0x61800006ac40>{number = 4,name = (null)}
3---<NSThread: 0x61800006ac40>{number = 5,name = (null)}
1---<NSThread: 0x61800006ac40>{number = 3,name = (null)}
3---<NSThread: 0x61800006ac40>{number = 5,name = (null)}
1---<NSThread: 0x61800006ac40>{number = 3,name = (null)}
2---<NSThread: 0x61800006ac40>{number = 4,name = (null)}
```

**可以看出：使用 addOperationWithBlock: 将操作加入到操作队列后能够开启新线程，进行并发执行。**
