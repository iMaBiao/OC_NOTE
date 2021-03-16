## UITableView具体优化



https://juejin.cn/post/6844903740940501005



常见的：

- Cell复用机制 

- Cell高度预先计算 ， 提前计算好cell的高度,缓存在相应的数据源模型

- 缓存一切可以缓存的，这个在开发的时候，往往是性能优化最多的方向；

  - 比如缓存Cell高度，

  - 展示cell是需要用到的某些数据

    

- 圆角切割，使用绘图方式

  - 让服务器直接传圆角图片
  - `YYWebImage`为例，可以先下载图片，再对图片进行圆角处理，再设置到`cell`上显示

  

- 尽量少用或不用透明图层

  

- 滑动过程中尽量减少重新布局

  - 不要频繁的改动布局

    

- 不要阻塞主线程， 避免**同步**的从网络、文件获取数据，

  - cell内实现的内容来自web，使用异步加载，缓存请求结果

    

- 不要在cell内添加过多view，

  -  善用hidden隐藏(显示)subviews

  - 不要动态的增加、删除cell内部的子view

    

- 避免大量的图片缩放、颜色渐变等，尽量显示“大小刚好合适的图片资源

  

- 滑动时按需加载

  - 处于滚动状态，不加载图片；滚动结束的时候，获取当前界面内可见的所有`cell`
  - 处于快速滚动时，不加载图片，当滚动速度小于某个区间值的时候再从网络加载未加载过的图片



```
/**
   runloop - 滚动时候 - trackingMode，
   - 默认情况 - defaultRunLoopMode
   ==> 滚动的时候，进入`trackingMode`，defaultMode下的任务会暂停
   停止滚动的时候 - 进入`defaultMode` - 继续执行`trackingMode`下的任务 - 例如这里的loadImage
   */
  [self performSelector:@selector(p_loadImgeWithIndexPath:)
             withObject:indexPath
             afterDelay:0.0
                inModes:@[NSDefaultRunLoopMode]];

```

