cmake_minimum_required(VERSION 3.16)
project(guess_poetry_game VERSION 1.0 LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_AUTOMOC ON)
set(CMAKE_AUTORCC ON)
set(CMAKE_AUTOUIC ON)

# 设置Qt的AUTOMOC相关策略
set(CMAKE_POLICY_DEFAULT_CMP0100 NEW)

# 设置MOC预定义头文件
set(CMAKE_AUTOMOC_COMPILER_PREDEFINES OFF)
set(CMAKE_AUTOMOC ON)
set(CMAKE_AUTORCC ON)
set(CMAKE_AUTOUIC ON)

# 设置Qt的AUTOMOC相关策略
if(POLICY CMP0100)
    cmake_policy(SET CMP0100 NEW)
endif()

# 查找Qt6
find_package(Qt6 REQUIRED COMPONENTS Core Widgets)

# 添加源文件
set(SOURCES
    main.cpp
    src/models/question.cpp
    src/models/question.h
    src/models/poem.cpp
    src/models/poem.h
    src/models/feedback.cpp
    src/models/feedback.h
    src/models/game_state.cpp
    src/models/game_state.h
    src/data/file_storage.cpp
    src/data/file_storage.h
    src/data/question_bank.cpp
    src/data/question_bank.h
    src/data/poem_bank.cpp
    src/data/poem_bank.h
    src/logic/validator.cpp
    src/logic/validator.h
    src/logic/feedback_processor.cpp
    src/logic/feedback_processor.h
    src/logic/game_controller.cpp
    src/logic/game_controller.h
    src/ui/main_window.cpp
    src/ui/main_window.h
    src/ui/game_widget.cpp
    src/ui/game_widget.h
    src/ui/admin_widget.cpp
    src/ui/admin_widget.h
    resources.qrc
)

# 添加可执行文件
add_executable(${PROJECT_NAME} ${SOURCES})

# 链接Qt库
target_link_libraries(${PROJECT_NAME} PRIVATE Qt6::Core Qt6::Widgets)

# 包含目录
target_include_directories(${PROJECT_NAME} PRIVATE
    ${CMAKE_CURRENT_SOURCE_DIR}/src
    ${CMAKE_CURRENT_SOURCE_DIR}/third_party
)

# 设置输出目录
set_target_properties(${PROJECT_NAME} PROPERTIES
    RUNTIME_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/bin
)
