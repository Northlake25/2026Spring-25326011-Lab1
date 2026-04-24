#pragma once
#include <QVector>
#include <QJsonArray>
#include <QJsonObject>
#include <QRandomGenerator>
#include <optional>
#include "models/question.h"
#include "data/file_storage.h"

class QuestionBank {
public:
    explicit QuestionBank(FileStorage& storage) : m_storage(storage) {}
    
    // 加载题库数据
    bool load() {
        try {
            QJsonDocument doc = m_storage.readJson("questions.json");
            if (doc.isNull() || !doc.isObject()) {
                return false;
            }
            
            QJsonObject root = doc.object();
            QJsonArray questionsArray = root["questions"].toArray();
            
            m_questions.clear();
            for (const auto& item : questionsArray) {
                QJsonObject obj = item.toObject();
                Question q;
                q.id = obj["id"].toString();
                q.content = obj["content"].toString();
                
                // 处理position字段
                QString posStr = obj["position"].toString();
                if (posStr == "upper") {
                    q.position = Position::Upper;
                } else if (posStr == "lower") {
                    q.position = Position::Lower;
                } else {
                    q.position = Position::Both;
                }
                
                // 处理上下句字段
                if (obj.contains("upperSentence")) {
                    q.upperSentence = obj["upperSentence"].toString();
                }
                if (obj.contains("lowerSentence")) {
                    q.lowerSentence = obj["lowerSentence"].toString();
                }
                
                if (obj.contains("poem_id") && !obj["poem_id"].isNull()) {
                    q.poem_id = obj["poem_id"].toString();
                }
                q.difficulty = obj["difficulty"].toInt(1);
                q.category = obj["category"].toString();
                m_questions.append(q);
            }
            
            return true;
        } catch (...) {
            return false;
        }
    }
    
    // 保存题库数据
    bool save() {
        QJsonArray questionsArray;
        for (const auto& q : m_questions) {
            QJsonObject obj;
            obj["id"] = q.id;
            obj["content"] = q.content;
            
            // 保存position字段
            if (q.position == Position::Upper) {
                obj["position"] = "upper";
            } else if (q.position == Position::Lower) {
                obj["position"] = "lower";
            } else {
                obj["position"] = "both";
            }
            
            // 保存上下句字段
            if (!q.upperSentence.isEmpty()) {
                obj["upperSentence"] = q.upperSentence;
            }
            if (!q.lowerSentence.isEmpty()) {
                obj["lowerSentence"] = q.lowerSentence;
            }
            
            if (q.poem_id.has_value()) {
                obj["poem_id"] = *q.poem_id;
            } else {
                obj["poem_id"] = QJsonValue::Null;
            }
            obj["difficulty"] = q.difficulty;
            obj["category"] = q.category;
            questionsArray.append(obj);
        }
        
        QJsonObject root;
        root["version"] = "1.0";
        root["questions"] = questionsArray;
        
        return m_storage.writeJson("questions.json", QJsonDocument(root));
    }
    
    // 添加题目
    bool addQuestion(const Question& question) {
        for (const auto& q : m_questions) {
            if (q.id == question.id) {
                return false;
            }
        }
        m_questions.append(question);
        return true;
    }
    
    // 删除题目
    bool removeQuestion(const QString& questionId) {
        for (int i = 0; i < m_questions.size(); ++i) {
            if (m_questions[i].id == questionId) {
                m_questions.remove(i);
                return true;
            }
        }
        return false;
    }
    
    // 随机获取题目
    std::optional<Question> getRandomQuestion(std::optional<int> difficulty = std::nullopt) {
        QVector<Question> candidates;
        for (const auto& q : m_questions) {
            if (!difficulty.has_value() || q.difficulty == *difficulty) {
                candidates.append(q);
            }
        }
        
        if (candidates.isEmpty()) {
            return std::nullopt;
        }
        
        int index = QRandomGenerator::global()->bounded(candidates.size());
        return candidates[index];
    }
    
    // 根据分类获取随机题目
    std::optional<Question> getRandomQuestionByCategories(const QSet<QString>& categories) {
        if (categories.isEmpty()) {
            return getRandomQuestion();
        }
        
        QVector<Question> candidates;
        for (const auto& q : m_questions) {
            if (categories.contains(q.category)) {
                candidates.append(q);
            }
        }
        
        if (candidates.isEmpty()) {
            return std::nullopt;
        }
        
        int index = QRandomGenerator::global()->bounded(candidates.size());
        return candidates[index];
    }
    
    // 获取所有分类
    QSet<QString> getAllCategories() const {
        QSet<QString> categories;
        for (const auto& q : m_questions) {
            if (!q.category.isEmpty()) {
                categories.insert(q.category);
            }
        }
        return categories;
    }
    
    // 获取所有题目
    QVector<Question> getAllQuestions() const {
        return m_questions;
    }
    
    // 检查是否为空
    bool isEmpty() const {
        return m_questions.isEmpty();
    }
    
private:
    FileStorage& m_storage;
    QVector<Question> m_questions;
};
