#### isKindOfClass和isMemberOfClass区别

源码

```objective-c
+ (BOOL)isMemberOfClass:(Class)cls {
    return object_getClass((id)self) == cls;
}

- (BOOL)isMemberOfClass:(Class)cls {
    return [self class] == cls;
}

+ (BOOL)isKindOfClass:(Class)cls {
  	//比较元类对象
    for (Class tcls = object_getClass((id)self); tcls; tcls = tcls->superclass) {
        if (tcls == cls) return YES;
    }
    return NO;
}

- (BOOL)isKindOfClass:(Class)cls {
	  //比较类对象
    for (Class tcls = [self class]; tcls; tcls = tcls->superclass)     {
        if (tcls == cls) return YES;
    }
    return NO;
}
```



#### isMemberOfClass

```objective-c
一个对象是否是指定类的实例对象

- (BOOL)isMemberOfClass:(Class)cls {
    return [self class] == cls;
}

+ (BOOL)isMemberOfClass:(Class)cls {
    return object_getClass((id)self) == cls;
}
```



```objective-c
int main(int argc, const char * argv[]) {
    @autoreleasepool {
          
        Person *p = [[Person alloc]init];
      	//NSObject的类对象与元类对象比较
        NSLog(@"%d",[[NSObject class]isMemberOfClass:[NSObject class]]);
      	
        NSLog(@"%d",[[Person class]isMemberOfClass:[NSObject class]]);
      
        NSLog(@"%d",[p isMemberOfClass:[NSObject class]]);
      
        NSLog(@"%d",[p isMemberOfClass:[Person class]]);
        
    }
    return 0;
}

打印： 
interview[32743:1298401] 0
interview[32743:1298401] 0
interview[32743:1298401] 0
interview[32743:1298401] 1

```



#### isKindOfClass

判断一个对象是否是指定类或者某个从该类继承类的实例对象

```objective-c
- (BOOL)isKindOfClass:(Class)cls {
    for (Class tcls = [self class]; tcls; tcls = tcls->superclass) {
    if (tcls == cls) return YES;
}
    return NO;
}
```



```objective-c
int main(int argc, const char * argv[]) {
    @autoreleasepool {

        Person *p = [[Person alloc]init];
      
        NSLog(@"%d",[[NSObject class]isKindOfClass:[NSObject class]]);

      	//NSObject的元类对象的superClass指向NSObject的类对象
        NSLog(@"%d",[[Person class]isKindOfClass:[NSObject class]]);
      	
      	//Person的元类对象与类对象比较
        NSLog(@"%d",[[Person class]isKindOfClass:[Person class]]);
      	
      	//Person的元类相比较 
        NSLog(@"%d",[[Person class]isKindOfClass:object_getClass([Person class])]);
      
        NSLog(@"%d",[p isKindOfClass:[NSObject class]]);
        NSLog(@"%d",[p isKindOfClass:[Person class]]);
    }
    return 0;
}

打印： 
interview[32843:1302480] 1
interview[32843:1302480] 1
interview[32843:1302480] 0
interview[32843:1302480] 1
interview[32843:1302480] 1
interview[32843:1302480] 1
```



需要注意类的查找方式：

- 实例对象isa指向类对象，类对象isa指向元类对象
- 对象的superClass 指向父类。
- `Person`  和  `[Person class]`是相等的
