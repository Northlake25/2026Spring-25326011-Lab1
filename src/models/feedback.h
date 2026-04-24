#pragma once
#include <QString>
#include <QVector>
#include <optional>

enum class FeedbackStatus { Green, Yellow, Gray };

struct CharFeedback {
    QChar character;              // 字符
    FeedbackStatus status;        // 状态
    int position;                 // 位置索引
    
    CharFeedback() = default;
    CharFeedback(QChar ch, FeedbackStatus stat, int pos)
        : character(ch), status(stat), position(pos) {}
};

struct Feedback {
    bool isValid = false;         // 是否有效猜测
    bool isCorrect = false;       // 是否正确
    QVector<CharFeedback> charFeedbacks;  // 各字符反馈
    std::optional<QString> message;       // 提示消息
    
    Feedback() = default;
    
    static Feedback invalid(const QString& msg) {
        Feedback fb;
        fb.isValid = false;
        fb.message = msg;
        return fb;
    }
    
    static Feedback correct() {
        Feedback fb;
        fb.isValid = true;
        fb.isCorrect = true;
        return fb;
    }
    
    static Feedback partial(const QVector<CharFeedback>& feedbacks) {
        Feedback fb;
        fb.isValid = true;
        fb.isCorrect = false;
        fb.charFeedbacks = feedbacks;
        return fb;
    }
};
