#pragma once
#include <QWidget>
#include <QVBoxLayout>
#include <QHBoxLayout>
#include <QLabel>
#include <QLineEdit>
#include <QPushButton>
#include <QGridLayout>
#include <QScrollArea>
#include "logic/game_controller.h"
#include "models/question.h"
#include "models/feedback.h"

class GameWidget : public QWidget {
    Q_OBJECT
    
public:
    explicit GameWidget(GameController& controller, QWidget* parent = nullptr);
    
public slots:
    void displayQuestion(const Question& question);
    void displayFeedback(const Feedback& feedback, int guessNumber);
    void updateGrayHints(const QSet<QChar>& grayChars);
    void showGameOver(bool isWin, const QString& answer);
    void reset();
    
private slots:
    void onSubmitGuess();
    void onInputTextChanged(const QString& text);
    
private:
    void setupUI();
    void addGuessRow(int row, const QString& guess, const QVector<CharFeedback>& feedbacks);
    void updateCurrentRowDisplay(const QString& text);
    QString getCharColorStyle(FeedbackStatus status);
    QString getGrayCharStyle(QChar ch);
    
    GameController& m_controller;
    
    // UI组件
    QLabel* m_hintLabel;
    QLabel* m_questionLabel;
    QLineEdit* m_inputEdit;
    QPushButton* m_submitButton;
    QLabel* m_remainingLabel;
    QScrollArea* m_scrollArea;
    QWidget* m_gridContainer;
    QGridLayout* m_gridLayout;
    
    // 当前题目
    Question m_currentQuestion;
    int m_currentRow;
};
