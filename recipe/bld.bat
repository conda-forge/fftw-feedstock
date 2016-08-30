if "%ARCH%" == "64" (
  set MACHINE=X64
) else (
  set MACHINE=X86
)

where /r c:\ msbuild

if errorlevel 1 exit 1
