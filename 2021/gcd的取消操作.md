## gcd完成NSOpetation的cancel操作

https://www.jianshu.com/p/c45f099c7fd4



### 1.dispatch_block_cancel

iOS8之后可以调用`dispatch_block_cancel`来取消

**需要注意必须用dispatch_block_create创建dispatch_block_t， dispatch_block_cancel也只能取消尚未执行的任务，对正在执行的任务不起作用。**

```objc
- (void)gcdBlockCancel{
    dispatch_queue_t queue = dispatch_queue_create("com.gcdtest.www", DISPATCH_QUEUE_CONCURRENT);
    dispatch_block_t block1 = dispatch_block_create(0, ^{
        sleep(5);
        NSLog(@"block1 %@",[NSThread currentThread]);
    });
    dispatch_block_t block2 = dispatch_block_create(0, ^{
        NSLog(@"block2 %@",[NSThread currentThread]);
    });
    dispatch_block_t block3 = dispatch_block_create(0, ^{
        NSLog(@"block3 %@",[NSThread currentThread]);
    });
    dispatch_async(queue, block1);
    dispatch_async(queue, block2);
    dispatch_block_cancel(block3);
  
  	//dispatch_block_cancel(block2);
}
```

打印：

```objc
-[ViewController viewDidLoad]_block_invoke_2 block2  <NSThread: 0x60000144b040>{number = 3, name = (null)}
-[ViewController viewDidLoad]_block_invoke_3 block3  <NSThread: 0x60000141d740>{number = 5, name = (null)}
-[ViewController viewDidLoad]_block_invoke block1  <NSThread: 0x60000144b900>{number = 4, name = (null)}
```

打开最后一行注释：`dispatch_block_cancel(block2);` 打印如下：

```
-[ViewController viewDidLoad]_block_invoke_3 block3  <NSThread: 0x6000033a8bc0>{number = 4, name = (null)}
-[ViewController viewDidLoad]_block_invoke block1  <NSThread: 0x6000033ee100>{number = 5, name = (null)}
```



### 2.定义外部变量，用于标记block是否需要取消

该方法是模拟NSOperation，在执行block前先检查isCancelled = YES ？在block中及时的检测标记变量，当发现需要取消时，终止后续操作。

```

```



