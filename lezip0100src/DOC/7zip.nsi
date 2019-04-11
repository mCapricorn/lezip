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
!define NAME_FULL "乐压压缩 ${VERSION_MAJOR}.${VERSION_MINOR}${VERSION_POSTFIX_FULL}${VERSION_SYS_POSTFIX_FULL}"
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


#!define MUI_ICON ".\setup.ico"
!define FM_LINK "leya File Manager.lnk"


!define CLSID_CONTEXT_MENU {EB447312-D1BE-41A7-8B7F-9EE3AF1E4455}

#!define NO_COMPRESSION

  !include "Library.nsh"
  !include "MUI.nsh"


;--------------------------------
;Configuration

  ;General
  Name "${NAME_FULL}"
  BrandingText "www.dazhe9.com"
  OutFile "..\setup.exe"

  ;Folder selection page

  InstallDir "$PROGRAMFILES64\leya"
  
  ;Get install folder from registry if available
  InstallDirRegKey HKCU "Software\leya" "Path32"

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
  DeleteRegKey HKLM "Software\Microsoft\Windows\CurrentVersion\App Paths\leya.exe"
  !endif

  # delete old unwanted files

  Delete $INSTDIR\leya.exe
  Delete $INSTDIR\compressdlg.exe





  Delete $INSTDIR\7z.dll



  Delete $INSTDIR\Lang\no.txt

  # install files

  SetOutPath $INSTDIR





  File x86\7z.dll
  File x86\leya.exe
  File x86\compressdlg.exe
  File x86\leya.dll


  SetOutPath $INSTDIR\Lang

  File x86\Lang\en.ttt

  File x86\Lang\zh-cn.txt
  File x86\Lang\zh-tw.txt

  SetOutPath $INSTDIR

  # delete "current user" menu items

  Delete "$SMPROGRAMS\leya\${FM_LINK}"
  RMDir $SMPROGRAMS\leya

  # set "all users" mode

  SetShellVarContext all

  !insertmacro InstallLib DLL NOTSHARED REBOOT_NOTPROTECTED x86\leya.dll $INSTDIR\leya.dll $INSTDIR

  ClearErrors

  # create start menu icons

  SetOutPath $INSTDIR

  CreateDirectory $SMPROGRAMS\leya
  CreateShortCut "$SMPROGRAMS\leya\${FM_LINK}" $INSTDIR\leya.exe

  IfErrors 0 noScErrors

  SetShellVarContext current

  CreateDirectory $SMPROGRAMS\leya
  CreateShortCut "$SMPROGRAMS\leya\${FM_LINK}" $INSTDIR\leya.exe


noScErrors:

  # store install folder

  WriteRegStr HKLM Software\leya Path32 $INSTDIR
  WriteRegStr HKLM Software\leya Path   $INSTDIR
  WriteRegStr HKCU Software\leya Path32 $INSTDIR
  WriteRegStr HKCU Software\leya Path   $INSTDIR
  WriteRegDWORD HKCU Software\leya\options ContextMenu   4903
  WriteRegDWORD HKCU Software\leya\options CascadedMenu   0
  WriteRegDWORD HKCU Software\leya\options MenuIcons   1
  # write reg entries

  WriteRegStr HKCR "CLSID\${CLSID_CONTEXT_MENU}" "" "leya Shell Extension"
  WriteRegStr HKCR "CLSID\${CLSID_CONTEXT_MENU}\InprocServer32" "" $INSTDIR\leya.dll
  WriteRegStr HKCR "CLSID\${CLSID_CONTEXT_MENU}\InprocServer32" ThreadingModel Apartment
  DeleteRegValue HKCR "CLSID\${CLSID_CONTEXT_MENU}\InprocServer32" "InprocServer32"

  WriteRegStr HKCR "*\shellex\ContextMenuHandlers\leya" "" "${CLSID_CONTEXT_MENU}"
  WriteRegStr HKCR "Directory\shellex\ContextMenuHandlers\leya" "" "${CLSID_CONTEXT_MENU}"
  WriteRegStr HKCR "Folder\shellex\ContextMenuHandlers\leya" "" "${CLSID_CONTEXT_MENU}"

  WriteRegStr HKCR "Directory\shellex\DragDropHandlers\leya" "" "${CLSID_CONTEXT_MENU}"
  WriteRegStr HKCR "Drive\shellex\DragDropHandlers\leya" "" "${CLSID_CONTEXT_MENU}"

  WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Shell Extensions\Approved" "${CLSID_CONTEXT_MENU}" "leya Shell Extension"
  
  WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\App Paths\leya.exe" "" $INSTDIR\leya.exe
  WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\App Paths\leya.exe" Path $INSTDIR

  # create uninstaller

  WriteRegStr HKLM Software\Microsoft\Windows\CurrentVersion\Uninstall\leya DisplayName "${NAME_FULL}"
  WriteRegStr HKLM Software\Microsoft\Windows\CurrentVersion\Uninstall\leya UninstallString '"$INSTDIR\Uninstall.exe"'
  WriteRegDWORD HKLM Software\Microsoft\Windows\CurrentVersion\Uninstall\leya NoModify 1
  WriteRegDWORD HKLM Software\Microsoft\Windows\CurrentVersion\Uninstall\leya NoRepair 1

  WriteUninstaller $INSTDIR\Uninstall.exe

  WriteRegStr HKCR ".zip" "" "leyazip"
  WriteRegStr HKCR ".rar" "" "leyazip"
  WriteRegStr HKCR ".7z" "" "leyazip"
  WriteRegStr HKCR "leyazip" "" '乐压文件'
  WriteRegStr HKCR "leyazip\DefaultIcon" "" "$INSTDIR\leya.exe,0"
  WriteRegStr HKCR "leyazip\shell" "" open
  WriteRegStr HKCR "leyazip\shell\open" "" "打开(&leya)"
  WriteRegStr HKCR "leyazip\shell\open\command" "" '"$INSTDIR\leya.exe" "%1"'

  ExecWait 'regsvr32 /s "$INSTDIR\leya.dll"'
  System::Call 'Shell32::SHChangeNotify(i ${SHCNE_ASSOCCHANGED}, i ${SHCNF_IDLIST}, i 0, i 0)' 

SectionEnd
 
section "64-bit" SEC0001
  !ifndef WIN64
  DeleteRegKey HKLM "Software\Microsoft\Windows\CurrentVersion\App Paths\leya.exe"
  !endif

  # delete old unwanted files

  Delete $INSTDIR\leya.exe
  Delete $INSTDIR\compressdlg.exe





  Delete $INSTDIR\7z.dll



  Delete $INSTDIR\Lang\no.txt

  # install files

  SetOutPath $INSTDIR



  File x64\7z.dll
  File x64\leya.exe
  File x64\compressdlg.exe
  File x64\leya.dll


  SetOutPath $INSTDIR\Lang

  File x86\Lang\en.ttt

  File x86\Lang\zh-cn.txt
  File x86\Lang\zh-tw.txt

  SetOutPath $INSTDIR

  # delete "current user" menu items

  Delete "$SMPROGRAMS\leya\${FM_LINK}"
  RMDir $SMPROGRAMS\leya

  # set "all users" mode

  SetShellVarContext all

  !insertmacro InstallLib DLL NOTSHARED REBOOT_NOTPROTECTED x64\leya.dll $INSTDIR\leya.dll $INSTDIR

  ClearErrors

  # create start menu icons

  SetOutPath $INSTDIR

  CreateDirectory $SMPROGRAMS\leya
  CreateShortCut "$SMPROGRAMS\leya\${FM_LINK}" $INSTDIR\leya.exe

  IfErrors 0 noScErrors

  SetShellVarContext current

  CreateDirectory $SMPROGRAMS\leya
  CreateShortCut "$SMPROGRAMS\leya\${FM_LINK}" $INSTDIR\leya.exe


noScErrors:

  # store install folder

  WriteRegStr HKLM Software\leya Path32 $INSTDIR
  WriteRegStr HKLM Software\leya Path   $INSTDIR
  WriteRegStr HKCU Software\leya Path32 $INSTDIR
  WriteRegStr HKCU Software\leya Path   $INSTDIR
  WriteRegDWORD HKCU Software\leya\options ContextMenu   4903
  WriteRegDWORD HKCU Software\leya\options CascadedMenu   0
  WriteRegDWORD HKCU Software\leya\options MenuIcons   1

  # write reg entries

  WriteRegStr HKCR "CLSID\${CLSID_CONTEXT_MENU}" "" "leya Shell Extension"
  WriteRegStr HKCR "CLSID\${CLSID_CONTEXT_MENU}\InprocServer32" "" $INSTDIR\leya.dll
  WriteRegStr HKCR "CLSID\${CLSID_CONTEXT_MENU}\InprocServer32" ThreadingModel Apartment
  DeleteRegValue HKCR "CLSID\${CLSID_CONTEXT_MENU}\InprocServer32" "InprocServer32"

  WriteRegStr HKCR "*\shellex\ContextMenuHandlers\leya" "" "${CLSID_CONTEXT_MENU}"
  WriteRegStr HKCR "Directory\shellex\ContextMenuHandlers\leya" "" "${CLSID_CONTEXT_MENU}"
  WriteRegStr HKCR "Folder\shellex\ContextMenuHandlers\leya" "" "${CLSID_CONTEXT_MENU}"

  WriteRegStr HKCR "Directory\shellex\DragDropHandlers\leya" "" "${CLSID_CONTEXT_MENU}"
  WriteRegStr HKCR "Drive\shellex\DragDropHandlers\leya" "" "${CLSID_CONTEXT_MENU}"

  WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Shell Extensions\Approved" "${CLSID_CONTEXT_MENU}" "leya Shell Extension"
  
  WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\App Paths\leya.exe" "" $INSTDIR\leya.exe
  WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\App Paths\leya.exe" Path $INSTDIR

  # create uninstaller

  WriteRegStr HKLM Software\Microsoft\Windows\CurrentVersion\Uninstall\leya DisplayName "${NAME_FULL}"
  WriteRegStr HKLM Software\Microsoft\Windows\CurrentVersion\Uninstall\leya UninstallString '"$INSTDIR\Uninstall.exe"'
  WriteRegDWORD HKLM Software\Microsoft\Windows\CurrentVersion\Uninstall\leya NoModify 1
  WriteRegDWORD HKLM Software\Microsoft\Windows\CurrentVersion\Uninstall\leya NoRepair 1

  WriteUninstaller $INSTDIR\Uninstall.exe
  WriteRegStr HKCR ".zip" "" "leyazip"
  WriteRegStr HKCR ".rar" "" "leyazip"
  WriteRegStr HKCR ".7z" "" "leyazip"

  WriteRegStr HKCR "leyazip" "" '乐压文件'
  WriteRegStr HKCR "leyazip\DefaultIcon" "" "$INSTDIR\leya.exe,0"
  WriteRegStr HKCR "leyazip\shell" "" open
  WriteRegStr HKCR "leyazip\shell\open" "" "打开(&leya)"
  WriteRegStr HKCR "leyazip\shell\open\command" "" '"$INSTDIR\leya.exe" "%1"'

  ExecWait 'regsvr32 /s "$INSTDIR\leya.dll"'

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

  ExecWait 'regsvr32 /u /s "$INSTDIR\leya.dll"'

  # delete files

  Delete $INSTDIR\License.txt


  Delete $INSTDIR\7z.dll
  Delete $INSTDIR\leya.exe
  Delete $INSTDIR\compressdlg.exe


  Delete $INSTDIR\Lang\en.ttt

  Delete $INSTDIR\Lang\zh-cn.txt
  Delete $INSTDIR\Lang\zh-tw.txt

  RMDir $INSTDIR\Lang

  Delete /REBOOTOK $INSTDIR\leya.dll
  Delete $INSTDIR\Uninstall.exe

  RMDir $INSTDIR

  # delete start menu entires

  SetShellVarContext all

  # ClearErrors

  Delete "$SMPROGRAMS\leya\${FM_LINK}"
  RMDir $SMPROGRAMS\leya

  # IfErrors 0 noScErrors

  SetShellVarContext current

  Delete "$SMPROGRAMS\leya\${FM_LINK}"

  RMDir $SMPROGRAMS\leya

  # noScErrors:


  # delete registry entries

  DeleteRegKey HKLM Software\Microsoft\Windows\CurrentVersion\Uninstall\leya
  DeleteRegKey HKLM "Software\Microsoft\Windows\CurrentVersion\App Paths\leya.exe"

  DeleteRegKey HKLM Software\leya
  DeleteRegKey HKCU Software\leya

  DeleteRegKey HKCR CLSID\${CLSID_CONTEXT_MENU}

  DeleteRegKey HKCR *\shellex\ContextMenuHandlers\leya
  DeleteRegKey HKCR Directory\shellex\ContextMenuHandlers\leya
  DeleteRegKey HKCR Folder\shellex\ContextMenuHandlers\leya

  DeleteRegKey HKCR Drive\shellex\DragDropHandlers\leya
  DeleteRegKey HKCR Directory\shellex\DragDropHandlers\leya
  DeleteRegKey HKCR Folder\shellex\DragDropHandlers\leya

  DeleteRegValue HKLM "Software\Microsoft\Windows\CurrentVersion\Shell Extensions\Approved" "${CLSID_CONTEXT_MENU}"

  DeleteRegKey HKCR leya.001
  DeleteRegKey HKCR leya.7z
  DeleteRegKey HKCR leya.arj
  DeleteRegKey HKCR leya.bz2
  DeleteRegKey HKCR leya.bzip2
  DeleteRegKey HKCR leya.tbz
  DeleteRegKey HKCR leya.tbz2
  DeleteRegKey HKCR leya.cab
  DeleteRegKey HKCR leya.cpio
  DeleteRegKey HKCR leya.deb
  DeleteRegKey HKCR leya.dmg
  DeleteRegKey HKCR leya.fat
  DeleteRegKey HKCR leya.gz
  DeleteRegKey HKCR leya.gzip
  DeleteRegKey HKCR leya.hfs
  DeleteRegKey HKCR leya.iso
  DeleteRegKey HKCR leya.lha
  DeleteRegKey HKCR leya.lzh
  DeleteRegKey HKCR leya.lzma
  DeleteRegKey HKCR leya.ntfs
  DeleteRegKey HKCR leya.rar
  DeleteRegKey HKCR leya.rpm
  DeleteRegKey HKCR leya.split
  DeleteRegKey HKCR leya.squashfs
  DeleteRegKey HKCR leya.swm
  DeleteRegKey HKCR leya.tar
  DeleteRegKey HKCR leya.taz
  DeleteRegKey HKCR leya.tgz
  DeleteRegKey HKCR leya.tpz
  DeleteRegKey HKCR leya.txz
  DeleteRegKey HKCR leya.vhd
  DeleteRegKey HKCR leya.wim
  DeleteRegKey HKCR leya.xar
  DeleteRegKey HKCR leya.xz
  DeleteRegKey HKCR leya.z
  DeleteRegKey HKCR leya.zip

SectionEnd
