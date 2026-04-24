#pragma once
#include <QSet>
#include <QVector>
#include "models/question.h"
#include "models/feedback.h"

enum class GameStatus { InProgress, Success, Failed };

struct GuessRecord {
    QString guess;
    Feedback feedback;
    
    GuessRecord() = default;
    GuessRecord(const QString& g, const Feedback& fb) : guess(g), feedback(fb) {}
};

class GameState {
public:
    Question currentQuestion;
    int maxAttempts = 20;
    int remainingAttempts = 20;
    QVector<GuessRecord> guessHistory;
    GameStatus status = GameStatus::InProgress;
    QSet<QChar> grayCharacters;
    
    GameState() = default;
    
    // 是否还能继续猜测
    bool canGuess() const {
        return remainingAttempts > 0 && status == GameStatus::InProgress;
    }
    
    // 添加猜测记录
    void addGuess(const QString& guess, const Feedback& feedback) {
        guessHistory.append(GuessRecord(guess, feedback));
        remainingAttempts--;
        
        // 更新灰色字符集合
        for (const auto& cf : feedback.charFeedbacks) {
            if (cf.status == FeedbackStatus::Gray) {
                grayCharacters.insert(cf.character);
            }
        }
        
        // 更新游戏状态
        if (feedback.isCorrect) {
            status = GameStatus::Success;
        } else if (remainingAttempts == 0) {
            status = GameStatus::Failed;
        }
    }
    
    // 重置游戏状态
    void reset(const Question& question) {
        currentQuestion = question;
        remainingAttempts = maxAttempts;
        guessHistory.clear();
        grayCharacters.clear();
        status = GameStatus::InProgress;
    }
};
