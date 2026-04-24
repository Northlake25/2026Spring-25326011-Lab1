@echo off
echo ========================================
echo 猜诗词游戏 - 构建脚本
echo ========================================
echo.

REM 检查Qt路径是否设置
if "%QT_DIR%"=="" (
    echo [警告] QT_DIR 环境变量未设置
    echo 请设置Qt安装路径，例如：
    echo set QT_DIR=C:\Qt\6.5.0\msvc2019_64
    echo.
    echo 或者直接修改此脚本中的QT_PATH变量
    echo.
    set QT_PATH=C:\Qt\6.5.0\msvc2019_64
) else (
    set QT_PATH=%QT_DIR%
)

echo 使用Qt路径: %QT_PATH%
echo.

REM 创建构建目录
if not exist build (
    echo 创建构建目录...
    mkdir build
)

cd build

REM 配置CMake
echo.
echo 配置CMake...
cmake .. -DCMAKE_PREFIX_PATH="%QT_PATH%"

if %ERRORLEVEL% neq 0 (
    echo.
    echo [错误] CMake配置失败！
    echo 请检查：
    echo 1. Qt6是否正确安装
    echo 2. CMake是否已安装
    echo 3. 编译器是否可用
    cd ..
    pause
    exit /b 1
)

REM 编译项目
echo.
echo 编译项目...
cmake --build . --config Release

if %ERRORLEVEL% neq 0 (
    echo.
    echo [错误] 编译失败！
    cd ..
    pause
    exit /b 1
)

echo.
echo ========================================
echo 构建成功！
echo ========================================
echo.
echo 可执行文件位置: build\bin\Release\guess_poetry_game.exe
echo.
echo 是否立即运行？(Y/N)
set /p RUN_CHOICE=

if /i "%RUN_CHOICE%"=="Y" (
    echo.
    echo 启动游戏...
    cd bin\Release
    guess_poetry_game.exe
)

cd ..
