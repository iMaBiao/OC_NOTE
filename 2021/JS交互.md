# OC与JS交互



### iOS与JS交互的方法:

 1.拦截url (适用于UIWebView和WKWebView)

```objc
//拦截url
- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType{
    if ([request.URL.absoluteString isEqualToString:@"jxaction://scan"]) {
        //调用原生扫描二维码
        return NO;
    }
    return YES;
}

//原生调用js
//回调方法
[self.webView stringByEvaluatingJavaScriptFromString:@"scanResult('我是扫描结果~')"];
[self.wkWebView evaluateJavaScript:@"scanResult" completionHandler:^(id _Nullable result, NSError * _Nullable error) {
        //回调结果
}];
```

 2.JavaScriptCore (只适用于UIWebView, iOS7+)

```objc
//js调用原生
<1>新建类继承自NSObject(如AppJSObject)
<2>.h文件中声明一个代理并遵循JSExport，代理内的方法和js定义的方法名一致.
<3>.m文件中实现<2>代理中对应的方法，可以在方法内处理事件或通知代理.
  
//将AppJSObject实例注入到JS中 那么在js中调用方法就会调用到原生AppJSObject实例对象中对应的方法了。
- (void)webViewDidFinishLoad:(UIWebView *)webView{
    
    JSContext *context = [webView valueForKeyPath:@"documentView.webView.mainFrame.javaScriptContext"];
     
    AppJSObject *jsObject = [[AppJSObject alloc] init]; //AppJSObject的实例
    jsObject.delegate = self;
    context[@"app"] = jsObject;
    
}


//原生调用js
JSContext *context=[_mainWebView valueForKeyPath:@"documentView.webView.mainFrame.javaScriptContext"];
NSString *alertJS= [NSString stringWithFormat:@"%@('%@')",_photoMethod,fileUrl];
[context evaluateScript:alertJS];
```

 3.WKScriptMessageHandler(只适用与WKWebView, iOS8+)

```objc
<1>初始化WKWebView时，调用addScriptMessageHandler:name:方法，name为js中的方法名
    WKWebViewConfiguration *configuration = [[WKWebViewConfiguration alloc] init];

    configuration.userContentController = [[WKUserContentController alloc] init];

    [configuration.userContentController addScriptMessageHandler:self name:@"scan"];

<2>实现WKScriptMessageHandler代理方法，当js调用scan方法时，会回调此代理方法：
- (void)userContentController:(WKUserContentController *)userContentController didReceiveScriptMessage:(WKScriptMessage *)message{
    if ([message.name isEqualToString:@"scan"]) {
        //调用原生扫码
     }
}
```



 4.WebViewJavascriptBridge (适用于UIWebView和WKWebView, 属于第三方框架.以后会单讲这个框架)





### 详细使用

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





https://www.jianshu.com/p/2f6bb80a26fe

### WebViewJavascriptBridge

> WebViewJavascriptBridgeBase : 主要包括对bridge的处理，以及OC端消息收发的处理。
>  WKWebViewJavascriptBridge : 封装了一层WKWebView并实现了代理，代理主要负责拦截符合自己定制的规则的url，并通过WebViewJavascriptBridgeBase处理一些细节。
>  WebViewJavascriptBridge : 这主要是给UIWebview用的，和WKWebViewJavascriptBridge的逻辑差不多。
>  WebViewJavascriptBridge_JS :这个类是向JS中注入代码，负责JS端的消息处理和收发的工作。



##### WebViewJavascriptBridge的方法介绍

```objc
//为WKWebView添加与JS沟通的bridge桥梁
+ (instancetype)bridgeForWebView:(id)webView;
//注册JS调用OC的函数名，handler是JS给的回调
- (void)registerHandler:(NSString*)handlerName handler:(WVJBHandler)handler;
//移除JS与OC交互的函数名
- (void)removeHandler:(NSString*)handlerName;
//添加OC调用JS的函数名，无参数无回调
- (void)callHandler:(NSString*)handlerName;
//添加OC调用JS的函数名，有参数无回调
- (void)callHandler:(NSString*)handlerName data:(id)data;
//添加OC调用JS的函数名，有参数有回调
- (void)callHandler:(NSString*)handlerName data:(id)data responseCallback:(WVJBResponseCallback)responseCallback;
//若在WKWebView的VC中使用WKWebview的代理，就实现这个方法
- (void)setWebViewDelegate:(id)webViewDelegate;
```





##### WebViewJavascriptBridge的基本使用

- 在OC中使用

1、先为WKWebView添加与JS沟通的`bridge`桥梁

```objc
self.bridge = [WebViewJavascriptBridge bridgeForWebView:self.wkWebView];
//如果要在ViewController中实现代理，就设置这个方法
[self.bridge setWebViewDelegate:self];
```

2、JS调用OC
注册需要JS调用OC的函数名，`handler`是JS给的回调

```objc
//JS第一个按钮点击事件
[self.bridge registerHandler:@"firstClick" handler:^(id data, WVJBResponseCallback responseCallback) {
    //handler在主线程
    NSLog(@"thread = %@", [NSThread currentThread]);
    __strong typeof(self) strongSelf = weakSelf;
    [strongSelf firstClick:[data valueForKey:@"token"]];
    responseCallback([NSString stringWithFormat:@"成功调用OC的%@方法", [data valueForKey:@"action"]]);
}];
```

需要注意的是
1）这个handler回调是在主线程
2）循环引用



3、OC调用JS
添加OC调用JS的函数名，有参数有回调

```objc
[self.bridge callHandler:@"showTextOnDiv" data:@"这是OC调用JS方法" responseCallback:^(id responseData) {
    NSLog(@"JS给的回调responseData = %@", responseData);
}];
```

