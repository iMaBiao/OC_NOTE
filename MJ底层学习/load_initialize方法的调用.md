### load与initialize

### load

- ##### +load方法会在runtime加载类、分类时调用

- ##### 每个类、分类的+load，在程序运行过程中只调用一次

- 调用顺序

##### 1、先调用类的+load

```objective-c
 按照编译先后顺序调用（先编译，先调用）

 调用子类的+load之前会先调用父类的+load
```

##### 2、再调用分类的+load

      按照编译先后顺序调用（先编译，先调用）

- #### +load方法是根据方法地址直接调用，并不是经过objc_msgSend函数调用



##### 源码解读顺序

```objective-c
objc-os.mm

· _objc_init
· load_images
· prepare_load_methods
	schedule_class_load
	add_class_to_loadable_list
	add_category_to_loadable_list
	
· call_load_methods
	call_class_loads
	call_category_loads
	(*load_method)(cls, SEL_load)

```

##### 源码介绍（有删减）

```objective-c
· objc-runtime-new.mm
void
load_images(const char *path __unused, const struct mach_header *mh)
{
    // Return without taking locks if there are no +load methods here.
    if (!hasLoadMethods((const headerType *)mh)) return;

    recursive_mutex_locker_t lock(loadMethodLock);

    // Discover load methods
    {
        mutex_locker_t lock2(runtimeLock);
      	//准备加载load方法
        prepare_load_methods((const headerType *)mh);
    }

    // Call +load methods (without runtimeLock - re-entrant)
  	//调用load方法
    call_load_methods();
}

//准备加载load方法
void prepare_load_methods(const headerType *mhdr)
{
    size_t count, i;

    runtimeLock.assertLocked();

    classref_t *classlist = 
        _getObjc2NonlazyClassList(mhdr, &count);
    for (i = 0; i < count; i++) {
      	//排序类的load方法
        schedule_class_load(remapClass(classlist[i]));
    }
		
 	 //添加分类的load方法
    category_t **categorylist = _getObjc2NonlazyCategoryList(mhdr, &count);
    for (i = 0; i < count; i++) {
        category_t *cat = categorylist[i];
        Class cls = remapClass(cat->cls);
        if (!cls) continue;  // category for ignored weak-linked class

        realizeClassWithoutSwift(cls);
        assert(cls->ISA()->isRealized());
      	//添加分类的load方法到数组中
        add_category_to_loadable_list(cat);
    }
}


// Recursively schedule +load for cls and any un-+load-ed superclasses.
// cls must already be connected.
static void schedule_class_load(Class cls)
{
    if (!cls) return;
    assert(cls->isRealized());  // _read_images should realize

    if (cls->data()->flags & RW_LOADED) return;

    // Ensure superclass-first ordering
  	//递归调用，优先调用父类的，将父类的cls加到数组中
    schedule_class_load(cls->superclass);
		
  	//将cls添加到loadable_classes数组中
    add_class_to_loadable_list(cls);
    cls->setInfo(RW_LOADED); 
}

//将cls添加到loadable_classes数组中最后面
void add_class_to_loadable_list(Class cls)
{
    IMP method;

    loadMethodLock.assertLocked();

    method = cls->getLoadMethod();
    if (!method) return;  // Don't bother if cls has no +load method
    
    if (loadable_classes_used == loadable_classes_allocated) {
        loadable_classes_allocated = loadable_classes_allocated*2 + 16;
        loadable_classes = (struct loadable_class *)
            realloc(loadable_classes,
                              loadable_classes_allocated *
                              sizeof(struct loadable_class));
    }
  	//将类的load方法添加到数组最后面
    loadable_classes[loadable_classes_used].cls = cls;
    loadable_classes[loadable_classes_used].method = method;
    loadable_classes_used++;
}


//添加分类的load方法到数组中
void add_category_to_loadable_list(Category cat)
{
    IMP method;

    loadMethodLock.assertLocked();

    method = _category_getLoadMethod(cat);

    // Don't bother if cat has no +load method
    if (!method) return;
    
    if (loadable_categories_used == loadable_categories_allocated) {
        loadable_categories_allocated = loadable_categories_allocated*2 + 16;
        loadable_categories = (struct loadable_category *)
            realloc(loadable_categories,
                              loadable_categories_allocated *
                              sizeof(struct loadable_category));
    }
		//直接将分类的load方法添加到数组最后面，不存在优先父类的问题
    loadable_categories[loadable_categories_used].cat = cat;
    loadable_categories[loadable_categories_used].method = method;
    loadable_categories_used++;
}


· objc-loadmethods.mm

void call_load_methods(void)
{
    static bool loading = NO;
    bool more_categories;
    // Re-entrant calls do nothing; the outermost call will finish the job.
    if (loading) return;
    loading = YES;

    void *pool = objc_autoreleasePoolPush();

    do {
        // 1. Repeatedly call class +loads until there aren't any more
        //先调用类的load方法
        while (loadable_classes_used > 0) {
            call_class_loads();
        }

        // 2. Call category +loads ONCE
      	//再调用分类的load方法
        more_categories = call_category_loads();

        // 3. Run more +loads if there are classes OR more untried categories
    } while (loadable_classes_used > 0  ||  more_categories);

    objc_autoreleasePoolPop(pool);

    loading = NO;
}

//调用类的load方法
static void call_class_loads(void)
{
    int i;
    
    // Detach current loadable list.
  	/* 类的load方法
  		struct loadable_class {
    		Class cls;  // may be nil
    		IMP method;
			};
  	*/
    struct loadable_class *classes = loadable_classes;
    int used = loadable_classes_used;
		...
    
    // Call all +loads for the detached list.
    for (i = 0; i < used; i++) {
        Class cls = classes[i].cls;
      	/*
      	直接取出类里面的load方法，获取方法地址
        typedef void(*load_method_t)(id, SEL); 指向函数的指针
        */
        load_method_t load_method = (load_method_t)classes[i].method;
        if (!cls) continue; 

      	//直接调用函数
        (*load_method)(cls, SEL_load);
    }
    ...
}

//调用分类的load方法
static bool call_category_loads(void)
{
    int i, shift;
    bool new_categories_added = NO;
    
    // Detach current loadable list.
  	/* 分类的load方法
  		struct loadable_category {
    		Category cat;  // may be nil
    		IMP method;
			};
  	*/
    struct loadable_category *cats = loadable_categories;
		...

    // Call all +loads for the detached list.
    for (i = 0; i < used; i++) {
        Category cat = cats[i].cat;
      	//取出分类的load方法，获取方法地址
      	//typedef void(*load_method_t)(id, SEL); 指向函数的指针
        load_method_t load_method = (load_method_t)cats[i].method;
        Class cls;
        if (!cat) continue;

        cls = _category_getClass(cat);
        if (cls  &&  cls->isLoadable()) {
          	//直接调用函数
            (*load_method)(cls, SEL_load);
            cats[i].cat = nil;
        }
    }
  
  	...
    return new_categories_added;
}
```



### initialize方法

- ##### +initialize方法会在类第一次接收到消息时调用

- 调用顺序

##### 先调用父类的+initialize，再调用子类的+initialize

##### (先初始化父类，再初始化子类，每个类只会初始化1次)

- ##### +initialize和+load的很大区别是，+initialize是通过objc_msgSend进行调用的，所以有以下特点

- ##### 如果子类没有实现+initialize，会调用父类的+initialize（所以父类的+initialize可能会被调用多次）

- ##### 如果分类实现了+initialize，就覆盖类本身的+initialize调用



##### 源码解读顺序

```objective-c
objc4源码解读过程
objc-msg-arm64.s
objc_msgSend

objc-runtime-new.mm
class_getInstanceMethod
lookUpImpOrNil
lookUpImpOrForward
initializeAndLeaveLocked
initializeAndMaybeRelock
initializeNonMetaClass
callInitialize
objc_msgSend(cls, SEL_initialize)
新版有改动（貌似增加了锁）
```

##### 源码介绍（有删减）

```objective-c
objc-runtime-new.mm

//获取实例对象的方法
Method class_getInstanceMethod(Class cls, SEL sel)
{
    if (!cls  ||  !sel) return nil;

    // This deliberately avoids +initialize because it historically did so.

    // This implementation is a bit weird because it's the only place that 
    // wants a Method instead of an IMP.

#warning fixme build and search caches
        
    // Search method lists, try method resolver, etc.
    //查找方法的实现
    lookUpImpOrNil(cls, sel, nil, 
                   NO/*initialize*/, NO/*cache*/, YES/*resolver*/);

#warning fixme build and search caches

    return _class_getMethod(cls, sel);
}


IMP lookUpImpOrNil(Class cls, SEL sel, id inst, 
                   bool initialize, bool cache, bool resolver)
{
    IMP imp = lookUpImpOrForward(cls, sel, inst, initialize, cache, resolver);
    if (imp == _objc_msgForward_impcache) return nil;
    else return imp;
}


IMP lookUpImpOrForward(Class cls, SEL sel, id inst, 
                       bool initialize, bool cache, bool resolver)
{
    IMP imp = nil;
    bool triedResolver = NO;

    runtimeLock.assertUnlocked();

    // Optimistic cache lookup
    if (cache) {
        imp = cache_getImp(cls, sel);
        if (imp) return imp;
    }

  	//如果需要初始化 且 类并没有被初始化过
    if (initialize && !cls->isInitialized()) {
      
        cls = initializeAndLeaveLocked(cls, inst, runtimeLock);
    }
	
  	//初始化过就走正常的调用流程
	  ...
      
    return imp;
}


// Locking: caller must hold runtimeLock; this may drop and re-acquire it
static Class initializeAndLeaveLocked(Class cls, id obj, mutex_t& lock)
{
    return initializeAndMaybeRelock(cls, obj, lock, true);
}

static Class initializeAndMaybeRelock(Class cls, id inst,
                                      mutex_t& lock, bool leaveLocked)
{
    lock.assertLocked();
    assert(cls->isRealized());

    if (cls->isInitialized()) {
        if (!leaveLocked) lock.unlock();
        return cls;
    }

		...
      
    // runtimeLock is now unlocked, for +initialize dispatch
    assert(nonmeta->isRealized());
    initializeNonMetaClass(nonmeta);

    if (leaveLocked) runtimeLock.lock();
    return cls;
}


void initializeNonMetaClass(Class cls)
{
    assert(!cls->isMetaClass());

    Class supercls;
    bool reallyInitialize = NO;

    // Make sure super is done initializing BEFORE beginning to initialize cls.
    // See note about deadlock above.
    supercls = cls->superclass;
  	//如果存在父类且父类并没有被初始化，就会去初始化父类（递归调用）
    if (supercls  &&  !supercls->isInitialized()) {
        initializeNonMetaClass(supercls);
    }
        
    if (reallyInitialize) {
        // We successfully set the CLS_INITIALIZING bit. Initialize the class.

        // Exceptions: A +initialize call that throws an exception 
        // is deemed to be a complete and successful +initialize.
        //
        // Only __OBJC2__ adds these handlers. !__OBJC2__ has a
        // bootstrapping problem of this versus CF's call to
        // objc_exception_set_functions().
#if __OBJC2__
        @try
#endif
        {
          //调用initialize方法
            callInitialize(cls);
        }
				...
        return;
    }
    
}


//调用initialize方法（通过消息发送方式）
void callInitialize(Class cls)
{
    ((void(*)(Class, SEL))objc_msgSend)(cls, SEL_initialize);
    asm("");
}
```



面试题：

##### category中有load方法吗？load方法什么时候调用？load方法能继承吗？

有，能继承

但是一般情况下不会主动去调用load方法，都是让系统自动调用



- #### load、initialize方法的区别是什么？

  1、调用方式

       load是根据函数地址直接调用
      
      initialize是通过objc_msgsend调用

  2、调用时刻

      load是runtime加载类、分类的时候调用（只会调用一次）
      
      initialize是类第一次接收到消息的时候调用，每一个类只会initialize一次（父类的initialize方法可能会被调用多次）

- #### load 、initialize的调用顺序？

  1、load :   

  - 先调用类的load 

    ​	先编译的类，优先调用load；

    ​	调用子类的load之前，会先调用父类的load；

  - 再调用分类的load
  
    ​	先编译的分类，优先调用load；
  
    
  
  2、initialize
  
  - 先初始化父类
  
  - 再初始化子类（可能最终调用的是父类的initialize方法）