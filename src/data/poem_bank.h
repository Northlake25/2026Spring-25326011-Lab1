#pragma once
#include <QVector>
#include <QSet>
#include <QHash>
#include <QJsonArray>
#include <QJsonObject>
#include <optional>
#include "models/poem.h"
#include "data/file_storage.h"

class PoemBank {
public:
    explicit PoemBank(FileStorage& storage) : m_storage(storage) {}
    
    // 加载诗词库数据
    bool load() {
        try {
            QJsonDocument doc = m_storage.readJson("poems.json");
            if (doc.isNull() || !doc.isObject()) {
                return false;
            }
            
            QJsonObject root = doc.object();
            QJsonArray poemsArray = root["poems"].toArray();
            
            m_poems.clear();
            for (const auto& item : poemsArray) {
                QJsonObject obj = item.toObject();
                Poem p;
                p.id = obj["id"].toString();
                p.title = obj["title"].toString();
                p.author = obj["author"].toString();
                p.dynasty = obj["dynasty"].toString();
                
                // 加载诗句
                QJsonArray versesArray = obj["verses"].toArray();
                for (const auto& v : versesArray) {
                    p.verses.append(v.toString());
                }
                
                // 加载标点
                QJsonArray punctsArray = obj["punctuations"].toArray();
                for (const auto& punct : punctsArray) {
                    QString pstr = punct.toString();
                    if (!pstr.isEmpty()) {
                        p.punctuations.append(pstr[0]);
                    }
                }
                
                // 加载特殊联组合
                QJsonArray specialArray = obj["specialCouplets"].toArray();
                for (const auto& couplet : specialArray) {
                    QJsonObject coupletObj = couplet.toObject();
                    int upperIdx = coupletObj["upper"].toInt();
                    int lowerIdx = coupletObj["lower"].toInt();
                    p.specialCouplets.insert(qMakePair(upperIdx, lowerIdx));
                }
                
                m_poems.append(p);
            }
            
            // 构建索引
            buildIndex();
            
            return true;
        } catch (...) {
            return false;
        }
    }
    
    // 保存诗词库数据
    bool save() {
        QJsonArray poemsArray;
        for (const auto& p : m_poems) {
            QJsonObject obj;
            obj["id"] = p.id;
            obj["title"] = p.title;
            obj["author"] = p.author;
            obj["dynasty"] = p.dynasty;
            
            QJsonArray versesArray;
            for (const auto& v : p.verses) {
                versesArray.append(v);
            }
            obj["verses"] = versesArray;
            
            QJsonArray punctsArray;
            for (const auto& punct : p.punctuations) {
                punctsArray.append(QString(punct));
            }
            obj["punctuations"] = punctsArray;
            
            QJsonArray specialArray;
            for (const auto& couplet : p.specialCouplets) {
                QJsonObject coupletObj;
                coupletObj["upper"] = couplet.first;
                coupletObj["lower"] = couplet.second;
                specialArray.append(coupletObj);
            }
            obj["specialCouplets"] = specialArray;
            
            poemsArray.append(obj);
        }
        
        QJsonObject root;
        root["version"] = "1.0";
        root["poems"] = poemsArray;
        
        return m_storage.writeJson("poems.json", QJsonDocument(root));
    }
    
    // 添加诗词
    bool addPoem(const Poem& poem) {
        // 检查ID是否重复
        for (const auto& p : m_poems) {
            if (p.id == poem.id) {
                return false;
            }
        }
        m_poems.append(poem);
        buildIndex();  // 重建索引
        return true;
    }
    
    // 删除诗词
    bool removePoem(const QString& poemId) {
        for (int i = 0; i < m_poems.size(); ++i) {
            if (m_poems[i].id == poemId) {
                m_poems.remove(i);
                buildIndex();  // 重建索引
                return true;
            }
        }
        return false;
    }
    
    // 检查诗句是否在诗词库中
    bool containsSentence(const QString& sentence) const {
        return m_sentenceIndex.contains(sentence);
    }
    
    // 根据ID获取诗词
    std::optional<Poem> getPoemById(const QString& poemId) const {
        for (const auto& p : m_poems) {
            if (p.id == poemId) {
                return p;
            }
        }
        return std::nullopt;
    }
    
    // 获取所有诗词
    QVector<Poem> getAllPoems() const {
        return m_poems;
    }
    
    // 诗词库是否为空
    bool isEmpty() const {
        return m_poems.isEmpty();
    }
    
    // 构建句子索引（性能优化）
    void buildIndex() {
        m_sentenceIndex.clear();
        for (const auto& poem : m_poems) {
            for (const auto& sentence : poem.getAllSentences()) {
                m_sentenceIndex[sentence].insert(poem.id);
            }
        }
    }
    
private:
    FileStorage& m_storage;
    QVector<Poem> m_poems;
    QHash<QString, QSet<QString>> m_sentenceIndex;  // 句子 -> 诗词ID集合
};
