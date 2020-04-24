Singleton

```
+ (instancetype)shareInstance
{
    static Tools *_instance = nil;
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



在程序中，一个单例类在程序中只能初始化一次，为了保证在使用中始终都是存在的，所以单例是在存储器的`全局区域`，在编译时分配内存，只要程序还在运行就会一直占用内存，在APP结束后由系统释放这部分内存内存。
