#pragma once
#include <QHash>
#include "models/feedback.h"
#include "logic/validator.h"
#include "data/poem_bank.h"

class FeedbackProcessor {
public:
    // 生成反馈结果（支持上下联）
    static Feedback generateFeedback(const QString& guess, 
                                     const QString& answer, 
                                     const PoemBank& poemBank,
                                     bool isCouplet = false,
                                     const QString& upperAnswer = "",
                                     const QString& lowerAnswer = "") {
        // 标准化文本
        QString guessNorm = Validator::normalizeText(guess);
        QString answerNorm = Validator::normalizeText(answer);
        int targetCount = answerNorm.length();
        
        // 如果是上下联题目
        if (isCouplet && !upperAnswer.isEmpty() && !lowerAnswer.isEmpty()) {
            return generateCoupletFeedback(guess, upperAnswer, lowerAnswer, poemBank);
        }
        
        // 验证猜测有效性
        if (guessNorm.length() != targetCount) {
            return Feedback::invalid("请输入一句字数正确的古诗词");
        }
        
        // 检查是否在诗词库中（支持带标点的输入）
        if (!isInPoemBank(guess, poemBank)) {
            return Feedback::invalid("请输入一句字数正确的古诗词");
        }
        
        // 检查完全匹配
        if (guessNorm == answerNorm) {
            return Feedback::correct();
        }
        
        // 生成字符级反馈（Wordle算法）
        return generateWordleFeedback(guessNorm, answerNorm);
    }
    
private:
    // 检查输入是否在诗词库中（支持带标点）
    static bool isInPoemBank(const QString& input, const PoemBank& poemBank) {
        // 分割输入为多个句子
        QVector<QString> sentences = Validator::splitSentences(input);
        
        // 如果没有分割出句子，检查整个标准化后的文本
        if (sentences.isEmpty()) {
            QString normalized = Validator::normalizeText(input);
            return poemBank.containsSentence(normalized);
        }
        
        // 检查每个句子是否都在诗词库中
        for (const QString& sentence : sentences) {
            QString normalized = Validator::normalizeText(sentence);
            if (!normalized.isEmpty() && !poemBank.containsSentence(normalized)) {
                return false;
            }
        }
        
        return true;
    }
    
    // 生成上下联反馈
    static Feedback generateCoupletFeedback(const QString& guess,
                                           const QString& upperAnswer,
                                           const QString& lowerAnswer,
                                           const PoemBank& poemBank) {
        // 标准化输入（去除标点）
        QString normalized = Validator::normalizeText(guess);
        QString upperNorm = Validator::normalizeText(upperAnswer);
        QString lowerNorm = Validator::normalizeText(lowerAnswer);
        
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
        
        // 检查是否在诗词库中
        if (!poemBank.containsSentence(upperGuess) || !poemBank.containsSentence(lowerGuess)) {
            return Feedback::invalid("请输入一句字数正确的古诗词");
        }
        
        // 检查完全匹配
        if (upperGuess == upperNorm && lowerGuess == lowerNorm) {
            return Feedback::correct();
        }
        
        // 合并答案和猜测为完整字符串，一起处理
        QString fullAnswer = upperNorm + lowerNorm;
        QString fullGuess = upperGuess + lowerGuess;
        
        // 生成整联的反馈（上下句一起处理）
        QVector<CharFeedback> allFeedbacks = generateWordleFeedbackVector(fullGuess, fullAnswer);
        
        return Feedback::partial(allFeedbacks);
    }
    
    // 生成Wordle反馈
    static Feedback generateWordleFeedback(const QString& guess, const QString& answer) {
        QVector<CharFeedback> feedbacks = generateWordleFeedbackVector(guess, answer);
        return Feedback::partial(feedbacks);
    }
    
    // 生成Wordle反馈向量
    static QVector<CharFeedback> generateWordleFeedbackVector(const QString& guess, const QString& answer) {
        QVector<CharFeedback> feedbacks;
        int count = answer.length();
        feedbacks.resize(count);
        
        // 统计答案中每个字符的出现次数
        QHash<QChar, int> answerCounter;
        for (const QChar& ch : answer) {
            answerCounter[ch]++;
        }
        
        // 第一遍扫描：标记绿色（位置正确）
        for (int i = 0; i < count; ++i) {
            if (guess[i] == answer[i]) {
                feedbacks[i] = CharFeedback(guess[i], FeedbackStatus::Green, i);
                answerCounter[guess[i]]--;
            }
        }
        
        // 第二遍扫描：标记黄色和灰色
        for (int i = 0; i < count; ++i) {
            if (feedbacks[i].character.isNull()) {  // 未标记
                QChar ch = guess[i];
                if (answerCounter.contains(ch) && answerCounter[ch] > 0) {
                    feedbacks[i] = CharFeedback(ch, FeedbackStatus::Yellow, i);
                    answerCounter[ch]--;
                } else {
                    feedbacks[i] = CharFeedback(ch, FeedbackStatus::Gray, i);
                }
            }
        }
        
        return feedbacks;
    }
};
