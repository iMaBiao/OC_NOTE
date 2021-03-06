##### Block简介

[http://www.cocoachina.com/ios/20180628/23965.html]

block与函数类似，只不过是直接定义在另一个函数里，和定义它的那个函数共享同一个范围内的东西，

block的强大之处是：在声明它的范围里，所有变量都可以为其捕获，这也就是说，那个范围内的全部变量，在block依然可以用，默认情况下，为block捕获的变量，是不可以在block里修改的，不过声明的时候可以加上__block修饰符，这样就可以再block内修改了。

> block本身和其他对象一样，有引用计数，当最后一个指向block的引用移走之后，block就回收了，回收时也释放block所捕获的变量。

Block的实现是通过结构体的方式实现，在编译的过程中，将Block生成对应的结构体，在结构体中记录Block的匿名函数，以及使用到的自动变量，在最后的使用中，通过Block结构体实例访问成员中存放的匿名函数地址调用匿名函数，并将自身作为参数传递。
block其实就是C语言的扩充功能，实现了对C的闭包实现，一个带有局部变量的匿名函数，
block的本质也是一个OC对象，它内部也有一个isa指针，block是封装了函数调用以及函数调用环境的OC对象，为了保证block内部能够正常访问外部的变量，block有一个变量捕获机制。static 修饰的变量为指针传递，同样会被block捕获。局部变量因为跨函数访问所以需要捕获，全局变量在哪里都可以访问 ，所以不用捕获。
当block内部访问了对象类型的auto变量时，如果block在栈上，block内部不会对变量产生强应用，不论block的结构体内部的变量时__strong修饰还是__weak修饰，都不会对变量产生强引用
默认情况下block不能修改外部的局部变量

1.static修饰

      static修饰的age变量传递到block内部的是指针，在__main_block_func_0函数内部就可以拿到age变量的内存地址，因此就可以在block内部修改age的值。

有三种类型

1. __NSGlobalBlock__ （ _NSConcreteGlobalBlock ）

2. __NSStackBlock__ （ _NSConcreteStackBlock ）

3. __NSMallocBlock__ （ _NSConcreteMallocBlock ）

__block内存管理

当block内存在栈上时，并不会对__block变量产生内存管理，当block被copy到堆上时会调用block内部的copy函数，copy函数内部会滴啊用_Block_object_assign函数，_Block_object_assign函数会对__block变量形成强引用(相当于retain)。
当block被copy到堆上时，block内部引用的__block变量也会被复制到堆上，并且持有变量，如果block复制到堆上的同时，__block变量已经存在堆上了，则不会复制。

 当block从堆中移除的话，就会调用dispose函数，也就是__main_block_dispose_0函数，__main_block_dispose_0函数内部会调用_Block_object_dispose函数，会自动释放引用的__block变量

解决循环引用问题

使用__weak和__unsafe_unretained修饰符合一解决循环引用的问题，__weak会使block内部将指针变为弱指针。
__weak 和 __unsafe_unretained的区别。
__weak不会产生强引用，指向的对象销毁时，会自动将指针置为nil
__unsafe_unretained不会产生强引用，不安全，指向的对象销毁时，指针存储的地址值不变
__strong 和 __weak

在block内部重新使用__strong修饰self变量是为了在block内部有一个强指针指向weakSelf避免在block调用的时候weakSelf已经被销毁。

2.__block修饰的变量为什么能在block里面能改变其值？

__block用于解决block内部不能修改auto变量值的问题，__block不能修饰静态变量和全局变量

_block 所起到的作用就是只要观察到该变量被 block 所持有，就将“外部变量”在栈中的内存地址放到了堆中。进而在block内部也可以修改外部变量的值。
