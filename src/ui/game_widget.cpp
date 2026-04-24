#include "ui/game_widget.h"
#include <QMessageBox>
#include <QFrame>

GameWidget::GameWidget(GameController& controller, QWidget* parent)
    : QWidget(parent), m_controller(controller), m_currentRow(0)
{
    setupUI();
}

void GameWidget::setupUI() {
    QVBoxLayout* mainLayout = new QVBoxLayout(this);
    
    // 题目提示区域
    QFrame* hintFrame = new QFrame();
    hintFrame->setFrameStyle(QFrame::StyledPanel);
    QVBoxLayout* hintLayout = new QVBoxLayout(hintFrame);
    
    m_hintLabel = new QLabel("题目提示：");
    m_hintLabel->setStyleSheet("font-size: 16px; font-weight: bold;");
    m_questionLabel = new QLabel("上句：");
    m_questionLabel->setStyleSheet("font-size: 14px;");
    
    hintLayout->addWidget(m_hintLabel);
    hintLayout->addWidget(m_questionLabel);
    mainLayout->addWidget(hintFrame);
    
    // 猜测历史网格
    m_scrollArea = new QScrollArea();
    m_scrollArea->setWidgetResizable(true);
    m_scrollArea->setHorizontalScrollBarPolicy(Qt::ScrollBarAsNeeded);  // 允许横向滚动
    
    m_gridContainer = new QWidget();
    m_gridLayout = new QGridLayout(m_gridContainer);
    m_gridLayout->setSpacing(5);
    m_gridLayout->setAlignment(Qt::AlignTop | Qt::AlignHCenter);  // 居中对齐
    
    m_scrollArea->setWidget(m_gridContainer);
    mainLayout->addWidget(m_scrollArea, 1);
    
    // 输入区域
    QFrame* inputFrame = new QFrame();
    inputFrame->setFrameStyle(QFrame::StyledPanel);
    QHBoxLayout* inputLayout = new QHBoxLayout(inputFrame);
    
    QLabel* inputLabel = new QLabel("输入猜测：");
    m_inputEdit = new QLineEdit();
    m_inputEdit->setPlaceholderText("请输入诗句（无需标点）");
    m_submitButton = new QPushButton("猜测");
    
    inputLayout->addWidget(inputLabel);
    inputLayout->addWidget(m_inputEdit, 1);
    inputLayout->addWidget(m_submitButton);
    mainLayout->addWidget(inputFrame);
    
    // 剩余次数
    m_remainingLabel = new QLabel("剩余次数：20/20");
    m_remainingLabel->setStyleSheet("font-size: 14px; font-weight: bold;");
    mainLayout->addWidget(m_remainingLabel);
    
    // 连接信号槽
    connect(m_submitButton, &QPushButton::clicked, this, &GameWidget::onSubmitGuess);
    connect(m_inputEdit, &QLineEdit::returnPressed, this, &GameWidget::onSubmitGuess);
    connect(m_inputEdit, &QLineEdit::textChanged, this, &GameWidget::onInputTextChanged);
}

void GameWidget::displayQuestion(const Question& question) {
    m_currentQuestion = question;
    
    QString hint;
    if (question.isCouplet()) {
        // 上下联题目 - 显示上下句字数，但不显示谜底
        int total = question.getUpperCharCount() + question.getLowerCharCount();
        hint = QString("请猜上下联（共%1字，上句%2字+下句%3字）")
            .arg(total)
            .arg(question.getUpperCharCount())
            .arg(question.getLowerCharCount());
        m_questionLabel->setText("直接输入诗句即可，无需标点");  // 不显示谜底
    } else if (question.position == Position::Upper) {
        hint = QString("请猜上句（%1字）").arg(question.getCharCount());
        m_questionLabel->setText("请根据提示猜测诗句");
    } else {
        hint = QString("请猜下句（%1字）").arg(question.getCharCount());
        m_questionLabel->setText("请根据提示猜测诗句");
    }
    m_hintLabel->setText("题目提示：" + hint);
    m_hintLabel->setStyleSheet("font-size: 16px; font-weight: bold;");  // 重置样式
}

void GameWidget::displayFeedback(const Feedback& feedback, int guessNumber) {
    // 显示反馈结果
    if (feedback.isValid && !feedback.isCorrect) {
        addGuessRow(guessNumber, "", feedback.charFeedbacks);
    }
}

void GameWidget::onSubmitGuess() {
    QString guess = m_inputEdit->text().trimmed();
    if (guess.isEmpty()) {
        return;
    }
    
    Feedback feedback = m_controller.submitGuess(guess);
    
    if (!feedback.isValid) {
        QMessageBox::warning(this, "提示", feedback.message.value_or("无效输入"));
        return;
    }
    
    // 显示反馈
    addGuessRow(m_currentRow, guess, feedback.charFeedbacks);
    m_currentRow++;
    
    // 更新剩余次数
    const auto& state = m_controller.getCurrentState();
    m_remainingLabel->setText(QString("剩余次数：%1/%2")
        .arg(state.remainingAttempts).arg(state.maxAttempts));
    
    // 更新灰色提示
    updateGrayHints(m_controller.getGrayCharacters());
    
    // 检查游戏是否结束
    if (feedback.isCorrect) {
        // 猜对了：格子全绿，页面提示
        m_hintLabel->setText("🎉 恭喜你猜对了！");
        m_hintLabel->setStyleSheet("font-size: 18px; font-weight: bold; color: #6AAA64;");
        m_inputEdit->setEnabled(false);
        m_submitButton->setEnabled(false);
    } else if (m_controller.isGameOver()) {
        // 次数用尽：显示正确答案
        QString answer = m_currentQuestion.upperSentence + "，" + m_currentQuestion.lowerSentence;
        m_hintLabel->setText("游戏结束！正确答案：" + answer);
        m_hintLabel->setStyleSheet("font-size: 16px; font-weight: bold; color: #C9B458;");
        m_inputEdit->setEnabled(false);
        m_submitButton->setEnabled(false);
    }
    
    // 清空输入
    m_inputEdit->clear();
}

void GameWidget::addGuessRow(int row, const QString& guess, const QVector<CharFeedback>& feedbacks) {
    for (int col = 0; col < feedbacks.size(); ++col) {
        QLabel* charLabel = new QLabel(QString(feedbacks[col].character));
        charLabel->setAlignment(Qt::AlignCenter);
        charLabel->setFixedSize(40, 40);
        charLabel->setStyleSheet(getCharColorStyle(feedbacks[col].status));
        m_gridLayout->addWidget(charLabel, row, col);
    }
}

QString GameWidget::getCharColorStyle(FeedbackStatus status) {
    QString baseStyle = "font-size: 18px; font-weight: bold; color: white; border-radius: 5px;";
    
    switch (status) {
        case FeedbackStatus::Green:
            return baseStyle + "background-color: #6AAA64;";
        case FeedbackStatus::Yellow:
            return baseStyle + "background-color: #C9B458;";
        case FeedbackStatus::Gray:
            return baseStyle + "background-color: #787C7E;";
        default:
            return baseStyle + "background-color: #D3D6DA;";
    }
}

void GameWidget::updateGrayHints(const QSet<QChar>& grayChars) {
    // 不再显示灰色提示
}

void GameWidget::showGameOver(bool isWin, const QString& answer) {
    QString message;
    if (isWin) {
        message = "恭喜你猜对了！\n答案：" + answer;
    } else {
        message = "很遗憾，猜测次数用尽。\n正确答案：" + answer;
    }
    
    QMessageBox::information(this, "游戏结束", message);
}

void GameWidget::reset() {
    m_currentRow = 0;
    
    // 清空网格
    QLayoutItem* item;
    while ((item = m_gridLayout->takeAt(0)) != nullptr) {
        delete item->widget();
        delete item;
    }
    
    m_inputEdit->clear();
    m_inputEdit->setEnabled(true);  // 重新启用输入框
    m_submitButton->setEnabled(true);  // 重新启用按钮
    m_remainingLabel->setText("剩余次数：20/20");
}

void GameWidget::onInputTextChanged(const QString& text) {
    // 实时显示输入内容到当前行
    updateCurrentRowDisplay(text);
}

void GameWidget::updateCurrentRowDisplay(const QString& text) {
    // 获取目标字数
    int targetCount = 0;
    QString answer;
    if (m_currentQuestion.isCouplet()) {
        targetCount = m_currentQuestion.getUpperCharCount() + m_currentQuestion.getLowerCharCount();
        answer = m_currentQuestion.upperSentence + m_currentQuestion.lowerSentence;
    } else {
        targetCount = m_currentQuestion.getCharCount();
        answer = m_currentQuestion.content;
    }
    
    // 标准化输入（去除标点）- 使用简单方法
    QString normalized;
    for (const QChar& ch : text) {
        if (ch.script() == QChar::Script_Han) {  // 判断是否为汉字
            normalized += ch;
        }
    }
    
    // 清除当前行的显示
    for (int col = 0; col < targetCount; ++col) {
        QLayoutItem* item = m_gridLayout->itemAtPosition(m_currentRow, col);
        if (item && item->widget()) {
            delete item->widget();
        }
        m_gridLayout->takeAt(m_gridLayout->indexOf(item ? item->widget() : nullptr));
    }
    
    // 显示当前输入的字符
    QSet<QChar> grayChars = m_controller.getGrayCharacters();
    
    for (int col = 0; col < targetCount; ++col) {
        QLabel* charLabel = new QLabel();
        charLabel->setAlignment(Qt::AlignCenter);
        charLabel->setFixedSize(40, 40);  // 恢复原有大小
        
        if (col < normalized.length()) {
            QChar ch = normalized[col];
            charLabel->setText(QString(ch));
            
            // 如果是灰色字，且不在答案中，用特殊样式标记
            if (grayChars.contains(ch) && !answer.contains(ch)) {
                charLabel->setStyleSheet(getGrayCharStyle(ch));
            } else {
                charLabel->setStyleSheet("font-size: 18px; font-weight: bold; border: 2px solid #D3D6DA; border-radius: 5px;");
            }
        } else {
            charLabel->setText("");
            charLabel->setStyleSheet("font-size: 18px; border: 2px solid #D3D6DA; border-radius: 5px;");
        }
        
        m_gridLayout->addWidget(charLabel, m_currentRow, col);
    }
}

QString GameWidget::getGrayCharStyle(QChar ch) {
    // 灰色字用浅灰色背景，右下角三角形标记
    return "font-size: 18px; font-weight: bold; background-color: #D3D6DA; color: #787C7E; border-radius: 5px;";
}
