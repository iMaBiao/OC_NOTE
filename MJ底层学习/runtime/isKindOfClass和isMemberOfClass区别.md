#### isKindOfClass和isMemberOfClass区别

源码

```
+ (BOOL)isMemberOfClass:(Class)cls {
    return object_getClass((id)self) == cls;
}

- (BOOL)isMemberOfClass:(Class)cls {
    return [self class] == cls;
}

+ (BOOL)isKindOfClass:(Class)cls {
    for (Class tcls = object_getClass((id)self); tcls; tcls = tcls->superclass) {
        if (tcls == cls) return YES;
    }
    return NO;
}

- (BOOL)isKindOfClass:(Class)cls {
    for (Class tcls = [self class]; tcls; tcls = tcls->superclass)     {
        if (tcls == cls) return YES;
    }
    return NO;
}
```

##### isMemberOfClass

```
一个对象是否是指定类的实例对象

- (BOOL)isMemberOfClass:(Class)cls {
    return [self class] == cls;
}

+ (BOOL)isMemberOfClass:(Class)cls {
    return object_getClass((id)self) == cls;
}
```

![](img/isMemberOfClass.png)

##### isKindOfClass

判断一个对象是否是指定类或者某个从该类继承类的实例对象

```
- (BOOL)isKindOfClass:(Class)cls {
    for (Class tcls = [self class]; tcls; tcls = tcls->superclass) {
    if (tcls == cls) return YES;
}
    return NO;
}
```

![]()

需要注意类的查找方式：

- 实例对象isa指向类对象，类对象isa指向元类对象
- 对象的superClass 指向父类。
- `Person`  和  `[Person class]`是相等的
