project(cmake_test)
cmake_minimum_required(VERSION 3.3)
find_package(FFTW3 REQUIRED)
add_executable(test_fftw3 test_fftw3.c)
target_link_libraries(test_fftw3 fftw3)
