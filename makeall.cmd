rem @echo off
rem chcp 1251

echo ***
echo ***
echo *** Компиляция списка проектов
echo ***
echo ***

set home=%~dp0
set path=d9u1\bin";%path%

set CompanyName=ЗАО СИТИ ИНВЕСТ БАНК
set FileVersion=4.0.0.0
set FileDescription=none
set ProductName=Автоматизация Банка
set ProductVersion=4.0.0.0

rem перечень списков
set ListEnum=%2

set ExePath=%1\exe
set DcuSubDir=%1\dcu
set ResSubDir=%1\res
set HelpSubDir=%1\help
set SeachPath=p:\budget32\sourceax\global
set SrvReg=call Tregsvr.exe
set LogFile=compile.log
set VBUILD=:createversionstrings

rem set packeges=BudgetPack

set DCC=call dcc32 -B -$D-L- -DVERSION -u%SeachPath% -e%ExePath% -lu%packeges% -N%DcuSubDir% -R%ResSubDir%
rem set BRC=call BRCC32
set BRC=call rc
set HHC=call hhc.exe

if not exist %ExePath% md %ExePath%
if not exist %ResSubDir% md %ResSubDir%
if not exist %DcuSubDir% md %DcuSubDir%
if not exist %HelpSubDir% md %HelpSubDir%
rem компиляция проекта

rem разбор перечня списков файлов списков
for /f "eol=#" %%f in (%ListEnum%) do @call :compileenum %%f

rem Копирование скомпилированных файлов справки
echo Копирование файлов справки
rem copy p:\budget32\htmlhelp\*.chm %HelpSubDir%\

goto :eof

:compileenum
echo ***
echo *** обрабатывается список: %1
echo ***
for /f "eol=# delims=; tokens=1*" %%a in (%1) do @call :compile %%a "%%b"


goto :eof


rem ***************************************************************
rem ***************************************************************
rem ************ Компиляция текущего файла    *********************
rem ***************************************************************
rem ***************************************************************
:compile

title Compile %1
set FileDescription=%2
set FileDescription=%FileDescription:"=%
set FileDescription=%FileDescription:  =%
set FileDescription=%FileDescription:   =%
echo %FileDescription%

set error=0
rem разобрать имя файла
set projdir=%~p1
set projname=%~nx1
set projname=%~nx1
set projext=%~x1

pushd %projdir%

rem определить тип компиляции

set LogFile=%~n1.log
if exist %LogFile% del %LogFile%>nul

echo %1

if %~x1==.dpr goto :dpr
if %~x1==.rc goto :rc
if %~x1==.hhp goto :hhp
echo Компилятор не назначен %1
goto :quit

:dpr
   call :createversion
   
   %DCC% %~nx1>%LogFile%
   call :checklog %1
   if %error%==1 goto :quit

   set outputext=dll
   for /F "tokens=3" %%a in ('find /I /C "program" %1') do if not %%a==0 set outputext=exe
   if %outputext%==exe goto :quit
   for /F "tokens=3" %%a in ('find /I /C "{$E OCX}" %1') do if not %%a==0 set outputext=ocx
   if not %outputext%==ocx goto :quit
   call %SrvReg% %ExePath%\%~n1.ocx>reg.log
   if not %ERRORLEVEL%==0 echo Register error %ExePath%\%~n1.ocx
   goto :quit

:rc
   %BRC% -fo%ResSubDir%\%~n1.res %~nx1>%LogFile%
   call :checklog %1
   goto :quit

:hhp
   %HHC% %~nx1>%LogFile%
   call :checklog %1
   goto :quit

rem ***************************************************************
rem ***************************************************************
rem ************ Обработка ошибок             *********************
rem ***************************************************************
rem ***************************************************************
:checklog
if not %ERRORLEVEL%==0 set error=1
if %error%==0 goto :success
goto :error
:error
echo Error(%ERRORLEVEL%) %1 see %LogFile%
goto :eof
:success
echo Success %1
goto :eof


:createversion
call %VBUILD%>%ResSubDir%\version.rc
%BRC% -fo%ResSubDir%\version.res %ResSubDir%\version.rc
goto :eof

:createversionstrings
for /f "tokens=1" %%a in ('date /t') do set CompileDate=%%a
for /f "tokens=1" %%a in ('time /t') do set CompileDate=%CompileDate% %%a

echo LANGUAGE 25, 0
echo #pragma code_page(1251)
echo 1 VERSIONINFO
echo  FILEVERSION %FileVersion%
echo  PRODUCTVERSION %ProductVersion%
echo  FILEFLAGSMASK 0x3fL
echo  FILEFLAGS 0x0L
echo  FILEOS 0x4L
echo  FILETYPE 0x1L
echo  FILESUBTYPE 0x0L
echo BEGIN
echo     BLOCK "StringFileInfo"
echo     BEGIN
echo         BLOCK "041904E3"
echo         BEGIN
echo             VALUE "CompanyName", "%CompanyName%\0","\0","\0","\0","\0","\0","\0","\0","\0","\0","\0","\0"
echo             VALUE "FileDescription", "%FileDescription%\0","\0","\0","\0","\0","\0","\0","\0","\0","\0","\0","\0","\0","\0","\0"
echo             VALUE "FileVersion", "%FileVersion%\0","\0","\0","\0","\0","\0","\0","\0","\0"
echo             VALUE "InternalName", "\0"
echo             VALUE "LegalCopyright", "\0"
echo             VALUE "LegalTrademarks", "\0"
echo             VALUE "OriginalFilename", "\0","\0","\0","\0","\0","\0","\0","\0","\0","\0","\0","\0","\0","\0","\0"
echo             VALUE "ProductName", "%ProductName%\0","\0","\0","\0","\0","\0","\0","\0"
echo             VALUE "ProductVersion", "%ProductVersion%\0","\0","\0","\0","\0"
echo             VALUE "Comments", "\0"
echo             VALUE "Дата компиляции", "%CompileDate%"
echo         END
echo     END
echo     BLOCK "VarFileInfo"
echo     BEGIN
echo        VALUE "Translation", 0x419, 1251
echo     END
echo END

goto :eof


:quit
popd
