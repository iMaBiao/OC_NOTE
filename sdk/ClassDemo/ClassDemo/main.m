//
//  main.m
//  ClassDemo
//
//  Created by GoSun on 2021/1/29.
//

#import <Foundation/Foundation.h>
#import <objc/runtime.h>
#import <malloc/malloc.h>

struct objc_class{
    Class isa;
    Class superclass;
    cache_t cache;
    class_data_bits_t bits;
}


struct class_rw_t{
    uint32_t flags;
    uint16_t index;
    Class firstSubclass;
    Class nextSiblingClass;
    const class_ro_t *ro;
    const method_array_t methods;
    const property_array_t properties;
    const protocol_array_t protocols;

}

struct class_ro_t{
    uint32_t flags;
    uint32_t instanceStart;
    uint32_t instanceSize;
    uint32_t reserved;
    const char *name;
    void *baseMethodList;
    protocol_list_t * baseProtocols;
    const ivar_list_t * ivars;
    const uint8_t * weakIvarLayout;
}



//struct NSObject_IMPL {
//    Class isa;
//};

struct Cat_IMPL {
    Class isa;
    NSString *_name;
    int _age;
};

@interface  Cat : NSObject
{
    @public
    NSString *_name;
    int _age;
}
@end

@implementation Cat

@end




int main(int argc, const char * argv[]) {
    @autoreleasepool {
        
//       NSObject *obj = [[NSObject alloc]init];
        
        
//        Cat *cat = [[Cat alloc]init];
//        cat->_age = 10;
//        cat->_name = @"Tom";
//
//        struct Cat_IMPL *catImpl = (__bridge struct Cat_IMPL *)cat;
//        NSLog(@"name is %@, age is %d", catImpl->_name, catImpl->_age);
//
//        NSLog(@"%zd", class_getInstanceSize([Cat class]));
//        NSLog(@"%zd", malloc_size((__bridge const void *)cat));
        
        
//        NSObject *obj1 = [[NSObject alloc]init];
//        Class objectClass1 = [obj1 class];
//        Class objectClass2 = object_getClass(obj1);
//        Class objectClass3 = [NSObject class];
//
//        Class objectClass4 = [[NSObject class]class];
//        Class objectClass5 = [[[NSObject class]class]class];
//        NSLog(@"objectClass1 = %p",objectClass1);
//        NSLog(@"objectClass2 = %p",objectClass2);
//        NSLog(@"objectClass3 = %p",objectClass3);
//        NSLog(@"objectClass4 = %p",objectClass4);
//        NSLog(@"objectClass5 = %p",objectClass5);
        
//        Class objectMetaClass = object_getClass([NSObject class]);
        
        //添加弱引用
        Cat *cat = [[Cat alloc]init];
        __weak Cat *weakCat = cat;
        weakCat = nil;
        //添加关联对象
        objc_setAssociatedObject(cat, "like", @"mouse", OBJC_ASSOCIATION_COPY_NONATOMIC);
        objc_setAssociatedObject(cat, @"eat", nil, OBJC_ASSOCIATION_COPY_NONATOMIC);
        NSLog(@"cat = %p",cat);
        
    }
    return 0;
}
