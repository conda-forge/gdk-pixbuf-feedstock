setlocal EnableDelayedExpansion
@echo on

:: Ensure DLLs from the host and build prefixes can be found at build time.
:: g-ir-scanner links a temporary exe (in builddir\tmp-introspect*) against
:: glib/girepository from the prefixes and then runs it to dump introspection
:: data. Without these dirs on PATH the dump exe dies with
:: exit status 3221225785 (0xC0000135, STATUS_DLL_NOT_FOUND).
set "PATH=%LIBRARY_BIN%;%BUILD_PREFIX%\Library\bin;%PATH%"
:: Also cover the just-built gdk-pixbuf DLL next to the introspection exe.
set "PATH=%SRC_DIR%\builddir\gdk-pixbuf;%PATH%"

:: set pkg-config path so that host deps can be found
:: (set as env var so it's used by both meson and during build with g-ir-scanner)
set "PKG_CONFIG_PATH=%LIBRARY_LIB%\pkgconfig;%LIBRARY_PREFIX%\share\pkgconfig;%BUILD_PREFIX%\Library\lib\pkgconfig"

:: meson options
:: (set pkg_config_path so deps in host env can be found)
set ^"MESON_OPTIONS=^
  --prefix="%LIBRARY_PREFIX%" ^
  --wrap-mode=nofallback ^
  --buildtype=release ^
  --backend=ninja ^
  -D documentation=false ^
  -D man=false ^
  -D glycin=disabled ^
  -D installed_tests=false ^
  -D man=false ^
  -D introspection=enabled ^
  -D relocatable=true ^
  -D others=enabled ^
 ^"

:: configure build using meson
%BUILD_PREFIX%\Scripts\meson.exe setup builddir !MESON_OPTIONS!
if errorlevel 1 exit 1

:: print results of build configuration
%BUILD_PREFIX%\Scripts\meson.exe configure builddir
if errorlevel 1 exit 1

ninja -v -C builddir -j %CPU_COUNT%
if errorlevel 1 exit 1

ninja -C builddir install -j %CPU_COUNT%
if errorlevel 1 exit 1
