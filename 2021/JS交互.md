# OC与JS交互



### 1、 UIWebView

#### JS调OC

先用普通的方式"request拦截"，我们都知道webView在调用一个Url之前会走：

`- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType`

这个代理，我们看到有NSURLRequest这个类型的参数，而从这个request中可以获取到JS调用的url。

1、request.URL.scheme
我们通过scheme路由发放响应

```objc
if ([request.URL.scheme.lowercaseString isEqualToString:@"lfjstooc"]) {
    return NO;//webview停止继续加载
}
```

2、request.URL.pathComponents
通过pathComponents获取函数名和参数

```objc
NSArray *arr = request.URL.pathComponents;
/*
(
    "/",
    secondClick,//方法名
    "this is the message"//一个NSString类型参数
)
*/
```

3、调用OC方法
当然调用OC方法可以有很多种，`[self methodName]`直接调也行，`performSelector: withObject:`这种方式也行，我这里用`objc_msgSend`

```
objc_msgSend(self, sel, arr[2]);
```

综上：

```objc
- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    //拦截JS的回调
    if ([request.URL.scheme.lowercaseString isEqualToString:@"lfjstooc"]) {
        NSArray *arr = request.URL.pathComponents;
        SEL sel = NULL;
        if (arr.count > 2) {//表示调用js调用的方法有参数
            sel = NSSelectorFromString([NSString stringWithFormat:@"%@:",arr[1]]);
        } else if(arr.count == 2) {//js调用OC，数组中至少得有两个元素
            sel = NSSelectorFromString(arr[1]);
        }
        objc_msgSend(self, sel, arr[2]);//调用对应的OC方法
        
        return NO;
    }
    return YES;
}
```

#### OC调JS

OC调 JS 我们选择用 UIWebView 的**`stringByEvaluatingJavaScriptFromString`**方法，比如调用js的docoument.title方法获取当前页面的标题。

```objc
NSString *title = [webView stringByEvaluatingJavaScriptFromString:@"document.title"];
self.title = title;
```



## WKWebView



先设置`WKWebViewConfiguration`，这个类主要有以下东西需要设置

```objc
WKWebViewConfiguration *config = [[WKWebViewConfiguration alloc]init];
```

- WKPreferences 设置对象

```objc
WKPreferences *preference = [[WKPreferences alloc]init];
//最小字体大小 当将javaScriptEnabled属性设置为NO时，可以看到明显的效果
preference.minimumFontSize = 0;
preference.javaScriptEnabled = YES;
// 在iOS上默认为NO，表示是否允许不经过用户交互由javaScript自动打开窗口
preference.javaScriptCanOpenWindowsAutomatically = YES;
config.preferences = preference;

 // 是使用h5的视频播放器在线播放, 还是使用原生播放器全屏播放
config.allowsInlineMediaPlayback = YES;
 //设置视频是否需要用户手动播放  设置为NO则会允许自动播放
config.requiresUserActionForMediaPlayback = YES;
//设置是否允许画中画技术 在特定设备上有效
config.allowsPictureInPictureMediaPlayback = YES;
```



- WKUserContentController OC与JS交互的管理类

```objc
//添加OC和JS交互的一些参数

WKUserContentController *wkUserController = [[WKUserContentController alloc] init];
//提供给JS 调用的方法名
[wkUserController addScriptMessageHandler:weakScriptMessageDelegate name:@"beginSavePhoto"];
[wkUserController addScriptMessageHandler:weakScriptMessageDelegate name:@"beginCallPhone"];
[wkUserController addScriptMessageHandler:weakScriptMessageDelegate name:@"beginCopyService"];
config.userContentController = wkUserController;
```



##### WKWebView初始化

```
_wkWebView = [[WKWebView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT) configuration:config];
_wkWebView.navigationDelegate = self;
_wkWebView.UIDelegate = self;
```



#### JS调OC

我们使用WKScriptHandler交互需要JS按照如下格式调用，下面是JS需要写的代码：

```js
window.webkit.messageHandlers.<name>.postMessage(<messageBody>)
```

JS调用OC的代码，而OC这边接收需要遵守协议`WKScriptMessageHandler`，实现代理方法

```objc
- (void)userContentController:(WKUserContentController *)userContentController didReceiveScriptMessage:(WKScriptMessage *)message {
    NSDictionary *dic = message.body;
    //进行OC方法调用
    SEL sel = NSSelectorFromString([NSString stringWithFormat:@"%@:", dic[@"action"]]);
    objc_msgSend(self, sel, dic[@"token"]);
}
```



#### OC调用JS

OC调用JS使用WKWebView的`evaluateJavaScript`方法就行

```objc
NSString *jsFunctStr = [NSString stringWithFormat:@"showImageOnDiv('%@')",imageString];
//OC调用JS
[self.wkWebView evaluateJavaScript:jsFunctStr completionHandler:^(id _Nullable name, NSError * _Nullable error) {
    NSLog(@"完事儿");
}];
```

