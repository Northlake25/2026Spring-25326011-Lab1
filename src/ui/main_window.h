#pragma once
#include <QMainWindow>
#include <QStackedWidget>
#include <QMenuBar>
#include <QMenu>
#include <QAction>
#include "ui/game_widget.h"
#include "ui/admin_widget.h"
#include "logic/game_controller.h"
#include "data/question_bank.h"
#include "data/poem_bank.h"
#include "data/file_storage.h"

class MainWindow : public QMainWindow {
    Q_OBJECT
    
public:
    explicit MainWindow(QWidget* parent = nullptr);
    ~MainWindow() = default;
    
private slots:
    void showGame();
    void showAdmin();
    void startNewGame();
    
private:
    void setupMenuBar();
    void loadData();
    
    // 数据存储
    FileStorage* m_storage;
    QuestionBank* m_questionBank;
    PoemBank* m_poemBank;
    
    // 游戏控制器
    GameController* m_gameController;
    
    // UI组件
    QStackedWidget* m_stackedWidget;
    GameWidget* m_gameWidget;
    AdminWidget* m_adminWidget;
};
