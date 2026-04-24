#pragma once
#include <QString>
#include <QVector>
#include <QSet>
#include <QPair>

struct Poem {
    QString id;                      // 唯一标识
    QString title;                   // 诗词标题
    QString author;                  // 作者姓名
    QString dynasty;                 // 朝代
    QVector<QString> verses;         // 完整诗句列表
    QVector<QChar> punctuations;     // 句间标点列表（逗号/句号）
    QSet<QPair<int, int>> specialCouplets;  // 特殊联组合（上句索引, 下句索引）
    
    Poem() = default;
    
    Poem(const QString& id, const QString& title, const QString& author, 
         const QString& dynasty, const QVector<QString>& verses,
         const QVector<QChar>& punctuations = {}, const QSet<QPair<int, int>>& special = {})
        : id(id), title(title), author(author), dynasty(dynasty), 
          verses(verses), punctuations(punctuations), specialCouplets(special) {}
    
    // 获取所有句子（不含标点）
    QVector<QString> getAllSentences() const {
        return verses;
    }
    
    // 检查是否包含某句诗
    bool containsSentence(const QString& sentence) const {
        return verses.contains(sentence);
    }
    
    // 获取所有可能的联组合（标准+特殊）
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
    
    // 检查某个联组合是否有效
    bool isValidCouplet(int upperIndex, int lowerIndex) const {
        // 检查索引范围
        if (upperIndex < 0 || upperIndex >= verses.size() ||
            lowerIndex < 0 || lowerIndex >= verses.size() ||
            upperIndex >= lowerIndex) {
            return false;
        }
        
        // 检查是否是标准联
        if (lowerIndex == upperIndex + 1 && (upperIndex % 2 == 0)) {
            return true;
        }
        
        // 检查是否是特殊联
        return specialCouplets.contains(qMakePair(upperIndex, lowerIndex));
    }
};
