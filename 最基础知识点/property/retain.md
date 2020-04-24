

MRC下如何重写 retain 修饰变量的 setter方法？



```
@property (nonatomic, retain) id obj;

- (void)setObj:(id)obj
{
    if(_obj != obj){
        [_obj release];
        _obj = [obj retain];
    }
}
```


