## OCLint与Infer

在今天这篇文章中，我和你一一分析了 Clang 静态分析器、Infer 和 OCLint 这三个 iOS 静态分析工具。



对于 iOS 的静态分析，这三个工具都是基于 Clang 库开发的。

其中 Clang 静态分析器和 Xcode 的集成度高，也支持命令行。不过，它们检查的规则少，基本都是只能检查出较大的问题，比如类型转换问题，而对内存泄露问题检查的侧重点则在于可用性。



OCLint 检查规则多、定制性强，能够发现很多潜在问题。但缺点也是检查规则太多，反而容易找不到重点；可定制度过高，导致易用性变差。

Infer 的效率高，支持增量分析，可小范围分析。可定制性不算最强，属于中等。



综合来看，Infer 在准确性、性能效率、规则、扩展性、易用性整体度上的把握是做得最好的，我认为这些是决定静态分析器好不好最重要的几点。



所以，我比较推荐的是使用 Infer 来进行代码静态分析。