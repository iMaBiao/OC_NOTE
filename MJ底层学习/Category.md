### Category



定义在objc-runtime-new.h中

![](img/category_t.png)



#### Category的加载处理过程

1、通过Runtime加载某个类的所有Category数据

2、把所有Category的方法、属性、协议数据，合并到一个大数组中

      后面参与编译的Category数据，会在数组的前面

3、将合并后的分类数据（方法、属性、协议），插入到类原来数据的前面

```
源码解读顺序
objc-os.mm
_objc_init
map_images
map_images_nolock

objc-runtime-new.mm
_read_images
remethodizeClass
attachCategories
attachLists
realloc、memmove、 memcpy

```



### load

- ##### +load方法会在runtime加载类、分类时调用

- ##### 每个类、分类的+load，在程序运行过程中只调用一次

-   调用顺序

##### 1、先调用类的+load

        按照编译先后顺序调用（先编译，先调用）

        调用子类的+load之前会先调用父类的+load

##### 2、再调用分类的+load

           按照编译先后顺序调用（先编译，先调用）



- #### +load方法是根据方法地址直接调用，并不是经过objc_msgSend函数调用







### initialize

- ##### +initialize方法会在类第一次接收到消息时调用

-   调用顺序

##### 先调用父类的+initialize，再调用子类的+initialize

##### (先初始化父类，再初始化子类，每个类只会初始化1次)



- ##### +initialize和+load的很大区别是，+initialize是通过objc_msgSend进行调用的，所以有以下特点

- ##### 如果子类没有实现+initialize，会调用父类的+initialize（所以父类的+initialize可能会被调用多次）

- ##### 如果分类实现了+initialize，就覆盖类本身的+initialize调用





面试题：

##### Category的实现原理

-     Category编译之后的底层结构是struct  category_t，里面存储着分类的对象方法、类方法、属性、协议信息

-   在程序运行的时候，runtime会将Category的数据，合并到类信息中（类对象、元类对象中）



##### Category和Class  Extension的区别是什么？

-   Class  Extension在编译的时候，它的数据就已经包含在类信息中

-   Category是在运行时，才会将数据合并到类信息中



category中有load方法吗？load方法什么时候调用？load方法能继承吗？

有，能继承



- load、initialize方法的区别是什么？

  1、调用方式

       load是根据函数地址直接调用

      initialize是通过objc_msgsend调用

  2、调用时刻

      load是runtime加载类、分类的时候调用（只会调用一次）

      initialize是类第一次接收到消息的时候调用，每一个类只会initialize一次（父类的initialize方法可能会被调用多次）

  

-   load 、initialize的调用顺序？

  1、load :   

  先调用类的load ；先编译的类，优先调用load；调用之类的load之前，会先调用父类的load

  再调用分类的load, 先编译的分类，优先调用load

  2、initialize

  先初始化父类，再初始化子类（可能最终调用的是父类的initialize方法）




