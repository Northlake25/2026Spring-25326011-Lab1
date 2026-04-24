#pragma once
#include <QString>
#include <QFile>
#include <QJsonDocument>
#include <QJsonObject>
#include <QJsonArray>
#include <QTextStream>
#include <stdexcept>

class FileStorage {
public:
    explicit FileStorage(const QString& basePath) : m_basePath(basePath) {}
    
    // 读取JSON文件
    QJsonDocument readJson(const QString& filename) const {
        QString fullPath = m_basePath + "/" + filename;
        QFile file(fullPath);
        
        if (!file.exists()) {
            return QJsonDocument();  // 返回空文档
        }
        
        if (!file.open(QIODevice::ReadOnly | QIODevice::Text)) {
            throw std::runtime_error("无法打开文件: " + fullPath.toStdString());
        }
        
        QTextStream in(&file);
        in.setEncoding(QStringConverter::Utf8);
        QString content = in.readAll();
        file.close();
        
        QJsonParseError error;
        QJsonDocument doc = QJsonDocument::fromJson(content.toUtf8(), &error);
        
        if (error.error != QJsonParseError::NoError) {
            throw std::runtime_error("JSON解析错误: " + error.errorString().toStdString());
        }
        
        return doc;
    }
    
    // 写入JSON文件
    bool writeJson(const QString& filename, const QJsonDocument& doc) const {
        QString fullPath = m_basePath + "/" + filename;
        QFile file(fullPath);
        
        if (!file.open(QIODevice::WriteOnly | QIODevice::Text)) {
            throw std::runtime_error("无法写入文件: " + fullPath.toStdString());
        }
        
        QTextStream out(&file);
        out.setEncoding(QStringConverter::Utf8);
        out << doc.toJson(QJsonDocument::Indented);
        file.close();
        
        return true;
    }
    
    // 检查文件是否存在
    bool exists(const QString& filename) const {
        QString fullPath = m_basePath + "/" + filename;
        return QFile::exists(fullPath);
    }
    
private:
    QString m_basePath;
};
