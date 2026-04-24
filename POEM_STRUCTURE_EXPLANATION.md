# 诗词库解析逻辑说明

## 正确的理解

### 数据结构

```cpp
QVector<QString> verses;         // 每一句诗
QVector<QChar> punctuations;     // 每句后面的标点
```

### 示例：《长恨歌》片段

**输入**：
```
七月七日长生殿，夜半无人私语时。
在天愿作比翼鸟，在地愿为连理枝。
天长地久有时尽，此恨绵绵无绝期。
```

**解析结果**：
```
verses[0] = "七月七日长生殿"
verses[1] = "夜半无人私语时"
verses[2] = "在天愿作比翼鸟"
verses[3] = "在地愿为连理枝"
verses[4] = "天长地久有时尽"
verses[5] = "此恨绵绵无绝期"

punctuations[0] = '，'  // 第1句后面是逗号
punctuations[1] = '。'  // 第2句后面是句号
punctuations[2] = '，'  // 第3句后面是逗号
punctuations[3] = '。'  // 第4句后面是句号
punctuations[4] = '，'  // 第5句后面是逗号
punctuations[5] = '。'  // 第6句后面是句号
```

### 一联诗的定义

**一联诗** = 两个连续的句子

- 第1联：verses[0] + verses[1] = "七月七日长生殿，夜半无人私语时"
- 第2联：verses[2] + verses[3] = "在天愿作比翼鸟，在地愿为连理枝"
- 第3联：verses[4] + verses[5] = "天长地久有时尽，此恨绵绵无绝期"

### 标点的作用

**句号分隔规则**：
- 如果punctuations[i-1] == '。'，说明第i句是新的一联的开始
- 例如：punctuations[1] == '。'，说明verses[2]是新的一联的开始

**题目选择**：
- 第1联（verses[0-1]）：可以作为题目
- 第2联（verses[2-3]）：可以作为题目（因为punctuations[1] == '。'，但这是新联的开始）
- 第3联（verses[4-5]）：可以作为题目

### 玩家猜测

**题目**：第1联 = "七月七日长生殿，夜半无人私语时"

**玩家输入**：
- "七月七日长生殿夜半无人私语时"（无标点）
- "七月七日长生殿，夜半无人私语时"（有标点）

**验证**：
- 上句：七月七日长生殿（verses[0]）
- 下句：夜半无人私语时（verses[1]）
- 都在诗词库中 ✅

## 当前实现

### 解析逻辑

```cpp
// 按换行分割，每行是一联
QStringList lines = versesStr.split('\n', Qt::SkipEmptyParts);
for (const QString& line : lines) {
    // 每行用中文逗号分割为上下两句
    QStringList parts = trimmedLine.split(QChar(L'，'), Qt::SkipEmptyParts);
    for (const QString& part : parts) {
        // 去除句末标点
        verses.append(trimmed);
    }
}
```

### 标点逻辑

```cpp
// 默认：每联用逗号，最后一句用句号
for (int i = 0; i < verses.size(); ++i) {
    if ((i + 1) % 2 == 0) {  // 每联的下句
        if (i == verses.size() - 1) {
            punctuations.append(QChar(L'。'));  // 最后一句用句号
        } else {
            punctuations.append(QChar(L'。'));  // 其他用句号（表示一联结束）
        }
    } else {
        punctuations.append(QChar(L'，'));  // 上句用逗号
    }
}
```

## 问题

当前标点逻辑错误！

**应该是**：
- punctuations[0] = '，'（第1句后面）
- punctuations[1] = '。'（第2句后面，一联结束）
- punctuations[2] = '，'（第3句后面）
- punctuations[3] = '。'（第4句后面，一联结束）

**当前实现**：
- punctuations[0] = '，'（正确）
- punctuations[1] = '，'（错误！应该是'。'）
- punctuations[2] = '，'（正确）
- punctuations[3] = '。'（正确）

## 修复

需要修改标点逻辑，每联的下句后面应该是句号（表示一联结束）。
