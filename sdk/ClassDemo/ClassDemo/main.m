//
//  main.m
//  ClassDemo
//
//  Created by GoSun on 2021/1/29.
//

#import <Foundation/Foundation.h>
#import <objc/runtime.h>
#import <malloc/malloc.h>
#import "Cat.h"
#import "Cat+Test.h"
#import "Person.h"
//struct objc_class{
//    Class isa;
//    Class superclass;
//    cache_t cache;
//    class_data_bits_t bits;
//}
//
//
//struct class_rw_t{
//    uint32_t flags;
//    uint16_t index;
//    Class firstSubclass;
//    Class nextSiblingClass;
//    const class_ro_t *ro;
//    const method_array_t methods;
//    const property_array_t properties;
//    const protocol_array_t protocols;
//
//}
//
//struct class_ro_t{
//    uint32_t flags;
//    uint32_t instanceStart;
//    uint32_t instanceSize;
//    uint32_t reserved;
//    const char *name;
//    void *baseMethodList;
//    protocol_list_t * baseProtocols;
//    const ivar_list_t * ivars;
//    const uint8_t * weakIvarLayout;
//}



//struct NSObject_IMPL {
//    Class isa;
//};

struct Cat_IMPL {
    Class isa;
    NSString *_name;
    int _age;
};



NSString *demo_getLastName(id self, SEL selector)
{
    return @"Apple";
}

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
//        __weak Cat *weakCat = cat;
//        weakCat = nil;
//        //添加关联对象
//        objc_setAssociatedObject(cat, "like", @"mouse", OBJC_ASSOCIATION_COPY_NONATOMIC);
//        objc_setAssociatedObject(cat, @"eat", nil, OBJC_ASSOCIATION_COPY_NONATOMIC);
//        NSLog(@"cat = %p",cat);
        
//        cat.name = @"Tom";
//        NSLog(@"cat.name = %@",cat.name);
        
//        [cat run];
//
//        [cat eat];
        
//        unsigned int count;
//        Ivar *ivars = class_copyIvarList([Cat class], &count);
//        for (int i = 0; i < count; i++) {
//            // 取出i位置的成员变量
//            Ivar ivar = ivars[i];
//            NSLog(@"%s %s", ivar_getName(ivar), ivar_getTypeEncoding(ivar));
//        }
//        free(ivars);
        
        
//        class_addMethod([Cat class], @selector(jump), method_getImplementation(jump), @"v")
        
//        Person *p = [[Person alloc]init];
//
////        [p testInstanceMethod];
//
//        [p testMethod];
//
        
        
//        // 创建类
//        Class newClass = objc_allocateClassPair([NSObject class], "Dog", 0);
//        class_addIvar(newClass, "_age", 4, 1, @encode(int));
//        class_addIvar(newClass, "_weight", 4, 1, @encode(int));
//        //注册类
//        objc_registerClassPair(newClass);
//
//
//        // 成员变量的数量
//        unsigned int count;
//        Ivar *ivars = class_copyIvarList(newClass, &count);
//            for (int i = 0; i < count; i++) {
//                // 取出i位置的成员变量
//                Ivar ivar = ivars[i];
//                NSLog(@"%s %s", ivar_getName(ivar), ivar_getTypeEncoding(ivar));
//            }
//        free(ivars);
//
//        // 在不需要这个类时释放
//         objc_disposeClassPair(newClass);
        
        Person *person = [[Person alloc] init];
        person.firstName = @"Tom";
        person.lastName = @"Google";
        
        NSLog(@"person full name: %@ %@", person.firstName, person.lastName);

        
        // 1.创建一个子类
        NSString *oldName = NSStringFromClass([person class]);
        NSString *newName = [NSString stringWithFormat:@"Subclass_%@", oldName];
        Class customClass = objc_allocateClassPair([person class], newName.UTF8String, 0);
        objc_registerClassPair(customClass);
        // 2.重写get方法
        SEL sel = @selector(lastName);
        Method method = class_getInstanceMethod([person class], sel);
        const char *type = method_getTypeEncoding(method);
        class_addMethod(customClass, sel, (IMP)demo_getLastName, type);
        // 3.修改修改isa指针(isa swizzling)
        object_setClass(person, customClass);
        
        NSLog(@"person full name: %@ %@", person.firstName, person.lastName);
        
        Person *person2 = [[Person alloc] init];
        person2.firstName = @"Jerry";
        person2.lastName = @"Google";
        NSLog(@"person2 full name: %@ %@", person2.firstName, person2.lastName);
        
        NSLog(@"%s ",__func__);
        
        
    }
    return 0;
}



