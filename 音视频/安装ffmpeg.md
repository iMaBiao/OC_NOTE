#### Mac上安装ffmpeg



#### 利用homebrew安装ffmpeg

1、先搜索试试ffmpeg，如果安装了homebrew，就能搜索到

`brew search ffmpeg`

2、如果能搜索到，直接安装

`brew install ffmpeg`

这个过程可能会有的久

查看安装结果：`ffmpeg -version`

安装的位置在：

`/usr/local/Cellar`

在Cellar文件夹下，`ls`一下就能看到ffmpeg



3、如果没有安装brew，需要先安装homebrew

查看是否安装了brew : `brew -v`



---

#### 安装rvm

查看是否安装了rvm: `rvm -v`

如果没有安装，就执行命令安装：`curl -L [https://get.rvm.io](https://get.rvm.io/) | bash -s stable`

再载入RVM环境：`source ~/.rvm/scripts/rvm`

最后利用`rvm -v`检查是否安装成功



---

#### 安装更新cocoapods

gem源

查看：`gem sources -l`

```
*** CURRENT SOURCES***
https://gems.ruby-china.com/
```

如果不是要更换这个gem源

```
gem sources --remove https://rubygems.org/

gem sources --add https://gems.ruby-china.com/
```



安装：`sudo gem install cocoapods`

安装本地库：`pod setup`

查看版本： `pod --version`

