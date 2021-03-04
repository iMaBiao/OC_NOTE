## YYKit里的部分	



### YYCache缓存

https://www.cnblogs.com/machao/p/7086675.html

#### YYMemoryCache

使用YYMemoryCache可以把数据缓存进内存之中，它内部会创建了一个YYMemoryCache对象，然后把数据保存进这个对象之中。

**但凡涉及到类似这样的操作，代码都需要设计成线程安全的。所谓的线程安全就是指充分考虑多线程条件下的增删改查操作。**



YYMemoryCache暴露出来的接口我们在此就略过了，我们都知道**要想高效的查询数据，使用字典是一个很好的方法。字典的原理跟哈希有关，总之就是把key直接映射成内存地址，然后处理冲突和和扩容的问题。**

YYMemoryCache内部封装了一个对象`_YYLinkedMap`，包含了下边这些属性：

```objc
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

可以看出来，`CFMutableDictionaryRef _dic`将被用来保存数据。这里使用了CoreFoundation的字典，性能更好。字典里边保存着的是`_YYLinkedMapNode`对象。

```objc
/**
 A node in linked map.
 Typically, you should not use this class directly.
 */
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

但看上边的代码，就能知道使用了链表的知识。但是有一个疑问，单用字典我们就能很快的查询出数据，为什么还要实现链表这一数据结构呢？

**答案就是淘汰算法，YYMemoryCache使用了LRU淘汰算法，也就是当数据超过某个限制条件后，我们会从链表的尾部开始删除数据，直到达到要求为止。**

通过这种方式，就实现了类似数组的功能，是原本无序的字典成了有序的集合。



我们简单看一段把一个节点插入到最开始位置的代码：

```objc
- (void)bringNodeToHead:(_YYLinkedMapNode *)node {
    if (_head == node) return;
    
    if (_tail == node) {
        _tail = node->_prev;
        _tail->_next = nil;
    } else {
        node->_next->_prev = node->_prev;
        node->_prev->_next = node->_next;
    }
    node->_next = _head;
    node->_prev = nil;
    _head->_prev = node;
    _head = node;
}
```

如果有一列数据已经按顺序排好了，我使用了中间的某个数据，那么就要把这个数据插入到最开始的位置，这就是一条规则，越是最近使用的越靠前。

在设计上，YYMemoryCache还提供了是否异步释放数据这一选项，在这里就不提了，我们在来看看在YYMemoryCache中用到的锁的知识。

pthread_mutex_lock是一种互斥所：

```objc
pthread_mutex_init(&_lock, NULL); // 初始化
pthread_mutex_lock(&_lock); // 加锁
pthread_mutex_unlock(&_lock); // 解锁
pthread_mutex_trylock(&_lock) == 0 // 是否加锁，0:未锁住，其他值：锁住
```

在OC中有很多种锁可以用，pthread_mutex_lock就是其中的一种。YYMemoryCache有这样一种设置，每隔一个固定的时间就要处理数据，代码如下：

```objc
- (void)_trimRecursively {
    __weak typeof(self) _self = self;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(_autoTrimInterval * NSEC_PER_SEC)), dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
        __strong typeof(_self) self = _self;
        if (!self) return;
        [self _trimInBackground];
        [self _trimRecursively];
    });
}
```

上边的代码中，每隔_autoTrimInterval时间就会在后台尝试处理数据，然后再次调用自身，这样就实现了一个类似定时器的功能。这一个小技巧可以学习一下。

```
- (void)_trimInBackground {
    dispatch_async(_queue, ^{
        [self _trimToCost:self->_costLimit];
        [self _trimToCount:self->_countLimit];
        [self _trimToAge:self->_ageLimit];
    });
}
```

可以看出处理数据，做了三件事，他们内部的实现基本是一样的，我们选取第一个方法来看看代码：

```objc
- (void)_trimToCost:(NSUInteger)costLimit {
    BOOL finish = NO;
    pthread_mutex_lock(&_lock);
    if (costLimit == 0) {
        [_lru removeAll];
        finish = YES;
    } else if (_lru->_totalCost <= costLimit) {
        finish = YES;
    }
    pthread_mutex_unlock(&_lock);
    if (finish) return;
    
    NSMutableArray *holder = [NSMutableArray new];
    while (!finish) {
        if (pthread_mutex_trylock(&_lock) == 0) {
            if (_lru->_totalCost > costLimit) {
                _YYLinkedMapNode *node = [_lru removeTailNode];
                if (node) [holder addObject:node];
            } else {
                finish = YES;
            }
            pthread_mutex_unlock(&_lock);
        } else {
            usleep(10 * 1000); //10 ms
        }
    }
    if (holder.count) {
        dispatch_queue_t queue = _lru->_releaseOnMainThread ? dispatch_get_main_queue() : YYMemoryCacheGetReleaseQueue();
        dispatch_async(queue, ^{
            [holder count]; // release in queue
        });
    }
}
```

这段代码很经典，可以直接拿来用，我们在某个处理数据的类中，可以直接使用类似这样的代码。如果锁正在使用，那么可以使用`usleep(10 * 1000); //10 ms`等待一小段时间。

上边的代码把需要删除的数据，首先添加到一个数组中，然后使用`[holder count]; // release in queue`释放了资源。

**当某个变量在出了自己的作用域之后，正常情况下就会被自动释放。**



我个人对这些函数的总结是：

- **每个函数只实现先单一功能，函数组合使用形成新的功能**
- **对于类内部的私有方法，前边添加`_`**
- **使用预处理stmt对数据库进行了优化，避免不必要的开销**
- **健壮的错误处理机制**
- **可以说是使用iOS自带sqlite3的经典代码，在项目中可以直接拿来用**

这也许就是函数的魅力，有了这些函数，那么在给接口中的函数写逻辑的时候就会变得很简单。

**建议大家一定要读读YYKVStorage这个类的源码，这是一个类的典型设计。它内部使用了两种方式保存数据：一种是保存到数据库中，另一种是直接写入文件。当数据较大时，使用文件写入性能更好，反之数据库更好。**



#### YYDiskCache



#### YYCache

当我们读到YYCache的时候，感觉一下子就轻松了很多，YYCache就是对YYMemoryCache和YYDiskCache的综合运用，创建YYCache对象后，就创建了一个YYMemoryCache对象和一个YYDiskCache对象。

唯一新增的特性就是可以根据name来创建YYCache，内部会根据那么来创建一个path，本质上还是使用path定位的。





### YYAsyncLayer异步绘制

https://www.jianshu.com/p/154451e4bd42

YYAsyncLayer 是 ibireme 写的一个异步绘制的轮子，虽然代码加起来才 300 行左右，但质量比较高，涉及到很多优化思维，值得学习。

