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
echo ������%num%�ַ����������Զ��Ƴ���
