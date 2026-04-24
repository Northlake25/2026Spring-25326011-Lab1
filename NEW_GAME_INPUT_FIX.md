# 新游戏无法输入问题修复

## ❌ 问题

点击"新游戏"后，输入框和按钮被禁用，无法输入

## 🔍 原因分析

在猜对答案后，输入框和按钮被禁用：
```cpp
m_inputEdit->setEnabled(false);
m_submitButton->setEnabled(false);
```

但是`reset()`方法没有重新启用它们。

## ✅ 修复

**修改文件**：`src/ui/game_widget.cpp`

**修改前**：
```cpp
void GameWidget::reset() {
    m_currentRow = 0;

    // 清空网格
    QLayoutItem* item;
    while ((item = m_gridLayout->takeAt(0)) != nullptr) {
        delete item->widget();
        delete item;
    }

    m_inputEdit->clear();
    m_grayHintLabel->setText("灰色提示：无");
    m_remainingLabel->setText("剩余次数：20/20");
}
```

**修改后**：
```cpp
void GameWidget::reset() {
    m_currentRow = 0;

    // 清空网格
    QLayoutItem* item;
    while ((item = m_gridLayout->takeAt(0)) != nullptr) {
        delete item->widget();
        delete item;
    }

    m_inputEdit->clear();
    m_inputEdit->setEnabled(true);  // 重新启用输入框
    m_submitButton->setEnabled(true);  // 重新启用按钮
    m_grayHintLabel->setText("灰色提示：无");
    m_remainingLabel->setText("剩余次数：20/20");
}
```

## 📋 修复内容

| 项目 | 修改前 | 修改后 |
|------|--------|--------|
| 输入框状态 | 未重新启用 | ✅ 重新启用 |
| 按钮状态 | 未重新启用 | ✅ 重新启用 |

## 🎮 测试流程

1. 启动游戏
2. 猜对答案（输入框和按钮被禁用）
3. 点击"新游戏"
4. ✅ 输入框和按钮重新启用
5. ✅ 可以正常输入

## 🔄 下一步

重新编译：
```powershell
cd D:\Projects\demo\guess_poetry_game\build
cmake --build .
```

运行：
```powershell
.\bin\guess_poetry_game.exe
```

问题已修复！
