# 环境检查脚本
Write-Host "========================================"
Write-Host "猜诗词游戏 - 环境检查"
Write-Host "========================================"
Write-Host ""

# 检查CMake
Write-Host "[1/3] 检查 CMake..."
try {
    cmake --version
    Write-Host "  [OK] CMake 已安装" -ForegroundColor Green
}
catch {
    Write-Host "  [ERROR] CMake 未安装" -ForegroundColor Red
    Write-Host "  下载: https://cmake.org/download/"
}

Write-Host ""

# 检查Qt6
Write-Host "[2/3] 检查 Qt6..."
$qtPaths = @(
    "C:\Qt\6.5.0\msvc2019_64",
    "C:\Qt\6.5.0\mingw_64",
    "C:\Qt\6.4.0\msvc2019_64"
)

$qtFound = $false
foreach ($path in $qtPaths) {
    if (Test-Path $path) {
        Write-Host "  [OK] Qt6: $path" -ForegroundColor Green
        $qtFound = $true
        break
    }
}

if (-not $qtFound) {
    Write-Host "  [ERROR] Qt6 未安装" -ForegroundColor Red
    Write-Host "  下载: https://www.qt.io/download-qt-installer"
}

Write-Host ""

# 检查编译器
Write-Host "[3/3] 检查编译器..."
try {
    g++ --version
    Write-Host "  [OK] GCC 编译器已找到" -ForegroundColor Green
}
catch {
    try {
        cl 2>&1 | Out-Null
        Write-Host "  [OK] MSVC 编译器已找到" -ForegroundColor Green
    }
    catch {
        Write-Host "  [ERROR] 编译器未找到" -ForegroundColor Red
        Write-Host "  安装 Visual Studio 或 MinGW"
    }
}

Write-Host ""
Write-Host "========================================"
Write-Host "详细安装指南请查看: INSTALL.md"
Write-Host "========================================"
