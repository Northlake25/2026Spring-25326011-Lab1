# 编译错误修复完成

## ✅ 已修复

### 问题
poem_bank.h和main_window.cpp还在使用旧的allowedAsQuestion字段

### 修复内容

**1. poem_bank.h - load方法**

**修改前**：
```cpp
QJsonArray allowedArray = obj["allowedAsQuestion"].toArray();
for (const auto& idx : allowedArray) {
    p.allowedAsQuestion.insert(idx.toInt());
}
```

**修改后**：
```cpp
QJsonArray specialArray = obj["specialCouplets"].toArray();
for (const auto& couplet : specialArray) {
    QJsonObject coupletObj = couplet.toObject();
    int upperIdx = coupletObj["upper"].toInt();
    int lowerIdx = coupletObj["lower"].toInt();
    p.specialCouplets.insert(qMakePair(upperIdx, lowerIdx));
}
```

**2. poem_bank.h - save方法**

**修改前**：
```cpp
QJsonArray allowedArray;
for (int idx : p.allowedAsQuestion) {
    allowedArray.append(idx);
}
obj["allowedAsQuestion"] = allowedArray;
```

**修改后**：
```cpp
QJsonArray specialArray;
for (const auto& couplet : p.specialCouplets) {
    QJsonObject coupletObj;
    coupletObj["upper"] = couplet.first;
    coupletObj["lower"] = couplet.second;
    specialArray.append(coupletObj);
}
obj["specialCouplets"] = specialArray;
```

**3. main_window.cpp**

**修改前**：
```cpp
p2.allowedAsQuestion = {1, 3};  // 标记特殊情况
```

**修改后**：
```cpp
// 标准联：(0,1), (2,3)
```

## 📋 JSON格式

**修改前**：
```json
{
  "allowedAsQuestion": [1, 3]
}
```

**修改后**：
```json
{
  "specialCouplets": [
    {"upper": 2, "lower": 3},
    {"upper": 3, "lower": 4}
  ]
}
```

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

编译错误已修复！
