// Common.h

#ifndef __COMMON_COMMON_H
#define __COMMON_COMMON_H

/*
This file is included to all cpp files in 21Yasuo.
Each folder contains StdAfx.h file that includes "Common.h".
So 21Yasuo includes "Common.h" in both modes:
  with precompiled StdAfx.h
and
  without precompiled StdAfx.h

If you use 21Yasuo code, you must include "Common.h" before other h files of 21Yasuo.
If you don't need some things that are used in 21Yasuo,
you can change this h file or h files included in this file.
*/

// compiler pragmas to disable some warnings
#include "../../C/Compiler.h"

// it's <windows.h> or code that defines windows things, if it's not _WIN32
#include "MyWindows.h"

// NewHandler.h and NewHandler.cpp redefine operator new() to throw exceptions, if compiled with old MSVC compilers
#include "NewHandler.h"



#define ARRAY_SIZE(a) (sizeof(a) / sizeof((a)[0]))


/* There is BUG in MSVC 6.0 compiler for operator new[]:
   It doesn't check overflow, when it calculates size in bytes for allocated array.
   So we can use MY_ARRAY_NEW macro instead of new[] operator. */

#if defined(_MSC_VER) && (_MSC_VER == 1200) && !defined(_WIN64)
  #define MY_ARRAY_NEW(p, T, size) p = new T[(size > (unsigned)0xFFFFFFFF / sizeof(T)) ? (unsigned)0xFFFFFFFF / sizeof(T) : size];
#else
  #define MY_ARRAY_NEW(p, T, size) p = new T[size];
#endif

#endif
