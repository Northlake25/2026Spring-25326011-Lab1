# 玩家输入无需标点

## ✅ 已完成修改

### 问题
玩家猜测时必须输入标点分隔上下句，不够方便

### 解决方案
玩家可以直接输入连续的汉字，无需标点

### 修改内容

**1. 修改feedback_processor.h**

**修改前**：
```cpp
// 分割猜测为上下句
QVector<QString> guessSentences = Validator::splitSentences(guess);
if (guessSentences.size() != 2) {
    return Feedback::invalid("请输入上下两句诗，用标点分隔");
}
```

**修改后**：
```cpp
// 标准化输入（去除标点）
QString normalized = Validator::normalizeText(guess);
int upperLen = upperNorm.length();
int lowerLen = lowerNorm.length();
int totalLen = upperLen + lowerLen;

// 验证总字数
if (normalized.length() != totalLen) {
    return Feedback::invalid(QString("请输入%1个字的诗句").arg(totalLen));
}

// 分割为上下句（可以没有标点，直接按字数分割）
QString upperGuess = normalized.left(upperLen);
QString lowerGuess = normalized.mid(upperLen);
```

**2. 修改game_widget.cpp**

**修改前**：
```cpp
hint = QString("请猜上下联（上句%1字，下句%2字）")
    .arg(question.getUpperCharCount())
    .arg(question.getLowerCharCount());
m_questionLabel->setText("请输入两句诗，用标点分隔");
```

**修改后**：
```cpp
int total = question.getUpperCharCount() + question.getLowerCharCount();
hint = QString("请猜上下联（共%1字，上句%2字+下句%3字）")
    .arg(total)
    .arg(question.getUpperCharCount())
    .arg(question.getLowerCharCount());
m_questionLabel->setText("直接输入诗句即可，无需标点");
```

## 🎮 使用示例

### 输入方式

**可以输入**：
- ✅ 床前明月光疑是地上霜（无标点）
- ✅ 床前明月光，疑是地上霜（有标点）
- ✅ 床前明月光疑是地上霜。（有句号）

**处理逻辑**：
1. 去除所有标点符号
2. 按字数自动分割上下句
3. 验证是否在诗词库中

### 游戏界面

**显示**：
```
题目提示：请猜上下联（共10字，上句5字+下句5字）
直接输入诗句即可，无需标点
```

**输入**：
```
床前明月光疑是地上霜
```

**处理**：
- 去除标点：床前明月光疑是地上霜
- 分割上句：床前明月光（前5字）
- 分割下句：疑是地上霜（后5字）
- 验证通过

## 📊 修改统计

| 项目 | 修改前 | 修改后 |
|------|--------|--------|
| 输入要求 | 必须有标点 | 无需标点 |
| 分割方式 | 按标点分割 | 按字数分割 |
| 提示文字 | "用标点分隔" | "无需标点" |
| 字数提示 | "上句X字，下句Y字" | "共Z字，上句X字+下句Y字" |

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

玩家输入更方便了！
