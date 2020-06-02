### dealloc原理

在`NSObject.mm`可以查找到`dealloc`函数

```objective-c
- (void)dealloc {
    _objc_rootDealloc(self);
}

点击进入_objc_rootDealloc函数
_objc_rootDealloc(id obj)
{
    assert(obj);

    obj->rootDealloc();
}

点击rootDealloc
objc_object::rootDealloc()
{
    if (isTaggedPointer()) return;
    object_dispose((id)this);
}
```

这个里面有信息

- 1、首先判断对象是不是`isTaggedPointer`，如果是`TaggedPointer`那么没有采用引用计数技术，所以直接return
- 2、不是`TaggedPointer`，就去销毁这个对象`object_dispose`

```objective-c
点击object_dispose
id 
object_dispose(id obj)
{
    if (!obj) return nil;

    objc_destructInstance(obj);    
    free(obj);

    return nil;
}

点击objc_destructInstance函数
void *objc_destructInstance(id obj) 
{
    if (obj) {
    // Read all of the flags at once for performance.
    bool cxx = obj->hasCxxDtor();
    bool assoc = obj->hasAssociatedObjects();

    // This order is important.
    if (cxx) object_cxxDestruct(obj);
    if (assoc) _object_remove_assocations(obj);//清除成员变量
    obj->clearDeallocating(); //将指向当前对象的弱引用指针置为nil
    }

    return obj;
}
```

**主要步骤**

- 1、首先判断对象是不是`isTaggedPointer`，如果是`TaggedPointer`那么没有采用引用计数技术，所以直接return
- 2、不是`TaggedPointer`
  - 1、清除成员变量
  - 2、将指向当前对象的弱引用指针置为nil
