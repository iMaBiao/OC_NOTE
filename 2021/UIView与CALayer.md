## UIView 与 CALayer



https://www.jianshu.com/p/3a1f06c6183c?utm_campaign=hugo&utm_medium=reader_share&utm_content=note&utm_source=weixin-friends



#### UIView 负责响应事件，CALayer 负责绘制 UI

首先从继承关系来分析两者：`UIView : UIResponder`，`CALayer : NSObject`。



#### UIView 响应事件

UIView 继承 UIResponder，而 UIResponder 是响应者对象，实现了如下 API，所以继承自 UIResponder 的都具有响应事件的能力：

```objc
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(nullable UIEvent *)event;
- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(nullable UIEvent *)event;
- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(nullable UIEvent *)event;
- (void)touchesCancelled:(NSSet<UITouch *> *)touches withEvent:(nullable UIEvent *)event;
- (void)touchesEstimatedPropertiesUpdated:(NSSet<UITouch *> *)touches NS_AVAILABLE_IOS(9_1);
```



并且 UIView 提供了以下两个方法，来进行 iOS 中的事件的响应及传递（响应者链）：

```objc
- (nullable UIView *)hitTest:(CGPoint)point withEvent:(nullable UIEvent *)event;
- (BOOL)pointInside:(CGPoint)point withEvent:(nullable UIEvent *)event;  
```



#### CALayer 绘制 UI

CALayer 没有继承自 UIResponder，所以 CALayer 不具备响应处理事件的能力。CALayer 是 QuartzCore 中的类，是一个比较底层的用来绘制内容的类。



### UIView 对 CALayer 封装属性

UIView 中持有一个 layer 对象，同时还是这个 layer 对象 delegate，UIView 和 CALayer 协同工作。

#### 为什么UIView要加一层Layer来负责显示呢？

我们知道 QuartzCore 是跨 iOS 和 macOS 平台的，而 UIView 属于 UIKit 是 iOS 开发使用的，在 macOS 中对应 AppKit 里的 NSView。这是因为 macOS 是基于鼠标指针操作的系统，与 iOS 的多点触控有本质的区别。虽然 iOS 在交互上与 macOS 有所不同，但在显示层面却可以使用同一套技术。



**每一个UIView都有个属性layer、默认为CALayer类型，也可以使用自定义的Layer**

```objc
 // returns view's layer. Will always return a non-nil value. view is layer's delegate
@property(nonatomic,readonly,strong)                 CALayer  *layer;             
```



可以想象我们看到的View其实都是它的 layer，下面我们通过 CALayer 中的集合相关的属性来认识它

```objc
/* The bounds of the layer. Defaults to CGRectZero. Animatable. */
@property CGRect bounds;	//图层的bounds是一个CGRect的值，指定图层的大小（bounds.size)和原点(bounds.origin)

/* The position in the superlayer that the anchor point of the layer's
 * bounds rect is aligned to. Defaults to the zero point. Animatable. */
@property CGPoint position;	//指定图层的位置(相对于父图层而言)

/* The Z component of the layer's position in its superlayer. Defaults
 * to zero. Animatable. */
@property CGFloat zPosition;

/* Defines the anchor point of the layer's bounds rect, as a point in
 * normalized layer coordinates - '(0, 0)' is the bottom left corner of
 * the bounds rect, '(1, 1)' is the top right corner. Defaults to
 * '(0.5, 0.5)', i.e. the center of the bounds rect. Animatable. */
@property CGPoint anchorPoint;
//锚点指定了position在当前图层中的位置，坐标范围0~1。position点的值是相对于父图层的，而这个position到底位于当前图层的什么地方，是由锚点决定的。(默认在图层的中心，即锚点为(0.5,0.5) )

/* The Z component of the layer's anchor point (i.e. reference point for
 * position and transform). Defaults to zero. Animatable. */
@property CGFloat anchorPointZ;

/* A transform applied to the layer relative to the anchor point of its
 * bounds rect. Defaults to the identity transform. Animatable. */
@property CATransform3D transform;	//指定图层的几何变换，类型为上篇说过的CATransform3D
```

这些属性的注释最后都有一句`Animatable`，就是说我们可以通过改变这些属性来实现动画。

**默认地，我们修改这些属性都会导致图层从`旧值动画显示为新值`，称为`隐式动画`。**



**Layer 中很多属性都是 animatable 的，这就意味着修改这些属性会产生隐式动画。当是如果修改 UIView 主 Layer 的话，此时隐式动画会失效，因为：`UIView 默认情况下禁止了 layer 动画，但是在 animation block 中又重新启用了它们。`**



当一个 animatable 属性变化时，Layer 会询问代理方法该如何处理这个动画，即需要在代理方法中返回合适的 `CAAction` 对象。

**属性改变时 layer 会向 view 请求一个动作，而一般情况下 view 将返回一个 `NSNull`，只有当属性改变发生在动画 block 中时，view 才会返回实际的动作。**



```objc
/* Unlike NSView, each Layer in the hierarchy has an implicit frame
 * rectangle, a function of the `position', `bounds', `anchorPoint',
 * and `transform' properties. When setting the frame the `position'
 * and `bounds.size' are changed to match the given frame. */

@property CGRect frame;
```

注意到 frame的注释里面是没有Animatable的。

事实上，**我们可以理解为图层的`frame并不是一个真实的属性`：当我们读取frame时，会根据图层position、bounds、anchorPoint和transform的值计算出它的frame；而当我们设置frame时，图层会根据anchorPoint改变position和bounds。`也就是说frame本身并没有被保存`。**

Frame 属性主要是依赖：bounds、anchorPoint、transform、和position。



平时我们对 UIView 设置 frame、center、bounds 等位置信息，其实都是 UIView 对 CALayer 进一层封装，使得我们可以很方便地设置控件的位置；例如圆角、阴影等属性， UIView 就没有进一步封装，所以我们还是需要去设置 Layer 的属性来实现功能。



我们这主要说一下 anchorPoint 和 position 如何影响 Frame 的：anchorPoint 锚点是相对于当前 Layer 的一个点，position 是 Layer 中 anchorPoint 锚点在 superLayer 中的点，即 position 是由 anchorPoint 来确认的。

1、position 是 layer 中的 anchorPoint 在 superLayer 中的位置坐标。

2、单独修改 position 与 anchorPoint 中任何一个属性都不影响另一个属性。



**图层不但给自己提供可视化的内容和管理动画，而且充当了其他图层的容器类，构建图层层次结构**

图层树类似于 UIView 的层次结构，一个 view 实例拥有父视图 (superView) 和子视图 (subView) ；同样一个layer也有父图层(superLayer)和子图层(subLayer)。我们可以直接在 view 的 layer上添加子 layer达到一些显示效果，但这些单独的layer无法像UIView那样进行交互响应。

##### 

## 隐式动画

每个view都有一个layer，但是也有一些不依附view单独存在的layer，如CAShapelayer。它们不需要附加到 view 上就可以在屏幕上显示内容。

基本上你改变一个单独的 layer 的任何属性的时候，都会触发一个从旧的值过渡到新值的简单动画（这就是所谓的隐式动画）。然而，如果你改变的是 view 中 layer 的同一个属性，它只会从这一帧直接跳变到下一帧。尽管两种情况中都有 layer，但是当 layer 附加在 view 上时，它的默认的隐式动画的 layer 行为就不起作用了。

在 Core Animation 编程指南的 “How to Animate Layer-Backed Views” 中，对为什么会这样做出了一个解释：

`UIView` 默认情况下禁止了 `layer` 动画，但是在 `animation block` 中又重新启用了它们。

是因为任何可动画的 layer 属性改变时，`layer` 都会寻找并运行合适的 `action`来实行这个改变。在 `Core Animation` 的专业术语中就把这样的动画统称为动作 (`action`，或者 `CAAction`)。

`layer` 通过向它的 `delegate` 发送`actionForLayer:forKey:`消息来询问提供一个对应属性变化的 `action`。`delegate` 可以通过返回以下三者之一来进行响应：

1. 它可以返回一个动作对象，这种情况下 `layer` 将使用这个动作。
2. 它可以返回一个 `nil`， 这样 `layer` 就会到其他地方继续寻找。
3. 它可以返回一个 `NSNull` 对象，告诉`layer` 这里不需要执行一个动作，搜索也会就此停止。

当`layer`在背后支持一个`view` 的时候，`view` 就是它的 `delegate`。





### UIView 是 CALayer 的代理

UIView 持有一个 CALayer 的属性，并且是该属性的代理，用来提供一些 CALayer 行的数据，例如动画和绘制。

UIView遵守了**CALayerDelegate**协议

```objc
 @interface UIView : UIResponder <NSCoding, UIAppearance, UIAppearanceContainer, UIDynamicItem, UITraitEnvironment, UICoordinateSpace, UIFocusItem, UIFocusItemContainer, CALayerDelegate>
```



```objc
@protocol CALayerDelegate <NSObject>
@optional

/* If defined, called by the default implementation of the -display
 * method, in which case it should implement the entire display
 * process (typically by setting the `contents' property). */
- (void)displayLayer:(CALayer *)layer;

/* If defined, called by the default implementation of -drawInContext: */
- (void)drawLayer:(CALayer *)layer inContext:(CGContextRef)ctx;	//绘制相关

/* If defined, called by the default implementation of the -display method.
 * Allows the delegate to configure any layer state affecting contents prior
 * to -drawLayer:InContext: such as `contentsFormat' and `opaque'. It will not
 * be called if the delegate implements -displayLayer. */
- (void)layerWillDraw:(CALayer *)layer
  API_AVAILABLE(macos(10.12), ios(10.0), watchos(3.0), tvos(10.0));

/* Called by the default -layoutSublayers implementation before the layout
 * manager is checked. Note that if the delegate method is invoked, the
 * layout manager will be ignored. */
- (void)layoutSublayersOfLayer:(CALayer *)layer;

/* If defined, called by the default implementation of the
 * -actionForKey: method. Should return an object implementing the
 * CAAction protocol. May return 'nil' if the delegate doesn't specify
 * a behavior for the current event. Returning the null object (i.e.
 * '[NSNull null]') explicitly forces no further search. (I.e. the
 * +defaultActionForKey: method will not be called.) */
- (nullable id<CAAction>)actionForLayer:(CALayer *)layer forKey:(NSString *)event;	//动画相关

@end
```



### 绘制相关

CALayer 在屏幕上绘制东西是因为 CALayer 内部有一个 contents (CGImage)的属性，contents 也被称为寄宿图。

```objc
/* An object providing the contents of the layer, typically a CGImageRef,
 * but may be something else. (For example, NSImage objects are
 * supported on Mac OS X 10.6 and later.) Default value is nil.
 * Animatable. */

@property(nullable, strong) id contents;
```



绘制相关的 API 如下：

```objc
@protocol CALayerDelegate <NSObject>
@optional
- (void)displayLayer:(CALayer *)layer;
- (void)drawLayer:(CALayer *)layer inContext:(CGContextRef)ctx;	
@end
```

```objc
@interface UIView(UIViewRendering)
- (void)drawRect:(CGRect)rect;
- (void)setNeedsDisplay;
- (void)setNeedsDisplayInRect:(CGRect)rect;
@end
```



### drawRect 方法实现

平时为自定义 View 添加空间或者在上下文画图都会使用到这个函数，但是如果当我们实现了这个方法的时候，这个时候会生成一张寄宿图，这个寄宿图的尺寸是 layer 的宽 * 高 * contentsScale，其实算出来的是有多少像素。然后每个像素占用 4 个字节，总共消耗的内存大小为：宽 * 高 * contentsScale * 4 字节。



这里跟我们图片显示是一个道理：一张图片需要解压成位图才能显示到屏幕上，图片的颜色空间一般是 RGBA，每个像素点需要包含 RGBA 四个信息，所以一张图片解压成位图需要占用内存大小为：像素宽 * 像素高 * 4 个字节。（PS：将图片解压成位图是比较耗时的，这就是为什么通常会在子线程解压图片，然后再到主线程中显示，避免卡主主线程）



所以在使用 drawRect 方法来实现功能之前，需要看看是否有替代方案，避免产生寄宿图增加程序的内存，使用 CAShapeLayer 来绘制是一个不错的方案。



## 总结

通过了解 UIView 与 CALayer 是如何相互协同工作的，在之后的开发也可以选择相应的技术来实现功能，

如果确定是不需要交互的，可以将 UIView 替换成 CALayer，来省去 UIView 封装带来的损耗，

**AsyncDisplayKit** 库利用 ASDisplayNode 来替代 UIView 来节省资源。



UIView持有一个`CALayer`负责展示，view是这个layer的`delegate`。改变view的属性实际上是在改变它持有的layer的属性，layer属性发生改变时会调用代理方法`actionForLayer: forKey:`来得知此次变化是否需要动画。对`同一个属性叠加动画`会从当前展示状态开始叠加并`最终`停在`modelLayer`的`真实`位置。

CALayer内部控制两个属性`presentationLayer`和`modelLayer`，`modelLayer`为当前`layer真实`的状态，`presentationLayer`为当前`layer`在`屏幕上展示的状态`。`presentationLayer`会在`每次屏幕刷新时更新状态`，如果有动画则根据动画获取当前状态进行绘制，动画移除后则取`modelLayer的状态`。



在 View显示的时候，UIView 做为 Layer 的`CALayerDelegate`,View 的显示内容取决于内部的 CALayer 的 `display`

CALayer 是默认修改属性支持隐式动画的，在给 UIView 的 Layer 做动画的时候，View 作为 Layer 的代理，Layer 通过 `actionForLayer:forKey:`向 View请求相应的`action`(动画行为)



layer 内部维护着三分`layer tree`,分别是 `presentLayer Tree`(动画树),`modeLayer Tree`(模型树), `Render Tree` (渲染树),在做 iOS动画的时候，我们修改动画的属性，在动画的其实是 Layer 的 presentLayer的属性值,而最终展示在界面上的其实是提供 View的`modelLayer`



两者最明显的区别是 View可以接受并处理事件，而 Layer 不可以



