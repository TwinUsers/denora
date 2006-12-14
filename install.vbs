'
' install.vbs - Windows Configuration
'
' (C) 2004-2006 Denora Team
' Contact us at info@nomadirc.net
'
' Please read COPYING and README for furhter details.
'
' Based on the original code of Anope by Anope Team.
' Based on the original code of Thales by Lucas.
' 
'
' $Id: install.vbs 716 2006-09-20 17:06:11Z trystan $
'

' Declare global variables
Dim AnoVersion
Dim UseMySQL
Dim UsePostgreSQL
Dim CompilerVer
Dim fso
Dim DefaultDrive
Dim MySQLLibPath
Dim MySQLHeadPath
Dim LibPath
Dim LibPath2
Dim IncDir
Dim IncDir2
Dim verMaj
Dim verMin
Dim verPatch
Dim verExtra
Dim verBuild
Dim verStringShort
Dim verStringLong
Dim f2
Dim i
Dim VS2005Dep  ' We need to do some defines to prevent issues

' Set default values

  ' If you have installed your files onto a different drive letter
  ' please specify that drive letter here.
  DefaultDrive = "C"

AnoVersion = "1.2.0"
UseMySQL = "0"
CompilerVer = "VC7"
Set fso = CreateObject("Scripting.FileSystemObject")
MySQLLibPath = DefaultDrive & ":\Program Files\mysql\MySQL Server 4.1\lib\opt"
MySQLHeadPath = DefaultDrive & ":\Program Files\mysql\MySQL Server 4.1\include"
LibPath = ""
LibPath2 = ""
IncDir = ""
IncDir2 = ""

' Get Version
If (fso.FileExists("version.log") = False) Then
        WScript.Echo "I can't find 'version.log' in this directory."
        WScript.Echo "Please run this script from a complete Denora source."
Else
        Set f2 = fso.OpenTextFile("version.log", ForReading)
        Do While (i < 7)
                f2.SkipLine()
                i = i + 1
        Loop
        verMaj = Replace(Replace(Trim(f2.ReadLine), "VERSION_MAJOR=" & chr(34), ""), chr(34), "")
        verMin = Replace(Replace(Trim(f2.ReadLine), "VERSION_MINOR=" & chr(34), ""), chr(34), "")
        verPatch = Replace(Replace(Trim(f2.ReadLine), "VERSION_PATCH=" & chr(34), ""), chr(34), "")
        verExtra = Replace(Replace(Trim(f2.ReadLine), "VERSION_EXTRA=" & chr(34), ""), chr(34), "")
        verBuild = Replace(Replace(Trim(f2.ReadLine), "VERSION_BUILD=" & chr(34), ""), chr(34), "")
        f2.close
        verStringShort = verMaj & "." & verMin & "." & verPatch & verExtra
        verStringLong = verStringShort & "." & verBuild

        ' Display Header
        WScript.Echo ""
        WScript.Echo " _____                    __"
        WScript.Echo "|  _  \       __       __/  \"
        WScript.Echo "| | \  |     /  \__   /      \___"
        WScript.Echo "| |  | | ___/ _ __ \_/_  _ __  __\_"
        WScript.Echo "| |  |  / _ \| '_ \/ _ \| '__|/  _ |"
        WScript.Echo "| |_/  |  __/| | |  |_| | |  ' (_| |"
        WScript.Echo "|_____/ \___||_| |_\___/|_|   \__,_|_"
        WScript.Echo "          Statistics for IRC Networks"
        WScript.Echo "                        v" & verStringLong
        WScript.Echo ""
        WScript.Echo ""
        WScript.Echo "This program will help you to compile your Stats software, and ask you"
        WScript.Echo "questions regarding the compile-time settings of it during the process."
        WScript.Echo "regarding the setup of it, during the process."
        WScript.Echo ""
        WScript.Echo "Denora is a set of IRC Stats expanded upon Luca's Thales."
        WScript.Echo "For all your Denora needs please visit our portal"
        WScript.Echo "at http://denora.nomadirc.net/"
        WScript.Echo ""
        WScript.Echo "For more detailed information on the features of Denora "& verStringShort
        WScript.Echo "please read the self-named documentation found on the 'docs' directory."
        WScript.Echo ""
        WScript.Echo "Press Enter to Continue..."
        Wscript.StdIn.ReadLine
        
        ' Enable MySQL Support?
        Do While (UseMySQL <> "Y" AND UseMySQL <> "N" AND UseMySQL <> "YES" AND UseMySQL <> "NO")
                WScript.Echo "Would you like to compile Denora with MySQL Support?"
                WScript.Echo "(NOTE: You must have MySQL 3.23 or Later installed)"
                WScript.Echo ""
                WScript.Echo "Yes / No (Default)"
                UseMySQL = UCase(Trim(WScript.StdIn.ReadLine))
                If (UseMySQL = "") Then
                        UseMySQL = "N"
                End If
                If (UseMySQL <> "Y" AND UseMySQL <> "N" AND UseMySQL <> "YES" AND UseMySQL <> "NO") Then
                        WScript.Echo ""
                        WScript.Echo "Invalid Selection!"
                        WScript.Echo ""
                End If
        Loop
        WScript.Echo ""
        
        ' If enabled, find the required files
        If (UseMySQL = "Y" OR UseMySQL = "YES") Then
                If (fso.FileExists(MySQLLibPath & "\libmysql.lib") = False) Then
                        Do While (fso.FileExists(MySQLLibPath & "\libmysql.lib") = False)
                                WScript.Echo "ERROR: Cannot find 'libmysql.lib' in " & MySQLLibPath
                                WScript.Echo ""
                                WScript.Echo "Please enter the path to 'libmysql.lib': "
                                WScript.Echo "(Please DO NOT include a trailing slash '\')"
                                MySQLLibPath = Trim(WScript.StdIn.ReadLine)
                        Loop
				End If
                If (fso.FileExists(MySQLHeadPath & "\mysql.h") = False) Then
                        Do While (fso.FileExists(MySQLHeadPath & "\mysql.h") = False)
                                WScript.Echo "ERROR: Cannot find 'mysql.h' in " & MySQLHeadPath
                                WScript.Echo ""
                                WScript.Echo "Please enter the path to 'mysql.h': "
                                WScript.Echo "(Please DO NOT include a trailing slash '\')"
                                MySQLHeadPath = Trim(WScript.StdIn.ReadLine)
                        Loop
                End If
                WScript.Echo "All required files for MySQL Support have been located!"
                WScript.Echo "MySQL Support Enabled.."
                UseMySQL = "1"
        Else
                WScript.Echo "MySQL Support Disabled.."
                UseMySQL = "0"
        End If
        WScript.Echo ""

        ' Check for required libraries and paths
        WScript.Echo "I will now check you have all the things I need..."
        WScript.Echo ""

        If (fso.FolderExists(DefaultDrive & ":\Program Files\Microsoft Visual Studio 8\VC\Lib")) Then
                WScript.Echo "I found a copy of Microsoft Visual Studio 2005.."
                LibPath = DefaultDrive & ":\Program Files\Microsoft Visual Studio 8\VC\Lib"
                ' debug stuff  -- heinz
                LibPath2 = DefaultDrive & ":\Program Files\Microsoft Platform SDK\lib"
                ' LibPath2 = "F:\MSSDK\Lib"
                If (fso.FileExists(LibPath & "/MSVCRT.lib") = False And fso.FileExists(LibPath2 & "/MSVCRT.lib") = False) Then
                        WScript.Echo "Hm. I can't seem to find the default library.."
                        LibPath = ""
                        LibPath2 = ""
                ElseIf (fso.FileExists(LibPath & "/wsock32.lib") = False And fso.FileExists(LibPath2 & "/wsock32.lib") = False) Then
                        WScript.Echo "I couldn't seem to find wsock32.lib.. You probably haven't downloaded the PlatformSDK.."
                        LibPath = ""
                        LibPath2 = ""
                ElseIf (fso.FileExists(LibPath & "/advapi32.lib") = False And fso.FileExists(LibPath2 & "/advapi32.lib") = False) Then
                        WScript.Echo "I couldn't seem to find advapi32.lib.. You probably haven't downloaded the PlatformSDK.."
                        LibPath = ""
                        LibPath2 = ""
                ElseIf (fso.FileExists(LibPath & "/user32.lib") = False And fso.FileExists(LibPath2 & "/user32.lib") = False) Then
                        WScript.Echo "I couldn't seem to find user32.lib.. You probably haven't downloaded the PlatformSDK.."
                        LibPath = ""
                        LibPath2 = ""
                ElseIf (fso.FileExists(LibPath & "/uuid.lib") = False And fso.FileExists(LibPath2 & "/uuid.lib") = False) Then
                        WScript.Echo "I couldn't seem to find uuid.lib.. You probably haven't downloaded the PlatformSDK.."
                        LibPath = ""
                        LibPath2 = ""
                End If
                If LibPath = "" Then
                        WScript.Echo ""
                        WScript.Echo "For more details on PlatformSDK Installation visit:"
                        WScript.Echo "http://msdn.microsoft.com/vstudio/express/visualc/usingpsdk/"
                        Wscript.Echo ""
                Else
                        VS2005Dep = " /DMSVS2005 /w "
                        IncDir = DefaultDrive & ":\Program Files\Microsoft Visual Studio 8\VC\Include"
                End If
        End If
        
        If (fso.FolderExists(DefaultDrive & ":\Program Files\Microsoft Visual Studio .NET 2003\VC7\Lib") And LibPath = "") Then
                WScript.Echo "I found a copy of Microsoft Visual Studio .NET 2003.."
                LibPath = DefaultDrive & ":\Program Files\Microsoft Visual Studio .NET 2003\VC7\Lib"
                LibPath2 = DefaultDrive & ":\Program Files\Microsoft Visual Studio .NET 2003\Vc7\PlatformSDK\Lib"
                If (fso.FileExists(LibPath & "/MSVCRT.lib") = False And fso.FileExists(LibPath2 & "/MSVCRT.lib") = False) Then
                        WScript.Echo "Hm. I can't seem to find the default library.. You probably only have the SDK installed.."
                        LibPath = ""
                        LibPath2 = ""
                ElseIf (fso.FileExists(LibPath & "/wsock32.lib") = False And fso.FileExists(LibPath2 & "/wsock32.lib") = False) Then
                        WScript.Echo "I couldn't seem to find wsock32.lib.. You probably only have the SDK installed.."
                        LibPath = ""
                        LibPath2 = ""
                ElseIf (fso.FileExists(LibPath & "/advapi32.lib") = False And fso.FileExists(LibPath2 & "/advapi32.lib") = False) Then
                        WScript.Echo "I couldn't seem to find advapi32.lib.. You probably only have the SDK installed.."
                        LibPath = ""
                        LibPath2 = ""
                ElseIf (fso.FileExists(LibPath & "/uuid.lib") = False And fso.FileExists(LibPath2 & "/uuid.lib") = False) Then
                        WScript.Echo "I couldn't seem to find uuid.lib.. You probably only have the SDK installed.."
                        LibPath = ""
                        LibPath2 = ""
                ElseIf (fso.FileExists(LibPath & "/user32.lib") = False And fso.FileExists(LibPath2 & "/user32.lib") = False) Then
                        WScript.Echo "I couldn't seem to find user32.lib.. You probably only have the SDK installed.."
                        LibPath = ""
                        LibPath2 = ""
                Else
                        IncDir = DefaultDrive & ":\Program Files\Microsoft Visual Studio .NET 2003\VC7\Include"
                        IncDir2 = DefaultDrive & ":\Program Files\Microsoft Visual Studio .NET 2003\Vc7\PlatformSDK\Include"
                End If
        End If
        
        If (fso.FolderExists(DefaultDrive & ":\Program Files\Microsoft Visual Studio\VC98\Lib") And LibPath = "") Then
                WScript.Echo "I found a copy of Microsoft Visual Studio 6.. It's old, but we can use it.."
                LibPath = DefaultDrive & ":\Program Files\Microsoft Visual Studio\VC98\Lib"
                CompilerVer = "VC6"
                If (fso.FileExists(LibPath & "/MSVCRT.lib") = False) Then
                        WScript.Echo "Hm. I can't seem to find the default library.. Are you sure this is installed properly?"
                        LibPath = ""
                ElseIf (fso.FileExists(LibPath & "/wsock32.lib") = False) Then
                        WScript.Echo "I couldn't seem to find wsock32.lib.. We kind of need this.."
                        LibPath = ""
                ElseIf (fso.FileExists(LibPath & "/advapi32.lib") = False) Then
                        WScript.Echo "I couldn't seem to find advapi32.lib.. We kind of need this.."
                        LibPath = ""
                ElseIf (fso.FileExists(LibPath & "/uuid.lib") = False) Then
                        WScript.Echo "I couldn't seem to find uuid.lib.. We kind of need this.."
                        LibPath = ""
                ElseIf (fso.FileExists(LibPath & "/user32.lib") = False) Then
                        WScript.Echo "I couldn't seem to find user32.lib.. We kind of need this.."
                        LibPath = ""
                Else
                        IncDir = DefaultDrive & ":\Program Files\Microsoft Visual Studio\VC98\Inlcude"
                End If
        End If
        
        If (fso.FolderExists(DefaultDrive & ":\Program Files\Microsoft Platform SDK\Lib") And LibPath = "") Then
                WScript.Echo "I found a copy of Microsoft Platform SDK.."
                LibPath = DefaultDrive & ":\Program Files\Microsoft Platform SDK\Lib"
                LibPath2 = DefaultDrive & ":\Program Files\Microsoft Visual Studio .NET 2003\VC7\Lib"
                CompilerVer = "SDK"
                If (fso.FileExists(LibPath & "/MSVCRT.lib") = False And fso.FileExists(LibPath2 & "/MSVCRT.lib") = False) Then
                        WScript.Echo "Hm. I can't seem to find the default library.. Are you sure this is installed properly?"
                        LibPath = ""
                        LibPath2 = ""
                ElseIf (fso.FileExists(LibPath & "/wsock32.lib") = False And fso.FileExists(LibPath2 & "/wsock32.lib") = False) Then
                        WScript.Echo "I couldn't seem to find wsock32.lib.. We kind of need this.."
                        LibPath = ""
                        LibPath2 = ""
                ElseIf (fso.FileExists(LibPath & "/advapi32.lib") = False And fso.FileExists(LibPath2 & "/advapi32.lib") = False) Then
                        WScript.Echo "I couldn't seem to find advapi32.lib.. We kind of need this.."
                        LibPath = ""
                        LibPath2 = ""
                ElseIf (fso.FileExists(LibPath & "/uuid.lib") = False And fso.FileExists(LibPath2 & "/uuid.lib") = False) Then
                        WScript.Echo "I couldn't seem to find uuid.lib.. We kind of need this.."
                        LibPath = ""
                        LibPath2 = ""
                ElseIf (fso.FileExists(LibPath & "/user32.lib") = False And fso.FileExists(LibPath2 & "/user32.lib") = False) Then
                        WScript.Echo "I couldn't seem to find user32.lib.. We kind of need this.."
                        LibPath = ""
                        LibPath2 = ""
                Else
                        IncDir = DefaultDrive & ":\Program Files\Microsoft Visual C++ Toolkit 2003\include"
                        IncDir2 = "C:\Program Files\Microsoft Visual Studio .NET 2003\VC7\Include"
                End If
        End If
        
        If (fso.FileExists(DefaultDrive & ":\Program Files\Microsoft Visual Studio 8\VC\Bin\nmake.exe") = False And fso.FileExists(DefaultDrive & ":\Program Files\Microsoft Visual Studio .NET 2003\VC7\Bin\nmake.exe") = False AND fso.FileExists(DefaultDrive & ":\Program Files\Microsoft Visual Studio\VC98\Bin\nmake.exe") = False AND fso.FileExists(DefaultDrive & ":\nmake.exe") = False AND fso.FileExists(DefaultDrive & ":\Program Files\Microsoft Platform SDK\Bin\nmake.exe") = False) Then
                        WScript.Echo ""
                        WScript.Echo "I couldn't seem to find a copy of nmake.exe on your system.."
                        WScript.Echo ""
                        WScript.Echo "I can continue without it for now, but you'll need it when you want to compile."
                        WScript.Echo "I suggest downloading a copy from the URL below, and placing it in your C:\ drive."
                        WScript.Echo ""
                        WScript.Echo "http://download.microsoft.com/download/vc15/patch/1.52/w95/en-us/nmake15.exe"
                        WScript.Echo ""
                        WScript.Echo "You should place nmake.exe in " & DefaultDrive & ":\"
                        WScript.Echo ""
        End If
        
        If (LibPath = "") Then
                Dim tmpPath
                WScript.Echo "I couldn't find any of the paths I was looking for.."
                WScript.Echo "If you have installed the Visual C++ Libraries in a non-standard location, enter"
                WScript.Echo "this location below, and I will try and look there.."
                WScript.Echo "(NOTE: Do NOT enter a trailing slash)"
                WScript.Echo ""
                WScript.Echo "Path to Visual C++ Libraries: "
                tmpPath = Trim(WScript.StdIn.ReadLine)
                If (fso.FolderExists(tmpPath) AND fso.FileExists(tmpPath & "\MSVCRT.lib")) Then
                        LibPath = tmpPath
                        If (fso.FileExists(LibPath & "\wsock32.lib") = False) Then
                                WScript.Echo "I couldn't seem to find wsock32.lib.. We kind of need this.."
                                LibPath = ""
                        ElseIf (fso.FileExists(LibPath & "\advapi32.lib") = False) Then
                                WScript.Echo "I couldn't seem to find advapi32.lib.. We kind of need this.."
                                LibPath = ""
                        ElseIf (fso.FileExists(LibPath & "\uuid.lib") = False) Then
                                WScript.Echo "I couldn't seem to find uuid.lib.. We kind of need this.."
                                LibPath = ""
                        ElseIf (fso.FileExists(LibPath & "\user32.lib") = False) Then
                                WScript.Echo "I couldn't seem to find user32.lib.. We kind of need this.."
                                LibPath = ""
                        Else
                                WScript.Echo "Okay, I found what I was looking for.."
                        End If
                Else
                        WScript.Echo "I couldn't find the default library in that folder."
                End If
        End If
        
        If (LibPath <> "") Then
                        Dim f
                        Const ForReading = 1, ForWriting = 2
                        WScript.Echo "Looks like you've got all the libraries I need.."
                        Set f = fso.OpenTextFile("Makefile.inc.win32", ForWriting)
                        f.WriteLine("USE_MYSQL=" & UseMySQL)
                        If (UseMySQL = "1") Then
                                f.WriteLine("MYSQL_LIB=" & chr(34) & MySQLLibPath & chr(34))
                                f.WriteLine("MYSQL_INC="  & chr(34) & MySQLHeadPath & chr(34))
                        End If
                        If (CompilerVer = "VC6") Then
                                f.WriteLine("VC6=/QIfist")
                        End If
                        if (LibPath2 <> "") Then
                                LibPath = LibPath2 & chr(34) & " /LIBPATH:" & chr(34) & LibPath
                        End If
                        f.WriteLine("VERSION=" & verMaj & "." & verMin & "." & verPatch & verExtra & "." & verBuild)
                        f.WriteLine("LIBPATH=" & LibPath)
                        f.WriteLine("PROGRAM=denora.exe")
                        f.WriteLine("DATDEST=data")
                        f.WriteLine("CC=cl")
                        f.WriteLine("RC=rc")
                        f.WriteLine("MAKE=nmake -f Makefile.win32")
						f.WriteLine("BASE_CFLAGS=" & VS2005Dep & "/O2 /MD  /I " & Chr(34) & IncDir & Chr(34))
                        If IncDir2 <> "" Then
                                f.WriteLine("BASE_CFLAGS=$(BASE_CFLAGS) /I " & Chr(34) & IncDir2 & Chr(34))
                                f.WriteLine("RC_FLAGS=/i " & Chr(34) & IncDir2 & Chr(34))
                        End If
                        f.WriteLine("RC_FLAGS=$(RC_FLAGS) /i " & Chr(34) & IncDir & Chr(34))
                        f.WriteLine("LIBS=wsock32.lib User32.lib advapi32.lib /NODEFAULTLIB:libcmtd.lib")
                        f.WriteLine("LFLAGS=/LIBPATH:" & chr(34) & "$(LIBPATH)" & chr(34))
                        If (UseMySQL = "1") Then
                                f.WriteLine("LIBS=$(LIBS) /LIBPATH:$(MYSQL_LIB)")
                                f.WriteLine("MYSQL_LIB_PATH=/LIBPATH:$(MYSQL_LIB)")
                                f.WriteLine("BASE_CFLAGS=$(BASE_CFLAGS) /I $(MYSQL_INC)")
                                f.WriteLine("MYSQL_INC_PATH=/I $(MYSQL_INC)")
                                f.WriteLine("MYSQL_C=mysql.c")
                                f.WriteLine("MYSQL_O=mysql.obj")
                                f.WriteLine("BASE_CFLAGS=/D USE_MYSQL $(BASE_CFLAGS) /D HAVE_MYSQL_MYSQL_H")
                                f.WriteLine("MYPASQL_BUILD=$(CC) /LD $(MYSQL_INC_PATH) src\mypasql.c /link $(MYSQL_LIB_PATH) $(LFLAGS) \")
                                f.WriteLine("/DEF:src\mypasql.def libmysql.lib zlib.lib ws2_32.lib advapi32.lib /NODEFAULTLIB:LIBCMTD.lib")
                                f.WriteLine("LIBS=$(LIBS) libmysql.lib zlib.lib")
                        End If
                        f.WriteLine("MORE_CFLAGS = /I" & chr(34) & "../include" & chr(34))
                        f.WriteLine("CFLAGS = /nologo $(VC6) $(CDEFS) $(BASE_CFLAGS) $(MORE_CFLAGS)")
                        f.close()
                        Set f = fso.CreateTextFile("make.bat")
                        f.WriteLine("@echo off")
                        Set WshShell = WScript.CreateObject("WScript.Shell")
                        Set WshSysEnv = WshShell.Environment("SYSTEM")
                        EnvLibPath = WshSysEnv("PATH")
                        If CompilerVer = "SDK" Then
                                If InStr(EnvLibPath, "C:\Program Files\Microsoft Visual C++ Toolkit 2003\bin") Then
                                        f.WriteLine("Set PATH=C:\Program Files\Microsoft Visual C++ Toolkit 2003\bin;%PATH%")
                                        f.WriteLine("Set INCLUDE=C:\Program Files\Microsoft Visual C++ Toolkit 2003\include;%INCLUDE%")
                                        f.WriteLine("Set LIB=C:\Program Files\Microsoft Visual C++ Toolkit 2003\lib;%LIB%")
                                End If
                        ElseIf CompilerVer = "VC6" Then
                                If InStr(EnvLibPath, "C:\PROGRA~1\MICROS~3\VC98\LIB") Then
                                        f.WriteLine("set VSCommonDir=C:\PROGRA~1\MICROS~3\Common")
                                        f.WriteLine("set MSDevDir=C:\PROGRA~1\MICROS~3\Common\msdev98")
                                        f.WriteLine("set MSVCDir=C:\PROGRA~1\MICROS~3\VC98")
                                        f.WriteLine("set VcOsDir=WIN95")
                                        f.WriteLine("if " & Chr(34) & "%OS%" & Chr(34) & " == " & Chr(34) & "Windows_NT" & Chr(34) & " set VcOsDir=WINNT")
                                        f.WriteLine("if " & Chr(34) & "%OS%" & Chr(34) & " == " & Chr(34) & "Windows_NT" & Chr(34) & " set PATH=%MSDevDir%\BIN;%MSVCDir%\BIN;%VSCommonDir%\TOOLS\%VcOsDir%;%VSCommonDir%\TOOLS;%PATH%")
                                        f.WriteLine("if " & Chr(34) & "%OS%" & Chr(34) & " == " & Chr(34) & "" & Chr(34) & " set PATH=" & Chr(34) & "%MSDevDir%\BIN" & Chr(34) & ";" & Chr(34) & "%MSVCDir%\BIN" & Chr(34) & ";" & Chr(34) & "%VSCommonDir%\TOOLS\%VcOsDir%" & Chr(34) & ";" & Chr(34) & "%VSCommonDir%\TOOLS" & Chr(34) & ";" & Chr(34) & "%windir%\SYSTEM" & Chr(34) & ";" & Chr(34) & "%PATH%" & Chr(34) & "")
                                        f.WriteLine("set INCLUDE=%MSVCDir%\ATL\INCLUDE;%MSVCDir%\INCLUDE;%MSVCDir%\MFC\INCLUDE;%INCLUDE%")
                                        f.WriteLine("set LIB=%MSVCDir%\LIB;%MSVCDir%\MFC\LIB;%LIB%")
                                        f.WriteLine("set VcOsDir=")
                                        f.WriteLine("set VSCommonDir=")
                                End If
                        Else
                                If InStr(EnvLibPath, "C:\Program Files\Microsoft Visual Studio .NET 2003\Common7\Tools") Then
                                        f.WriteLine("@SET VSINSTALLDIR=C:\Program Files\Microsoft Visual Studio .NET 2003\Common7\IDE")
                                        f.WriteLine("@SET VCINSTALLDIR=C:\Program Files\Microsoft Visual Studio .NET 2003")
                                        f.WriteLine("@set VCINSTALLDIR=%VSINSTALLDIR%")
                                        f.WriteLine("@set DevEnvDir=%VSINSTALLDIR%")
                                        f.WriteLine("@set MSVCDir=%VCINSTALLDIR%\VC7")
                                        f.WriteLine("@set PATH=%DevEnvDir%;%MSVCDir%\BIN;%VCINSTALLDIR%\Common7\Tools;%VCINSTALLDIR%\Common7\Tools\bin\prerelease;%VCINSTALLDIR%\Common7\Tools\bin;%FrameworkSDKDir%\bin;%FrameworkDir%\%FrameworkVersion%;%PATH%;")
                                        f.WriteLine("@set INCLUDE=%MSVCDir%\ATLMFC\INCLUDE;%MSVCDir%\INCLUDE;%MSVCDir%\PlatformSDK\include\prerelease;%MSVCDir%\PlatformSDK\include;%FrameworkSDKDir%\include;%INCLUDE%")
                                        f.WriteLine("@set LIB=%MSVCDir%\ATLMFC\LIB;%MSVCDir%\LIB;%MSVCDir%\PlatformSDK\lib\prerelease;%MSVCDir%\PlatformSDK\lib;%FrameworkSDKDir%\lib;%LIB%")
                                End If
                        End If
                        If (fso.FileExists("denora.exe")) Then
                                f.WriteLine("nmake -f Makefile.win32 spotless")
                        End If
						f.WriteLine("if " & Chr(34) & "%1" & Chr(34) & " == " & Chr(34) & Chr(34) & " GOTO build")
						f.WriteLine("if " & Chr(34) & "%1" & Chr(34) & " == " & Chr(34) & "clean" & Chr(34) & " GOTO clean")
						f.WriteLine("if " & Chr(34) & "%1" & Chr(34) & " == " & Chr(34) & "distclean" & Chr(34) & " GOTO distclean")
                        f.WriteLine("")
                        f.WriteLine(":build")
						f.WriteLine("nmake -f Makefile.win32")
                        f.WriteLine("GOTO end")
                        f.WriteLine("")
                        f.WriteLine(":distclean")
						f.WriteLine("nmake -f Makefile.win32 spotless")
                        f.WriteLine("GOTO end")
                        f.WriteLine("")
                        f.WriteLine(":clean")
						f.WriteLine("nmake -f Makefile.win32 clean")
                        f.WriteLine("GOTO end")
                        f.WriteLine("")
                        f.WriteLine(":end")
                        f.close()
                        WScript.Echo "Configuration Complete!"
                        WScript.Echo ""
                        WScript.Echo "Type make to Compile Denora"
        Else
                        WScript.Echo ""
                        WScript.Echo "Sorry, but you didn't have all the required libraries installed."
                        WScript.Echo ""
                        WScript.Echo "See http://denora.nomadirc.net for a list of downloads needed to install Denora"
                        WScript.Echo ""
        End If

End If
