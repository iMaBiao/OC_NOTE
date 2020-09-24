#### load与initialize的区别

1、调用方式不同

​	load是通过地址直接调用

​	initialize是通过消息机制objc_msgSend调用

2、调用时间不同

​	load是runtime加载类、分类时调用（先调用类的load，再调用分类的load），且只会被调用一次；调用子类前先调用父类的load方法

​	initialize是类第一次收到消息时调用，每个类只会initialize一次；先初始化父类，再初始化子类，子类可能回调用父类的initialize

3、