cmake -S .. -G "Visual Studio 17 2022" -DCMAKE_BUILD_TYPE="Release" -B MSVC_Visual_Studio_17_2022-Release
cmake --build MSVC_Visual_Studio_17_2022-Release --target ALL_BUILD --config Release
pause
