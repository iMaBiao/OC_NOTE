## UI操作为什么不应该在子线程中操作？

###### (UI 操作为什么要在主线程中操作？)

https://github.com/BiBoyang/BoyangBlog/blob/master/File/Thread_06.md

##### [多线程-奇怪的GCD](http://sindrilin.com/2018/03/03/weird_thread.html)



- #### UI 线程不安全

  我们其实都明白，UI 其实是一个比较笼统的概念，我们能看到的所有东西都可以称之为 UI。换句话说，UI 是使用者直接接触，并且操作的东西，算得上用户体验的最直接的度量。如果在 UI 上出了问题，会极大地打击用户的使用感受，造成大问题。而 UI 的线程安全与否，也是我们直接需要关注的事，因为这里实在是太容易出问题了。

  我们一般创建 UI 的时候会使用属性，比如这样：

  `@property (nonatomic, strong) UILabel *label;`

  我们一般都是使用 `nonatomic` 来修饰 UI，这个其实就已经变相表明他们在多线程下的困境————需要自己去控制它们。

  >对于一个像 UIKit 这样的大型框架，确保它的线程安全将会带来巨大的工作量和成本。将 non-atomic 的属性变为 atomic 的属性只不过是需要做的变化里的微不足道的一小部分。通常来说，你需要同时改变若干个属性，才能看到它所带来的结果。为了解决这个问题，苹果可能不得不提供像 Core Data 中的 `performBlock:` 和 `performBlockAndWait:` 那样类似的方法来同步变更。另外你想想看，绝大多数对 UIKit 类的调用其实都是以配置为目的的，这使得将 UIKit 改为线程安全这件事情更显得毫无意义了。

  

- #### 线程消耗

  我们要先说明一个问题： `dealloc` 方法其实是可以在子线程中调用的。

  为了搭建一个不错的UI页面和效果，我们可能会频繁的创建UI、使用`addSubView`方法、销毁UI。这里的创建、销毁都是需要进行内存操作。如果我们在销毁一个UI的时候，不小心在另外线程中进行了其他的操作（比如说改变颜色），欧吼，UI都没了，还怎么搞啊。这样寻找不到应有的UI，就会直接 crash（也应该 crash ）。那么为了解决这个问题，为了保障 UI 在不同线程的上的安全操作，还需要去**加锁**。好吧，这个是一个大消耗！

  而且，线程的创建和通信并非毫无消耗的。在子线程上操作UI，你需要频繁的进行线程的切换，尤其是一个控件上的子控件，操作不在一个线程上，可以想象这会造成多大的性能浪费。

  

- #### 渲染

  我们的 iOS，是基于 60FPS 构建的，也即是说，每两帧的中间时间是 16.67 ms。在这么短的时间里，会需要完成一个 UI 页面的整个创作。

  而一个页面 UI 的展示，是需要 CPU 和 GPU 协同合作的。CPU 负责显示内容的创建、布局计算、图片解码、文本绘制，然后再讲计算好的内容提交给 GPU ，让 GPU 去进行合成渲染；再接着，GPU 会将渲染的结果提交到帧缓冲区，等待展示到屏幕上。

  而如果在子线程上操作了 UI，最有可能出线两种情况：

  >会导致时间的不同步，页面错乱。本该在这个时间创建出来的 UI，结果在下一个渲染区间才出现。 多个线程都提出了 UI 的操作，CPU 需要从多个线程去获取将要渲染内容的各种计算，然后提交给 GPU 统一处理，这个本身就很难同步。

  CPU 和 GPU 渲染一个页面已经很累了，就不要再让它们干多余的事了。

  

- #### 事件循环和传递

  在 Cocoa Touch 中，在主线程上设置了 UIApplication 。这是启动应用程序时实例化的应用程序的第一部分，也是最主要的部分；它存在于最开始的那个自动创建的 MainRunloop 上。当我们点击某个控件的时候，产生了点击事件，是需要通过主线程的 Runloop 去传递和驱动。

  我们可以设想这个这样的情况，有多个子线程去创建了 button。而 button 的点击事件是需要传递到 Runloop 上才能继续的去传递。如果真的要进行了跨线程的事件传递，平白多耗费时间在切换线程上，会让事件延迟。

  并且，我们都知道，UI 的变化其实并不是瞬间的变化。如果真要这样，UI 一旦多了起来，光互相传递 UI 操作，让其他 UI 响应的信息就会随着 UI 数量的上升而指数型上升。

  这里打一个现实的比方。从中国到美国的货运飞机，相当大的一部分，是从中国少数几个起点城市，比如说北京、深圳等起飞，让后降落在少数几个美国城市，比如说西雅图和纽约（你可以从北极点上看地球，你就会发现，为什么会这么飞了）。为什么不让每个发货地都直飞收货地呢？ 相信你稍微算一下，就会明白了。

  所以，存在一个**总线**是有利于节约资源的，我们可以把主线程的 Runloop 当成事件的**总线**，所有的事件，不应该去跨越多个线程再传递到 Runloop 上，直接在统一的单独 Runloop 上收发，会节约 CPU 的资源。



- #### 在主线程上就一定是安全的吗？

先看一下`SDWebImage`的一段代码

```objective-c
#ifndef dispatch_queue_async_safe
#define dispatch_queue_async_safe(queue, block)\
    if (dispatch_queue_get_label(DISPATCH_CURRENT_QUEUE_LABEL) == dispatch_queue_get_label(queue)) {\
        block();\
    } else {\
        dispatch_async(queue, block);\
    }
#endif

#ifndef dispatch_main_async_safe
#define dispatch_main_async_safe(block) dispatch_queue_async_safe(dispatch_get_main_queue(), block)
#endif
```

是不是很奇怪，一般来说下面的代码就足够了啊，可以保证在主线程运行

```objective-c
if ([NSThread isMainThread]) {
       block();
} else {
   dispatch_async(dispatch_get_main_queue(), ^{
       block();
   })
}
```

在[github issues](https://github.com/ReactiveCocoa/ReactiveCocoa/issues/2635)上看到下面的讨论：

`24025596: MapKit: It's not safe to call MKMapView's addOverlay on a non-main-queue, even if it is executed on the main thread #7053`

在非主队列中调用`MKMapView`的 `addOverlay`方法是不安全的，即使是在主线程，也有可能造成崩溃。

>[@NachoSoto](https://link.juejin.im/?target=https%3A%2F%2Fgithub.com%2FNachoSoto) I contacted Apple DTS, they confirmed it is a [bug in MapKit](https://link.juejin.im/?target=https%3A%2F%2Fgithub.com%2Flionheart%2Fopenradar-mirror%2Fissues%2F7053). But they also cautioned that the pattern of [`dispatch_sync`](https://link.juejin.im/?target=https%3A%2F%2Fgithub.com%2FReactiveCocoa%2FReactiveCocoa%2Fblob%2F2a708b77%2FReactiveCocoa%2FSwift%2FSignalProducer.swift%23L182) and the [`isMainThread`](https://link.juejin.im/?target=https%3A%2F%2Fgithub.com%2FReactiveCocoa%2FReactiveCocoa%2Fblob%2F2a708b77%2FReactiveCocoa%2FSwift%2FScheduler.swift%23L77-L83) will likely run into more issues like this and the one reported by [@laptobbe](https://link.juejin.im/?target=https%3A%2F%2Fgithub.com%2Flaptobbe) above.
>
>They also explicitly stated that main queue and the main thread are not the same thing, but are have subtle differences, as shown in my demo app.
>
>



**在主队列中的任务，一定会放到主线程执行**
 所以只要是在主队列中的任务，既可以保证在主队列，也可以保证在主线程中执行。所以就可以通过判断当前队列是不是主队列来代替判断当前执行任务的线程是否是主线程，这样会更加安全。



- #### 如何防范子线程 UI？

  在实际操作中，子线程操作 UI 还是偶有发生的一个重要原因就是————如果你真的在子线程进行了 UI 操作，它不是必然崩溃的！很多时候写着写着就这么过去了。

  为了防止这个问题，实际上有两种解决办法。

  >1. hook 所有的 UIView 的 `setNeedsLayout`、`setNeedsDisplay`、`setNeedsDisplayInRect:` 的方法，让它们直接在开发阶段就发出提醒。
  >2. hook 所有的 UIView 的 `setNeedsLayout`、`setNeedsDisplay`、`setNeedsDisplayInRect:` 的方法，在线上做好防护，让所有子线程的 UI 操作强制回到主线程上去。

  在这里，我强烈推荐第一种方法。这里引用[DoraemonKit](https://github.com/didi/DoraemonKit)的方法。

  ```objective-c
  @implementation UIView (Doraemon)
  
  + (void)load{
      [[self  class] doraemon_swizzleInstanceMethodWithOriginSel:@selector(setNeedsLayout) swizzledSel:@selector(doraemon_setNeedsLayout)];
      [[self class] doraemon_swizzleInstanceMethodWithOriginSel:@selector(setNeedsDisplay) swizzledSel:@selector(doraemon_setNeedsDisplay)];
      [[self class] doraemon_swizzleInstanceMethodWithOriginSel:@selector(setNeedsDisplayInRect:) swizzledSel:@selector(doraemon_setNeedsDisplayInRect:)];
  }
  
  - (void)doraemon_setNeedsLayout{
      [self doraemon_setNeedsLayout];
      [self uiCheck];
  }
  
  - (void)doraemon_setNeedsDisplay{
      [self doraemon_setNeedsDisplay];
      [self uiCheck];
  }
  
  - (void)doraemon_setNeedsDisplayInRect:(CGRect)rect{
      [self doraemon_setNeedsDisplayInRect:rect];
      [self uiCheck];
  }
  
  - (void)uiCheck{
      if([[DoraemonCacheManager sharedInstance] subThreadUICheckSwitch]){
          if(![NSThread isMainThread]){
              NSString *report = [BSBacktraceLogger bs_backtraceOfCurrentThread];
              NSDictionary *dic = @{
                                    @"title":[DoraemonUtil dateFormatNow],
                                    @"content":report
                                    };
              [[DoraemonSubThreadUICheckManager sharedInstance].checkArray addObject:dic];
          }
      }
  }
  
  @end
  ```

  