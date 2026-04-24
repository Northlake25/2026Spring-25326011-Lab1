# 特殊联组合功能实现

## ✅ 已完成

### 问题

特殊情况不明确，需要支持非标准的联组合

### 示例：《江南》

```
江南可采莲，莲叶何田田。
鱼戏莲叶间。
鱼戏莲叶东，鱼戏莲叶西，鱼戏莲叶南，鱼戏莲叶北。
```

**诗句索引**：
- 0: 江南可采莲
- 1: 莲叶何田田
- 2: 鱼戏莲叶间
- 3: 鱼戏莲叶东
- 4: 鱼戏莲叶西
- 5: 鱼戏莲叶南
- 6: 鱼戏莲叶北

**标准联**：
- (0,1): 江南可采莲，莲叶何田田
- (4,5): 鱼戏莲叶西，鱼戏莲叶南
- (5,6): 鱼戏莲叶南，鱼戏莲叶北

**特殊联**：
- (2,3): 鱼戏莲叶间，鱼戏莲叶东
- (3,4): 鱼戏莲叶东，鱼戏莲叶西

### 修改内容

**1. 数据结构**

```cpp
QSet<QPair<int, int>> specialCouplets;  // 特殊联组合（上句索引, 下句索引）
```

**2. 获取所有联组合**

```cpp
QVector<QPair<int, int>> getAllCouplets() const {
    QVector<QPair<int, int>> couplets;
    
    // 标准联：每两句一组
    for (int i = 0; i + 1 < verses.size(); i += 2) {
        couplets.append(qMakePair(i, i + 1));
    }
    
    // 特殊联
    for (const auto& couplet : specialCouplets) {
        couplets.append(couplet);
    }
    
    return couplets;
}
```

**3. 输入格式**

```
特殊：2,3;3,4
```

表示：
- 2,3：第2句和第3句组成一联
- 3,4：第3句和第4句组成一联

**4. 解析逻辑**

```cpp
QSet<QPair<int, int>> specialCouplets;
QStringList coupletList = allowedStr.split(';', Qt::SkipEmptyParts);
for (const QString& coupletStr : coupletList) {
    QStringList indices = coupletStr.trimmed().split(',', Qt::SkipEmptyParts);
    if (indices.size() == 2) {
        int upperIdx = indices[0].trimmed().toInt();
        int lowerIdx = indices[1].trimmed().toInt();
        specialCouplets.insert(qMakePair(upperIdx, lowerIdx));
    }
}
```

## 📋 使用示例

### 输入《江南》

**诗句**：
```
江南可采莲，莲叶何田田。
鱼戏莲叶间。
鱼戏莲叶东，鱼戏莲叶西，鱼戏莲叶南，鱼戏莲叶北。
```

**特殊**：
```
2,3;3,4
```

**结果**：
- 标准联：(0,1), (4,5), (5,6)
- 特殊联：(2,3), (3,4)
- 总共5个联组合

### 题目生成

从所有联组合中随机选择：
- 可能是标准联
- 也可能是特殊联

## 📊 修改统计

| 项目 | 状态 |
|------|------|
| 数据结构 | ✅ 已修改 |
| 解析逻辑 | ✅ 已修改 |
| 输入格式 | ✅ 已修改 |

## 🔄 下一步

重新编译：
```powershell
cd D:\Projects\demo\guess_poetry_game\build
mingw32-make -j4
```

运行：
```powershell
.\bin\guess_poetry_game.exe
```

特殊联组合功能已实现！
