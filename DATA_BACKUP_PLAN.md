# 数据备份紧急方案

## ⚠️ 数据丢失原因分析

### 问题
- build目录下的数据文件在重新构建时被删除
- 数据文件位置不安全（在build目录内）

### 解决方案

**方案1：立即修改数据存储位置**
将数据文件存储到不受构建影响的位置：
- Windows: `C:/Users/[用户名]/AppData/Local/guess_poetry_game/`
- 或: `C:/Users/[用户名]/Documents/guess_poetry_game/`

**方案2：自动备份机制**
每次保存数据时，自动备份到多个位置：
1. 应用程序目录
2. 用户文档目录
3. AppData目录

**方案3：Git版本控制**
初始化Git仓库，自动跟踪数据文件变化

## 🔧 立即实施

### 1. 修改file_storage.h，使用安全的数据目录

```cpp
// 在FileStorage构造函数中
QString dataPath = QStandardPaths::writableLocation(QStandardPaths::AppDataLocation);
QDir().mkpath(dataPath);
m_dataPath = dataPath;
```

### 2. 添加自动备份功能

```cpp
void backupData() {
    QString backupPath = QStandardPaths::writableLocation(QStandardPaths::DocumentsLocation);
    backupPath += "/guess_poetry_backup/";

    // 备份questions.json
    QFile::copy(m_dataPath + "/questions.json",
                backupPath + "questions_" + QDateTime::currentDateTime().toString("yyyyMMdd_HHmmss") + ".json");

    // 备份poems.json
    QFile::copy(m_dataPath + "/poems.json",
                backupPath + "poems_" + QDateTime::currentDateTime().toString("yyyyMMdd_HHmmss") + ".json");
}
```

### 3. 初始化Git仓库

```bash
cd D:\Projects\demo\guess_poetry_game
git init
git add bin/resources/*.json
git commit -m "数据备份"
```

## 📋 建议

1. **立即修改数据存储位置**到安全目录
2. **实现自动备份**到多个位置
3. **使用Git**跟踪数据变化
4. **定期导出**数据到外部存储

非常抱歉造成了数据丢失！我会立即实施这些保护措施。
