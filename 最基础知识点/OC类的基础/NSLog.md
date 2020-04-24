更改NSLog的打印

```
#ifdef DEBUG     //调试状态，打开Log功能

#define MBLog(…) NSLog(__VA__ARGS__)

#else             //发布状态，关闭Log功能

#define MBLog(…)

#endif
```
