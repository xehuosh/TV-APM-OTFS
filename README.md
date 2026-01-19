# 1.程序介绍
&emsp;Hello，这是我的本科毕业设计的完整MATLAB程序，主要关于时变水声传播模型和OTFS水声信道估计与迭代均衡技术，该项目是为了水下移动网络节点间高速水声通信与组网设计的。欢迎用户修复Bug、扩展功能，并在开源社区分享。

&emsp;水声信道有限的带宽、严重的多径扩展与显著的多普勒频移是制约高速可靠通信的关键因素。与OFDM系统相比，OTFS系统使时变信道在时延-多普勒域中变为准静态稀疏信道，防止子载波正交性被破坏。

&emsp;Bellhop水声工具箱功能强大，已经被广泛应用于各类水声原理和算法验证。
其中对于单载波静态水声通信仿真，利用Bellhop可以生成完整多径信道冲激响应，在接收端进行信道估计与均衡仿真。

&emsp;但是Bellhop只能针对静态场景进行水下声学仿真，因此需要基于Bellhop，在其上层开发框架，将动态场景采样为多个时间切片，分别调用Bellhop进行仿真。

&emsp;闫正强等人[1]使用Bellhop水声工具箱进行OFDM水声通信系统仿真，验证了Bellhop应用于多载波场景的可行性，文献第三章使用了OFDM系统的中心频率作为Bellhop的声波频率参数。

[1]闫正强.基于压缩感知的水声OFDM系统信道估计方法研究[D].青岛科技大学,2020.DOI:10.27264/d.cnki.gqdhc.2020.000591.

# 2.运行环境（供参考）

## 2.1.软件环境

&emsp;操作系统: Windows 10家庭中文版

&emsp;Matlab版本: R2024b

&emsp;水声工具箱: The Acoustics Toolbox for Windows 10 (2020_11_4 ver.)

## 2.2.硬件环境
&emsp;CPU: AMD Ryzen 5 PRO 4650U

&emsp;GPU: AMD Radeon Graphics（集显）

&emsp;运行内存: 15.4GB

# 3.程序架构
&emsp;程序总体架构图：

![图1](https://github.com/xehuosh/TV-APM-OTFS/blob/main/README_Pictures/1.png?raw=true)
&emsp;TV-APM主要文件关系图：

![图2](https://github.com/xehuosh/TV-APM-OTFS/blob/main/README_Pictures/2.png?raw=true)

# 4.安装水声工具箱
## 4.1.下载The Acoustics Toolbox
&emsp;访问Ocean Acoustics Library - OALIB官网的水声工具箱下载栏目
http://oalib.hlsresearch.com/AcousticsToolbox/
&emsp;点击“Download”下面的第二个蓝色**at**，即可下载“atWin10_2020_11_4.zip”
![图3](https://github.com/xehuosh/TV-APM-OTFS/blob/main/README_Pictures/3.png?raw=true)

&emsp;接下来将这个压缩包解压，放到一个相对安全，不容易被误删的路径下。我放在了MATLAB的安装路径下的toolbox文件夹下，便于后续管理：

```
D:\Software\Matlab\toolbox
```

## 4.2.MATLAB添加路径

&emsp;启动MATLAB，在主页中选择“环境”→“设置路径”

![图4](https://github.com/xehuosh/TV-APM-OTFS/blob/main/README_Pictures/4.png?raw=true)

&emsp;出现弹窗后点击左上角的按钮“添加并包含子文件夹...”，选择刚才存放atWin10_2020_11_4文件夹的位置

![图5](https://github.com/xehuosh/TV-APM-OTFS/blob/main/README_Pictures/5.png?raw=true)

&emsp;依次点击“保存”和“关闭”，保存设置。

## 4.3.添加环境变量

1.右击**此电脑（我的电脑）**，**选择属性**；

2.点击**高级系统设置**；

3.选择**环境变量（N）...**；

4.双击**用户变量**中的**Path**选项，进入**编辑环境变量**；

5.选择**新建**；

6.添加atWin10_2020_11_4文件夹中**bellhop.exe**所在路径，点击**确定**即可。

本人添加路径是D:\Software\Matlab\toolbox\atWin10_2020_11_4\atWin10_2020_11_4\windows-bin-20201102，供参考。

7.**重启**使环境变量生效。



# 5.初次运行
