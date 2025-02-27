@echo off

if %EXEName%. == . goto MissingEnvironmentVariables
if %BuildMode%. == . goto MissingEnvironmentVariables
if %HB_COMPILER%. ==. goto MissingEnvironmentVariables

if not exist %EXEName%.hbp (
	echo Invalid Workspace Folder. Missing file %EXEName%.hbp
	goto End
)

if %BuildMode%. == debug.   goto GoodParameters
if %BuildMode%. == release. goto GoodParameters

echo You must send "debug" or "release" as parameter
goto End

:GoodParameters

if %HB_COMPILER% == msvc64 call "%ProgramFiles(x86)%\Microsoft Visual Studio\2019\Community\VC\Auxiliary\Build\vcvarsall.bat" x86_amd64

if %HB_COMPILER% == mingw64 set PATH=C:\Program Files\mingw-w64\x86_64-8.1.0-win32-seh-rt_v6-rev0\mingw64\bin;%PATH%

set HB_PATH=C:\Harbour

set PATH=%HB_PATH%\bin\win\%HB_COMPILER%;C:\HarbourTools;%PATH%

echo HB_PATH     = %HB_PATH%
echo HB_COMPILER = %HB_COMPILER%
echo PATH        = %PATH%

md build
md build\win64
md build\win64\%HB_COMPILER%
md build\win64\%HB_COMPILER%\%BuildMode%

del build\win64\%HB_COMPILER%\%BuildMode%\%EXEName%.exe
if exist build\win64\%HB_COMPILER%\%BuildMode%\%EXEName%.exe (
	echo Could not delete previous version of %EXEName%.exe
	goto End
)

if %BuildMode% == debug (
    hbmk2 %EXEName%.hbp -b -p -w3 -shared
) else (
    hbmk2 %EXEName%.hbp -w3 -fullstatic
)

if not exist build\win64\%HB_COMPILER%\%BuildMode%\%EXEName%.exe (
	echo Failed To build %EXEName%.exe
) else (
	if errorlevel 0 (
        copy build\win64\%HB_COMPILER%\%BuildMode%\%EXEName%.exe ..\FCGITaskManagerBin\%EXEName%.exe
		echo.
		echo No Errors

		echo.
		echo Ready            BuildMode = %BuildMode%
		
	) else (
		echo Compilation Error
		if errorlevel  1 echo Unknown platform
		if errorlevel  2 echo Unknown compiler
		if errorlevel  3 echo Failed Harbour detection
		if errorlevel  5 echo Failed stub creation
		if errorlevel  6 echo Failed in compilation (Harbour, C compiler, Resource compiler)
		if errorlevel  7 echo Failed in final assembly (linker or library manager)
		if errorlevel  8 echo Unsupported
		if errorlevel  9 echo Failed to create working directory
		if errorlevel 19 echo Help
		if errorlevel 10 echo Dependency missing or disabled
		if errorlevel 20 echo Plugin initialization
		if errorlevel 30 echo Too deep nesting
		if errorlevel 50 echo Stop requested
	)
)

goto End
:MissingEnvironmentVariables
echo Missing Environment Variables
:End