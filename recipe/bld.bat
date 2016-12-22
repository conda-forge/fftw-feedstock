if "%ARCH%" == "64" (
  set MACHINE=X64
) else (
  set MACHINE=X86
)

xcopy /s %RECIPE_DIR%\\win_sln .

cd win32
C:\Windows\Microsoft.NET\Framework\v4.0.30319\MSBuild.exe fftw-vs2008.sln /t:libfftw
C:\Windows\Microsoft.NET\Framework\v4.0.30319\MSBuild.exe fftw-vs2008.sln /t:libfftwf
C:\Windows\Microsoft.NET\Framework\v4.0.30319\MSBuild.exe fftw-vs2008.sln /t:libfftwl

if errorlevel 1 exit 1
