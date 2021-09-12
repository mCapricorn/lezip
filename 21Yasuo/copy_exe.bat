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

copy .\CPP\7zip\UI\GUI\x86\compressdlg.exe .\DOC\x86\compressdlg.exe
copy .\CPP\7zip\Bundles\Fm\x86\21Yasuo.exe .\DOC\x86\21Yasuo.exe
copy .\CPP\7zip\UI\Explorer\x86\21Yasuo.dll .\DOC\x86\21Yasuo.dll

pause
goto again
)

if "%num%"=="2" (
cls

copy .\CPP\7zip\UI\GUI\x64\compressdlg.exe .\DOC\x64\compressdlg.exe
copy .\CPP\7zip\Bundles\Fm\x64\21Yasuo.exe .\DOC\x64\21Yasuo.exe
copy .\CPP\7zip\UI\Explorer\x64\21Yasuo.dll .\DOC\x64\21Yasuo.dll

pause
goto again
)

echo.
echo.
echo 输入了%num%字符，批处理自动推出。
