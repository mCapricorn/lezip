@echo off
:again
cls
echo.
echo.
echo ######################��ѡ��Ҫִ�еĲ���######################
echo ----------------------1������32λ�ļ�----------------------
echo ----------------------2������64λ�ļ�----------------------
echo ----------------------*�������κ������ַ�����ֹ������----------------------
echo.
echo.
echo ��ѡ��Ҫִ�еĲ���
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
echo ������%num%�ַ����������Զ��Ƴ���
