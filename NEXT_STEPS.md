# 编译错误已修复 - 下一步操作

## ✅ 已修复的问题

**问题**：头文件路径错误
```
fatal error: question_bank.h: No such file or directory
```

**修复内容**：
- ✅ 已修正所有头文件的include路径
- ✅ 使用相对路径从src目录开始（如：`#include "data/question_bank.h"`）
- ✅ 已清理构建目录

**修改的文件**：
- src/ui/admin_widget.h
- src/ui/main_window.h
- src/ui/game_widget.h
- src/logic/game_controller.h
- src/logic/feedback_processor.h
- src/data/question_bank.h
- src/data/poem_bank.h
- src/models/game_state.h

## 📋 下一步操作

### 步骤1：确认CMake已安装

```powershell
cmake --version
```

如果显示"无法识别cmake"，请安装CMake：
- 下载：https://cmake.org/download/
- 安装时勾选"Add CMake to system PATH"
- 重启PowerShell

### 步骤2：确认Qt6已安装

```powershell
Test-Path C:\Qt\6.5.0\mingw_64
```

如果返回False，请安装Qt6：
- 下载：https://www.qt.io/download-qt-installer
- 安装组件：Qt 6.5.0 → MinGW 11.2.0 64-bit

### 步骤3：重新构建

```powershell
# 1. 进入项目目录
cd D:\Projects\demo\guess_poetry_game

# 2. 创建构建目录（如果不存在）
if (-not (Test-Path build)) { mkdir build }
cd build

# 3. 配置CMake
cmake .. -G "MinGW Makefiles" -DCMAKE_PREFIX_PATH="C:/Qt/6.5.0/mingw_64"

# 4. 编译
cmake --build .

# 5. 运行
.\bin\guess_poetry_game.exe
```

## 🔍 验证修复

所有include路径已修正为从src目录开始的相对路径：

| 文件 | 原路径 | 新路径 |
|------|--------|--------|
| admin_widget.h | `#include "question_bank.h"` | `#include "data/question_bank.h"` |
| main_window.h | `#include "game_controller.h"` | `#include "logic/game_controller.h"` |
| game_widget.h | `#include "feedback.h"` | `#include "models/feedback.h"` |

## ⚠️ 注意事项

1. **必须使用CMake构建**
   - 不能直接用g++编译
   - Qt项目需要MOC、UIC、RCC工具

2. **必须指定Qt路径**
   - 使用`-DCMAKE_PREFIX_PATH`参数
   - 路径指向Qt安装目录

3. **MinGW需要指定生成器**
   - 使用`-G "MinGW Makefiles"`
   - Visual Studio不需要此参数

## 📚 相关文档

- **INSTALL.md** - 环境安装指南
- **BUILD.md** - 详细构建步骤
- **TROUBLESHOOTING.md** - 故障排除

## 🎯 预期结果

成功编译后，应该看到：
```
[100%] Built target guess_poetry_game
```

运行程序后，应该看到游戏窗口。
