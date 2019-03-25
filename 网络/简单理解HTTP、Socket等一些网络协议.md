#### 简单理解HTTP，TCP，UDP，Socket，WebSocket

- 从本质上来区分，HTTP，WebSocket，TCP，UDP，IP都是协议，而TCP/IP是不同协议的组合，你也可以称之为协议栈，协议族，TCP/IP模型等等都可以，反正都是虚无的不能吃的东西，都是为了完成对应功能而制定的统一规则。

  而Socket（套接字）才是真正能操作的东西。Socket的本质是API，是先人对TCP/IP协议族的抽象或者说封装，它就像一个门面，给你一个操作TCP/IP协议的入口，来建立Socket连接。值得一提的是，此Socket是指网络编程下的Socket，而不是Unix中的Socket。虽然概念相似，但是Unix中的Socket不是基于这些乱七八糟的协议，而是基于操作系统本身的文件系统。

- 从分层上来区分，HTTP，WebSocket是应用层协议，TCP，UDP是传输层协议，IP是网络层协议。

##### 1.TCP和UDP

TCP是面向连接的一种传输控制协议。TCP连接之后，客户端和[服务器](https://www.baidu.com/s?wd=%E6%9C%8D%E5%8A%A1%E5%99%A8&tn=24004469_oem_dg&rsv_dl=gh_pl_sl_csd)可以互相发送和接收消息，在客户端或者服务器没有主动断开之前，连接一直存在，故称为长连接。特点：连接有耗时，传输数据无大小限制，准确可靠，先发先至。

UDP是无连接的用户数据报协议，所谓的无连接就是在传输数据之前不需要交换信息，没有握手建立连接的过程，只需要直接将对应的数据发送到指定的地址和端口就行。故UDP的特点是不稳定，速度快，可广播，一般数据包限定64KB之内，先发未必先至。

##### 2.HTTP

HTTP是基于TCP协议的应用，请求时需建立TCP连接，而且请求包中需要包含请求方法，URL，协议版本等信息，请求结束后断开连接，完成一次请求/响应操作。故称为短连接。

而HTTP/1.1中的keep-alive所保持的长连接则是为了优化每次HTTP请求中TCP连接三次握手的麻烦和资源开销，只建立一次TCP连接，多次的在这个通道上完成请求/响应操作。

值得一提的是，服务器无法主动给客户端推送消息。

##### 3.WebSocket

WebSocket也是一种协议，并且也是基于TCP协议的。具体流程是WebSocket通过HTTP先发送一个标记了 Upgrade 的请求，服务端解析后开始建立TCP连接，省去了HTTP长连接每次请求都要上传header的冗余，可以理解为WebSocket是HTTP的优化，但WebSocket不仅仅在Web应用程序上得到支持。

##### 4.Socket连接和TCP连接

其实这就是一个文字游戏而已，建立Socket连接需要至少一对Socket（套接字），而创建Socket连接可以指定不同的传输层协议，即TCP或UDP，所以当采用TCP建立连接时，该Socket连接就视为一个TCP连接。而采用UDP则是无连接的。



##### 5.Socket和WebSocket

这两个虽然名字差不多，但却是两个完全不同的概念，就好比Java和JavaScript一样毫无关系。Socket是一套协议封装后的接口，用于建立Socket连接，而WebSocket虽然是Html5的产物，但也不仅仅局限于浏览器的应用程序，许多语言都提供了WebSocket的支持，比如C，C++，Python等。

##### 6.HTTP、WebSocket与TCP的关系

HTTP通信过程属于“你推一下，我走一下”的方式，客户端不发请求则服务器永远无法发送数据给客户端，而WebSocket则在进行第一次HTTP请求之后，其他全部采用TCP通道进行双向通讯。所以，HTTP和WebSocket虽都是基于TCP协议，但是两者属于完全不同的两种通讯方式。
