#### UITableView的优化2

1. Cell重用

2. 定义一种(尽量少)类型的Cell及善用hidden隐藏(显示)subviews

    2.1>一种类型的Cell

       分析Cell结构，尽可能的将 相同内容的抽取到一种样式Cell中，前面已经提到了Cell的重用机制，这样就能保证UITbaleView要显示多少内容，真正创建出的Cell可能只比屏幕显示的Cell多一点。虽然Cell的’体积’可能会大点，但是因为Cell的数量不会很多，完全可以接受的。好处：

- 减少代码量，减少Nib文件的数量，统一一个Nib文件定义Cell，容易修改、维护

- 基于Cell的重用，真正运行时铺满屏幕所需的Cell数量大致是固定的，设为N个。所以如果如果只有一种Cell，那就是只有N个Cell的实例；但是如果有M种Cell，那么运行时最多可能会是“M x N = MN”个Cell的实例，虽然可能并不会占用太多内存，但是能少点不是更好吗。

           2.2>善用hidden隐藏(显示)subviews

   只定义一种Cell，那该如何显示不同类型的内容呢？答案就是，把所有不同类型的view都定义好，放在cell里面，通过hidden显示、隐藏，来显示不同类型的内容。毕竟，在用户快速滑动中，只是单纯的显示、隐藏subview比实时创建要快得多。



3. 提前计算并缓存Cell的高度





4.异步绘制（自定义Cell绘制）

   遇到比较复杂的[界面](https://www.baidu.com/s?wd=%E7%95%8C%E9%9D%A2&tn=24004469_oem_dg&rsv_dl=gh_pl_sl_csd)的时候，如复杂点的图文混排，上面的那种优化行高的方式可能就不能满足要求了，当然了，由于我的开发经验尚短，说实话，还没遇到要将自定义的Cell重新绘制。至于这方面，大家可以参考这篇博客，绝对是开发经验十足的大神，分享足够多的UITableView方面的性能优化，好多借鉴自这里，我都不好意思了。[http://www.cocoachina.com/ios/20150602/11968.html]





5.滑动时，按需加载

   开发的过程中，自定义Cell的种类[千奇百怪](https://www.baidu.com/s?wd=%E5%8D%83%E5%A5%87%E7%99%BE%E6%80%AA&tn=24004469_oem_dg&rsv_dl=gh_pl_sl_csd)，但Cell本来就是用来显示数据的，不说100%带有图片，也差不多，这个时候就要考虑，下滑的过程中可能会有点卡顿，尤其网络不好的时候，异步加载图片是个程序员都会想到，但是如果给每个循环对象都加上异步加载，开启的线程太多，一样会卡顿，我记得好像线程条数一般3-5条，最多也就6条吧。这个时候利用UIScrollViewDelegate两个代理方法就能很好地解决这个问题。

```
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
```



思想就是识别UITableView禁止或者减速滑动结束的时候，进行异步加载图片，快滑动过程中，只加载目标范围内的Cell，这样按需加载，极大的提高流畅度。而SDWebImage可以实现异步加载，与这条性能配合就完美了，尤其是大量图片展示的时候。而且也不用担心图片缓存会造成内存警告的问题。

```
//获取可见部分的Cell
NSArray *visiblePaths = [self.tableView indexPathsForVisibleRows];
        for (NSIndexPath *indexPath in visiblePaths)
        {
        //获取的dataSource里面的对象，并且判断加载完成的不需要再次异步加载
             <code>
        }
```

记得在记得在“tableView:cellForRowAtIndexPath:”方法中加入判断：

```
// tableView 停止滑动的时候异步加载图片
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
 
         if (self.tableView.dragging == NO && self.tableView.decelerating == NO)
            {
               //开始异步加载图片
                <code>
            }
```



6.缓存View

   当Cell中的部分View是非常独立的，并且不便于重用的，而且“体积”非常小，在内存可控的前提下，我们完全可以将这些view缓存起来。当然也是缓存在模型中。



7.避免大量的图片缩放、颜色渐变等，尽量显示“大小刚好合适的图片资源



8.避免同步的从网络、文件获取数据，Cell内实现的内容来自web，使用异步加载，缓存请求结果



9.渲染

   9.1>减少subviews的个数和层级

      子控件的层级越深，渲染到屏幕上所需要的计算量就越大；如多用drawRect绘制元素，替代用view显示

   9.2>少用subviews的透明图层

      对于不透明的View，设置opaque为YES，这样在绘制该View时，就不需要考虑被View覆盖的其他内容（尽量设置Cell的view为opaque，避免GPU对Cell下面的内容也进行绘制）

   9.3>避免CALayer特效（shadowPath）

      给Cell中View加阴影会引起性能问题，如下面代码会导致滚动时有明显的卡顿：

```
view.layer.shadowColor = color.CGColor;
view.layer.shadowOffset = offset;
view.layer.shadowOpacity = 1;
view.layer.shadowRadius = radius;
```



总结：UITableView的优化主要从三个方面入手:

- 提前计算并缓存好高度（布局），因为heightForRowAtIndexPath:是调用最频繁的方法；(这个是开发中肯定会要优化的，不可能一个app就几个Cell吧)

- 滑动时按需加载，防止卡顿，这个我也认为是很有必要做的性能优化，配合SDWebImage

- 异步绘制，遇到复杂界面，遇到性能瓶颈时，可能就是突破口（如题，遇到复杂的界面，可以从这入手）

- 缓存一切可以缓存的，这个在开发的时候，往往是性能优化最多的方向
