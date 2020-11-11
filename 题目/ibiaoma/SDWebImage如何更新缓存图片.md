# SDWebImage是如何做到Url不变的情况下，更新图片内容的？



https://blog.csdn.net/jiadabin/article/details/52129789



#### 1. 问题引入


SDWebImage以其便捷性深受开发者欢迎，不过长期使用以后，可能你会发现的有时候也不是那么给力？

  主要问题表现在哪里呢？

 很多app都有用户的概念，用户一般都会有头像，基本上都上传到服务器上，而服务器往往也支持在pc端更新头像。

 如果你的头像使用SDWebImage设置的，那么你会发现，pc端更新头像后，客户端可能（往往）不会自动更新！！！

 很多开发者会建议你设置SDWebImageRefreshCached标识，甚至SDWebImage的官网也这么说！

  那么SDWebImageRefreshCached到底能否解决我们的问题呢？



#### 2. 原理分析

我们来简单探讨一下SDWebImage的实现原理：

 SDWebImageManager内部利用SDWebImageDownloader来下载，它的缓存策略有两种，一种是用NSURL缓存，一种是自己定义了SDImageCache（内部使用NSCache）进行缓存。



 如果设置了SDWebImageRefreshCached标示位，那么SDWebImageDownloader则利用NSURL进行缓存，而且使用的policy为NSURLRequestUseProtocolCachePolicy。

 

 那么如果设置了SDWebImageRefreshCached标识位，图片是否更新则要取决于你服务器的cache-control设置了，如果没有cache-control的话，客户端则然享受不了自动更新的功能。

 所以说仅仅设置SDWebImageRefreshCached往往是不能解决问题的。。。。

 那么如何查看服务器是否支持cache-control呢？

 其实简单，只需要要终端输入 curl [url] --head，即可。

如下图：

![](./img/sd_curl_img.png)



那么如何让SDWebImage支持自动更新呢？
 实现方法有几种：

1. ##### 让服务器更新url，也就是说服务器端如果更新了头像，那么就生成新的url(推荐)

2. ##### 让服务器端支持cache-control

3. ##### 修改SDWebImage，让它支持http的Last-Modified或者etag（前提是服务器端也要支持）



----



https://blog.csdn.net/lizhilin_vip/article/details/53185423



 SDWebImage在iOS项目中是一个很常用的开源库，而且众所周知的是，它是基于URL作为Key来实现图片缓存机制的。

在90%左右的情况下，图片与URL是一一对应的，即使服务器修改了图片也会相应的变更URL。但是在少数情况下，服务器修改了图片后不会变更相应的URL，也就是说图片本身的内容变了然而它的URL没有变化，那么按照对SDWebImage的常规使用方法的话，客户端肯定更新不到同一URL对应到服务器已变更的图片内容。



基于这一现象，我们来进行分析。

客户端第一次请求图片时，Charles抓包得知response header里有一个名为Last-Modified、数据是时间戳的键值对。

客户端第二次及以后请求图片时，通过Charles抓包发现，服务器返回304 not modified状态，说明服务器在接收客户端请求后通过某种判断逻辑得出结论：“客户端已缓存的图片与服务器图片都是最新的”，那么服务器如何判断的呢？

通过查阅HTTP协议相关的资料得知，与服务器返回的Last-Modified相对应的request header里可以加一个名为If-Modified-Since的key，value即是服务器回传的服务端图片最后被修改的时间，第一次图片请求时If-Modified-Since的值为空，第二次及以后的客户端请求会把服务器回传的Last-Modified值作为If-Modified-Since的值传给服务器，这样服务器每次接收到图片请求时就将If-Modified-Since与Last-Modified进行比较，如果客户端图片已陈旧那么返回状态码200、Last-Modified、图片内容，客户端存储Last-Modified和图片；如果客户端图片是最新的那么返回304 Not Modified、不会返回Last-Modified、图片内容。

关于服务器的比较逻辑，需要强调一下。

经查资料得知，Apache比较时是看If-Modified-Since之后有没有更新图片，Nginx比较时是看If-Modified-Since与Last-Modified是否相等，所以对于Apache服务器环境客户端每次都要严格的存储服务器回传的Last-Modified以便下次请求时作为If-Modified-Since的值传给服务器，对于Nginx服务器环境客户端不必存储服务器回传的Last-Modified，每次请求时只需将图片自身的fileModificationDate作为If-Modified-Since的值传服务器即可。在实际开发中，如果遇到明明传了If-Modified-Since、服务器图片也变更了、但是客户端却请求不到最新的图片的情况时，那么就需要查看一下服务器对这两个时间戳的比较逻辑。

那么，现在我们可以回到SDWebImage上来了。通过查看SDWebImageDownloader的源码得知，它开放了一个headersFilter的block，意在让开发者可以对所有图片请求追加一些额外的header，这正合我意。那么我们就可以在诸如AppDelegate didFinishLaunching的地方追加如下代码：

```objective-c
SDWebImageDownloader *imgDownloader = SDWebImageManager.sharedManager.imageDownloader;
imgDownloader.headersFilter  = ^NSDictionary *(NSURL *url, NSDictionary *headers) {
 
    NSFileManager *fm = [[NSFileManager alloc] init];
    NSString *imgKey = [SDWebImageManager.sharedManager cacheKeyForURL:url];
    NSString *imgPath = [SDWebImageManager.sharedManager.imageCache defaultCachePathForKey:imgKey];
    NSDictionary *fileAttr = [fm attributesOfItemAtPath:imgPath error:nil];
 
    NSMutableDictionary *mutableHeaders = [headers mutableCopy];
 
    NSDate *lastModifiedDate = nil;
 
    if (fileAttr.count > 0) {
        if (fileAttr.count > 0) {
            lastModifiedDate = (NSDate *)fileAttr[NSFileModificationDate];
        }
 
    }
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.timeZone = [NSTimeZone timeZoneWithAbbreviation:@"GMT"];
    formatter.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
    formatter.dateFormat = @"EEE, dd MMM yyyy HH:mm:ss z";
 
    NSString *lastModifiedStr = [formatter stringFromDate:lastModifiedDate];
    lastModifiedStr = lastModifiedStr.length > 0 ? lastModifiedStr : @"";
    [mutableHeaders setValue:lastModifiedStr forKey:@"If-Modified-Since"];
 
    return mutableHeaders;
};
```

 

然后，加载图片的地方以前怎么写还是怎么写，但别忘了Option是SDWebImageRefreshCached

```objective-c
NSURL *imgURL = [NSURL URLWithString:@"http://handy-img-storage.b0.upaiyun.com/3.jpg"];
[[self imageView] sd_setImageWithURL:imgURL
                    placeholderImage:nil
                             options:SDWebImageRefreshCached];
```



#### 知识扩展

>1. 其实，在抓取服务器返回的数据包时，还发现response header中还有一个ETag，与之相对应的request header中可以追加一个
>2. If-None-Match的key，这对header与Last-Modified、If-Modified-Since的作用是相同的，即服务器是否需要返回最新的图片，
>3. 当然它们在服务器端的判断逻辑应该是等与不等的判断，Etag在客户端的存储同样可以采用在plist文件中存放图片key名称与Etag的对应
>4. 关系。





补充：

[浏览器缓存详解:expires, cache-control, last-modified, etag详细说明](https://blog.csdn.net/xiaoke815/article/details/76686901)

