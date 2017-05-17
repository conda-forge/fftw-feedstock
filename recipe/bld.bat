
@rem See https://github.com/Microsoft/vcpkg/tree/master/ports/fftw3
cp "%RECIPE_DIR%\CMakeLists.txt" .
if errorlevel 1 exit 1
cp "%RECIPE_DIR%\config.h" .
if errorlevel 1 exit 1

mkdir buildw && cd buildw

set CMAKE_CONFIG="Release"

cmake -LAH -G"NMake Makefiles" -D"BUILD_SHARED_LIBS:BOOL=ON" ^
    -DCMAKE_INSTALL_PREFIX="%LIBRARY_PREFIX%" ..
if errorlevel 1 exit 1

cmake --build . --config %CMAKE_CONFIG% --target INSTALL
if errorlevel 1 exit 1
