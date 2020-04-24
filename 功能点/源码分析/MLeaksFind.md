# MLeaksFinder

#####  iOS 平台的自动内存泄漏检测工具

https://github.com/Tencent/MLeaksFinder

摘录： https://www.jianshu.com/p/5a7e8360ba3f

​			https://juejin.im/post/5dabb6d7e51d4522780f22b8



###  使用

```objective-c
pod 'MLeaksFinder'
```

在运行时（debug 模式下）帮助你检测项目里的内存泄露，无需修改任何业务逻辑代码，而且只在 debug 下开启，完全不影响你的 release 包。

团队博客： http://wereadteam.github.io/2016/07/20/MLeaksFinder2/



#### 三种提示：

- 「Memory Leak」： 当离开视图页面时，如果该页面视图控制图／其中的视图存在内存泄漏时，会弹出「Memory Leak」警告框，展示存在内存泄漏问题的相关视图控制器／视图堆栈信息

【OK】【Retain Cycle】

```objective-c
 Memory Leak: (
	"GSPopulationEditInfoViewController",
	"UIView",
	"UITextField",
)
```

- 「Retain Cycle」：点击Retain Cycle按钮后，会显示「Retain Cycle」警告框，展示引发内存泄漏的具体循环引用信息
- 「 Object Deallocated 」： 当发现可能的内存泄漏对象并弹出「Memory Leak」警告框之后，MLeaksFinder 会进一步地追踪该对象的生命周期。如果该对象最终能释放，则在该对象释放时给出「 Object Deallocated 」的 alert ，据此可推断出该对象存在释放不及时的问题，可能需要进一步优化；



#### 原理

MLeaksFinder 的基本原理是这样的，当一个 ViewController 被 pop 或 dismiss 之后，我们认为该 ViewController，包括它上面的子 ViewController，以及它的 View，View 的 subView 等等，都很快会被释放（除非设计成单例，或者持有它的强引用，但一般很少这样做），如果某个 View 或者 ViewController 没释放，我们就认为该对象泄漏了。



#### 基本实现：

为基类 NSObject 添加一个方法 `-willDealloc` ，它先用一个弱指针指向 self，并在一小段时间 (2秒) 后，通过这个弱指针调用 `-assertNotDealloc`，而 `-assertNotDealloc` 主要作用是打印堆栈信息 (早期版本是直接中断言，不过那样会打断正常的开发工作)。

当我们认为某个对象应该要被释放了，在释放前调用 `-assertNotDealloc` ，如果 2 秒后它被释放成功，weakSelf 就指向 nil，`-assertNotDealloc` 方法就不会执行（向 nil 发送消息，实际什么也不会做），如果它没被释放，`-assertNotDealloc` 就会执行，从而打印出堆栈信息。

于是，当一个NavigationController 或 UIViewController 被 pop 或 dismiss 时，我们遍历它的所有 view，依次调 `-willDealloc`（对 `-willDealloc` 的调用是通过 method-swizzle 追加到 pop/dismiss 方法中的），若 2 秒后没被释放，就会打印相关堆栈信息。



#### 从UIViewController开始看起：

通过`UIViewController+MemoryLeak.h`的`load`方法可以看出，交换了`viewDidDisappear:、viewWillAppear:、dismissViewControllerAnimated:completion:`三个方法。

```objective-c
UIViewController+MemoryLeak.m
  
+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [self swizzleSEL:@selector(viewDidDisappear:) withSEL:@selector(swizzled_viewDidDisappear:)];
        [self swizzleSEL:@selector(viewWillAppear:) withSEL:@selector(swizzled_viewWillAppear:)];
        [self swizzleSEL:@selector(dismissViewControllerAnimated:completion:) withSEL:@selector(swizzled_dismissViewControllerAnimated:completion:)];
    });
}

```

#### 交换后的`viewDidDisappear：`

```objective-c
UIViewController+MemoryLeak.m

// 先取出了 kHasBeenPoppedKey 对应的值，这个值是在右滑返回上个页面并触发 pop 时，设置为 YES 的，说明当前 ViewController 要销毁了，所以在这个时候调用了 -willDealloc 方法。
- (void)swizzled_viewDidDisappear:(BOOL)animated {
    [self swizzled_viewDidDisappear:animated];
    
    if ([objc_getAssociatedObject(self, kHasBeenPoppedKey) boolValue]) {
        [self willDealloc];
    }
}

//与上边对应，这里是在当前 ViewController 的视图展示出来的时候，将 kHasBeenPoppedKey 关联的值设为 NO，即当前 ViewController 没有通过右滑返回。
- (void)swizzled_viewWillAppear:(BOOL)animated {
  [self swizzled_viewWillAppear:animated];
    
  objc_setAssociatedObject(self, kHasBeenPoppedKey, @(NO), OBJC_ASSOCIATION_RETAIN);
}

//前边两个方法是针对滑动返回做的处理，这里是针对通过 present 的对象 dismiss 时的操作，即如果当前 ViewController 没有 presentedViewController，就直接调用当前 ViewController 的 -willDealloc 方法检测内泄。
- (void)swizzled_dismissViewControllerAnimated:(BOOL)flag completion:(void (^)(void))completion {
    [self swizzled_dismissViewControllerAnimated:flag completion:completion];
    
    UIViewController *dismissedViewController = self.presentedViewController;
    if (!dismissedViewController && self.presentingViewController) {
        dismissedViewController = self;
    }
    
    if (!dismissedViewController) return;
    
    [dismissedViewController willDealloc];
}
```

#### 调用`willDealloc`方法

```objective-c
UIViewController+MemoryLeak.m

- (BOOL)willDealloc {
    if (![super willDealloc]) {
        return NO;
    }
    
    [self willReleaseChildren:self.childViewControllers];
    [self willReleaseChild:self.presentedViewController];
    
    if (self.isViewLoaded) {
        [self willReleaseChild:self.view];
    }
    
    return YES;
}
```

###### 通过super调用父类的`-willDealloc`

```objective-c
NSObject+MemoryLeak.m

- (BOOL)willDealloc {
  ///1、首先通过`classNamesWhitelist`检测白名单，如果对象在白名单之中，便`return NO`，即不是内存泄漏。
    NSString *className = NSStringFromClass([self class]);
    if ([[NSObject classNamesWhitelist] containsObject:className])
        return NO;
  /// 2、判断该对象是否是上一次发送action的对象，是的话，不进行内存检测
    NSNumber *senderPtr = objc_getAssociatedObject([UIApplication sharedApplication], kLatestSenderKey);
    if ([senderPtr isEqualToNumber:@((uintptr_t)self)])
        return NO;
  /// 3、弱指针指向self，2s延迟，然后通过这个弱指针调用-assertNotDealloc，若被释放，给nil发消息直接返回，不触发-assertNotDealloc方法，认为已经释放；如果它没有被释放（泄漏了），-assertNotDealloc就会被调用
    __weak id weakSelf = self;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        __strong id strongSelf = weakSelf;
        [strongSelf assertNotDealloc];
    });
    
    return YES;
}
```

构建白名单时，使用了单例，确保只有一个，方法是私有的；

（如果需要添加新的白名单，就在此方法中添加）

```objective-c
+ (NSMutableSet *)classNamesWhitelist {
    static NSMutableSet *whitelist = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        whitelist = [NSMutableSet setWithObjects:
                     @"UIFieldEditor", // UIAlertControllerTextField
                     @"UINavigationBar",
                     @"_UIAlertControllerActionView",
                     @"_UIVisualEffectBackdropView",
                     nil];
        
        // System's bug since iOS 10 and not fixed yet up to this ci.
        NSString *systemVersion = [UIDevice currentDevice].systemVersion;
        if ([systemVersion compare:@"10.0" options:NSNumericSearch] != NSOrderedAscending) {
            [whitelist addObject:@"UISwitch"];
        }
    });
    return whitelist;
}

另外，用户也可以自行添加额外的类名，方法如下：
+ (void)addClassNamesToWhitelist:(NSArray *)classNames {
    [[self classNamesWhitelist] addObjectsFromArray:classNames];
}
```



#### 接着``willDealloc`会调用`-willReleaseChildren、-willReleaseChild`遍历该对象的子对象，判断是否释放

```objective-c
NSObject+MemoryLeak.m
  
- (void)willReleaseChildren:(NSArray *)children {
    NSArray *viewStack = [self viewStack];
    NSSet *parentPtrs = [self parentPtrs];
    for (id child in children) {
        NSString *className = NSStringFromClass([child class]);
        [child setViewStack:[viewStack arrayByAddingObject:className]];
        [child setParentPtrs:[parentPtrs setByAddingObject:@((uintptr_t)child)]];
        [child willDealloc];
    }
}

- (void)willReleaseChild:(id)child {
    if (!child) {
        return;
    }
    
    [self willReleaseChildren:@[ child ]];
}

// 1、拿到当前对象的 viewStack 和 parentPtrs，然后遍历 children，为每一个 child 设置 viewStack 和 parentPtrs ，而且是将自己 (child) 加进去了的。

// 2、执行 [child willDealloc]; ，结合前边提到的 willDealloc 知道，这就去检测子类了。
```

通过代码可以看出，`-willReleaseChildren`拿到当前对象的`viewStack`和`parentPtrs`，然后遍历`children`，为每个子对象设置`viewStack`和`parentPtrs`。 然后会执行`[child willDealloc]`，去检测子类。



看下`viewStack`与`parentPtrs`的get和set实现方法

```objective-c
NSObject+MemoryLeak.m

//`viewStack` 与 `parentPtrs` 两者实现方法类似，通过运行时机制，即利用关联对象给一个类添加属性信息，只不过前者是一个数组，后者是一个集合。
  
- (NSArray *)viewStack {
    NSArray *viewStack = objc_getAssociatedObject(self, kViewStackKey);
    if (viewStack) {
        return viewStack;
    }
    
    NSString *className = NSStringFromClass([self class]);
    return @[ className ];
}

- (void)setViewStack:(NSArray *)viewStack {
    objc_setAssociatedObject(self, kViewStackKey, viewStack, OBJC_ASSOCIATION_RETAIN);
}
//viewStack 是一个数组，存放的是类名，从 getter 可以看出来，初次使用时，直接将当前类名作为第一个元素添加进去了。

- (NSSet *)parentPtrs {
    NSSet *parentPtrs = objc_getAssociatedObject(self, kParentPtrsKey);
    if (!parentPtrs) {
        parentPtrs = [[NSSet alloc] initWithObjects:@((uintptr_t)self), nil];
    }
    return parentPtrs;
}

- (void)setParentPtrs:(NSSet *)parentPtrs {
    objc_setAssociatedObject(self, kParentPtrsKey, parentPtrs, OBJC_ASSOCIATION_RETAIN);
}

```





延迟 2 秒执行 `-assertNotDealloc` 方法；

关联对象`parentPtrs`，会在`-assertNotDealloc`中，会判断当前对象是否与父节点集合有交集。下面仔细看下`-assertNotDealloc`方法

```objective-c
- (void)assertNotDealloc {
  	// 1.检测父控件体系中是否有没被释放的
    if ([MLeakedObjectProxy isAnyObjectLeakedAtPtrs:[self parentPtrs]]) {
        return;
    }
    [MLeakedObjectProxy addLeakedObject:self];
    // 2.打印堆栈信息
    NSString *className = NSStringFromClass([self class]);
    NSLog(@"Possibly Memory Leak.\nIn case that %@ should not be dealloced, override -willDealloc in %@ by returning NO.\nView-ViewController stack: %@", className, className, [self viewStack]);
  //打印 viewStack 这个数组，数组里存放的是从父对象到子对象，一直到当前对象的类名。
}

判断当前对象父控件的层级体系中是否有没被释放的对象，如果有就不往下执行了，否则把自己加进去，并打印堆栈信息。

因为父对象的 -willDealloc 会先执行，所以如果父对象一定会销毁的话，那么也应该是先销毁，即先从 MLeakedObjectProxy 中移除，加了这个判断之后，就不会出现一个堆栈中出现多个未释放对象的情况。
```



这里调用了`MLeakedObjectProxy`类中的`+isAnyObjectLeakedAtPtrs`

```objective-c
MLeakedObjectProxy.m

+ (BOOL)isAnyObjectLeakedAtPtrs:(NSSet *)ptrs {
    NSAssert([NSThread isMainThread], @"Must be in main thread.");
    // 1.初始化 leakedObjectPtrs
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        leakedObjectPtrs = [[NSMutableSet alloc] init];
    });
    
    if (!ptrs.count) {
        return NO;
    }
   // 2.检测 `leakedObjectPtrs` 与 `ptrs` 之间是否有交集
   // 当 leakedObjectPtrs 中 至少有一个对象也出现在 ptrs 中时，返回 YES。
    if ([leakedObjectPtrs intersectsSet:ptrs]) {
        return YES;
    } else {
        return NO;
    }
}
```

该方法中初始化了一个单例对象`leakedObjectPtrs`，通过`leakedObjectPtrs`与传入的参数`[self parentPtrs]`检测他们的交集，传入的 ptrs 中是否是泄露的对象。



如果上述方法返回的是NO，则继续调用下面方法`+addLeakedObject`

```objective-c
MLeakedObjectProxy.m

+ (void)addLeakedObject:(id)object {
    NSAssert([NSThread isMainThread], @"Must be in main thread.");

  /// 1、构造MLeakedObjectProxy对象，给传入的泄漏对象 object 关联一个代理即 proxy
    MLeakedObjectProxy *proxy = [[MLeakedObjectProxy alloc] init];
    proxy.object = object;
    proxy.objectPtr = @((uintptr_t)object);
    proxy.viewStack = [object viewStack];
  
  ///2、通过objc_setAssociatedObject()方法，object强持有proxy， proxy若持有object，如果object释放，proxy也会释放
    static const void *const kLeakedObjectProxyKey = &kLeakedObjectProxyKey;
    objc_setAssociatedObject(object, kLeakedObjectProxyKey, proxy, OBJC_ASSOCIATION_RETAIN);
    
  /// 3、存储 proxy.objectPtr（实际是对象地址）到集合 leakedObjectPtrs 里边
    [leakedObjectPtrs addObject:proxy.objectPtr];
    
  
  /// 4、弹框 AlertView若 _INTERNAL_MLF_RC_ENABLED == 1，则弹框会增加检测循环引用的选项；若 _INTERNAL_MLF_RC_ENABLED == 0，则仅展示堆栈信息。
#if _INTERNAL_MLF_RC_ENABLED
    [MLeaksMessenger alertWithTitle:@"Memory Leak"
                            message:[NSString stringWithFormat:@"%@", proxy.viewStack]
                           delegate:proxy
              additionalButtonTitle:@"Retain Cycle"];
#else
    [MLeaksMessenger alertWithTitle:@"Memory Leak"
                            message:[NSString stringWithFormat:@"%@", proxy.viewStack]];
#endif
}

/*
做了这么几件事：
	1、给传入的泄漏对象 object 关联一个代理即 proxy
	2、存储 proxy.objectPtr（实际是对象地址）到集合 leakedObjectPtrs 里边
	3、弹框 AlertView：若 _INTERNAL_MLF_RC_ENABLED == 1，则弹框会增加检测循环引用的选项；若 			_INTERNAL_MLF_RC_ENABLED == 0，则仅展示堆栈信息。
*/
```

对于`MLeakedObjectProxy`类而言，是检测到内存泄漏才产生的，作为泄漏对象的属性存在的，如果泄漏的对象被释放，那么`MLeakedObjectProxy`也会被释放，则调用`-dealloc`函数



集合`leakedObjectPtrs`中移除该对象地址，同时再次弹窗，提示该对象已经释放了

```objective-c
- (void)dealloc {
    NSNumber *objectPtr = _objectPtr;
    NSArray *viewStack = _viewStack;
    dispatch_async(dispatch_get_main_queue(), ^{
        [leakedObjectPtrs removeObject:objectPtr];
        [MLeaksMessenger alertWithTitle:@"Object Deallocated"
                                message:[NSString stringWithFormat:@"%@", viewStack]];
    });
}
```



当点击弹框中的检测循环引用按钮时，相关的操作都在下面 `AlertView` 的代理方法里边，即异步地通过 `FBRetainCycleDetector` 检测循环引用，然后回到主线程，利用弹框提示用户检测结果。







### 遇到的坑

- ##### UITextField 在iOS11下 导致的内存泄漏

```objective-c
 Memory Leak: (
	"GSPopulationEditInfoViewController",
	"UIView",
	"UITextField",
)
```



通过查看了[苹果开发者论坛](https://forums.developer.apple.com/thread/94323)和github上面另一个内存检测的框架的讨论，初步鉴定为UITextField本身的内存泄漏，也就是在iOS系统中没有对它做好内存管理。



解决方案:   https://github.com/Tencent/MLeaksFinder/issues/80

**推荐第二种**

```objective-c
第一种方式：

目前可以添加下列类别来暂时屏蔽掉误报问题（不用设置头文件，直接在项目中创建即可）：
#import <UIKit/UIKit.h>

@interface UITextField (MemoryLeak)

@end

#import "UITextField+MemoryLeak.h"
#import "NSObject+MemoryLeak.h"

@implementation UITextField (MemoryLeak)

- (BOOL)willDealloc {
    
    return NO;
}

@end
```



```objective-c
第二种方式：

框架的提供者有为我们提供了一个更好的解决方法：就是白名单，把UITextField加入到白名单内就好了。
在框架的NSObject+MemoryLeak.m 这个文件下 ，第114行的函数就是返回白名单数组，在这个方法里面添加2行代码，判断一下当前版本是否是11以上，然后将UITextField加入白名单即可，iOS11以下也能监测UITextField的内存泄漏问题

+ (NSMutableSet *)classNamesWhitelist {
    static NSMutableSet *whitelist = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        whitelist = [NSMutableSet setWithObjects:
                     @"UIFieldEditor", // UIAlertControllerTextField
                     @"UINavigationBar",
                     @"_UIAlertControllerActionView",
                     @"_UIVisualEffectBackdropView",
                     nil];
        
        // System's bug since iOS 10 and not fixed yet up to this ci.
        NSString *systemVersion = [UIDevice currentDevice].systemVersion;
        if ([systemVersion compare:@"10.0" options:NSNumericSearch] != NSOrderedAscending) {
            [whitelist addObject:@"UISwitch"];
        }
       // 将UITextField加入白名单
        if ([systemVersion compare:@"11.0" options:NSNumericSearch] != NSOrderedAscending) {
            [whitelist addObject:@"UITextField"];
        }
    });
    return whitelist;
}
```

