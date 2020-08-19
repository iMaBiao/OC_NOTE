## YYCache



引用：[深入理解 YYCache](https://juejin.im/post/6856665902655078407)

[YYCache 设计思路](https://blog.ibireme.com/2015/10/26/yycache/)



YYCache 包含

```objective-c
YYCache.h 				YYCache.m

YYDiskCache.h			YYDiskCache.m

YYKVStorage.h			YYKVStorage.m

YYMemoryCache.h  	YYMemoryCache.m
```



### 一、YYMemoryCache 的实现机制

#### 1.优先删除低频使用的元素

苹果也有自己的缓存方案，NSCache，它结合了各种自动删除策略，以确保不会占用过多的系统内存，当系统内存紧张时，就会自动执行这些策略，从缓存中删除一些对象，但是它的删除顺序是不确定的。

而 YYCache 采用的删除机制是，优先删除低频使用的数据，它是怎么做到的？

YYCache 分为了 YYMemoryCache（内存缓存） 和 YYDiskCache（磁盘缓存），我们先来看 YYMemoryCache。



YYMemoryCache 内部维护了一个双向链表：`_YYLinkedMap`， 在每次存数据的时候，都将数据存到链表首部，然后如果内存紧张了，就从链表的尾部开始删，这样去保证删除的元素不是经常使用的，从而一定程度上提高了效率。

说是双向链表，不过实际的载体还是字典，`_YYLinkedMap` 的结构如下：

```objective-c
@interface _YYLinkedMap : NSObject {
    @package
    CFMutableDictionaryRef _dic; // do not set object directly
    NSUInteger _totalCost;
    NSUInteger _totalCount;
    _YYLinkedMapNode *_head; // MRU, do not change it directly
    _YYLinkedMapNode *_tail; // LRU, do not change it directly
    BOOL _releaseOnMainThread;
    BOOL _releaseAsynchronously;
}
```

实际的载体就是 `_dic`，`CFMutableDictionaryRef`，C 级别的可变字典，与 `NSMuatbleDictionary` 对应。

链表的每个节点，都是一个 `_YYLinkedMapNode` 类型的对象，该对象的结构如下：

```objective-c
@interface _YYLinkedMapNode : NSObject {
    @package
    __unsafe_unretained _YYLinkedMapNode *_prev; // retained by dic
    __unsafe_unretained _YYLinkedMapNode *_next; // retained by dic
    id _key;
    id _value;
    NSUInteger _cost;
    NSTimeInterval _time;
}
@end
```

`_prev` 和 `_next` 分别是指向前面一个结点和后面一个结点。



##### 链表存储数据时，都将数据放到首部

```objective-c
- (void)insertNodeAtHead:(_YYLinkedMapNode *)node {
    CFDictionarySetValue(_dic, (__bridge const void *)(node->_key), (__bridge const void *)(node));
    _totalCost += node->_cost;
    _totalCount++;
    if (_head) {
        node->_next = _head;
        _head->_prev = node;
        _head = node;
    } else {
        _head = _tail = node;
    }
}
```



##### 删除数据时，从链表的尾部开始删

```objective-c
- (void)removeNode:(_YYLinkedMapNode *)node {
    CFDictionaryRemoveValue(_dic, (__bridge const void *)(node->_key));
    _totalCost -= node->_cost;
    _totalCount--;
    if (node->_next) node->_next->_prev = node->_prev;
    if (node->_prev) node->_prev->_next = node->_next;
    if (_head == node) _head = node->_next;
    if (_tail == node) _tail = node->_prev;
}
```



#### 2.删除缓存的时机

YYMemoryCache 提供了三个维度，来控制缓存：

```objective-c
//The maximum number of objects the cache should hold.
// 缓存对象的个数，默认 NSUIntegerMax，无上限
@property NSUInteger countLimit;

//The maximum total cost that the cache can hold before it starts evicting objects.
// 缓存的开销，默认 NSUIntegerMax，无上限
@property NSUInteger costLimit;

//The maximum expiry time of objects in cache.
// 缓存的时间，默认 DBL_MAX，无上限
@property NSTimeInterval ageLimit;
```

可以自己设置这几个值，比如设定缓存的对象上限为 5 个，当缓存超出 5 个对象时，YYCache 就会自动帮你删除，直到缓存的对象小于或等于5个。

这是怎么做到的呢？

在这几个属性下面，紧跟着另外一个属性：

```objective-c
//The auto trim check time interval in seconds. Default is 5.0.
// 清理超出上限之外的缓存的操作间隔时间，默认为5s
@property NSTimeInterval autoTrimInterval;
```

在 YYMemoryCache 被初始化之后，会维护一个定时器，每隔 `autoTrimInterval` 秒之后，就会执行以下方法：

```objective-c
- (void)_trimRecursively {
    __weak typeof(self) _self = self;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(_autoTrimInterval * NSEC_PER_SEC)), dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
        __strong typeof(_self) self = _self;
        if (!self) return;
        [self _trimInBackground];
        [self _trimRecursively];
    });
}

- (void)_trimInBackground {
    dispatch_async(_queue, ^{
        [self _trimToCost:self->_costLimit];
        [self _trimToCount:self->_countLimit];
        [self _trimToAge:self->_ageLimit];
    });
}
```

这个方法会去轮询判断当前缓存是否已经超出设置的限制，如果超出限制，释放缓存到设定的限制。



除开定时器，还有另外两个清除缓存的时机，分别对应两个通知：

一个是系统内存紧张时的通知，一个是app进入后台时的通知，收到这两个通知，就会清空缓存。

```objective-c
[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_appDidReceiveMemoryWarningNotification) name:UIApplicationDidReceiveMemoryWarningNotification object:nil];

[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_appDidEnterBackgroundNotification) name:UIApplicationDidEnterBackgroundNotification object:nil];
```

顺便提一下，如果没有特别指定要在主线程删除缓存，那么所有的清除缓存的操作都会放在子线程中执行。

根据`_releaseOnMainThread`判断主线程



##### 异步释放对象的小技巧

YYCache 通过将对象捕获到 block 中的方式，做到了在 block 中去释放对象，提高了用户的体验，这个小技巧我们也可以学习

```objective-c
    if (_lru->_totalCount > _countLimit) {
        _YYLinkedMapNode *node = [_lru removeTailNode];
        if (_lru->_releaseAsynchronously) {
            dispatch_queue_t queue = _lru->_releaseOnMainThread ? dispatch_get_main_queue() : YYMemoryCacheGetReleaseQueue();
            dispatch_async(queue, ^{
                [node class]; //hold and release in queue
            });
        } else if (_lru->_releaseOnMainThread && !pthread_main_np()) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [node class]; //hold and release in queue
            });
        }
    }
```



下面是一个小例子：

```objective-c
NSArray *tmp = self.array;
self.array = nil;
dispatch_async(queue, ^{
  [tmp class];  // 这个调用只是为了避免编译器的警告
});
```

_我表示没看懂_



#### 3.YYMemoryCache 使用的锁

YYMemoryCache 和 YYDiskCache 都是线程安全的，它们使用了不同的锁来保证这。YYMemoryCache 最先开始使用的 OOSpinLock 来实现的，这是一个自旋锁，当想访问的资源被占用，自旋锁会不断轮询，也就是 CPU 一直在不断的问：好了没、好了没....，直到资源可用，所以也称这种锁是 "忙等" 的。自旋锁的这种机制会导致优先级反转的问题，所以 iOS 不再提倡使用这种锁，作者也专门写了另外一篇 [文章](https://blog.ibireme.com/2016/01/16/spinlock_is_unsafe_in_ios/) 来讨论这个问题，这里不再展开。



代替了 OOSpinLock 的，是 `pthread_mutex`，这是一个互斥锁，互斥锁与自旋锁最大的区别就是：互斥锁锁住的资源被占用时，系统会先挂起等待，不耗费系统资源。

iOS 也提供了一些锁，性能较高的是 `NSLock` ，不过其实它是对 `pthred_mutex` 的封装，NSLock 需要进行一个对象调用的过程，所以性能相较 `pthread_mutex` 会差。所以 YYMemoryCache 直接使用了`pthred_mutex`，已经是 iOS 可用的锁里性能相对最好的了



### 二、YYDiskCache 的实现机制



#### 1.数据存储方式

磁盘缓存其实也分了两部分，一部分是数据库缓存，一部分是文件缓存，在初始化时，指定这个界限，默认是20KB，也即 20KB 以内的数据，存在数据库中，大于 20KB 的数据就使用文件存储，磁盘缓存中的每个对象都被封装成 `YYKVStorageItem` 类型：

```objective-c
/**
 YYKVStorageItem is used by `YYKVStorage` to store key-value pair and meta data.
 Typically, you should not use this class directly.
 */
@interface YYKVStorageItem : NSObject
@property (nonatomic, strong) NSString *key;                ///< key
@property (nonatomic, strong) NSData *value;                ///< value
@property (nullable, nonatomic, strong) NSString *filename; ///< filename (nil if inline)
@property (nonatomic) int size;                             ///< value's size in bytes
@property (nonatomic) int modTime;                          ///< modification unix timestamp
@property (nonatomic) int accessTime;                       ///< last access unix timestamp
@property (nullable, nonatomic, strong) NSData *extendedData; ///< extended data (nil if no extended data)
@end
```

大于 20KB 时，value 会被缓存到文件中，而元数据，也就是 `YYKVStorageItem` ，会以数据库的方式被保存起来，取的时候先从数据库取出元数据，再拿到对应的文件、

为什么使用数据库而不直接使用文件存储，为什么数据库和文件的界限在 20KB，这是 YYCache 的作者自己的测试结果：

>基于文件系统，即一个 value 对应一个文件，通过文件读写来缓存数据的缺点在于：不方便扩展、没有元数据、难以实现较好的淘汰算法、数据统计缓慢。
>
>基于数据库的缓存可以很好的支持元数据、扩展方便、数据统计更快，也很容易实现 LRU 或其他淘汰算法，唯一不确定的就是数据库读写的性能，为此我评测了一下 SQLite 在真机上的表现。iPhone 6 64G 下，SQLite 写入性能比直接读文件要高，但读性能取决于数据大小：当单条数据小于 20K 时，直接写为文件速度会更快一些。
>
>所以，存盘缓存最好是把 SQLite 和文件存储结合起来，key-value 元数据保存在 SQLite 中，而 value 数据则根据大小不同选择 SQLite 或文件存储。

YYDiskCache 是使用系统自带的 `sqlite3` 来实现这个数据库的，至于数据库的存取代码，这里就不展开说了，代码都在 `YYKVStorage.m` 中，可以从 github 下载 YYCache 的源码来看。



#### 2.LRU 算法

磁盘缓存的删除时机与内存缓存基本一致，不过它的自动轮询时间为 60s，另外磁盘缓存也有对应的 `costLimit`、`countLimit` 和 `ageLimit`。

上面提到 YYMemoryCache 删数据，优先从链表的尾部开始删，但是 YYDiskCache 的结构是个数据库，这时根据什么来删呢？

每个元数据入库时，都会带上一个参数，`last_access_time`，每次操作这个元数据，都会记录一下当前的操作时间，等到要删除的时候，就依据这个时间，从最久远的开始删起。

看一下数据库的查询指令就知道了：

```objective-c
- (NSMutableArray *)_dbGetItemSizeInfoOrderByTimeAscWithLimit:(int)count {
    NSString *sql = @"select key, filename, size from manifest order by last_access_time asc limit ?1;";
    sqlite3_stmt *stmt = [self _dbPrepareStmt:sql];
    if (!stmt) return nil;
    sqlite3_bind_int(stmt, 1, count);
 		...   
 }
```



#### 3.YYDiskCache 使用的锁

这里是用信号量来实现了锁的功能：

```objective-c
static dispatch_semaphore_t _globalInstancesLock;
```

简单来说，信号量就是一个计数器，其取值为当前累积的信号数量。它支持两个操作，加法操作 up 和减法操作 down，分别描述如下：

down 减法操作：

1. 判断信号量的取值是否大于等于1
2. 如果是，将信号量的值减去1，继续往下执行
3. 否则在该信号量上等待（线程将被挂起）

up 加法操作：

1. 将信号量的值加1（此操作将叫醒一个在该信号量上面等待的线程）
2. 线程继续往下执行

这里需要注意的是，down 和 up 两个操作虽然包含多个步骤，但这些操作是一组原子操作，它们之间是不能分开的。



如果将信号量的取值限制为 0 和 1 两种情况，则获得的就是一把锁，也被称为 **二元信号量**。其操作如下：

down 减法操作：

1. 等待信号量的值变为1
2. 将信号量的值设置为0
3. 继续往下执行

up 加法操作：

1. 将信号量的值设置为1
2. 叫醒在该信号量上面等待的第1个线程
3. 线程继续往下执行

由于二元信号量的取值只有 0 和 1，因此上述程序防止任何两个程序同时进入临界区，所以这就相当于一个锁的概念，YYDiskCache 使用的就是二元信号量，其实用 `pthread_mutex` 来代替也是可以的。对比一下两者，在没有等待情况出现的时候，信号量的性能比 `pthread_mutex` 的性能还要高。但一旦有等待情况出现时。性能就会下降许多。另外，信号量在等待时，也是不会占用 CPU 的资源的，这对于磁盘缓存来说正好合适。



