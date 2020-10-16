### fastlane自动化打包

简单参考： https://www.jianshu.com/p/6ab8d2b7253a



#### 准备

1、首先确认是否安装了ruby，终端查看下ruby版本
使用命令`ruby -v`

```
gosun@181-181-1-154 GriddingPro % ruby -v
ruby 2.6.3p62 (2019-04-16 revision 67580) [universal.x86_64-darwin19]
```

2、确认是否安装了Xcode命令行工具

命令：`xcode-select --install`

```
gosun@181-181-1-154 GriddingPro % xcode-select --install
xcode-select: error: command line tools are already installed, use "Software Update" to install updates
//这是已安装的提示
```



#### 安装

1、安装fastlane

命令：`sudo gem install fastlane -NV`



2、使用

1、打开终端，cd 到你的项目下
命令： `cd + 项目目录`
2、执行fastlane命令 `fastlane init`


下面会有四个选项供你选择

1. 自动截屏。帮我们自动截取APP中的截图
2. 自动发布beta版本用于TestFlight
3. 自动发布到AppStore
4. 手动设置

选择4 



成功之后会在项目文件夹出现两个文件夹

`Appfile`  `Fastfile`



```
 //Appfile文件
 
 app_identifier("[[com.hzgosun.GriddingPro]]") # The bundle identifier of your app
# apple_id("[[1463921958]]") # Your Apple email address


# For more information about the Appfile, see:
#     https://docs.fastlane.tools/advanced/#appfile

//app_identifier用于指定APP的bundle id，apple_id指的是你的AppleID
```



```
//Fastfile文件


# This file contains the fastlane.tools configuration
# You can find the documentation at https://docs.fastlane.tools
#
# For a list of all available actions, check out
#
#     https://docs.fastlane.tools/actions
#
# For a list of all available plugins, check out
#
#     https://docs.fastlane.tools/plugins/available-plugins
#

# Uncomment the line if you want fastlane to automatically update itself
# update_fastlane

default_platform(:ios)

platform :ios do
  desc "Description of what the lane does"
  lane :GriddingPro do
    # add actions here: https://docs.fastlane.tools/actions

	time = Time.new.strftime("%Y%m%d") #获取时间格式
    version = get_version_number#获取版本号
    ipaName = "Release_#{version}_#{time}.ipa"
    gym(
       scheme:"GriddingPro", #项目名称
       export_method:"ad-hoc",#打包的类型
       configuration:"Release",#模式，默认Release，还有Debug
       output_name:"#{ipaName}",#输出的包名
       output_directory:"./build"#输出的位置
     )

  end
end

//lane :custom_lane do中的custom_lane是函数的名称，打包执行命令的时候使用。
//# add actions here: https://docs.fastlane.tools/actions 这块就是让我们加具体执行的插件、命令等操作用于打包。
// export_method : ["app-store", "ad-hoc", "package", "enterprise", "development", "developer-id"]

```

 配置完成之后执行命令： `fastlane 项目名`  (如：`fastlane GriddingPro`)



在项目文件夹中会出现`build`文件夹，里面就有了ipa包