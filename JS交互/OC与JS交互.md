#### OC与JS交互







1、创建WKWebView

```

- (WKWebView *)webView
{
    if (!_webView) {
        //创建网页配置对象
        WKWebViewConfiguration *config = [[WKWebViewConfiguration alloc]init];
         // 创建设置对象
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
        
        //自定义的WKScriptMessageHandler 是为了解决内存不释放的问题
        WeakWebViewScriptMessageDelegate *weakScriptMessageDelegate = [[WeakWebViewScriptMessageDelegate alloc]initWithDelegate:self];
        
        //这个类主要用来做native与JavaScript的交互管理
        WKUserContentController *wkUserController = [[WKUserContentController alloc]init];
        [wkUserController addScriptMessageHandler:weakScriptMessageDelegate name:@"jsToOcNoPrams"];
        [wkUserController addScriptMessageHandler:weakScriptMessageDelegate name:@"jsToOcWithPrams"];
        config.userContentController = wkUserController;
        
        //用于进行JavaScript注入
        WKUserScript *wkUserScript = [[WKUserScript alloc]initWithSource:@"" injectionTime:WKUserScriptInjectionTimeAtDocumentEnd forMainFrameOnly:YES];
        [config.userContentController addUserScript:wkUserScript];
        
        _webView = [[WKWebView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT) configuration:config];
        // UI代理
        _webView.UIDelegate = self;
        // 导航代理
        _webView.navigationDelegate = self;
        // 是否允许手势左滑返回上一级, 类似导航控制的左滑返回
        _webView.allowsBackForwardNavigationGestures = YES;
        
        //可返回的页面列表, 存储已打开过的网页
        WKBackForwardList *backForwardList = [_webView backForwardList];
        
#warning 第一次需要在url中获取cookie
        //如果加载时url且第一次需要在url中获取cookie
        //NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:@"http://www.chinadaily.com.cn"]];
        //[request addValue:[self readCurrentCookieWithDomain:@"http://www.chinadaily.com.cn"] forHTTPHeaderField:@"Cookie"];
        //[_webView loadRequest:request];
        
        //加载本地html
        NSString *path = [[NSBundle mainBundle]pathForResource:@"index.html" ofType:nil];
        NSString *htmlString = [[NSString alloc]initWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
        [_webView loadHTMLString:htmlString baseURL:[NSURL fileURLWithPath:[[NSBundle mainBundle] bundlePath]]];
    }
    return _webView;
}
```



2、OC调用JS

```
//OC调用JS
- (void)ocToJs
{
    //OC调用JS  changeColor()是JS方法名，completionHandler是异步回调block
    NSString *jsString = [NSString stringWithFormat:@"changeColor('%@')",@"I am param"];
    [_webView evaluateJavaScript:jsString completionHandler:^(id _Nullable data, NSError * _Nullable error) {
       NSLog(@"%s 改变HTML的背景色", __FUNCTION__);
    }];
    
    //改变字体大小 调用原生JS方法
    NSString *jsFont = [NSString stringWithFormat:@"document.getElementsByTagName('body')[0].style.webkitTextSizeAdjust = '%d%%'",arc4random()%99 + 100];
    [_webView evaluateJavaScript:jsFont completionHandler:^(id _Nullable data, NSError * _Nullable error) {
        NSLog(@"%s 改变字体大小", __FUNCTION__);
    }];
}
```

3、JS调用OC

```
#pragma mark - WKScriptMessageHandler
//js调用到了oc
//被自定义的WKScriptMessageHandler在回调方法里通过代理回调回来，绕了一圈就是为了解决内存不释放的问题
//通过接收JS传出消息的name进行捕捉的回调方法
- (void)userContentController:(WKUserContentController *)userContentController didReceiveScriptMessage:(WKScriptMessage *)message
{
    NSLog(@"%s name = %@", __FUNCTION__,message.name);
    NSLog(@"%s body = %@", __FUNCTION__,message.body);
    NSLog(@"%s frameInfo = %@", __FUNCTION__,message.frameInfo);
    //用message.body获得JS传出的参数体
    NSDictionary * parameter = message.body;
    //JS调用OC
    if ([message.name isEqualToString:@"jsToOcNoPrams"]) {
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"js调用到了oc" message:@"不带参数" preferredStyle:UIAlertControllerStyleAlert];
        [alertController addAction:([UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        }])];
        [self presentViewController:alertController animated:YES completion:nil];
    }else if ([message.name isEqualToString:@"jsToOcWithPrams"]){
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"js调用到了oc" message:parameter[@"params"] preferredStyle:UIAlertControllerStyleAlert];
        [alertController addAction:([UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        }])];
        [self presentViewController:alertController animated:YES completion:nil];
    }
}
```

4、web页中弹框的调用

```
#pragma mark -- WKUIDelegate
/**
 *  web界面中有弹出警告框时调用
 *
 *  @param webView           实现该代理的webview
 *  @param message           警告框中的内容
 *  @param completionHandler 警告框消失调用
 */
- (void)webView:(WKWebView *)webView runJavaScriptAlertPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(void))completionHandler
{
    NSLog(@"%s 警告框中的内容 message = %@", __FUNCTION__,message);
     completionHandler();
}
// 确认框
//JavaScript调用confirm方法后回调的方法 confirm是js中的确定框，需要在block中把用户选择的情况传递进去
- (void)webView:(WKWebView *)webView runJavaScriptConfirmPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(BOOL))completionHandler
{
    NSLog(@"%s JS调用confirm方法后回调的方法 确定框 message = %@", __FUNCTION__,message);
    completionHandler(YES);
}
// 输入框
//JavaScript调用prompt方法后回调的方法 prompt是js中的输入框 需要在block中把用户输入的信息传入
- (void)webView:(WKWebView *)webView runJavaScriptTextInputPanelWithPrompt:(NSString *)prompt defaultText:(NSString *)defaultText initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(NSString * _Nullable))completionHandler
{
    completionHandler(@"");
}

// 页面是弹出窗口 _blank 处理
- (WKWebView *)webView:(WKWebView *)webView createWebViewWithConfiguration:(WKWebViewConfiguration *)configuration forNavigationAction:(WKNavigationAction *)navigationAction windowFeatures:(WKWindowFeatures *)windowFeatures {
    if (!navigationAction.targetFrame.isMainFrame) {
        [webView loadRequest:navigationAction.request];
    }
    return nil;
}
```



5、cookie

https://www.jianshu.com/p/4fa8c4eb1316

以前UIWebView会自动去NSHTTPCookieStorage中读取cookie，但是WKWebView并不会去读取,因此导致cookie丢失以及一系列问题，解决方式就是在request中手动帮其添加上。



```
mainWebView.UIDelegate = self;
mainWebView.navigationDelegate = self;
NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:@"http://www.test.com"]];
[request addValue:[self readCurrentCookieWithDomain:@"http://www.test.com/"] forHTTPHeaderField:@"Cookie"];
[mainWebView loadRequest:request];

- (NSString *)readCurrentCookieWithDomain:(NSString *)domainStr{
    NSHTTPCookieStorage*cookieJar = [NSHTTPCookieStorage sharedHTTPCookieStorage];
    NSMutableString * cookieString = [[NSMutableString alloc]init];
    for (NSHTTPCookie*cookie in [cookieJar cookies]) {
        [cookieString appendFormat:@"%@=%@;",cookie.name,cookie.value];
    }

//删除最后一个“；”
    [cookieString deleteCharactersInRange:NSMakeRange(cookieString.length - 1, 1)];
    return cookieString;
}
```

但是这只能解决第一次进入的cookie问题，如果页面内跳转（a标签等）还是取不到cookie，因此还要再加代码。

```
- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation {

   //取出cookie
    NSHTTPCookieStorage *cookieStorage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
    //js函数
    NSString *JSFuncString =
@"function setCookie(name,value,expires)\
    {\
    var oDate=new Date();\
    oDate.setDate(oDate.getDate()+expires);\
document.cookie=name+'='+value+';expires='+oDate+';path=/'\
    }\
    function getCookie(name)\
    {\
    var arr = document.cookie.match(new RegExp('(^| )'+name+'=([^;]*)(;|$)'));\
    if(arr != null) return unescape(arr[2]); return null;\
    }\
    function delCookie(name)\
    {\
    var exp = new Date();\
    exp.setTime(exp.getTime() - 1);\
    var cval=getCookie(name);\
    if(cval!=null) document.cookie= name + '='+cval+';expires='+exp.toGMTString();\
    }";

    //拼凑js字符串
    NSMutableString *JSCookieString = JSFuncString.mutableCopy;
    for (NSHTTPCookie *cookie in cookieStorage.cookies) {
    NSString *excuteJSString = [NSString stringWithFormat:@"setCookie('%@', '%@', 1);", cookie.name, cookie.value];
        [JSCookieString appendString:excuteJSString];
    }
    //执行js
    [webView evaluateJavaScript:JSCookieString completionHandler:nil];

}
```











跨域问题

https://www.jianshu.com/p/91cfe58c032d
