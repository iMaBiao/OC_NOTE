#### iOS一些常见的优化方案

**TableViewCell 复用**

在cellForRowAtIndexPath:回调的时候只创建实例，快速返回cell，不绑定数据。在willDisplayCell: forRowAtIndexPath:的时候绑定数据（赋值）。

**高度缓存**

在tableView滑动时，会不断调用heightForRowAtIndexPath:，当cell高度需要自适应时，每次回调都要计算高度，会导致 UI 卡顿。为了避免重复无意义的计算，需要缓存高度。

**不要用JPEG的图片，应当使用PNG图片。**

子线程预解码（Decode），主线程直接渲染。因为当image没有Decode，直接赋值给imageView会进行一个Decode操作。

优化图片大小，尽量不要动态缩放(contentMode)。

尽可能将多张图片合成为一张进行显示。

**减少透明view**

使用透明view会引起blending，在iOS的图形处理中，blending主要指的是混合像素颜色的计算。最直观的例子就是，我们把两个图层叠加在一起，如果第一个图层的透明的，则最终像素的颜色计算需要将第二个图层也考虑进来。这一过程即为Blending。

**会导致blending的原因：**

UIView的alpha<1。

UIImageView的image含有alpha channel（即使UIImageView的alpha是1，但只要image含有透明通道，则仍会导致blending）。

为什么blending会导致性能的损失？

原因是很直观的，如果一个图层是不透明的，则系统直接显示该图层的颜色即可。而如果图层是透明的，则会引起更多的计算，因为需要把另一个的图层也包括进来，进行混合后的颜色计算。

opaque设置为YES，减少性能消耗，因为GPU将不会做任何合成，而是简单从这个层拷贝。

**减少离屏渲染**

离屏渲染指的是在图像在绘制到当前屏幕前，需要先进行一次渲染，之后才绘制到当前屏幕。

OpenGL中，GPU屏幕渲染有以下两种方式：

**On-Screen**

Rendering即当前屏幕渲染，指的是GPU的渲染操作是在当前用于显示的屏幕缓冲区中进行。

**Off-Screen**

Rendering即离屏渲染，指的是GPU在当前屏幕缓冲区以外新开辟一个缓冲区进行渲染操作。
