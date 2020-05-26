### 常见问答



##### 1、讲讲RunLoop项目中有用到吗？

- 控制线程的生命周期（线程保活、常驻线程）

- 解决NSTimer在滑动时停止工作的问题

- 监控应用卡顿

- 性能优化

  

  定时器切换的时候，为了保证定时器的准确性，需要添加runLoop

  在聊天界面，我们需要持续的把聊天信息存到数据库中，这个时候需要开启一个保活线程，在这个线程中处理



##### 2、RunLoop内部实现逻辑？

- 1、通知观察者（observers）进入Runloop

- 2、通知观察者（observers）即将处理`Timers`

- 3、通知观察者（observers）即将处理`source0`事件

- 4、处理`blocks`

- 5、处理`source0 `事件，（可能会再次处理Blocks）

- 6、如果有`source1`,就执行第 8 步

- 7、通知观察者（observers）线程开始进入休眠（等待消息唤醒）

- 8、通知观察者（observers）结束休眠（被某个消息唤醒）

  - 01、处理`timer`
  - 02、处理GCD Async To Main Queue
  - 03、处理Source1

  

- 9、处理`Blocks`
- 10、根据前面的执行结果，决定如何操作
  - 01、回到第 2 步
  - 02、退出ronloop
- 11、通知观察者（observers），退出`runloop`



补充：

Source0：

- 触摸事件处理
- performSelector : onThread :



Source1 :

- 基于Port的线程通信
- 系统事件捕捉



Timers :

- NSTimer
- PerformSelector :  withObject : afterDelay : 



Observers :

- 用于监听Runloop的状态
- UI刷新 (Before Waitting)
- Autorelease pool  (Before Waitting)





##### 3、RunLoop和线程的关系？

- 每一条线程都有唯一的一个与之对应的RunLoop对象
- RunLoop保存在一个全局的Dictionary里，线程作为Key，RunLoop作为Value
- 线程刚创建时，并没有RunLoop对象，RunLoop会在第一次获取她时创建
- RunLoop会在线程结束的时候销毁
- 主线程的RunLoop已经自动获取（创建），子线程默认没有开启RunLoop



##### 4、RunLoop有几种状态?

```objective-c
typedef CF_OPTIONS(CFOptionFlags, CFRunLoopActivity) {
    kCFRunLoopEntry = (1UL << 0),	// 即将进入
    kCFRunLoopBeforeTimers = (1UL << 1),	// 即将处理Timer
    kCFRunLoopBeforeSources = (1UL << 2),	 // 即将处理Source
    kCFRunLoopBeforeWaiting = (1UL << 5),	//即将进入休眠
    kCFRunLoopAfterWaiting = (1UL << 6),	// 刚从休眠中唤醒
    kCFRunLoopExit = (1UL << 7),	// 即将退出RunLoop
    kCFRunLoopAllActivities = 0x0FFFFFFFU
};
```



##### 5、RunLoop的mode的作用?

 系统注册了5种mode

```objective-c
//App的默认Mode，通常主线程是在这个Mode下运行
kCFRunLoopDefaultMode 
  
//界面跟踪 Mode，用于 ScrollView 追踪触摸滑动，保证界面滑动时不受其他 Mode 影响
UITrackingRunLoopMode 
  
// 在刚启动 App 时第进入的第一个 Mode，启动完成后就不再使用  
UIInitializationRunLoopMode 
  
// 接受系统事件的内部 Mode，通常用不到
GSEventReceiveRunLoopMode
  
//这是一个占位用的Mode，不是一种真正的Mode
kCFRunLoopCommonModes 		
```

但是我们只能使用两种mode

```
kCFRunLoopDefaultMode //App的默认Mode，通常主线程是在这个Mode下运行
UITrackingRunLoopMode //界面跟踪 Mode，用于 ScrollView 追踪触摸滑动，保证界面滑动时不受其他 Mode 影响
```

