#pragma once
#include <QString>
#include <optional>

enum class Position { Upper, Lower, Both };

struct Question {
    QString id;                      // 唯一标识
    QString content;                 // 诗句内容（不含标点）
    QString upperSentence;           // 上句内容（用于上下联题目）
    QString lowerSentence;           // 下句内容（用于上下联题目）
    Position position;               // 上下句位置
    std::optional<QString> poem_id;  // 所属诗词ID
    int difficulty = 1;              // 难度等级（1-5）
    QString category;                // 分类标签
    
    Question() = default;
    
    Question(const QString& id, const QString& content, Position pos, 
             const std::optional<QString>& poemId = std::nullopt, int diff = 1, const QString& cat = "")
        : id(id), content(content), position(pos), poem_id(poemId), difficulty(diff), category(cat) {}
    
    // 获取字数
    int getCharCount() const {
        return content.length();
    }
    
    // 获取上句字数
    int getUpperCharCount() const {
        return upperSentence.length();
    }
    
    // 获取下句字数
    int getLowerCharCount() const {
        return lowerSentence.length();
    }
    
    // 是否为上下联题目
    bool isCouplet() const {
        return position == Position::Both && !upperSentence.isEmpty() && !lowerSentence.isEmpty();
    }
};
