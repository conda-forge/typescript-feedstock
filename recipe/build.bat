@echo on

call npm pkg delete optionalDependencies
if errorlevel 1 exit 1
call npm pack --ignore-scripts
if errorlevel 1 exit 1
call npm install -ddd --global --build-from-source %SRC_DIR%\%PKG_NAME%-%PKG_VERSION%.tgz
if errorlevel 1 exit 1

set "NODE_ARCH=%GOARCH%"
if "%GOARCH%"=="amd64" set "NODE_ARCH=x64"
set "PLATFORM_PACKAGE_NAME=typescript-win32-%NODE_ARCH%"
set "PLATFORM_PACKAGE_DIR=%PREFIX%\node_modules\@typescript\%PLATFORM_PACKAGE_NAME%"

mkdir "%PLATFORM_PACKAGE_DIR%\lib"
if errorlevel 1 exit 1
pushd typescript-go
go-licenses save .\cmd\tsgo --save_path "%SRC_DIR%\library_licenses"
if errorlevel 1 exit 1
go build -trimpath -ldflags="-s -w" -tags noembed -o "%PLATFORM_PACKAGE_DIR%\lib\tsc.exe" .\cmd\tsgo
if errorlevel 1 exit 1
copy internal\bundled\libs\* "%PLATFORM_PACKAGE_DIR%\lib\"
if errorlevel 1 exit 1
copy LICENSE "%PLATFORM_PACKAGE_DIR%\"
if errorlevel 1 exit 1
copy NOTICE.txt "%PLATFORM_PACKAGE_DIR%\"
if errorlevel 1 exit 1
popd

(
echo {
echo     "name": "@typescript/%PLATFORM_PACKAGE_NAME%",
echo     "version": "%PKG_VERSION%",
echo     "license": "Apache-2.0",
echo     "os": ["win32"],
echo     "cpu": ["%NODE_ARCH%"],
echo     "exports": {
echo         "./package.json": "./package.json"
echo     }
echo }
) > "%PLATFORM_PACKAGE_DIR%\package.json"
if errorlevel 1 exit 1
