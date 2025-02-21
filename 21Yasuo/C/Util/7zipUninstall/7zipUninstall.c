/* 7zipUninstall.c - 21Yasuo Uninstaller
2019-02-02 : Zhi Yun : Public domain */

#include "Precomp.h"

#define SZ_ERROR_ABORT 100

#ifdef _MSC_VER
#pragma warning(disable : 4201) // nonstandard extension used : nameless struct/union
#pragma warning(disable : 4011) // vs2010: identifier truncated to _CRT_SECURE_CPP_OVERLOAD_SECURE
#endif

#include <windows.h>
#include <ShlObj.h>

#include "../../7zVersion.h"

#include "resource.h"

#define LLL_(quote) L##quote
#define LLL(quote) LLL_(quote)

// static const WCHAR * const k_7zip = L"21Yasuo";

// #define _64BIT_INSTALLER 1

#ifdef _WIN64
  #define _64BIT_INSTALLER 1
#endif

#define k_7zip_with_Ver_base L"21Yasuo " LLL(MY_VERSION)

#ifdef _64BIT_INSTALLER
  #define k_7zip_with_Ver k_7zip_with_Ver_base L" (x64)"
#else
  #define k_7zip_with_Ver k_7zip_with_Ver_base
#endif

// static const WCHAR * const k_7zip_with_Ver_str = k_7zip_with_Ver;

static const WCHAR * const k_Reg_Software_7zip = L"Software\\21Yasuo";

static const WCHAR * const k_Reg_Path = L"Path";
 
static const WCHAR * const k_Reg_Path32 = L"Path"
  #ifdef _64BIT_INSTALLER
    L"64"
  #else
    L"32"
  #endif
  ;

#if defined(_64BIT_INSTALLER) && !defined(_WIN64)
  #define k_Reg_WOW_Flag KEY_WOW64_64KEY
#else
  #define k_Reg_WOW_Flag 0
#endif

#ifdef _WIN64
  #define k_Reg_WOW_Flag_32 KEY_WOW64_32KEY
#else
  #define k_Reg_WOW_Flag_32 0
#endif

#define k_7zip_CLSID L"{EB447312-D1BE-41A7-8B7F-9EE3AF1E4455}"

static const WCHAR * const k_Reg_CLSID_7zip = L"CLSID\\" k_7zip_CLSID;
static const WCHAR * const k_Reg_CLSID_7zip_Inproc = L"CLSID\\" k_7zip_CLSID L"\\InprocServer32";


#define g_AllUsers True

static BoolInt g_Install_was_Pressed;
static BoolInt g_Finished;
static BoolInt g_SilentMode;

static HWND g_HWND;
static HWND g_Path_HWND;
static HWND g_InfoLine_HWND;
static HWND g_Progress_HWND;

typedef WINADVAPI LONG (APIENTRY *Func_RegDeleteKeyExW)(HKEY hKey, LPCWSTR lpSubKey, REGSAM samDesired, DWORD Reserved);
static Func_RegDeleteKeyExW func_RegDeleteKeyExW;

static WCHAR path[MAX_PATH * 2 + 40];
static WCHAR workDir[MAX_PATH + 10];
static WCHAR modulePath[MAX_PATH + 10];
static WCHAR modulePrefix[MAX_PATH + 10];
static WCHAR tempPath[MAX_PATH * 2 + 40];
static WCHAR cmdLine[MAX_PATH * 3 + 40];
static WCHAR copyPath[MAX_PATH * 2 + 40];

static const WCHAR * const kUninstallExe = L"Uninstall.exe";

#define MAKE_CHAR_UPPER(c) ((((c) >= 'a' && (c) <= 'z') ? (c) -= 0x20 : (c)))

static BoolInt AreStringsEqual_NoCase(const wchar_t *s1, const wchar_t *s2)
{
  for (;;)
  {
    wchar_t c1 = *s1++;
    wchar_t c2 = *s2++;
    if (c1 != c2 && MAKE_CHAR_UPPER(c1) != MAKE_CHAR_UPPER(c2))
      return False;
    if (c2 == 0)
      return True;
  }
}

static BoolInt IsString1PrefixedByString2_NoCase(const wchar_t *s1, const wchar_t *s2)
{
  for (;;)
  {
    wchar_t c1;
    wchar_t c2 = *s2++;
    if (c2 == 0)
      return True;
    c1 = *s1++;
    if (c1 != c2 && MAKE_CHAR_UPPER(c1) != MAKE_CHAR_UPPER(c2))
      return False;
  }
}

static void NormalizePrefix(WCHAR *s)
{
  size_t len = wcslen(s);
  if (len != 0)
    if (s[len - 1] != WCHAR_PATH_SEPARATOR)
    {
      s[len] = WCHAR_PATH_SEPARATOR;
      s[len + 1] = 0;
    }
}

static int MyRegistry_QueryString(HKEY hKey, LPCWSTR name, LPWSTR dest)
{
  DWORD cnt = MAX_PATH * sizeof(name[0]);
  DWORD type = 0;
  LONG res = RegQueryValueExW(hKey, name, NULL, &type, (LPBYTE)dest, (DWORD *)&cnt);
  if (type != REG_SZ)
    return False;
  return res == ERROR_SUCCESS;
}

static int MyRegistry_QueryString2(HKEY hKey, LPCWSTR keyName, LPCWSTR valName, LPWSTR dest)
{
  HKEY key = 0;
  LONG res = RegOpenKeyExW(hKey, keyName, 0, KEY_READ | k_Reg_WOW_Flag, &key);
  if (res != ERROR_SUCCESS)
    return False;
  {
    BoolInt res2 = MyRegistry_QueryString(key, valName, dest);
    RegCloseKey(key);
    return res2;
  }
}

static LONG MyRegistry_OpenKey_ReadWrite(HKEY parentKey, LPCWSTR name, HKEY *destKey)
{
  return RegOpenKeyExW(parentKey, name, 0, KEY_READ | KEY_WRITE | k_Reg_WOW_Flag, destKey);
}

static LONG MyRegistry_DeleteKey(HKEY parentKey, LPCWSTR name)
{
  #if k_Reg_WOW_Flag != 0
    if (func_RegDeleteKeyExW)
      return func_RegDeleteKeyExW(parentKey, name, k_Reg_WOW_Flag, 0);
    return E_FAIL;
  #else
    return RegDeleteKeyW(parentKey, name);
  #endif
}

#ifdef _64BIT_INSTALLER

static int MyRegistry_QueryString2_32(HKEY hKey, LPCWSTR keyName, LPCWSTR valName, LPWSTR dest)
{
  HKEY key = 0;
  LONG res = RegOpenKeyExW(hKey, keyName, 0, KEY_READ | k_Reg_WOW_Flag_32, &key);
  if (res != ERROR_SUCCESS)
    return False;
  {
    BoolInt res2 = MyRegistry_QueryString(key, valName, dest);
    RegCloseKey(key);
    return res2;
  }
}

static LONG MyRegistry_OpenKey_ReadWrite_32(HKEY parentKey, LPCWSTR name, HKEY *destKey)
{
  return RegOpenKeyExW(parentKey, name, 0, KEY_READ | KEY_WRITE | k_Reg_WOW_Flag_32, destKey);
}

static LONG MyRegistry_DeleteKey_32(HKEY parentKey, LPCWSTR name)
{
  #if k_Reg_WOW_Flag_32 != 0
    if (func_RegDeleteKeyExW)
      return func_RegDeleteKeyExW(parentKey, name, k_Reg_WOW_Flag_32, 0);
    return E_FAIL;
  #else
    return RegDeleteKeyW(parentKey, name);
  #endif
}

#endif




static void MyReg_DeleteVal_Path_if_Equal(HKEY hKey, LPCWSTR name)
{
  WCHAR s[MAX_PATH + 10];
  if (MyRegistry_QueryString(hKey, name, s))
  {
    NormalizePrefix(s);
    if (AreStringsEqual_NoCase(s, path))
      RegDeleteValueW(hKey, name);
  }
}

static void SetRegKey_Path2(HKEY parentKey)
{
  HKEY key = 0;
  LONG res = MyRegistry_OpenKey_ReadWrite(parentKey, k_Reg_Software_7zip, &key);
  if (res == ERROR_SUCCESS)
  {
    MyReg_DeleteVal_Path_if_Equal(key, k_Reg_Path32);
    MyReg_DeleteVal_Path_if_Equal(key, k_Reg_Path);

    RegCloseKey(key);
    // MyRegistry_DeleteKey(parentKey, k_Reg_Software_7zip);
  }
}

static void SetRegKey_Path()
{
  SetRegKey_Path2(HKEY_CURRENT_USER);
  SetRegKey_Path2(HKEY_LOCAL_MACHINE);
}

static HRESULT CreateShellLink(LPCWSTR srcPath, LPCWSTR targetPath)
{
  IShellLinkW *sl;
 
  // CoInitialize has already been called.
  HRESULT hres = CoCreateInstance(&CLSID_ShellLink, NULL, CLSCTX_INPROC_SERVER, &IID_IShellLinkW, (LPVOID*)&sl);

  if (SUCCEEDED(hres))
  {
    IPersistFile *pf;
    
    hres = sl->lpVtbl->QueryInterface(sl, &IID_IPersistFile, (LPVOID *)&pf);
   
    if (SUCCEEDED(hres))
    {
      WCHAR s[MAX_PATH + 10];
      hres = pf->lpVtbl->Load(pf, srcPath, TRUE);
      pf->lpVtbl->Release(pf);

      if (SUCCEEDED(hres))
      {
        hres = sl->lpVtbl->GetPath(sl, s, MAX_PATH, NULL, 0); // SLGP_RAWPATH
        if (!AreStringsEqual_NoCase(s, targetPath))
          hres = S_FALSE;
      }
    }

    sl->lpVtbl->Release(sl);
  }

  return hres;
}

static void SetShellProgramsGroup(HWND hwndOwner)
{
  #ifdef UNDER_CE

  UNUSED_VAR(hwndOwner)

  #else

  unsigned i = (g_AllUsers ? 1 : 2);

  for (; i < 3; i++)
  {
    // BoolInt isOK = True;
    WCHAR link[MAX_PATH + 40];
    WCHAR destPath[MAX_PATH + 40];

    link[0] = 0;
    
    if (SHGetFolderPathW(hwndOwner,
        i == 1 ? CSIDL_COMMON_PROGRAMS : CSIDL_PROGRAMS,
        NULL, SHGFP_TYPE_CURRENT, link) != S_OK)
      continue;

    NormalizePrefix(link);
    wcscat(link, L"21Yasuo\\");
    
    {
      const size_t baseLen = wcslen(link);
      unsigned k;
      BoolInt needDelete = False;

      for (k = 0; k < 2; k++)
      {
        wcscpy(link + baseLen, k == 0 ?
            L"21Yasuo File Manager.lnk" :
            L"21Yasuo Help.lnk");
        wcscpy(destPath, path);
        wcscat(destPath, k == 0 ?
            L"21Yasuo.exe" :
            L"21Yasuo.chm");
        
        if (CreateShellLink(link, destPath) == S_OK)
        {
          needDelete = True;
          DeleteFileW(link);
        }
      }

      if (needDelete)
      {
        link[baseLen] = 0;
        RemoveDirectoryW(link);
      }
    }
  }

  #endif
}


static const WCHAR * const k_ShellEx_Items[] =
{
    L"*\\shellex\\ContextMenuHandlers"
  , L"Directory\\shellex\\ContextMenuHandlers"
  , L"Folder\\shellex\\ContextMenuHandlers"
  , L"Directory\\shellex\\DragDropHandlers"
  , L"Drive\\shellex\\DragDropHandlers"
};

static const WCHAR * const k_Shell_Approved = L"Software\\Microsoft\\Windows\\CurrentVersion\\Shell Extensions\\Approved";

static const WCHAR * const k_AppPaths_21Yasuo = L"Software\\Microsoft\\Windows\\CurrentVersion\\App Paths\\21Yasuo.exe";
#define k_REG_Uninstall L"Software\\Microsoft\\Windows\\CurrentVersion\\Uninstall\\"
static const WCHAR * const k_Uninstall_7zip = k_REG_Uninstall L"21Yasuo";


static BoolInt AreEqual_Path_PrefixName(const wchar_t *s, const wchar_t *prefix, const wchar_t *name)
{
  if (!IsString1PrefixedByString2_NoCase(s, prefix))
    return False;
  return AreStringsEqual_NoCase(s + wcslen(prefix), name);
}

static void WriteCLSID()
{
  WCHAR s[MAX_PATH + 30];
  
  if (MyRegistry_QueryString2(HKEY_CLASSES_ROOT, k_Reg_CLSID_7zip_Inproc, NULL, s))
  {
    if (AreEqual_Path_PrefixName(s, path, L"21Yasuo.dll"))
    {
      {
        LONG res = MyRegistry_DeleteKey(HKEY_CLASSES_ROOT, k_Reg_CLSID_7zip_Inproc);
        if (res == ERROR_SUCCESS)
          MyRegistry_DeleteKey(HKEY_CLASSES_ROOT, k_Reg_CLSID_7zip);
      }

      {
        unsigned i;
        for (i = 0; i < sizeof(k_ShellEx_Items) / sizeof(k_ShellEx_Items[0]); i++)
        {
          WCHAR destPath[MAX_PATH];
          wcscpy(destPath, k_ShellEx_Items[i]);
          wcscat(destPath, L"\\21Yasuo");
          
          MyRegistry_DeleteKey(HKEY_CLASSES_ROOT, destPath);
        }
      }

      {
        HKEY destKey = 0;
        LONG res = MyRegistry_OpenKey_ReadWrite(HKEY_LOCAL_MACHINE, k_Shell_Approved, &destKey);
        if (res == ERROR_SUCCESS)
        {
          RegDeleteValueW(destKey, k_7zip_CLSID);
          /* res = */ RegCloseKey(destKey);
        }
      }
    }
  }

  
  #ifdef _64BIT_INSTALLER
  
  if (MyRegistry_QueryString2_32(HKEY_CLASSES_ROOT, k_Reg_CLSID_7zip_Inproc, NULL, s))
  {
    if (AreEqual_Path_PrefixName(s, path, L"21Yasuo32.dll"))
    {
      {
        LONG res = MyRegistry_DeleteKey_32(HKEY_CLASSES_ROOT, k_Reg_CLSID_7zip_Inproc);
        if (res == ERROR_SUCCESS)
          MyRegistry_DeleteKey_32(HKEY_CLASSES_ROOT, k_Reg_CLSID_7zip);
      }

      {
        unsigned i;
        for (i = 0; i < sizeof(k_ShellEx_Items) / sizeof(k_ShellEx_Items[0]); i++)
        {
          WCHAR destPath[MAX_PATH];
          wcscpy(destPath, k_ShellEx_Items[i]);
          wcscat(destPath, L"\\21Yasuo");
          
          MyRegistry_DeleteKey_32(HKEY_CLASSES_ROOT, destPath);
        }
      }

      {
        HKEY destKey = 0;
        LONG res = MyRegistry_OpenKey_ReadWrite_32(HKEY_LOCAL_MACHINE, k_Shell_Approved, &destKey);
        if (res == ERROR_SUCCESS)
        {
          RegDeleteValueW(destKey, k_7zip_CLSID);
          /* res = */ RegCloseKey(destKey);
        }
      }
    }
  }
  
  #endif


  if (MyRegistry_QueryString2(HKEY_LOCAL_MACHINE, k_AppPaths_21Yasuo, NULL, s))
    if (AreEqual_Path_PrefixName(s, path, L"21Yasuo.exe"))
      MyRegistry_DeleteKey(HKEY_LOCAL_MACHINE, k_AppPaths_21Yasuo);

  if (MyRegistry_QueryString2(HKEY_LOCAL_MACHINE, k_Uninstall_7zip, L"UninstallString", s))
    if (AreEqual_Path_PrefixName(s, path, kUninstallExe))
      MyRegistry_DeleteKey(HKEY_LOCAL_MACHINE, k_Uninstall_7zip);
}


static const wchar_t *GetCmdParam(const wchar_t *s)
{
  BoolInt quoteMode = False;
  for (;; s++)
  {
    wchar_t c = *s;
    if (c == L'\"')
      quoteMode = !quoteMode;
    else if (c == 0 || (c == L' ' && !quoteMode))
      return s;
  }
}

static void RemoveQuotes(wchar_t *s)
{
  const wchar_t *src = s;
  for (;;)
  {
    wchar_t c = *src++;
    if (c == '\"')
      continue;
    *s++ = c;
    if (c == 0)
      return;
  }
}

static BoolInt DoesFileOrDirExist()
{
  return (GetFileAttributesW(path) != INVALID_FILE_ATTRIBUTES);
}

static BOOL RemoveFileAfterReboot2(const WCHAR *s)
{
  #ifndef UNDER_CE
  return MoveFileExW(s, NULL, MOVEFILE_DELAY_UNTIL_REBOOT);
  #else
  UNUSED_VAR(s)
  return TRUE;
  #endif
}

static BOOL RemoveFileAfterReboot()
{
  return RemoveFileAfterReboot2(path);
}

#define IS_LIMIT_CHAR(c) (c == 0 || c == ' ')

static BoolInt IsThereSpace(const wchar_t *s)
{
  for (;;)
  {
    wchar_t c = *s++;
    if (c == 0)
      return False;
    if (c == ' ')
      return True;
  }
}

static void AddPathParam(wchar_t *dest, const wchar_t *src)
{
  BoolInt needQuote = IsThereSpace(src);
  if (needQuote)
    wcscat(dest, L"\"");
  wcscat(dest, src);
  if (needQuote)
    wcscat(dest, L"\"");
}



static BoolInt GetErrorMessage(DWORD errorCode, WCHAR *message)
{
  LPWSTR msgBuf;
  if (FormatMessageW(
          FORMAT_MESSAGE_ALLOCATE_BUFFER
        | FORMAT_MESSAGE_FROM_SYSTEM
        | FORMAT_MESSAGE_IGNORE_INSERTS,
        NULL, errorCode, 0, (LPWSTR) &msgBuf, 0, NULL) == 0)
    return False;
  wcscpy(message, msgBuf);
  LocalFree(msgBuf);
  return True;
}

static BOOL RemoveDir()
{
  DWORD attrib = GetFileAttributesW(path);
  if (attrib == INVALID_FILE_ATTRIBUTES)
    return TRUE;
  if (RemoveDirectoryW(path))
    return TRUE;
  return RemoveFileAfterReboot();
}





#define k_Lang L"Lang"

// NUM_LANG_TXT_FILES files are placed before en.ttt
#define NUM_LANG_TXT_FILES 88

#ifdef _64BIT_INSTALLER
  #define NUM_EXTRA_FILES_64BIT 1
#else
  #define NUM_EXTRA_FILES_64BIT 0
#endif

#define NUM_FILES (NUM_LANG_TXT_FILES + 1 + 13 + NUM_EXTRA_FILES_64BIT)

static const char * const k_Names =
  "af an ar ast az ba be bg bn br ca co cs cy da de el eo es et eu ext"
  " fa fi fr fur fy ga gl gu he hi hr hu hy id io is it ja ka kaa kab kk ko ku ku-ckb ky"
  " lij lt lv mk mn mng mng2 mr ms nb ne nl nn pa-in pl ps pt pt-br ro ru"
  " sa si sk sl sq sr-spc sr-spl sv ta th tr tt ug uk uz va vi yo zh-cn zh-tw"
  " en.ttt"
  " descript.ion"
  " History.txt"
  " License.txt"
  " readme.txt"
  " 21Yasuo.chm"
  " 7z.sfx"
  " 7zCon.sfx"
  " 7z.exe"
  " 7zG.exe"
  " 7z.dll"
  " 21Yasuo.exe"
  #ifdef _64BIT_INSTALLER
  " 21Yasuo32.dll"
  #endif
  " 21Yasuo.dll"
  " Uninstall.exe";



static int Install()
{
  SRes res = SZ_OK;
  WRes winRes = 0;
  
  // BoolInt needReboot = False;
  const size_t pathLen = wcslen(path);

  if (!g_SilentMode)
  {
    ShowWindow(g_Progress_HWND, SW_SHOW);
    ShowWindow(g_InfoLine_HWND, SW_SHOW);
    SendMessage(g_Progress_HWND, PBM_SETRANGE32, 0, NUM_FILES);
  }

  {
    unsigned i;
    const char *curName = k_Names;

    for (i = 0; *curName != 0; i++)
    {
      WCHAR *temp;

      if (!g_SilentMode)
      {
        MSG msg;
        
        // g_HWND
        while (PeekMessage(&msg, NULL, 0, 0, PM_REMOVE))
        {
          if (!IsDialogMessage(g_HWND, &msg))
          {
            TranslateMessage(&msg);
            DispatchMessage(&msg);
          }
          if (!g_HWND)
            return 1;
        }

        // Sleep(1);
        SendMessage(g_Progress_HWND, PBM_SETPOS, i, 0);
      }

      path[pathLen] = 0;
      temp = path + pathLen;
      
      if (i <= NUM_LANG_TXT_FILES)
        wcscpy(temp, k_Lang L"\\");
      
      {
        WCHAR *dest = temp + wcslen(temp);

        for (;;)
        {
          char c = *curName;
          if (c == 0)
            break;
          curName++;
          if (c == ' ')
            break;
          *dest++ = (Byte)c;
        }

        *dest = 0;
      }

      if (i < NUM_LANG_TXT_FILES)
        wcscat(temp, L".txt");
  
      if (!g_SilentMode)
        SetWindowTextW(g_InfoLine_HWND, temp);

      {
        DWORD attrib = GetFileAttributesW(path);
        if (attrib == INVALID_FILE_ATTRIBUTES)
          continue;
        if (attrib & FILE_ATTRIBUTE_READONLY)
          SetFileAttributesW(path, 0);
        if (!DeleteFileW(path))
        {
          if (!RemoveFileAfterReboot())
          {
            winRes = GetLastError();
          }
          /*
          else
            needReboot = True;
          */
        }
      }
    }

    wcscpy(path + pathLen, k_Lang);
    RemoveDir();

    path[pathLen] = 0;
    RemoveDir();
    
    if (!g_SilentMode)
      SendMessage(g_Progress_HWND, PBM_SETPOS, i, 0);

    if (*curName == 0)
    {
      SetRegKey_Path();
      WriteCLSID();
      SetShellProgramsGroup(g_HWND);
      if (!g_SilentMode)
        SetWindowTextW(g_InfoLine_HWND, k_7zip_with_Ver L" is uninstalled");
    }
  }

  if (winRes != 0)
    res = SZ_ERROR_FAIL;

  if (res == SZ_OK)
  {
    // if (!g_SilentMode && needReboot);
    return 0;
  }

  if (!g_SilentMode)
  {
    WCHAR m[MAX_PATH + 100];
    m[0] = 0;
    if (winRes == 0 || !GetErrorMessage(winRes, m))
      wcscpy(m, L"ERROR");
    MessageBoxW(g_HWND, m, L"Error", MB_ICONERROR | MB_OK);
  }
  
  return 1;
}


static void OnClose()
{
  if (g_Install_was_Pressed && !g_Finished)
  {
    if (MessageBoxW(g_HWND,
        L"Do you want to cancel uninstallation?",
        k_7zip_with_Ver,
        MB_ICONQUESTION | MB_YESNO | MB_DEFBUTTON2) != IDYES)
      return;
  }
  DestroyWindow(g_HWND);
  g_HWND = NULL;
}

static INT_PTR CALLBACK MyDlgProc(HWND hwnd, UINT message, WPARAM wParam, LPARAM lParam)
{
  UNUSED_VAR(lParam)

  switch (message)
  {
    case WM_INITDIALOG:
      g_Path_HWND = GetDlgItem(hwnd, IDE_EXTRACT_PATH);
      g_InfoLine_HWND = GetDlgItem(hwnd, IDT_CUR_FILE);
      g_Progress_HWND = GetDlgItem(hwnd, IDC_PROGRESS);

      SetWindowTextW(hwnd, k_7zip_with_Ver L" Uninstall");
      SetDlgItemTextW(hwnd, IDE_EXTRACT_PATH, path);

      ShowWindow(g_Progress_HWND, SW_HIDE);
      ShowWindow(g_InfoLine_HWND, SW_HIDE);

      break;

    case WM_COMMAND:
      switch (LOWORD(wParam))
      {
        case IDOK:
        {
          if (g_Finished)
          {
            OnClose();
            break;
          }
          if (!g_Install_was_Pressed)
          {
            SendMessage(hwnd, WM_NEXTDLGCTL, (WPARAM)GetDlgItem(hwnd, IDCANCEL), TRUE);
            
            EnableWindow(g_Path_HWND, FALSE);
            EnableWindow(GetDlgItem(hwnd, IDOK), FALSE);
            
            g_Install_was_Pressed = True;
            return TRUE;
          }
          break;
        }
        
        case IDCANCEL:
        {
          OnClose();
          break;
        }

        default: return FALSE;
      }
      break;
    
    case WM_CLOSE:
      OnClose();
      break;
    /*
    case WM_DESTROY:
      PostQuitMessage(0);
      return TRUE;
    */
    default:
      return FALSE;
  }
  
  return TRUE;
}


int APIENTRY WinMain(HINSTANCE hInstance, HINSTANCE hPrevInstance,
    #ifdef UNDER_CE
      LPWSTR
    #else
      LPSTR
    #endif
    lpCmdLine, int nCmdShow)
{
  const wchar_t *cmdParams;
  BoolInt useTemp = True;

  UNUSED_VAR(hPrevInstance)
  UNUSED_VAR(lpCmdLine)
  UNUSED_VAR(nCmdShow)

  #ifndef UNDER_CE
  CoInitialize(NULL);
  #endif

  #ifndef UNDER_CE
  func_RegDeleteKeyExW = (Func_RegDeleteKeyExW)
      GetProcAddress(GetModuleHandleW(L"advapi32.dll"), "RegDeleteKeyExW");
  #endif

  {
    const wchar_t *s = GetCommandLineW();
    
    #ifndef UNDER_CE
    s = GetCmdParam(s);
    #endif

    cmdParams = s;

    for (;;)
    {
      {
        wchar_t c = *s;
        if (c == 0)
          break;
        if (c == ' ')
        {
          s++;
          continue;
        }
      }

      {
        const wchar_t *s2 = GetCmdParam(s);
        if (s[0] == '/')
        {
          if (s[1] == 'S' && IS_LIMIT_CHAR(s[2]))
            g_SilentMode = True;
          else if (s[1] == 'N' && IS_LIMIT_CHAR(s[2]))
            useTemp = False;
          else if (s[1] == 'D' && s[2] == '=')
          {
            size_t num;
            s += 3;
            num = s2 - s;
            if (num <= MAX_PATH)
            {
              wcsncpy(workDir, s, num);
              workDir[num] = 0;
              RemoveQuotes(workDir);
              useTemp = False;
            }
          }
        }
        s = s2;
      }
    }
  }


  {
    wchar_t *name;
    DWORD len = GetModuleFileNameW(NULL, modulePath, MAX_PATH);
    if (len == 0 || len > MAX_PATH)
      return 1;

    name = NULL;
    wcscpy(modulePrefix, modulePath);

    {
      wchar_t *s = modulePrefix;
      for (;;)
      {
        wchar_t c = *s++;
        if (c == 0)
          break;
        if (c == WCHAR_PATH_SEPARATOR)
          name = s;
      }
    }
    
    if (!name)
      return 1;

    if (!AreStringsEqual_NoCase(name, kUninstallExe))
      useTemp = False;

    *name = 0; // keep only prefix for modulePrefix
  }


  if (useTemp)
  {
    DWORD winRes = GetTempPathW(MAX_PATH, path);

    // GetTempPath: the returned string ends with a backslash
    /*
      {
        WCHAR s[MAX_PATH + 1];
        wcscpy(s, path);
        GetLongPathNameW(s, path, MAX_PATH);
      }
    */

    if (winRes != 0 && winRes <= MAX_PATH + 1
        && !IsString1PrefixedByString2_NoCase(modulePrefix, path))
    {
      unsigned i;
      DWORD d;
    
      const size_t pathLen = wcslen(path);
      d = (GetTickCount() << 12) ^ (GetCurrentThreadId() << 14) ^ GetCurrentProcessId();
      
      for (i = 0; i < 100; i++, d += GetTickCount())
      {
        wcscpy(path + pathLen, L"7z");
        
        {
          wchar_t *s = path + wcslen(path);
          UInt32 value = d;
          unsigned k;
          for (k = 0; k < 8; k++)
          {
            unsigned t = value & 0xF;
            value >>= 4;
            s[7 - k] = (wchar_t)((t < 10) ? ('0' + t) : ('A' + (t - 10)));
          }
          s[k] = 0;
        }
        
        if (DoesFileOrDirExist())
          continue;
        if (CreateDirectoryW(path, NULL))
        {
          wcscat(path, WSTRING_PATH_SEPARATOR);
          wcscpy(tempPath, path);
          break;
        }
        if (GetLastError() != ERROR_ALREADY_EXISTS)
          break;
      }
      
      if (tempPath[0] != 0)
      {
        wcscpy(copyPath, tempPath);
        wcscat(copyPath, L"Uninst.exe"); // we need not "Uninstall.exe" here
        
        if (CopyFileW(modulePath, copyPath, TRUE))
        {
          RemoveFileAfterReboot2(copyPath);
          RemoveFileAfterReboot2(tempPath);
          
          {
            STARTUPINFOW si;
            PROCESS_INFORMATION pi;
            cmdLine[0] = 0;
            
            // maybe CreateProcess supports path with spaces even without quotes.
            AddPathParam(cmdLine, copyPath);
            wcscat(cmdLine, L" /N /D=");
            AddPathParam(cmdLine, modulePrefix);
            
            if (cmdParams[0] != 0 && wcslen(cmdParams) < MAX_PATH * 2 + 10)
              wcscat(cmdLine, cmdParams);
            
            memset(&si, 0, sizeof(si));
            si.cb = sizeof(si);
            
            if (CreateProcessW(NULL, cmdLine, NULL, NULL, FALSE, 0, NULL, tempPath, &si, &pi))
            {
              CloseHandle(pi.hThread);
              if (pi.hProcess)
              {
                CloseHandle(pi.hProcess);
                return 0;
              }
            }
          }
        }
      }
    }
  }

  wcscpy(path, modulePrefix);

  if (workDir[0] != 0)
  {
    wcscpy(path, workDir);
    NormalizePrefix(path);
  }

  /*
  if (path[0] == 0)
  {
    HKEY key = 0;
    BoolInt ok = False;
    LONG res = RegOpenKeyExW(HKEY_CURRENT_USER, k_Reg_Software_7zip, 0, KEY_READ | k_Reg_WOW_Flag, &key);
    if (res == ERROR_SUCCESS)
    {
      ok = MyRegistry_QueryString(key, k_Reg_Path32, path);
      // ok = MyRegistry_QueryString(key, k_Reg_Path, path);
      RegCloseKey(key);
    }
  }
  */


  if (g_SilentMode)
    return Install();

  {
    int retCode = 1;
    g_HWND = CreateDialog(
        hInstance,
        // GetModuleHandle(NULL),
        MAKEINTRESOURCE(IDD_INSTALL), NULL, MyDlgProc);
    if (!g_HWND)
      return 1;

    {
      HICON hIcon = LoadIcon(hInstance, MAKEINTRESOURCE(IDI_ICON));
      // SendMessage(g_HWND, WM_SETICON, (WPARAM)ICON_SMALL, (LPARAM)hIcon);
      SendMessage(g_HWND, WM_SETICON, (WPARAM)ICON_BIG, (LPARAM)hIcon);
    }

    {
      BOOL bRet;
      MSG msg;
      
      while ((bRet = GetMessage(&msg, NULL, 0, 0)) != 0)
      {
        if (bRet == -1)
          return retCode;
        if (!g_HWND)
          return retCode;

        if (!IsDialogMessage(g_HWND, &msg))
        {
          TranslateMessage(&msg);
          DispatchMessage(&msg);
        }
        if (!g_HWND)
          return retCode;

        if (g_Install_was_Pressed && !g_Finished)
        {
          retCode = Install();
          g_Finished = True;
          if (retCode != 0)
            break;
          if (!g_HWND)
            break;
          {
            SetDlgItemTextW(g_HWND, IDOK, L"Close");
            EnableWindow(GetDlgItem(g_HWND, IDOK), TRUE);
            EnableWindow(GetDlgItem(g_HWND, IDCANCEL), FALSE);
            SendMessage(g_HWND, WM_NEXTDLGCTL, (WPARAM)GetDlgItem(g_HWND, IDOK), TRUE);
          }
        }
      }

      if (g_HWND)
      {
        DestroyWindow(g_HWND);
        g_HWND = NULL;
      }
    }

    return retCode;
  }
}
