setlocal EnableDelayedExpansion
set CHERE_INVOKING=1
set MSYS2_PATH_TYPE=inherit
copy %RECIPE_DIR%\build.sh .
for /F "delims=" %%i in ('cygpath.exe -u %PREFIX%') do set "PREFIX=%%i"

for /F "delims=" %%i in ('cygpath.exe -u -p "%INCLUDE%"') do set "INCLUDE=%%i"

for /F "delims=" %%i in ('cygpath.exe -u -p "%LIB%"') do set "LIB=%%i"

set "PKG_CONFIG_PATH=%PREFIX%/lib/pkgconfig:%PREFIX%/share/pkgconfig"
set "ACLOCAL_PATH=%PREFIX%/share/aclocal:/usr/share/aclocal"
bash -lc ./build.sh
