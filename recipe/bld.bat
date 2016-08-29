if "%ARCH%" == "64" (
  set MACHINE=X64
) else (
  set MACHINE=X86
)

:: make MSVC .lib files from .def
lib /MACHINE:%MACHINE% /def:libfftw3-3.def
lib /MACHINE:%MACHINE% /def:libfftw3f-3.def
lib /MACHINE:%MACHINE% /def:libfftw3l-3.def

copy libfftw3-3.dll "%LIBRARY_LIB%\"
copy libfftw3f-3.dll "%LIBRARY_LIB%\"
copy libfftw3l-3.dll "%LIBRARY_LIB%\"

copy libfftw3-3.lib "%LIBRARY_LIB%\"
copy libfftw3f-3.lib "%LIBRARY_LIB%\"
copy libfftw3l-3.lib "%LIBRARY_LIB%\"

copy *.h "%LIBRARY_INC%\"

if errorlevel 1 exit 1
