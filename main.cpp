#include <QApplication>
#include <QFile>
#include <QTextStream>
#include "ui/main_window.h"

int main(int argc, char *argv[]) {
    // Qt6默认启用高DPI支持，无需手动设置
    
    QApplication app(argc, argv);
    
    // 加载样式表
    QFile styleFile(":/styles.qss");
    if (styleFile.open(QFile::ReadOnly | QFile::Text)) {
        QTextStream stream(&styleFile);
        app.setStyleSheet(stream.readAll());
        styleFile.close();
    }
    
    // 创建主窗口
    MainWindow mainWindow;
    mainWindow.setWindowTitle("猜诗词游戏");
    mainWindow.resize(800, 600);
    mainWindow.show();
    
    return app.exec();
}
