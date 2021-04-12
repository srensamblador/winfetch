@echo off
setlocal enabledelayedexpansion

set color=dull
set usecolor=no
set temppath=%PATH%;%~dp0

:args
if "%1" == "/?" (goto :credits)
if "%1" == "/n" (
    for %%X in (colous.exe) do set FOUND=%%~$temppath:X
    if defined FOUND (
        set usecolor=yes
    ) else (
        echo.Warning: colous not found in PATH.
    )
	shift
	goto :args
)
if "%1" == "/b" (
    for %%X in (colous.exe) do set FOUND=%%~$temppath:X
    if defined FOUND (
        set usecolor=yes
    	set color=bright
    ) else (
        echo.Warning: colous not found in PATH.
    )
	shift
	goto :args
)
if "%1" == "" (goto :main)
shift
goto :args

:main
echo.

set count=1
for /f "tokens=* usebackq" %%f in (`wmic path Win32_VideoController get caption^,CurrentVerticalResolution^,CurrentHorizontalResolution /format:list`) do (
  set tempvar!count!=%%f
  set /a count=!count!+1
)
for /f "tokens=1,* delims==" %%a in ("%tempvar3%") do set %%a=%%b
for /f "tokens=1,* delims==" %%a in ("%tempvar4%") do set %%a=%%b
for /f "tokens=1,* delims==" %%a in ("%tempvar5%") do set %%a=%%b
set gpu=%Caption%
set caption=
set gpu=%gpu:(tm) =%
set gpu=%gpu:(r) =%
set gpu=%gpu:(c) =%

set count=1
for /f "tokens=* usebackq" %%f in (`wmic cpu get name^,AddressWidth /format:list`) do (
  set tempvar!count!=%%f
  set /a count=!count!+1
)
for /f "tokens=1,* delims==" %%a in ("%tempvar3%") do set %%a=%%b
for /f "tokens=1,* delims==" %%a in ("%tempvar4%") do set %%a=%%b

set cpu=%name%
set cpu=%cpu:(tm)=%
set cpu=%cpu:(r)=%
set cpu=%cpu:(c)=%

set count=1
for /f "tokens=* usebackq" %%f in (`wmic os get Caption^,Version^,FreePhysicalMemory^,TotalVisibleMemorySize /format:list`) do (
  set tempvar!count!=%%f
  set /a count=!count!+1
)
for /f "tokens=1,* delims==" %%a in ("%tempvar3%") do set %%a=%%b
for /f "tokens=1,* delims==" %%a in ("%tempvar4%") do set %%a=%%b
for /f "tokens=1,* delims==" %%a in ("%tempvar5%") do set %%a=%%b
for /f "tokens=1,* delims==" %%a in ("%tempvar6%") do set %%a=%%b
set /a totalram=%TotalVisibleMemorySize% / 1024
set /a freeram=%FreePhysicalMemory% / 1024
set /a usedram=%totalram% - %freeram%
for /f "tokens=1-2 delims=. " %%i in ("%Version%") do set OSVERSION=%%i.%%j

set count=1
for /f "tokens=* usebackq" %%f in (`wmic logicaldisk %SystemDrive% get Freespace^,Size /format:list`) do (
  set tempvar!count!=%%f
  set /a count=!count!+1
)
for /f "tokens=1,* delims==" %%a in ("%tempvar3%") do set %%a=%%b
for /f "tokens=1,* delims==" %%a in ("%tempvar4%") do set %%a=%%b
set /a all=%Size:~0,-6% / 1074
set /a free=%Freespace:~0,-6% / 1074
set /a used=%all%-%free%

set osname=%Caption%
set osname=%osname:VistaT=Vista%
if "%osname:~10%" == " Windows Vista Home Premium " set osname=%osname:~0,9%%osname:~10%

for /F "tokens=1,* delims==" %%v in ('wmic path Win32_PerfFormattedData_PerfOS_System get SystemUptime /format:list ^| findstr "[0-9]"') do set "%%v=%%w"

if "%OSVERSION%" == "5.1" ( goto :XP )

if "%AddressWidth%" == "64" ( goto :theme64 )

:theme86
if "%OSVERSION%" == "6.0" (
    set Theme_RegKey=HKCU\Software\Microsoft\Windows\CurrentVersion\Themes\LastTheme
    set Theme_RegVal=ThemeFile
) else (
    set Theme_RegKey=HKCU\Software\Microsoft\Windows\CurrentVersion\Themes
    set Theme_RegVal=CurrentTheme
)
reg query %Theme_RegKey% /v %Theme_RegVal% >nul || (set Theme_NAME="No_Theme_Name_Found" & goto :endTheme)
set Theme_NAME=
for /f "tokens=2,*" %%a in ('reg query %Theme_RegKey% /v %Theme_RegVal% ^| findstr %Theme_RegVal%') do set Theme_NAME=%%b
call :label "%Theme_NAME%"
goto :endTheme


:theme64
set Theme_RegKey=HKCU\Software\Microsoft\Windows\CurrentVersion\ThemeManager
set Theme_RegVal=DllName
reg query %Theme_RegKey% /v %Theme_RegVal% >nul || (set Theme_NAME="No_Theme_Name_Found" & goto :endTheme)
set Theme_NAME=
for /f "tokens=2,*" %%a in ('reg query %Theme_RegKey% /v %Theme_RegVal% ^| findstr %Theme_RegVal%') do set Theme_NAME=%%b
goto :endTheme

:endTheme
call :label "%Theme_NAME%"
goto :endXP

:XP
for /f "tokens=2,*" %%a in ('reg query HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\ThemeManager  /v ThemeActive ^| findstr ThemeActive') do set Theme_active=%%b

if "%Theme_active%" == "0" (
    set themename="Windows Classic"
    goto :endXPTheme
)

:XPtheme
set Theme_RegKey=HKCU\Software\Microsoft\Windows\CurrentVersion\ThemeManager
set Theme_RegVal=DllName
reg query %Theme_RegKey% /v %Theme_RegVal% >NUL || (set Theme_NAME="No_Theme_Name_Found" & goto :endXPTheme)
set Theme_NAME=
for /f "tokens=2,*" %%a in ('reg query %Theme_RegKey% /v %Theme_RegVal% ^| findstr %Theme_RegVal%') do set Theme_NAME=%%b
call :label "%Theme_NAME%"
)
:endXPTheme
:endXP

for /f "usebackq tokens=1,* delims==" %%a in (`wmic computersystem get model /format:list ^| findstr "^Model="`) do set %%a=%%b

::Get Shell
set shell_var=%COMSPEC%
set var1=%shell_var%
set i=0
:loopprocess
for /F "tokens=1* delims=\" %%A in ("%var1%") do (
  set /A i+=1
  set var1=%%B
  goto loopprocess
)
for /F "tokens=%i% delims=\" %%G in ("%shell_var%") do set last=%%G
set shell_NAME=%last%

::Get Window Manager
set WM_RegKey="HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon"
set WM_RegVal=Shell
reg query %WM_RegKey% /v %WM_RegVal% >NUL || (set WM_NAME="Explorer.exe" & goto :endWM)
for /f "tokens=2,*" %%a in ('reg query %WM_RegKey% /v %WM_RegVal% ^| findstr %WM_RegVal%') do set WM_NAME=%%b
:endWM

:: Get motherboard
set count=1
for /f "tokens=* usebackq" %%f in (`wmic baseboard get product^,manufacturer /format:list`) do (
  set tempvar!count!=%%f
  set /a count=!count!+1
)
for /f "tokens=1,* delims==" %%a in ("%tempvar3%") do set %%a=%%b
for /f "tokens=1,* delims==" %%a in ("%tempvar4%") do set %%a=%%b

:: User info
set "s=%username%"
set "len=1"
for %%N in (4096 2048 1024 512 256 128 64 32 16 8 4 2 1) do (
  if "!s:~%%N,1!" neq "" (
    set /a "len+=%%N"
    set "s=!s:~%%N!"
  )
)
set userlength=%len%
set "s=%COMPUTERNAME%"
set "len=1"
for %%N in (4096 2048 1024 512 256 128 64 32 16 8 4 2 1) do (
  if "!s:~%%N,1!" neq "" (
    set /a "len+=%%N"
    set "s=!s:~%%N!"
  )
)
set machinelength=%len%
set /a totallength=%userlength% + 1 + %machinelength%
set dashstring=
for /l %%x in (1, 1, %totallength%) do set "dashstring=!dashstring!^="


set osname=%osname:~0,33%
set cpu=%cpu:~0,35%
set gpu=%gpu:~0,35%
set MOBO_NAME=%Manufacturer:  =%
set MOBO_NAME=%MOBO_NAME:~0,20%
set MOBO_MODEL=%Product:~0,10%
set themename=%themename:~0,35%
if "%themename%" == "aero" (
    if "%OSVERSION%" == "6.2" set themename=metro
    if "%OSVERSION%" == "6.3" set themename=metro
    if "%OSVERSION%" == "6.4" set themename=fluent
    if "%OSVERSION%" == "10.0" set themename=fluent
)

if "%color%" == "bright" (
    set color1=12
    set color2=9
    set color3=10
    set color4=14
) else (
    set color1=4
    set color2=1
    set color3=2
    set color4=6
)
set bgcolor=0
set textcolor1=7
set textcolor2=15

if "%usecolor%" == "yes" ( colous gety )
set sycord=%errorlevel%
set ycord=%errorlevel%

if "%usecolor%" == "yes" (
    colous %color1% %bgcolor% 0,0 "         ,.=:^!^!t3Z3z.,                 "
    colous %textcolor1% %bgcolor% 0,0 "%username%"
    colous %textcolor2% %bgcolor% 0,0 "@"
    colous %textcolor1% %bgcolor% 0,0 "%COMPUTERNAME%"
    echo.
    colous %color1% %bgcolor% 0,0 "        :tt:::tt333EE3                 "
    colous %color3% %bgcolor% 0,0 "%dashstring%"
    echo.
    colous %color1% %bgcolor% 0,0 "        Et:::ztt33EEE  "
    colous %color3% %bgcolor% 0,0 "@Ee.,      ..,  "
    colous %textcolor1% %bgcolor% 0,0 "OS: "
    colous %textcolor2% %bgcolor% 0,0 "%osname%%AddressWidth%-bit"
    echo.
    colous %color1% %bgcolor% 0,0 "       ;tt:::tt333EE7 "
    colous %color3% %bgcolor% 0,0 ";EEEEEEttttt33#  "
    colous %textcolor1% %bgcolor% 0,0 "Host: "
    colous %textcolor2% %bgcolor% 0,0 "%Model%"
    echo.
    colous %color1% %bgcolor% 0,0 "      :Et:::zt333EEQ. "
    colous %color3% %bgcolor% 0,0 "SEEEEEttttt33QL  "
    colous %textcolor1% %bgcolor% 0,0 "Kernel:"
    colous %textcolor2% %bgcolor% 0,0 " %Version%"
    echo.
    colous %color1% %bgcolor% 0,0 "      it::::tt333EEF "
    colous %color3% %bgcolor% 0,0 "@EEEEEEttttt33F   "
    colous %textcolor1% %bgcolor% 0,0 "Uptime: "
    colous %textcolor2% %bgcolor% 0,0 "%SystemUptime%s"
    echo.
    colous %color1% %bgcolor% 0,0 "     ;3=*^```'*4EEV "
    colous %color3% %bgcolor% 0,0 ":EEEEEEttttt33@.   "
    colous %textcolor1% %bgcolor% 0,0 "Resolution:"
    colous %textcolor2% %bgcolor% 0,0 " %CurrentHorizontalResolution%x%CurrentVerticalResolution%"
    echo.
    colous %color2% %bgcolor% 0,0 "     ,.=::::it=., "
    colous %color1% %bgcolor% 0,0 "` "
    colous %color3% %bgcolor% 0,0 "@EEEEEEtttz33QF    "
    colous %textcolor1% %bgcolor% 0,0 "Motherboard: "
    colous %textcolor2% %bgcolor% 0,0 "%MOBO_NAME% - %MOBO_MODEL%"
    echo.
    colous %color2% %bgcolor% 0,0 "    ;::::::::zt33)   "
    colous %color3% %bgcolor% 0,0 "'4EEEtttji3P*     "
    colous %textcolor1% %bgcolor% 0,0 "Shell: "
    colous %textcolor2% %bgcolor% 0,0 "%shell_NAME%"
    echo.
    colous %color2% %bgcolor% 0,0 "   :t::::::::tt33 "
    colous %color4% %bgcolor% 0,0 ":Z3z..  "
    colous %color3% %bgcolor% 0,0 "`` "
    colous %color4% %bgcolor% 0,0 ",..g.     "
    colous %textcolor1% %bgcolor% 0,0 "Theme: "
    colous %textcolor2% %bgcolor% 0,0 %themename%
    echo.
    colous %color2% %bgcolor% 0,0 "   i::::::::zt33F "
    colous %color4% %bgcolor% 0,0 "AEEEtttt::::ztF      "
    colous %textcolor1% %bgcolor% 0,0 "WM: "
    colous %textcolor2% %bgcolor% 0,0 "%WM_NAME%"
    echo.
    colous %color2% %bgcolor% 0,0 "  ;:::::::::t33V "
    colous %color4% %bgcolor% 0,0 ";EEEttttt::::t3       "
    colous %textcolor1% %bgcolor% 0,0 "CPU: "
    colous %textcolor2% %bgcolor% 0,0 "%cpu%"
    echo.
    colous %color2% %bgcolor% 0,0 "  E::::::::zt33L "
    colous %color4% %bgcolor% 0,0 "@EEEtttt::::z3F       "
    colous %textcolor1% %bgcolor% 0,0 "GPU: "
    colous %textcolor2% %bgcolor% 0,0 "%gpu%"
    echo.
    colous %color2% %bgcolor% 0,0 " {3=*^```'*4E3) "
    colous %color4% %bgcolor% 0,0 ";EEEtttt:::::tZ`       "
    colous %textcolor1% %bgcolor% 0,0 "Memory: "
    colous %color4% %bgcolor% 0,0 "%usedram% MB "
    colous %textcolor2% %bgcolor% 0,0 "/ %totalram% MB"
    echo.
    colous %color2% %bgcolor% 0,0 "             `"
    colous %color4% %bgcolor% 0,0 " :EEEEtttt::::z7         "
    colous %textcolor1% %bgcolor% 0,0 "Disk: "
    colous %textcolor2% %bgcolor% 0,0 "[%SYSTEMDRIVE%] "
    colous %color3% %bgcolor% 0,0 "%used% GB "
    colous %textcolor2% %bgcolor% 0,0 "/ %all% GB"
    echo.
    colous %color2% %bgcolor% 0,0 "                "
    colous %color4% %bgcolor% 0,0 " 'VEzjt:;;z>*`       "
    colous %textcolor2% %bgcolor% 0,0 "  "
    colous %textcolor2% 8 0,0 "   "
    colous %textcolor2% 9 0,0 "   "
    colous %textcolor2% 10 0,0 "   "
    colous %textcolor2% 11 0,0 "   "
    colous %textcolor2% 12 0,0 "   "
    colous %textcolor2% 13 0,0 "   "
    colous %textcolor2% 14 0,0 "   "
    colous %textcolor2% 15 0,0 "   "
    echo.
) else (
    echo.         ,.=:^^!^^!t3Z3z.,                 %username%@%COMPUTERNAME%
    echo.        :tt:::tt333EE3                 %dashstring%
    echo.        Et:::ztt33EEE  @Ee.,      ..,  OS: %osname%%AddressWidth%-bit
    echo.       ;tt:::tt333EE7 ;EEEEEEttttt33#  Host: %Model%
    echo.      :Et:::zt333EEQ. SEEEEEttttt33QL  Kernel: %Version%
    echo.      it::::tt333EEF @EEEEEEttttt33F   Uptime: %SystemUptime%s
    echo.     ;3=*^^```'*4EEV :EEEEEEttttt33@.   Resolution: %CurrentHorizontalResolution%x%CurrentVerticalResolution%
    echo.     ,.=::::it=., ` @EEEEEEtttz33QF    Motherboard: %MOBO_NAME% - %MOBO_MODEL%
    echo.    ;::::::::zt33^)   '4EEEtttji3P*     Shell: %shell_NAME%
    echo.   :t::::::::tt33 :Z3z..  `` ,..g.     Theme: %themename%
    echo.   i::::::::zt33F AEEEtttt::::ztF      WM: %WM_NAME%
    echo.  ;:::::::::t33V ;EEEttttt::::t3       CPU: %cpu%
    echo.  E::::::::zt33L @EEEtttt::::z3F       GPU: %gpu%
    echo. {3=*^^```'*4E3^) ;EEEtttt:::::tZ`       Memory: %usedram% MB / %totalram% MB
    echo.             ` :EEEEtttt::::z7         Disk: [%SYSTEMDRIVE%] %used% GB / %all% GB
    echo.                 'VEzjt:;;z^>*`
)
goto :EnOF

:label
set themename=%~n1
goto :EOF

:EnOF
set color=
set color1=
set color2=
set color3=
set color4=
set temppath=
if "%usecolor%" == "yes" ( colous cursoron )
exit /b
goto :EOF

:credits
echo.Usage: winfetch [/n] [/b] [/?]
echo.
echo.Options:
echo.    /n             Use colors. Requires colous.
echo.    /b             Use (brighter) colors. Requires colous.
echo.    /?             Display this text.
echo.Note: Output redirection does not work with colous.
echo.
echo.Thanks to:
echo.    anonymous
echo.    Arashi ^^!1IXzW.VjDs (Zanthas)
echo.    SaladFingers ^^!SpOONsgtAo
echo.    Jz9 ^^!//QwUWqnYY
echo.    Sk8rjwd
echo.    rashil2000
echo.

if "%usecolor%" == "yes" ( colous cursoron )
goto :EOF
