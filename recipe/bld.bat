if "%ARCH%" == "64" (
  set MACHINE=X64
) else (
  set MACHINE=X86
)

xcopy /s %RECIPE_DIR%\\win_sln .

cd win32
msbuild.exe fftw-vs2008.sln /t:libfftw
msbuild.exe fftw-vs2008.sln /t:libfftwf
msbuild.exe fftw-vs2008.sln /t:libfftwl

if errorlevel 1 exit 1
