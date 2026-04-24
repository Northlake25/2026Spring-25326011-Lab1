# 构建和运行指南

## 前置要求

### Windows系统
1. **安装Qt6**
   - 下载Qt Online Installer: https://www.qt.io/download
   - 安装Qt 6.x版本（建议6.2或更高）
   - 记住安装路径（如：C:\Qt\6.5.0）

2. **安装CMake**
   - 下载：https://cmake.org/download/
   - 安装时选择"Add CMake to system PATH"

3. **安装编译器**
   - Visual Studio 2019或更高版本（包含MSVC编译器）
   - 或安装MinGW-w64

### Linux系统
```bash
# Ubuntu/Debian
sudo apt-get install qt6-base-dev cmake g++

# Fedora
sudo dnf install qt6-qtbase-devel cmake gcc-c++
```

### macOS系统
```bash
# 使用Homebrew
brew install qt6 cmake
```

## 构建步骤

### Windows (使用Visual Studio)

```powershell
# 1. 进入项目目录
cd d:\Projects\demo\guess_poetry_game

# 2. 创建构建目录
mkdir build
cd build

# 3. 配置CMake（需要指定Qt路径）
cmake .. -DCMAKE_PREFIX_PATH="C:/Qt/6.5.0/msvc2019_64"

# 4. 编译
cmake --build . --config Release

# 5. 运行
.\bin\Release\guess_poetry_game.exe
```

### Windows (使用MinGW)

```powershell
# 1. 进入项目目录
cd d:\Projects\demo\guess_poetry_game

# 2. 创建构建目录
mkdir build
cd build

# 3. 配置CMake
cmake .. -G "MinGW Makefiles" -DCMAKE_PREFIX_PATH="C:/Qt/6.5.0/mingw_64"

# 4. 编译
cmake --build .

# 5. 运行
.\bin\guess_poetry_game.exe
```

### Linux/macOS

```bash
# 1. 进入项目目录
cd /path/to/guess_poetry_game

# 2. 创建构建目录
mkdir build && cd build

# 3. 配置CMake
cmake ..

# 4. 编译
cmake --build .

# 5. 运行
./bin/guess_poetry_game
```

## 常见问题解决

### 问题1: "Could not find Qt6"

**解决方案**：
- 确保Qt6已正确安装
- 使用`-DCMAKE_PREFIX_PATH`指定Qt安装路径
- Windows示例：`-DCMAKE_PREFIX_PATH="C:/Qt/6.5.0/msvc2019_64"`

### 问题2: "源文件无法打开"

**解决方案**：
- 确保在项目根目录（guess_poetry_game）下运行cmake
- 检查所有源文件是否存在
- 已添加resources.qrc资源文件

### 问题3: "找不到Qt库"

**Windows解决方案**：
- 将Qt的bin目录添加到PATH环境变量
- 或将Qt的dll文件复制到可执行文件目录

**Linux/macOS解决方案**：
```bash
export LD_LIBRARY_PATH=/path/to/qt/lib:$LD_LIBRARY_PATH  # Linux
export DYLD_LIBRARY_PATH=/path/to/qt/lib:$DYLD_LIBRARY_PATH  # macOS
```

### 问题4: 编译错误

**检查清单**：
- ✅ C++17支持已启用
- ✅ Qt6正确安装
- ✅ CMake版本 >= 3.16
- ✅ 所有源文件完整

## 验证构建

构建成功后，应该看到：
```
[100%] Built target guess_poetry_game
```

运行程序后，应该看到游戏窗口，包含：
- 题目提示区域
- 猜测输入框
- 猜测历史网格
- 管理界面入口

## 开发模式运行

如果想在IDE中调试：

### Visual Studio Code
1. 安装CMake Tools扩展
2. 打开项目文件夹
3. 选择Kit（编译器）
4. 点击"Build"
5. 点击"Run"

### Visual Studio
1. 打开文件夹
2. CMake会自动配置
3. 选择生成项目
4. F5调试运行

### CLion
1. 打开项目文件夹
2. CMake会自动配置
3. 点击运行按钮
