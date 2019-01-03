KVC: Key - value coding

主要方法:

- (void)setValue:(id)value forKey:(NSString *)key;
- (id)valueForKey:(NSString *)key;

- (void)setValue:(id)value forKeyPath:(NSString *)keyPath;
- (void)setValue:(id)value forUndefinedKey:(NSString *)key;


问：通过健值编码技术，是否会违背面向对象的编程思想？
如果知道一个类的内部某个私有变量时，在外面可以通过key来访问或操作的

valueForKey: 方法实现流程
kvc1.png


setValue:  forKey:方法实现流程
kvc2.png
