#pragma once
#include <QWidget>
#include <QVBoxLayout>
#include <QTabWidget>
#include <QListWidget>
#include <QPushButton>
#include <QLineEdit>
#include <QTextEdit>
#include <QLabel>
#include <QComboBox>
#include <QCheckBox>
#include "data/question_bank.h"
#include "data/poem_bank.h"

class AdminWidget : public QWidget {
    Q_OBJECT
    
public:
    explicit AdminWidget(QuestionBank& questionBank, PoemBank& poemBank, QWidget* parent = nullptr);
    
private slots:
    void onAddQuestion();
    void onRemoveQuestion();
    void onAddPoem();
    void onRemovePoem();
    void onQuestionSelectionChanged();
    void onPoemSelectionChanged();
    void onPoemDoubleClicked(QListWidgetItem* item);
    void onExportData();
    void onImportData();
    
private:
    void setupUI();
    void refreshQuestionList();
    void refreshPoemList();
    void refreshCategoryList();
    
    QuestionBank& m_questionBank;
    PoemBank& m_poemBank;
    
    // 题库管理UI
    QListWidget* m_questionList;
    QLineEdit* m_questionContentEdit;
    QLineEdit* m_questionDifficultyEdit;
    QLineEdit* m_questionCategoryEdit;      // 分类输入
    QListWidget* m_categoryList;            // 分类列表
    QVector<QCheckBox*> m_categoryCheckBoxes;  // 分类勾选框
    
    // 诗词库管理UI
    QListWidget* m_poemList;
    QLineEdit* m_poemTitleEdit;
    QLineEdit* m_poemAuthorEdit;
    QLineEdit* m_poemDynastyEdit;
    QTextEdit* m_poemVersesEdit;
    QLineEdit* m_poemPunctsEdit;
    QLineEdit* m_poemAllowedEdit;
};
