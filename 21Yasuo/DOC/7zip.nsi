;--------------------------------
;Defines

!define VERSION_MAJOR 2
!define VERSION_MINOR 0
!define VERSION_POSTFIX_FULL ""
!ifdef WIN64
!ifdef IA64
!define VERSION_SYS_POSTFIX_FULL " for Windows IA-64"
!else
!define VERSION_SYS_POSTFIX_FULL " for Windows x64"
!endif
!else
!define VERSION_SYS_POSTFIX_FULL ""
!endif
!define NAME_FULL "21压缩 ${VERSION_MAJOR}.${VERSION_MINOR}${VERSION_POSTFIX_FULL}${VERSION_SYS_POSTFIX_FULL}"
!define VERSION_POSTFIX ""
!ifdef WIN64
!ifdef IA64
!define VERSION_SYS_POSTFIX "-ia64"
!else
!define VERSION_SYS_POSTFIX "-x64"
!endif
!else
!define VERSION_SYS_POSTFIX ""
!endif


!define MUI_ICON ".\setup.ico"
!define FM_LINK "21Yasuo.lnk"


!define CLSID_CONTEXT_MENU {919877B6-CEF2-410A-B976-CA1C6C549685}

!define PRODUCT_NAME "21Yasuo"
!define PRODUCT_VERSION "1.0"
!define PRODUCT_PUBLISHER "重庆智云教育科技有限公司"
!define PRODUCT_WEB_SITE "http://www.21Yasuo.com"
!define PRODUCT_UNINST_KEY "Software\Microsoft\Windows\CurrentVersion\Uninstall\${PRODUCT_NAME}"
!define PRODUCT_UNINST_ROOT_KEY "HKLM"

#!define NO_COMPRESSION

  !include "Library.nsh"
  !include "MUI.nsh"
  !include "FileFunc.nsh"
  !include "WordFunc.nsh"

;--------------------------------
;Configuration

  ;General
  Name "${NAME_FULL}"
  BrandingText "www.21Yasuo.com"
  OutFile "..\21Yasuo_setup_1.0.0.exe"

  ;Folder selection page

  InstallDir "$PROGRAMFILES64\21Yasuo"

  ;Get install folder from registry if available
  InstallDirRegKey HKCU "Software\21Yasuo" "Path32"

  ;Compressor
!ifndef NO_COMPRESSION
  SetCompressor /solid lzma
  ; SetCompressorFilter 1
!ifdef IA64
  SetCompressorDictSize 8
!else
  SetCompressorDictSize 4
!endif
!else
  SetCompress off
!endif


;--------------------------------
;Variables
var channel
;--------------------------------
;Interface Settings

  !define MUI_ABORTWARNING

;--------------------------------
;Pages

  !insertmacro MUI_PAGE_LICENSE "License.txt"
  !insertmacro MUI_PAGE_DIRECTORY
  !insertmacro MUI_PAGE_INSTFILES
  !insertmacro MUI_PAGE_FINISH

  !insertmacro MUI_UNPAGE_CONFIRM
  !insertmacro MUI_UNPAGE_INSTFILES
  !insertmacro MUI_UNPAGE_FINISH

;--------------------------------
;Languages

!insertmacro MUI_LANGUAGE "SimpChinese"
;--------------------------------
;Reserve Files

  ;These files should be inserted before other files in the data block
  ;Keep these lines before any File command
  ;Only for solid compression (by default, solid compression is enabled for BZIP2 and LZMA)

  !insertmacro MUI_RESERVEFILE_LANGDLL

;--------------------------------
;Installer Sections
section "32-bit" SEC0000
  !ifndef WIN64
  DeleteRegKey HKLM "Software\Microsoft\Windows\CurrentVersion\App Paths\21Yasuo.exe"
  !endif

  # delete old unwanted files

  Delete $INSTDIR\21Yasuo.exe
  Delete $INSTDIR\compressdlg.exe





  Delete $INSTDIR\7z.dll



  Delete $INSTDIR\Lang\no.txt

  # install files

  SetOutPath $INSTDIR





  File x86\7z.dll
  File x86\21Yasuo.exe
  File x86\compressdlg.exe
  File x86\21Yasuo.dll


  SetOutPath $INSTDIR\Lang

  File x86\Lang\en.ttt

  File x86\Lang\zh-cn.txt
  File x86\Lang\zh-tw.txt

  SetOutPath $INSTDIR

  # delete "current user" menu items

  Delete "$SMPROGRAMS\21Yasuo\${FM_LINK}"
  RMDir $SMPROGRAMS\21Yasuo

  # set "all users" mode

  SetShellVarContext all

  !insertmacro InstallLib DLL NOTSHARED REBOOT_NOTPROTECTED x86\21Yasuo.dll $INSTDIR\21Yasuo.dll $INSTDIR

  ClearErrors

  # create start menu icons

  SetOutPath $INSTDIR

  CreateDirectory $SMPROGRAMS\21Yasuo
  CreateShortCut "$SMPROGRAMS\21Yasuo\${FM_LINK}" $INSTDIR\21Yasuo.exe

  IfErrors 0 noScErrors

  SetShellVarContext current

  CreateDirectory $SMPROGRAMS\21Yasuo
  CreateShortCut "$SMPROGRAMS\21Yasuo\${FM_LINK}" $INSTDIR\21Yasuo.exe


noScErrors:
  # 获取参数中的渠道号
  ${GetOptions} $CMDLINE "/Chnl=" $channel
  ${if} $channel == ""
        StrCpy $channel "channel_init"
  ${endif}

  # store install folder

  WriteRegStr HKLM Software\21Yasuo Path32 $INSTDIR
  WriteRegStr HKLM Software\21Yasuo Path   $INSTDIR
  WriteRegStr HKCU Software\21Yasuo Path32 $INSTDIR
  WriteRegStr HKCU Software\21Yasuo Path   $INSTDIR
  WriteRegDWORD HKCU Software\21Yasuo\options ContextMenu   4903
  WriteRegDWORD HKCU Software\21Yasuo\options CascadedMenu   0
  WriteRegDWORD HKCU Software\21Yasuo\options MenuIcons   1
  # write reg entries

  WriteRegStr HKCR "CLSID\${CLSID_CONTEXT_MENU}" "" "21Yasuo Shell Extension"
  WriteRegStr HKCR "CLSID\${CLSID_CONTEXT_MENU}\InprocServer32" "" $INSTDIR\21Yasuo.dll
  WriteRegStr HKCR "CLSID\${CLSID_CONTEXT_MENU}\InprocServer32" ThreadingModel Apartment
  DeleteRegValue HKCR "CLSID\${CLSID_CONTEXT_MENU}\InprocServer32" "InprocServer32"

  WriteRegStr HKCR "*\shellex\ContextMenuHandlers\21Yasuo" "" "${CLSID_CONTEXT_MENU}"
  WriteRegStr HKCR "Directory\shellex\ContextMenuHandlers\21Yasuo" "" "${CLSID_CONTEXT_MENU}"
  WriteRegStr HKCR "Folder\shellex\ContextMenuHandlers\21Yasuo" "" "${CLSID_CONTEXT_MENU}"

  WriteRegStr HKCR "Directory\shellex\DragDropHandlers\21Yasuo" "" "${CLSID_CONTEXT_MENU}"
  WriteRegStr HKCR "Drive\shellex\DragDropHandlers\21Yasuo" "" "${CLSID_CONTEXT_MENU}"

  WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Shell Extensions\Approved" "${CLSID_CONTEXT_MENU}" "21Yasuo Shell Extension"

  WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\App Paths\21Yasuo.exe" "" $INSTDIR\21Yasuo.exe
  WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\App Paths\21Yasuo.exe" Path $INSTDIR

  # create uninstaller

  WriteRegStr ${PRODUCT_UNINST_ROOT_KEY} "${PRODUCT_UNINST_KEY}" "DisplayName" "${NAME_FULL}"
  WriteRegStr ${PRODUCT_UNINST_ROOT_KEY} "${PRODUCT_UNINST_KEY}" "UninstallString" '"$INSTDIR\Uninstall.exe"'
  WriteRegDWORD ${PRODUCT_UNINST_ROOT_KEY} "${PRODUCT_UNINST_KEY}" "NoModify" 1
  WriteRegDWORD ${PRODUCT_UNINST_ROOT_KEY} "${PRODUCT_UNINST_KEY}" "NoRepair" 1
  WriteRegStr ${PRODUCT_UNINST_ROOT_KEY} "${PRODUCT_UNINST_KEY}" "DisplayVersion" "${PRODUCT_VERSION}"
  WriteRegStr ${PRODUCT_UNINST_ROOT_KEY} "${PRODUCT_UNINST_KEY}" "URLInfoAbout" "${PRODUCT_WEB_SITE}"
  WriteRegStr ${PRODUCT_UNINST_ROOT_KEY} "${PRODUCT_UNINST_KEY}" "Publisher" "${PRODUCT_PUBLISHER}"
  WriteRegStr ${PRODUCT_UNINST_ROOT_KEY} "${PRODUCT_UNINST_KEY}" "Channel" "$channel"

  WriteUninstaller $INSTDIR\Uninstall.exe

  WriteRegStr HKCR ".zip" "" "21Yasuozip"
  WriteRegStr HKCR ".rar" "" "21Yasuozip"
  WriteRegStr HKCR ".7z" "" "21Yasuozip"
  WriteRegStr HKCR "21Yasuozip" "" '21zip文件'
  WriteRegStr HKCR "21Yasuozip\DefaultIcon" "" "$INSTDIR\21Yasuo.exe,0"
  WriteRegStr HKCR "21Yasuozip\shell" "" open
  WriteRegStr HKCR "21Yasuozip\shell\open" "" "打开(21&Yasuo)"
  WriteRegStr HKCR "21Yasuozip\shell\open\command" "" '"$INSTDIR\21Yasuo.exe" "%1"'

  ExecWait 'regsvr32 /s "$INSTDIR\21Yasuo.dll"'
  System::Call 'Shell32::SHChangeNotify(i ${SHCNE_ASSOCCHANGED}, i ${SHCNF_IDLIST}, i 0, i 0)'

SectionEnd

section "64-bit" SEC0001
  !ifndef WIN64
  DeleteRegKey HKLM "Software\Microsoft\Windows\CurrentVersion\App Paths\21Yasuo.exe"
  !endif

  # delete old unwanted files

  Delete $INSTDIR\21Yasuo.exe
  Delete $INSTDIR\compressdlg.exe





  Delete $INSTDIR\7z.dll



  Delete $INSTDIR\Lang\no.txt

  # install files

  SetOutPath $INSTDIR



  File x64\7z.dll
  File x64\21Yasuo.exe
  File x64\compressdlg.exe
  File x64\21Yasuo.dll


  SetOutPath $INSTDIR\Lang

  File x86\Lang\en.ttt

  File x86\Lang\zh-cn.txt
  File x86\Lang\zh-tw.txt

  SetOutPath $INSTDIR

  # delete "current user" menu items

  Delete "$SMPROGRAMS\21Yasuo\${FM_LINK}"
  RMDir $SMPROGRAMS\21Yasuo

  # set "all users" mode

  SetShellVarContext all

  !insertmacro InstallLib DLL NOTSHARED REBOOT_NOTPROTECTED x64\21Yasuo.dll $INSTDIR\21Yasuo.dll $INSTDIR

  ClearErrors

  # create start menu icons

  SetOutPath $INSTDIR

  CreateDirectory $SMPROGRAMS\21Yasuo
  CreateShortCut "$SMPROGRAMS\21Yasuo\${FM_LINK}" $INSTDIR\21Yasuo.exe

  IfErrors 0 noScErrors

  SetShellVarContext current

  CreateDirectory $SMPROGRAMS\21Yasuo
  CreateShortCut "$SMPROGRAMS\21Yasuo\${FM_LINK}" $INSTDIR\21Yasuo.exe


noScErrors:
  # 获取参数中的渠道号
  ${GetOptions} $CMDLINE "/Chnl=" $channel
  ${if} $channel == ""
        StrCpy $channel "channel_init"
  ${endif}
  # store install folder

  WriteRegStr HKLM Software\21Yasuo Path32 $INSTDIR
  WriteRegStr HKLM Software\21Yasuo Path   $INSTDIR
  WriteRegStr HKCU Software\21Yasuo Path32 $INSTDIR
  WriteRegStr HKCU Software\21Yasuo Path   $INSTDIR
  WriteRegDWORD HKCU Software\21Yasuo\options ContextMenu   4903
  WriteRegDWORD HKCU Software\21Yasuo\options CascadedMenu   0
  WriteRegDWORD HKCU Software\21Yasuo\options MenuIcons   1

  # write reg entries

  WriteRegStr HKCR "CLSID\${CLSID_CONTEXT_MENU}" "" "21Yasuo Shell Extension"
  WriteRegStr HKCR "CLSID\${CLSID_CONTEXT_MENU}\InprocServer32" "" $INSTDIR\21Yasuo.dll
  WriteRegStr HKCR "CLSID\${CLSID_CONTEXT_MENU}\InprocServer32" ThreadingModel Apartment
  DeleteRegValue HKCR "CLSID\${CLSID_CONTEXT_MENU}\InprocServer32" "InprocServer32"

  WriteRegStr HKCR "*\shellex\ContextMenuHandlers\21Yasuo" "" "${CLSID_CONTEXT_MENU}"
  WriteRegStr HKCR "Directory\shellex\ContextMenuHandlers\21Yasuo" "" "${CLSID_CONTEXT_MENU}"
  WriteRegStr HKCR "Folder\shellex\ContextMenuHandlers\21Yasuo" "" "${CLSID_CONTEXT_MENU}"

  WriteRegStr HKCR "Directory\shellex\DragDropHandlers\21Yasuo" "" "${CLSID_CONTEXT_MENU}"
  WriteRegStr HKCR "Drive\shellex\DragDropHandlers\21Yasuo" "" "${CLSID_CONTEXT_MENU}"

  WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Shell Extensions\Approved" "${CLSID_CONTEXT_MENU}" "21Yasuo Shell Extension"

  WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\App Paths\21Yasuo.exe" "" $INSTDIR\21Yasuo.exe
  WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\App Paths\21Yasuo.exe" Path $INSTDIR

  # create uninstaller

  WriteRegStr ${PRODUCT_UNINST_ROOT_KEY} "${PRODUCT_UNINST_KEY}" "DisplayName" "${NAME_FULL}"
  WriteRegStr ${PRODUCT_UNINST_ROOT_KEY} "${PRODUCT_UNINST_KEY}" "UninstallString" '"$INSTDIR\Uninstall.exe"'
  WriteRegDWORD ${PRODUCT_UNINST_ROOT_KEY} "${PRODUCT_UNINST_KEY}" "NoModify" 1
  WriteRegDWORD ${PRODUCT_UNINST_ROOT_KEY} "${PRODUCT_UNINST_KEY}" "NoRepair" 1
  WriteRegStr ${PRODUCT_UNINST_ROOT_KEY} "${PRODUCT_UNINST_KEY}" "DisplayVersion" "${PRODUCT_VERSION}"
  WriteRegStr ${PRODUCT_UNINST_ROOT_KEY} "${PRODUCT_UNINST_KEY}" "URLInfoAbout" "${PRODUCT_WEB_SITE}"
  WriteRegStr ${PRODUCT_UNINST_ROOT_KEY} "${PRODUCT_UNINST_KEY}" "Publisher" "${PRODUCT_PUBLISHER}"
  WriteRegStr ${PRODUCT_UNINST_ROOT_KEY} "${PRODUCT_UNINST_KEY}" "Channel" "$channel"

  WriteUninstaller $INSTDIR\Uninstall.exe
  WriteRegStr HKCR ".zip" "" "21Yasuozip"
  WriteRegStr HKCR ".rar" "" "21Yasuozip"
  WriteRegStr HKCR ".7z" "" "21Yasuozip"

  WriteRegStr HKCR "21Yasuozip" "" '21zip文件'
  WriteRegStr HKCR "21Yasuozip\DefaultIcon" "" "$INSTDIR\21Yasuo.exe,0"
  WriteRegStr HKCR "21Yasuozip\shell" "" open
  WriteRegStr HKCR "21Yasuozip\shell\open" "" "打开(21&Yasuo)"
  WriteRegStr HKCR "21Yasuozip\shell\open\command" "" '"$INSTDIR\21Yasuo.exe" "%1"'

  ExecWait 'regsvr32 /s "$INSTDIR\21Yasuo.dll"'

  System::Call 'Shell32::SHChangeNotify(i ${SHCNE_ASSOCCHANGED}, i ${SHCNF_IDLIST}, i 0, i 0)'
sectionEND
;--------------------------------
;Installer Functions


!include x64.nsh

Function .onInit
  #Determine the bitness of the OS and enable the correct section
  ${If} ${RunningX64}
    SectionSetFlags ${SEC0000}  ${SECTION_OFF}
    SectionSetFlags ${SEC0001}  ${SF_SELECTED}

  ${Else}
    SectionSetFlags ${SEC0001}  ${SECTION_OFF}
    SectionSetFlags ${SEC0000}  ${SF_SELECTED}

  ${EndIf}
FunctionEnd





;--------------------------------
;Uninstaller Section

Section Uninstall

  ExecWait 'regsvr32 /u /s "$INSTDIR\21Yasuo.dll"'

  # delete files

  Delete $INSTDIR\License.txt


  Delete $INSTDIR\7z.dll
  Delete $INSTDIR\21Yasuo.exe
  Delete $INSTDIR\compressdlg.exe


  Delete $INSTDIR\Lang\en.ttt

  Delete $INSTDIR\Lang\zh-cn.txt
  Delete $INSTDIR\Lang\zh-tw.txt

  RMDir $INSTDIR\Lang

  Delete /REBOOTOK $INSTDIR\21Yasuo.dll
  Delete $INSTDIR\Uninstall.exe

  RMDir $INSTDIR

  # delete start menu entires

  SetShellVarContext all

  # ClearErrors

  Delete "$SMPROGRAMS\21Yasuo\${FM_LINK}"
  RMDir $SMPROGRAMS\21Yasuo

  # IfErrors 0 noScErrors

  SetShellVarContext current

  Delete "$SMPROGRAMS\21Yasuo\${FM_LINK}"

  RMDir $SMPROGRAMS\21Yasuo

  # noScErrors:


  # delete registry entries

  DeleteRegKey HKLM Software\Microsoft\Windows\CurrentVersion\Uninstall\21Yasuo
  DeleteRegKey HKLM "Software\Microsoft\Windows\CurrentVersion\App Paths\21Yasuo.exe"

  DeleteRegKey HKLM Software\21Yasuo
  DeleteRegKey HKCU Software\21Yasuo

  DeleteRegKey HKCR CLSID\${CLSID_CONTEXT_MENU}

  DeleteRegKey HKCR *\shellex\ContextMenuHandlers\21Yasuo
  DeleteRegKey HKCR Directory\shellex\ContextMenuHandlers\21Yasuo
  DeleteRegKey HKCR Folder\shellex\ContextMenuHandlers\21Yasuo

  DeleteRegKey HKCR Drive\shellex\DragDropHandlers\21Yasuo
  DeleteRegKey HKCR Directory\shellex\DragDropHandlers\21Yasuo
  DeleteRegKey HKCR Folder\shellex\DragDropHandlers\21Yasuo

  DeleteRegValue HKLM "Software\Microsoft\Windows\CurrentVersion\Shell Extensions\Approved" "${CLSID_CONTEXT_MENU}"

  DeleteRegKey HKCR 21Yasuo.001
  DeleteRegKey HKCR 21Yasuo.7z
  DeleteRegKey HKCR 21Yasuo.arj
  DeleteRegKey HKCR 21Yasuo.bz2
  DeleteRegKey HKCR 21Yasuo.bzip2
  DeleteRegKey HKCR 21Yasuo.tbz
  DeleteRegKey HKCR 21Yasuo.tbz2
  DeleteRegKey HKCR 21Yasuo.cab
  DeleteRegKey HKCR 21Yasuo.cpio
  DeleteRegKey HKCR 21Yasuo.deb
  DeleteRegKey HKCR 21Yasuo.dmg
  DeleteRegKey HKCR 21Yasuo.fat
  DeleteRegKey HKCR 21Yasuo.gz
  DeleteRegKey HKCR 21Yasuo.gzip
  DeleteRegKey HKCR 21Yasuo.hfs
  DeleteRegKey HKCR 21Yasuo.iso
  DeleteRegKey HKCR 21Yasuo.lha
  DeleteRegKey HKCR 21Yasuo.lzh
  DeleteRegKey HKCR 21Yasuo.lzma
  DeleteRegKey HKCR 21Yasuo.ntfs
  DeleteRegKey HKCR 21Yasuo.rar
  DeleteRegKey HKCR 21Yasuo.rpm
  DeleteRegKey HKCR 21Yasuo.split
  DeleteRegKey HKCR 21Yasuo.squashfs
  DeleteRegKey HKCR 21Yasuo.swm
  DeleteRegKey HKCR 21Yasuo.tar
  DeleteRegKey HKCR 21Yasuo.taz
  DeleteRegKey HKCR 21Yasuo.tgz
  DeleteRegKey HKCR 21Yasuo.tpz
  DeleteRegKey HKCR 21Yasuo.txz
  DeleteRegKey HKCR 21Yasuo.vhd
  DeleteRegKey HKCR 21Yasuo.wim
  DeleteRegKey HKCR 21Yasuo.xar
  DeleteRegKey HKCR 21Yasuo.xz
  DeleteRegKey HKCR 21Yasuo.z
  DeleteRegKey HKCR 21Yasuo.zip

SectionEnd
