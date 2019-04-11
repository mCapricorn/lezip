lezip基于开源软件7-zip。
针对中国人的使用习惯做了优化。
现在的压缩软件往往会弹广告，使用开源软件编译出的软件，能够自己掌握。
lezip采用visual studio 2013编译，采用命令行编译
打开visual studio环境命令行
cd lezip0100src\CPP\7zip
x86运行nmake PLATFORM="x86" SUB_SYS_VER=1
x64运行nmake PLATFORM="x64"
安装包使用nsis制作
有疑问请联系微信号yitianyigeguanjun
