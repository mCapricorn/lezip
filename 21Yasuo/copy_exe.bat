@echo off
:again
cls
echo.
echo.
echo ######################请选择要执行的操作######################
echo ----------------------1、拷贝32位文件----------------------
echo ----------------------2、拷贝64位文件----------------------
echo ----------------------*、输入任何其它字符，终止批处理----------------------
echo.
echo.
echo 请选择要执行的操作
set /p num=

if "%num%"=="1" (
cls

copy C:\A\zhouxin\project\yasuo\source\lezip-master\lezip0100src\CPP\7zip\UI\GUI\x86\compressdlg.exe C:\A\zhouxin\project\yasuo\source\lezip-master\lezip0100src\DOC\x86\compressdlg.exe
copy C:\A\zhouxin\project\yasuo\source\lezip-master\lezip0100src\CPP\7zip\Bundles\Fm\x86\21Yasuo.exe C:\A\zhouxin\project\yasuo\source\lezip-master\lezip0100src\DOC\x86\21Yasuo.exe
copy C:\A\zhouxin\project\yasuo\source\lezip-master\lezip0100src\CPP\7zip\UI\Explorer\x86\21Yasuo.dll C:\A\zhouxin\project\yasuo\source\lezip-master\lezip0100src\DOC\x86\21Yasuo.dll

pause
goto again
)

if "%num%"=="2" (
cls

copy C:\A\zhouxin\project\yasuo\source\lezip-master\lezip0100src\CPP\7zip\UI\GUI\x64\compressdlg.exe C:\A\zhouxin\project\yasuo\source\lezip-master\lezip0100src\DOC\x64\compressdlg.exe
copy C:\A\zhouxin\project\yasuo\source\lezip-master\lezip0100src\CPP\7zip\Bundles\Fm\x64\21Yasuo.exe C:\A\zhouxin\project\yasuo\source\lezip-master\lezip0100src\DOC\x64\21Yasuo.exe
copy C:\A\zhouxin\project\yasuo\source\lezip-master\lezip0100src\CPP\7zip\UI\Explorer\x64\21Yasuo.dll C:\A\zhouxin\project\yasuo\source\lezip-master\lezip0100src\DOC\x64\21Yasuo.dll

pause
goto again
)

echo.
echo.
echo 输入了%num%字符，批处理自动推出。
