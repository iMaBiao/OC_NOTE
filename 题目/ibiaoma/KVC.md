#### KVC

[iOS KVC底层原理、应用场景](https://blog.csdn.net/qq_27909209/article/details/81106631)



###### 1、`setValue: forKey: `的执行流程

>查找方法： `setKey:`    ` _setKey:` ，如果找到了就传递参数进行调用，如果没有找到，就进行下一步；
>
>调用 `accessInstanceVariablesDirectly`方法，返回NO的话就调用`setValue：forUndefineKey:`并抛出异常，但如果返回 YES的话，就进行下一步查找；
>
>按照 `_key`  `_isKey`  `key`   `isKey` 的顺序查找，找到了就直接赋值，没找到就调用 `setValue: forUndefineKey:` 并抛出异常



###### 2、`valueForKey:`的执行流程

>查找方法按照 `getKey`  `key` `isKey` `_key`  顺序查找，找到了就调用方法，如果未找到，就进行下一步；
>
>调用 `accessInstanceVariablesDirectly`方法，返回NO 的话就调用`valueForUndefineKey:`并抛出异常，如果返回YES的话，就进行下一步；
>
>按照 `_key` `_isKey` `key`  `isKey` 的顺序查找，找到了就直接取值，没有找到 就调用 `valueForUndefineKey:` 并抛出异常



###### 3、`setValue:forKey`会触发KVO吗？

> 会，因为会调用setter方法，即使类没有写setter方法，系统内部也会自动补充然后调用setter方法。



###### 4、KVC异常处理？

>KVC中最常见的异常就是不小心使用了错误的`key`，或者在设值中不小心传递了`nil`的值，KVC中有专门的方法来处理这些异常。
>
>通常在用KVC操作Model时，抛出异常的那两个方法是需要重写的。
>
>虽然一般很小出现传递了错误的Key值这种情况，但是如果不小心出现了，直接抛出异常让APP崩溃显然是不合理的。
>
>一般在这里直接让这个`key`打印出来即可，或者有些特殊情况需要特殊处理。通常情况下，KVC不允许你要在调用`setValue：属性值 forKey：@”name“`(或者keyPath)时**对非对象**传递一个`nil`的值。
>
>很简单，因为值类型是不能为`nil`的。如果你不小心传了，KVC会调用`setNilValueForKey:`方法。这个方法默认是抛出异常，所以一般而言最好还是重写这个方法。
>
>  [people1 setValue:nil forKey:@"age"]
>
>   *** Terminating app due to uncaught exception 'NSInvalidArgumentException', reason: '[<People 0x100200080> setNilValueForKey]: could not set nil as the value for the key age.' 
>
>*// 调用setNilValueForKey抛出异常*
>
>
>
>如果重写`setNilValueForKey:`就没问题了
>
>```
>@implementation People
> 
>-(void)setNilValueForKey:(NSString *)key{
>    NSLog(@"不能将%@设成nil",key);
>}
>@end
>
>//打印：KVCDemo[1304:92472] 不能将age设成ni
>```
>
> 



##### 5、自己手动实现一个KVC ?

前面我们对析了KVC是怎么搜索`key`的。所以如果明白了`key`的搜索顺序，是可以自己写代码实现KVC的。在考虑到集合和`keyPath`的情况下，KVC的实现会比较复杂，我们只写代码实现最普通的取值和设值即可。

```objective-c
//下面为简单实现，待完善
@interface NSObject(MYKVC)
  
- (void)setMyValue:(id)value forKey:(NSString*)key;
- (id)myValueforKey:(NSString*)key;
 
@end
  
@implementation NSObject(MYKVC)
- (void)setMyValue:(id)value forKey:(NSString *)key{
  
    if (key == nil || key.length == 0) {  //key名要合法
        return;
    }
  
    if ([value isKindOfClass:[NSNull class]]) {
        [self setNilValueForKey:key]; //如果需要完全自定义，那么这里需要写一个setMyNilValueForKey，但是必要性不是很大，就省略了
        return;
    }
  
    if (![value isKindOfClass:[NSObject class]]) {
        @throw @"must be s NSObject type";
        return;
    }
 
    NSString* funcName = [NSString stringWithFormat:@"set%@:",key.capitalizedString];
    if ([self respondsToSelector:NSSelectorFromString(funcName)]) {  //默认优先调用set方法
        [self performSelector:NSSelectorFromString(funcName) withObject:value];
        return;
    }
  	
  	//运行时遍历所有属性，找到差不多同名的
    unsigned int count;
    BOOL flag = false;
    Ivar* vars = class_copyIvarList([self class], &count);
    for (NSInteger i = 0; i<count; i++) {
        Ivar var = vars[i];
        NSString* keyName = [[NSString stringWithCString:ivar_getName(var) encoding:NSUTF8StringEncoding] substringFromIndex:1];
        
        if ([keyName isEqualToString:[NSString stringWithFormat:@"_%@",key]]) {
            flag = true;
            object_setIvar(self, var, value);
            break;
        }
        
        
        if ([keyName isEqualToString:key]) {
            flag = true;
            object_setIvar(self, var, value);
            break;
        }
    }
  
    if (!flag) {
        [self setValue:value forUndefinedKey:key];//如果需要完全自定义，那么这里需要写一个self setMyValue:value forUndefinedKey:key，但是必要性不是很大，就省略了
    }
}
 
- (id)myValueforKey:(NSString *)key{
  
    if (key == nil || key.length == 0) {
        return [NSNull new]; //其实不能这么写的
    }
  
    //这里为了更方便，我就不做相关集合的方法查询了
    NSString* funcName = [NSString stringWithFormat:@"gett%@:",key.capitalizedString];
    if ([self respondsToSelector:NSSelectorFromString(funcName)]) {
       return [self performSelector:NSSelectorFromString(funcName)];
    }
 
    unsigned int count;
    BOOL flag = false;
    Ivar* vars = class_copyIvarList([self class], &count);
    for (NSInteger i = 0; i<count; i++) {
        Ivar var = vars[i];
        NSString* keyName = [[NSString stringWithCString:ivar_getName(var) encoding:NSUTF8StringEncoding] substringFromIndex:1];
        if ([keyName isEqualToString:[NSString stringWithFormat:@"_%@",key]]) {
            flag = true;
            return  object_getIvar(self, var);
            break;
        }
        if ([keyName isEqualToString:key]) {
            flag = true;
            return  object_getIvar(self, var);
            break;
        }
    }
    if (!flag) {
        [self valueForUndefinedKey:key];//如果需要完全自定义，那么这里需要写一个self myValueForUndefinedKey，但是必要性不是很大，就省略了
    }
   return [NSNull new]; //其实不能这么写的
}
@end
 
 
Address* add = [Address new];
add.country = @"China";
add.province = @"Guang Dong";
add.city = @"Shen Zhen";
add.district = @"Nan Shan";
 
[add setMyValue:nil forKey:@"area"];            //测试设置 nil value
[add setMyValue:@"UK" forKey:@"country"];
[add setMyValue:@"South" forKey:@"area"];
[add setMyValue:@"300169" forKey:@"postCode"];
NSLog(@"country:%@  province:%@ city:%@ postCode:%@",add.country,add.province,add.city,add._postCode);
NSString* postCode = [add myValueforKey:@"postCode"];
NSString* country = [add myValueforKey:@"country"];
NSLog(@"country:%@ postCode: %@",country,postCode);
 
//打印结果：
 
2016-04-19 14:29:39.498 KVCDemo[7273:275129] country:UK  province:South city:Shen Zhen postCode:300169
2016-04-19 14:29:39.499 KVCDemo[7273:275129] country:UK postCode: 300169

```



##### 6、kvc的使用

>1、动态地取值和设值，利用KVC动态的取值和设值是最基本的用途了。
>
>2、用KVC来访问和修改私有变量
>
>​	对于类里的私有属性，Objective-C是无法直接访问的，但是KVC是可以的
>
>3、Model和字典转换，运用了KVC和Objc的`runtime`组合的技巧
>
>4、修改一些控件的内部属性
>
>​	最常用的就是个性化UITextField中的placeHolderText了。但iOS13之后这样做就不允许上架了。
>
>​	改用以下方式：
>
>```objective-c
>self.textField.attributedPlaceholder = [[NSAttributedString alloc]initWithString:@"请输入密码" attributes:@{NSForegroundColorAttributeName : [UIColor colorWithHexString:@"cccccc"] }];
>```
>
>