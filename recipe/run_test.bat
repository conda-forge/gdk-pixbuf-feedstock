@echo on
cmake -S . -B consumer-build -G Ninja -DCMAKE_BUILD_TYPE=Release
if errorlevel 1 exit /b 1
cmake --build consumer-build
if errorlevel 1 exit /b 1
consumer-build\gdk-pixbuf-consumer.exe
if errorlevel 1 exit /b 1
