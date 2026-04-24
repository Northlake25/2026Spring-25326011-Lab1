QT += core widgets

# 使用C++17标准
CONFIG += c++17
QMAKE_CXXFLAGS += -std=c++17

TARGET = guess_poetry_game
TEMPLATE = app

# 源文件
SOURCES += \
    main.cpp \
    src/models/question.cpp \
    src/models/poem.cpp \
    src/models/feedback.cpp \
    src/models/game_state.cpp \
    src/data/file_storage.cpp \
    src/data/question_bank.cpp \
    src/data/poem_bank.cpp \
    src/logic/validator.cpp \
    src/logic/feedback_processor.cpp \
    src/logic/game_controller.cpp \
    src/ui/main_window.cpp \
    src/ui/game_widget.cpp \
    src/ui/admin_widget.cpp

# 头文件
HEADERS += \
    src/models/question.h \
    src/models/poem.h \
    src/models/feedback.h \
    src/models/game_state.h \
    src/data/file_storage.h \
    src/data/question_bank.h \
    src/data/poem_bank.h \
    src/logic/validator.h \
    src/logic/feedback_processor.h \
    src/logic/game_controller.h \
    src/ui/main_window.h \
    src/ui/game_widget.h \
    src/ui/admin_widget.h

# 资源文件
RESOURCES += resources.qrc

# 包含路径
INCLUDEPATH += src third_party

# 输出目录
DESTDIR = bin
