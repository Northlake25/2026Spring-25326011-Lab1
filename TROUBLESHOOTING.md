# 故障排除指南

## 问题：源文件无法打开

### 原因分析

这个错误通常由以下原因引起：

1. **缺少Qt资源文件** - 已修复 ✅
2. **CMake配置错误** - 需要正确指定Qt路径
3. **工作目录错误** - 需要在项目根目录运行
4. **Qt未正确安装** - 需要安装Qt6

### 解决方案

#### 方案1：使用构建脚本（推荐）

```powershell
# 1. 编辑 build.bat，设置正确的Qt路径
set QT_PATH=C:\Qt\6.5.0\msvc2019_64

# 2. 运行构建脚本
.\build.bat
```

#### 方案2：手动构建

```powershell
# 1. 确保在项目根目录
cd d:\Projects\demo\guess_poetry_game

# 2. 创建并进入构建目录
mkdir build
cd build

# 3. 配置CMake（替换为你的Qt路径）
cmake .. -DCMAKE_PREFIX_PATH="C:/Qt/6.5.0/msvc2019_64"

# 4. 编译
cmake --build . --config Release

# 5. 运行
.\bin\Release\guess_poetry_game.exe
```

#### 方案3：使用Visual Studio

1. 打开Visual Studio 2019/2022
2. 选择"打开本地文件夹"
3. 选择 `guess_poetry_game` 文件夹
4. 等待CMake自动配置
5. 如果提示选择Kit，选择已安装的MSVC编译器
6. 点击"生成" -> "全部生成"
7. F5运行调试

## 常见错误信息

### 错误1: "Could not find Qt6"

**完整错误**：
```
CMake Error at CMakeLists.txt:11 (find_package):
  Could not find a package configuration file provided by "Qt6" with any of
  the following names...
```

**解决方法**：
```powershell
# 方法1: 设置环境变量
set Qt6_DIR=C:\Qt\6.5.0\msvc2019_64\lib\cmake\Qt6
cmake ..

# 方法2: 直接指定路径
cmake .. -DCMAKE_PREFIX_PATH="C:/Qt/6.5.0/msvc2019_64"
```

### 错误2: "Cannot open include file: 'QApplication'"

**原因**：Qt路径未正确配置

**解决方法**：
- 确保Qt6已安装
- 使用正确的CMAKE_PREFIX_PATH
- 检查Qt安装路径是否正确

### 错误3: "LNK2019: unresolved external symbol"

**原因**：Qt库未正确链接

**解决方法**：
```powershell
# 清理构建目录
Remove-Item -Recurse -Force build
mkdir build
cd build

# 重新配置
cmake .. -DCMAKE_PREFIX_PATH="C:/Qt/6.5.0/msvc2019_64"
cmake --build . --config Release
```

### 错误4: "找不到资源文件"

**原因**：resources.qrc未正确配置

**已修复**：
- ✅ 已创建 resources.qrc
- ✅ 已添加到 CMakeLists.txt
- ✅ 已配置CMAKE_AUTORCC

## 验证步骤

### 步骤1: 检查文件完整性

```powershell
# 检查关键文件是否存在
Test-Path guess_poetry_game\main.cpp
Test-Path guess_poetry_game\CMakeLists.txt
Test-Path guess_poetry_game\resources.qrc
Test-Path guess_poetry_game\resources\styles.qss
```

所有检查应返回 `True`

### 步骤2: 检查Qt安装

```powershell
# 检查Qt目录
Test-Path C:\Qt\6.5.0\msvc2019_64

# 检查Qt CMake配置
Test-Path C:\Qt\6.5.0\msvc2019_64\lib\cmake\Qt6\Qt6Config.cmake
```

### 步骤3: 检查CMake版本

```powershell
cmake --version
# 应显示版本 >= 3.16
```

## 环境配置

### Windows环境变量

```powershell
# 设置Qt路径（根据实际安装路径修改）
setx QT_DIR "C:\Qt\6.5.0\msvc2019_64"

# 添加Qt到PATH
setx PATH "%PATH%;C:\Qt\6.5.0\msvc2019_64\bin"
```

### PowerShell配置文件

```powershell
# 编辑PowerShell配置文件
notepad $PROFILE

# 添加以下内容
$env:QT_DIR = "C:\Qt\6.5.0\msvc2019_64"
$env:PATH += ";C:\Qt\6.5.0\msvc2019_64\bin"
```

## 最小系统要求

- ✅ Windows 10 或更高版本
- ✅ Visual Studio 2019 或更高版本
- ✅ CMake 3.16 或更高版本
- ✅ Qt 6.2 或更高版本

## 获取帮助

如果以上方法都无法解决问题，请提供以下信息：

1. 操作系统版本
2. Visual Studio版本
3. CMake版本 (`cmake --version`)
4. Qt版本和安装路径
5. 完整的错误信息
6. CMake配置输出

## 快速测试

创建一个最小测试程序验证Qt是否正常工作：

```cpp
// test_qt.cpp
#include <QApplication>
#include <QLabel>

int main(int argc, char *argv[]) {
    QApplication app(argc, argv);
    QLabel label("Qt6 工作正常！");
    label.show();
    return app.exec();
}
```

编译测试：
```powershell
cmake -G "MinGW Makefiles" -DCMAKE_PREFIX_PATH="C:/Qt/6.5.0/mingw_64" ..
cmake --build .
.\test_qt.exe
```

如果测试程序能正常显示窗口，说明Qt配置正确。
