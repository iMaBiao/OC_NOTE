AFNetworking：2.0常驻线程与3.0最大并发数问题



https://blog.csdn.net/lcx_love_yx/article/details/89946340





一 常驻线程：

1、2.0 需要常驻线程的作用？

2.0常驻线程，用来并发请求，和处理数据回调；避免多个网络请求的线程开销(不用开辟一个线程，就保活一条线程)；

2、而3.0不需要常驻线程？

因为NSURLSession可以指定回调delegateQueue，NSURLConnection而不行；

NSURLConnection的一大痛点就是：发起请求后，而需要一直处于等待回调的状态。而3.0后NSURLSession解决的这个问题；NSURLSession发起的请求，不再需要在当前线程进行回调，可以指定回调的delegateQueue，这样就不用为了等待代理回调方法而保活线程了。

 

二 最大并发数：

1 、3.0需要设置最大并发数为1，self.operationQueue.maxConcurrentOperationCount = 1？

串行：让并发的请求，串行的进行回调；

锁：且为了防止多线程资源竞争加了锁（对 self.mutableTaskDelegatesKeyedByTaskIdentifier（多任务代理） 的访问进行了加锁），本来就需要等待，如果多线程并发反而造成资源浪费；

2、2.0为什么不需要？

功能不一样：AF3.0的operationQueue是用来接收NSURLSessionDelegate回调的，鉴于一些多线程数据访问的安全性考虑，设置了maxConcurrentOperationCount = 1来达到串行回调的效果。

而AF2.0的operationQueue是用来添加operation并进行并发请求的，所以不要设置为1。

 

三 总结：

af2.0

1 、保活常驻线程原因：可以避免多个网络请求，就要保活多个线程；

2 、常驻线程特点：并发请求，和代理回调都在同一线程（常驻线程）；所以线程等待回调；

3 、并发请求：系统根据情况控制最大并发数；

4、2.0的operationQueue是用于并发请求的；

 

af3.0

1 、无需常驻线程原因：因为NSURLSession可以指定回调的delegateQueue，NSURLConnection而不行；

2 、最大并发数设置：3.0的operationQueue是用于接收NSURLSessionDelegate回调的；

self.operationQueue.maxConcurrentOperationCount = 1，是为了达到串行回调的效果，况且加了锁；

备注：

锁：且为了防止多线程资源竞争加了锁（对 self.mutableTaskDelegatesKeyedByTaskIdentifier（多任务代理） 的访问进行了加锁），本来就需要等待，如果多线程并发反而造成资源浪费；