# 三个新功能实现方案

## 功能1：数据导出导入

### 实现方案

**导出功能**：
- 在管理界面添加"导出数据"按钮
- 选择导出位置（默认：用户文档目录）
- 导出questions.json和poems.json

**导入功能**：
- 在管理界面添加"导入数据"按钮
- 选择导入文件位置
- 合并或替换现有数据

**代码位置**：
- admin_widget.h/cpp：添加导出导入按钮
- file_storage.h/cpp：添加导出导入方法

## 功能2：题库分类

### 实现方案

**数据结构**：
```cpp
struct Question {
    QString category;  // 分类标签，如"唐诗"、"宋词"、"五言"、"七言"
};
```

**分类管理**：
- 在添加题目时选择分类
- 在题目列表显示分类
- 可以按分类筛选查看

**代码位置**：
- question.h：添加category字段
- question_bank.h：添加getCategories()方法
- admin_widget.cpp：添加分类输入框和筛选功能

## 功能3：分类筛选游戏

### 实现方案

**管理界面**：
- 显示所有分类列表
- 勾选要包含的分类

**游戏逻辑**：
```cpp
QVector<Question> getQuestionsByCategories(const QSet<QString>& categories);
```

**代码位置**：
- admin_widget.cpp：添加分类勾选列表
- game_controller.cpp：修改startNewGame()支持分类筛选

## 实现顺序

1. ✅ 修改Question模型，添加category字段
2. 修改question_bank.h，支持category的保存加载
3. 修改admin_widget，添加分类输入和导出导入按钮
4. 修改game_controller，支持分类筛选
5. 测试所有功能

## 数据格式

### questions.json

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
      "difficulty": 1,
      "category": "唐诗"
    }
  ]
}
```

## UI设计

### 管理界面

```
题库管理
├─ 题目列表（显示分类）
├─ 添加题目
│  ├─ 诗句输入
│  ├─ 难度选择
│  └─ 分类选择（下拉框）
├─ 分类筛选（勾选框）
│  ├─ ☑ 唐诗
│  ├─ ☑ 宋词
│  └─ ☐ 元曲
├─ 导出数据按钮
└─ 导入数据按钮
```

## 下一步

1. 修改question_bank.h支持category
2. 修改admin_widget添加分类功能
3. 添加导出导入功能
4. 修改game_controller支持分类筛选
