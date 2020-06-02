#### weak&assign

###### Weak实现原理

`weak`其实就是一个hash表，key是所指`对象的地址`，value是`weak指针的地址数组`

**weak 实现原理的概括**

Runtime维护了一个weak表，用于存储指向某个对象的所有weak指针。weak表其实是一个hash（哈希）表，Key是所指对象的地址，Value是weak指针的地址（这个地址的值是所指对象的地址）数组

weak 的实现原理可以概括一下三步：

- 1、初始化时：runtime会调用objc_initWeak函数，初始化一个新的weak指针指向对象的地址。

- 2、添加引用时：objc_initWeak函数会调用 objc_storeWeak() 函数， objc_storeWeak() 的作用是更新指针指向，创建对应的弱引用表。

- 3、释放时，调用clearDeallocating函数。clearDeallocating函数首先根据对象地址获取所有weak指针地址的数组，然后遍历这个数组把其中的数据设为nil，最后把这个entry从weak表中删除，最后清理对象的记录。

```objective-c
NSObject.mm文件中,有一个objc_initWeak方法，这个就是weak初始化函数

objc_initWeak(id *location, id newObj)
{
    if (!newObj) {//无效对象直接导致指针释放
    *location = nil;
    return nil;
}

    return storeWeak<DontHaveOld, DoHaveNew, DoCrashIfDeallocating>
(location, (objc_object*)newObj);
}
```

```objective-c
更新指针指向，创建对应的弱引用表

我们storeWeak表面意思是weak商店,其实weak应该就是在storeWeak函数里面进行了进一步的处理。点击进入

//1、location地址
//2、newObj新的对象
static id 
storeWeak(id *location, objc_object *newObj)
{
    assert(haveOld  ||  haveNew);
    if (!haveNew) assert(newObj == nil);

    Class previouslyInitializedClass = nil;
    id oldObj;

    //声明新旧两个SideTable散列表
    SideTable *oldTable;
    SideTable *newTable;

retry:
    if (haveOld) {
    // 更改指针，获得以 oldObj 为索引所存储的值地址
    oldObj = *location;
    oldTable = &SideTables()[oldObj];
    } else {
        oldTable = nil;
    }
    if (haveNew) {
    // 更改新值指针，获得以 newObj 为索引所存储的值地址
        newTable = &SideTables()[newObj];
    } else {
        newTable = nil;
    }

    // 加锁操作，防止多线程中竞争冲突
    SideTable::lockTwo<haveOld, haveNew>(oldTable, newTable);
    // 避免线程冲突重处理
    // location 应该与 oldObj 保持一致，如果不同，说明当前的 location 已经处理过 oldObj 可是又被其他线程所修改
    if (haveOld  &&  *location != oldObj) {
        SideTable::unlockTwo<haveOld, haveNew>(oldTable, newTable);
        goto retry;
}


    if (haveNew  &&  newObj) {
        Class cls = newObj->getIsa();
        if (cls != previouslyInitializedClass  &&  
            !((objc_class *)cls)->isInitialized()) 
        {
        // 解锁
        SideTable::unlockTwo<haveOld, haveNew>(oldTable, newTable);
        // 对其 isa 指针进行初始化
            _class_initialize(_class_getNonMetaClass(cls, (id)newObj));
        // 如果该类已经完成执行 +initialize 方法是最理想情况
        // 如果该类 +initialize 在线程中
        // 例如 +initialize 正在调用 storeWeak 方法
        // 需要手动对其增加保护策略，并设置 previouslyInitializedClass 指针进行标记
        previouslyInitializedClass = cls;

        goto retry;
        }
    }
    //  清除旧值
    if (haveOld) {
        weak_unregister_no_lock(&oldTable->weak_table, oldObj, location);
    }

    //  分配新值 
    if (haveNew) {
        newObj = (objc_object *)
        weak_register_no_lock(&newTable->weak_table, (id)newObj, location, crashIfDeallocating);

    if (newObj  &&  !newObj->isTaggedPointer()) {
        newObj->setWeaklyReferenced_nolock();
}

    *location = (id)newObj;
}
else {

}

SideTable::unlockTwo<haveOld, haveNew>(oldTable, newTable);
    return (id)newObj;
}
```

我们注意到在刚进入`storeWeak`函数的时候，就初始化了新旧两个`SideTable`，我们点击进入

```
struct SideTable {
    spinlock_t slock;
    RefcountMap refcnts;
    weak_table_t weak_table;
}
```

我们发现`SideTable`是一个结构体

- 1、`spinlock_t slock;`  保证原子操作的自旋锁
- 2、`RefcountMap refcnts;`  引用计数的 hash 表
- 3、`weak_table_t weak_table;`  weak 引用全局 hash 表

我们是研究`weak`的，所以我们要研究一下`weak_table_t`这个hash表

```objective-c
struct weak_table_t {
    weak_entry_t *weak_entries;
    size_t    num_entries;
    uintptr_t mask;
    uintptr_t max_hash_displacement;
};
```

- 1、`weak_entry_t *weak_entries;`  保存了所有指向指定对象的 weak 指针
- 2、`size_t num_entries;`  存储空间
- 3、`uintptr_t mask;`  参与判断引用计数辅助量
- 4、`uintptr_t max_hash_displacement;`  hash key 最大偏移值

这是一个全局弱引用hash表。使用`对象的地址`作为key ，用 `weak_entry_t`类型结构体对象作为value

我们看字面意思`weak_entry_t`就是weak条目的意思，里面应该包含了weak的信息

```
struct weak_entry_t {
    DisguisedPtr<objc_object> referent;
    union {
        struct {
            weak_referrer_t *referrers;
            uintptr_t        out_of_line_ness : 2;
            uintptr_t        num_refs : PTR_MINUS_2;
            uintptr_t        mask;
            uintptr_t        max_hash_displacement;
        };
    struct {
    // out_of_line_ness field is low bits of inline_referrers[1]
        weak_referrer_t  inline_referrers[WEAK_INLINE_COUNT];
    };
};
```

`weak_entry_t`是存储在弱引用表中的一个内部结构体，它负责维护和存储指向一个对象的所有弱引用hash表

##### 释放调用clearDeallocating函数

objc_clear_deallocating该函数的动作如下：

- 1、从weak表中获取废弃对象的地址为键值的记录
- 2、将包含在记录中的所有附有 weak修饰符变量的地址，赋值为nil
- 3、将weak表中该记录删除
- 4、从引用计数表中删除废弃对象的地址为键值的记录

```objective-c
objc_object::clearDeallocating_slow()
{
    assert(isa.nonpointer  &&  (isa.weakly_referenced || isa.has_sidetable_rc));

    SideTable& table = SideTables()[this];//从weak表中获取废弃对象的地址为键值的记录
    table.lock();
    if (isa.weakly_referenced) {//如果存在引用计数
        weak_clear_no_lock(&table.weak_table, (id)this);
    }
    if (isa.has_sidetable_rc) {
        table.refcnts.erase(this);
    }
    table.unlock();
}
```

`clearDeallocating_slow`中首先是找到`weak表中获取废弃对象的地址为键值的记录`，然后调用`weak_clear_no_lock`函数进行清除操作

```objective-c
void 
weak_clear_no_lock(weak_table_t *weak_table, id referent_id) 
{
    //找到对象
    objc_object *referent = (objc_object *)referent_id;

    weak_entry_t *entry = weak_entry_for_referent(weak_table, referent);
    if (entry == nil) {
        /// XXX shouldn't happen, but does with mismatched CF/objc
        //printf("XXX no entry for clear deallocating %p\n", referent);
        return;
    }

    // zero out references
    weak_referrer_t *referrers;
    size_t count;

    if (entry->out_of_line()) {
        referrers = entry->referrers;
        count = TABLE_SIZE(entry);
    } 
    else {
        referrers = entry->inline_referrers;
        count = WEAK_INLINE_COUNT;
    }

    for (size_t i = 0; i < count; ++i) {
        objc_object **referrer = referrers[i];
        if (referrer) {
        if (*referrer == referent) {
        //清除对象，赋值为nil
        *referrer = nil;
    }
    else if (*referrer) {
        _objc_inform("__weak variable at %p holds %p instead of %p. "
        "This is probably incorrect use of "
        "objc_storeWeak() and objc_loadWeak(). "
        "Break on objc_weak_error to debug.\n", 
        referrer, (void*)*referrer, (void*)referent);
        objc_weak_error();
        }
    }
}
    //从引用计数表中删除废弃对象的地址为键值的记录
    weak_entry_remove(weak_table, entry);
}
```
