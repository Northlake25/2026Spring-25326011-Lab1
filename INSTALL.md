# 环境安装指南

## 当前问题

您遇到的错误：
```
fatal error: QApplication: No such file or directory
```

**原因**：
1. ❌ 没有安装Qt6
2. ❌ 没有安装CMake
3. ❌ 直接使用g++编译Qt项目（错误方法）

**正确方法**：Qt项目必须使用CMake构建系统！

## 完整安装步骤

### 步骤1：安装Qt6

#### 方法A：使用Qt Online Installer（推荐）

1. **下载安装器**
   - 访问：https://www.qt.io/download-qt-installer
   - 下载：qt-unified-windows-x64-online.exe

2. **运行安装器**
   - 双击运行安装器
   - 登录Qt账号（免费注册）
   - 选择安装路径：`C:\Qt`

3. **选择组件**
   - ✅ Qt 6.5.0（或最新版本）
   - ✅ MSVC 2019 64-bit（如果使用Visual Studio）
   - ✅ MinGW 11.2.0 64-bit（如果使用MinGW）
   - ✅ Qt Creator（IDE，可选）

4. **完成安装**
   - 安装路径示例：`C:\Qt\6.5.0\msvc2019_64`

#### 方法B：使用vcpkg（快速）

```powershell
# 安装vcpkg
git clone https://github.com/Microsoft/vcpkg.git
cd vcpkg
.\bootstrap-vcpkg.bat

# 安装Qt6
.\vcpkg install qt6-base:x64-windows
```

### 步骤2：安装CMake

#### 方法A：官方安装包（推荐）

1. **下载CMake**
   - 访问：https://cmake.org/download/
   - 下载：cmake-3.28.0-windows-x86_64.msi

2. **安装**
   - 运行安装包
   - ✅ 选择"Add CMake to the system PATH for all users"
   - 完成安装

3. **验证安装**
   ```powershell
   cmake --version
   # 应显示：cmake version 3.28.0
   ```

#### 方法B：使用winget

```powershell
winget install Kitware.CMake
```

#### 方法C：使用Chocolatey

```powershell
choco install cmake
```

### 步骤3：安装编译器

#### 选项A：Visual Studio（推荐）

1. **下载Visual Studio**
   - 访问：https://visualstudio.microsoft.com/
   - 下载：Visual Studio 2022 Community（免费）

2. **安装时选择组件**
   - ✅ "使用C++的桌面开发"
   - ✅ Windows 10/11 SDK
   - ✅ MSVC v143 编译器

#### 选项B：MinGW（轻量级）

1. **下载MinGW**
   - 访问：https://www.mingw-w64.org/
   - 或使用MSYS2：https://www.msys2.org/

2. **安装MSYS2 + MinGW**
   ```powershell
   # 安装MSYS2后，运行：
   pacman -S mingw-w64-x86_64-gcc
   ```

3. **添加到PATH**
   ```
   C:\msys64\mingw64\bin
   ```

## 快速验证

### 验证脚本

创建 `check_env.ps1`：

```powershell
Write-Host "环境检查..." -ForegroundColor Green

# 检查CMake
try {
    $cmakeVersion = cmake --version 2>&1
    Write-Host "✅ CMake: $cmakeVersion" -ForegroundColor Green
} catch {
    Write-Host "❌ CMake 未安装" -ForegroundColor Red
}

# 检查Qt
$qtPaths = @(
    "C:\Qt\6.5.0\msvc2019_64",
    "C:\Qt\6.5.0\mingw_64",
    "C:\Qt\6.4.0\msvc2019_64"
)

$qtFound = $false
foreach ($path in $qtPaths) {
    if (Test-Path $path) {
        Write-Host "✅ Qt6: $path" -ForegroundColor Green
        $qtFound = $true
        break
    }
}

if (-not $qtFound) {
    Write-Host "❌ Qt6 未安装" -ForegroundColor Red
}

# 检查编译器
try {
    $clVersion = cl 2>&1
    Write-Host "✅ MSVC 编译器已找到" -ForegroundColor Green
} catch {
    try {
        $gccVersion = g++ --version 2>&1
        Write-Host "✅ GCC 编译器: $gccVersion" -ForegroundColor Green
    } catch {
        Write-Host "❌ 编译器未找到" -ForegroundColor Red
    }
}
```

运行检查：
```powershell
.\check_env.ps1
```

## 环境变量配置

### 设置Qt环境变量

```powershell
# 方法1：临时设置（当前会话）
$env:Qt6_DIR = "C:\Qt\6.5.0\msvc2019_64"
$env:PATH += ";C:\Qt\6.5.0\msvc2019_64\bin"

# 方法2：永久设置（系统环境变量）
setx Qt6_DIR "C:\Qt\6.5.0\msvc2019_64" /M
setx PATH "%PATH%;C:\Qt\6.5.0\msvc2019_64\bin" /M
```

### PowerShell配置文件

```powershell
# 编辑配置文件
notepad $PROFILE

# 添加以下内容：
$env:Qt6_DIR = "C:\Qt\6.5.0\msvc2019_64"
$env:PATH += ";C:\Qt\6.5.0\msvc2019_64\bin"
```

## 完整构建流程

安装完成后，按以下步骤构建：

```powershell
# 1. 进入项目目录
cd d:\Projects\demo\guess_poetry_game

# 2. 创建构建目录
mkdir build
cd build

# 3. 配置CMake（根据你的Qt路径修改）
cmake .. -DCMAKE_PREFIX_PATH="C:/Qt/6.5.0/msvc2019_64"

# 4. 编译
cmake --build . --config Release

# 5. 运行
.\bin\Release\guess_poetry_game.exe
```

## 常见问题

### Q1: Qt安装太大怎么办？

**答**：只安装必要组件：
- Qt 6.5.0 → MSVC 2019 64-bit（约1GB）
- 不需要Qt Creator、源码、示例等

### Q2: 没有Visual Studio怎么办？

**答**：使用MinGW：
```powershell
# 安装Qt时选择MinGW组件
# 构建时使用：
cmake .. -G "MinGW Makefiles" -DCMAKE_PREFIX_PATH="C:/Qt/6.5.0/mingw_64"
```

### Q3: 能否使用vcpkg？

**答**：可以，但配置较复杂：
```powershell
vcpkg install qt6-base:x64-windows
cmake .. -DCMAKE_TOOLCHAIN_FILE=C:/vcpkg/scripts/buildsystems/vcpkg.cmake
```

## 最小安装方案

如果只想快速测试，最小安装：

1. **CMake** (约50MB)
2. **Qt6 Base** (约1GB)
3. **MinGW** (约500MB)

总计约1.5GB，比完整Qt安装小很多。

## 下一步

安装完成后，请参考 `BUILD.md` 进行构建。
