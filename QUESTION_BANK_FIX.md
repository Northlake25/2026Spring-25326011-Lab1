# 题库数据格式修复

## ❌ 问题

题库中的题目格式错误：
- 没有保存和加载`upperSentence`和`lowerSentence`字段
- 导致题目无法正确显示为两句一联

## ✅ 修复

### 修改文件：`src/data/question_bank.h`

### 1. 修复load方法

**修复前**：
```cpp
q.position = obj["position"].toString() == "upper" ? Position::Upper : Position::Lower;
// 没有处理Position::Both
// 没有加载upperSentence和lowerSentence
```

**修复后**：
```cpp
// 处理position字段
QString posStr = obj["position"].toString();
if (posStr == "upper") {
    q.position = Position::Upper;
} else if (posStr == "lower") {
    q.position = Position::Lower;
} else {
    q.position = Position::Both;  // 支持both
}

// 处理上下句字段
if (obj.contains("upperSentence")) {
    q.upperSentence = obj["upperSentence"].toString();
}
if (obj.contains("lowerSentence")) {
    q.lowerSentence = obj["lowerSentence"].toString();
}
```

### 2. 修复save方法

**修复前**：
```cpp
obj["position"] = (q.position == Position::Upper) ? "upper" : "lower";
// 没有处理Position::Both
// 没有保存upperSentence和lowerSentence
```

**修复后**：
```cpp
// 保存position字段
if (q.position == Position::Upper) {
    obj["position"] = "upper";
} else if (q.position == Position::Lower) {
    obj["position"] = "lower";
} else {
    obj["position"] = "both";  // 支持both
}

// 保存上下句字段
if (!q.upperSentence.isEmpty()) {
    obj["upperSentence"] = q.upperSentence;
}
if (!q.lowerSentence.isEmpty()) {
    obj["lowerSentence"] = q.lowerSentence;
}
```

## 📋 JSON数据格式

### 修复后的questions.json

```json
{
  "version": "1.0",
  "questions": [
    {
      "id": "q001",
      "content": "床前明月光疑是地上霜",
      "position": "both",
      "upperSentence": "床前明月光",
      "lowerSentence": "疑是地上霜",
      "poem_id": "p001",
      "difficulty": 1
    },
    {
      "id": "q002",
      "content": "举头望明月低头思故乡",
      "position": "both",
      "upperSentence": "举头望明月",
      "lowerSentence": "低头思故乡",
      "poem_id": "p001",
      "difficulty": 1
    }
  ]
}
```

## 🎮 题目格式说明

### 正确的题目格式

**两句一联**：
- position: "both"
- upperSentence: "床前明月光"
- lowerSentence: "疑是地上霜"
- content: "床前明月光疑是地上霜"

**不是**：
- ❌ position: "upper" 或 "lower"
- ❌ 单独一句

### 示例题目

1. **床前明月光，疑是地上霜**（5×2）
2. **举头望明月，低头思故乡**（5×2）
3. **白日依山尽，黄河入海流**（5×2）
4. **欲穷千里目，更上一层楼**（5×2）

## 📊 修复统计

| 问题 | 状态 |
|------|------|
| load方法不支持both | ✅ 已修复 |
| save方法不支持both | ✅ 已修复 |
| 未保存上下句字段 | ✅ 已修复 |
| 未加载上下句字段 | ✅ 已修复 |

## 🔄 下一步

重新编译：
```powershell
cd D:\Projects\demo\guess_poetry_game\build
cmake --build .
```

删除旧数据文件，让程序重新生成：
```powershell
Remove-Item .\bin\resources\questions.json
Remove-Item .\bin\resources\poems.json
```

运行：
```powershell
.\bin\guess_poetry_game.exe
```

题库数据格式已完全修复！
