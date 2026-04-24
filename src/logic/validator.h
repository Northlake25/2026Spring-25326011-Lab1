#pragma once
#include <QString>
#include <QRegularExpression>
#include <QVector>

class Validator {
public:
    // 标准化文本（去除标点、空格等）
    static QString normalizeText(const QString& text) {
        QString result;
        for (const QChar& ch : text) {
            if (ch.script() == QChar::Script_Han) {  // 判断是否为汉字
                result += ch;
            }
        }
        return result;
    }
    
    // 分割诗句（按标点分割成多个句子）
    static QVector<QString> splitSentences(const QString& text) {
        QVector<QString> sentences;
        
        // 按中文标点分割
        QRegularExpression re("[，。、；：！？,.;:!?]");
        QStringList parts = text.split(re, Qt::SkipEmptyParts);
        
        for (const QString& part : parts) {
            QString trimmed = part.trimmed();
            if (!trimmed.isEmpty()) {
                sentences.append(trimmed);
            }
        }
        
        return sentences;
    }
    
    // 验证字数是否正确（支持上下联）
    static bool validateCharCount(const QString& text, int targetCount) {
        QString normalized = normalizeText(text);
        return normalized.length() == targetCount;
    }
    
    // 验证上下联字数
    static bool validateCoupletCharCount(const QString& text, int upperCount, int lowerCount) {
        QVector<QString> sentences = splitSentences(text);
        
        if (sentences.size() != 2) {
            return false;
        }
        
        QString upperNorm = normalizeText(sentences[0]);
        QString lowerNorm = normalizeText(sentences[1]);
        
        return upperNorm.length() == upperCount && lowerNorm.length() == lowerCount;
    }
    
    // 验证是否为有效诗句（仅包含汉字和标点）
    static bool isValidPoetry(const QString& text) {
        QString normalized = normalizeText(text);
        return !normalized.isEmpty();
    }
};
