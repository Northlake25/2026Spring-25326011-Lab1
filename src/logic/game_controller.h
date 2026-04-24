#pragma once
#include <optional>
#include "models/game_state.h"
#include "data/question_bank.h"
#include "data/poem_bank.h"
#include "logic/feedback_processor.h"

class GameController {
public:
    GameController(QuestionBank& questionBank, PoemBank& poemBank)
        : m_questionBank(questionBank), m_poemBank(poemBank) {}
    
    // 开始新游戏
    std::optional<GameState> startNewGame(std::optional<int> difficulty = std::nullopt) {
        auto question = m_questionBank.getRandomQuestion(difficulty);
        if (!question.has_value()) {
            return std::nullopt;
        }
        
        m_gameState.reset(*question);
        return m_gameState;
    }
    
    // 根据分类开始新游戏
    std::optional<GameState> startNewGameByCategories(const QSet<QString>& categories) {
        auto question = m_questionBank.getRandomQuestionByCategories(categories);
        if (!question.has_value()) {
            return std::nullopt;
        }
        
        m_gameState.reset(*question);
        return m_gameState;
    }
    
    // 提交猜测
    Feedback submitGuess(const QString& guess) {
        if (!m_gameState.canGuess()) {
            return Feedback::invalid("游戏已结束");
        }
        
        const Question& question = m_gameState.currentQuestion;
        
        Feedback feedback = FeedbackProcessor::generateFeedback(
            guess, 
            question.content, 
            m_poemBank,
            question.isCouplet(),
            question.upperSentence,
            question.lowerSentence
        );
        
        if (feedback.isValid) {
            m_gameState.addGuess(guess, feedback);
        }
        
        return feedback;
    }
    
    // 获取当前游戏状态
    const GameState& getCurrentState() const {
        return m_gameState;
    }
    
    // 获取已确认不存在的字
    QSet<QChar> getGrayCharacters() const {
        return m_gameState.grayCharacters;
    }
    
    // 游戏是否结束
    bool isGameOver() const {
        return m_gameState.status != GameStatus::InProgress;
    }
    
private:
    QuestionBank& m_questionBank;
    PoemBank& m_poemBank;
    GameState m_gameState;
};
