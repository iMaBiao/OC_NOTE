#### AFN内存泄漏优化

使用Xcode自带工具Instruments监测工具Leaks分析就能发现，AFN会造成内存泄漏

原因：循环引用

大致原因就是AFURLSessionManager引用NSURLSession，同时设置NSURLSession的delegate为自己，NSURLSession会强引用delegate，于是产生了循环引用。

```objective-c
// AFURLSessionManager.m
- (instancetype)initWithSessionConfiguration:(NSURLSessionConfiguration *)configuration {
    // ... 初始化代码，省略

    // 导致循环引用的方法
    self.session = [NSURLSession sessionWithConfiguration:self.sessionConfiguration delegate:self delegateQueue:self.operationQueue];

    // ... 其它初始化代码，省略
    return self;
}
```

```objective-c
AFURLSessionManager.h

/**
 The managed session.
 */
@property (readonly, nonatomic, strong) NSURLSession *session;
```

```objective-c
NSURLSession.h

@property (nullable, readonly, retain) id <NSURLSessionDelegate> delegate;

```





> #### 解决方式

- 方式一：创建AFURLSessionManager单例

整个APP共享，虽然还是有循环引用，但是就没有内存泄露的问题了

多个网络请求复用一个AFURLSessionManager，连续发两个网络请求，用Wireshark抓包可以看到，第二次网络请求复用了第一次的TCP连接，没有做三次握手。



- 方式二：取消session

`AFURLSessionManager `调用`invalidateSessionCancelingTasks`方法来断开循环引用

一次泄漏也没有 , 对象释放最彻底；

改动很麻烦, 每个都需要修改, 如果对AFN 有封装的话, 修改还是比较方便, AFN 没有封装的话, 改动会有很多缺点；



AFN作者答复：(推荐单例)

```
https://github.com/AFNetworking/AFNetworking/issues/1528

This is known and documented behavior. When you're finished with a session, call invalidateSessionCancelingTasks:. This is not an issue for most apps, which keep a single session for the lifetime of the application.
```

