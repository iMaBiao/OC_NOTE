Singleton

```
static Tools *_instance = nil;


+ (instancetype)shareInstance
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [[self alloc] init];;
    });
    return _instance;
}

//当我们调用shareInstance方法时获取到的对象是相同的，但是当我们通过alloc和init来构造对象的时候，得到的对象却是不一样的。所以加上以下方法

+ (instancetype)allocWithZone:(struct _NSZone *)zone {  
    return [Tools shareInstance];  
}  

- (id)copyWithZone:(struct _NSZone *)zone {  
    return [Tools shareInstance];  
} 

- (id)mutableCopyWithZone:(struct _NSZone *)zone{
   return [Tools shareInstance]; 
}
@end
```
