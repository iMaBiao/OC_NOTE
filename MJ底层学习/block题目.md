##### block题目

block的原理是怎样的？本质是什么？

封装了函数调用以及调用环境的OC对象



block的属性修饰词为什么是copy？使用block有哪些注意点？

block一旦没有进行copy操作，就不会在堆上

使用注意：循环引用问题



block在修改NSMutableArray,需不需要添加__block?

如果addObject时，不需要


