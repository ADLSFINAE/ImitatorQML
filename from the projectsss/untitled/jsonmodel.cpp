#include "jsonmodel.h"
#include <QFile>
#include <QDebug>

JsonParserModel::JsonParserModel(QObject *parent)
    : QObject(parent)
{
}

bool JsonParserModel::loadJson(const QString &jsonString)
{
    QJsonDocument document = QJsonDocument::fromJson(jsonString.toUtf8());
    return parseJson(document);
}

bool JsonParserModel::loadJsonFromFile(const QString &filePath)
{
    QFile file(filePath);
    if (!file.open(QIODevice::ReadOnly)) {
        qWarning() << "Could not open file:" << filePath;
        return false;
    }

    QByteArray jsonData = file.readAll();
    QJsonDocument document = QJsonDocument::fromJson(jsonData);
    return parseJson(document);
}

bool JsonParserModel::parseJson(const QJsonDocument &document)
{
    if (document.isNull()) {
        qWarning() << "Invalid JSON format";
        return false;
    }

    m_items.clear();

    if (document.isObject()) {
        // Один объект - одна страница
        QJsonObject rootObj = document.object();
        m_pageName = rootObj.value("pageName").toString();

        QJsonArray itemsArray = rootObj.value("items").toArray();
        for (const QJsonValue &itemValue : itemsArray) {
            QJsonObject itemObj = itemValue.toObject();

            QVariantMap itemMap;
            itemMap["name"] = itemObj.value("name").toString();
            itemMap["text"] = itemObj.value("text").toString();
            itemMap["color"] = itemObj.value("color").toString();

            m_items.append(itemMap);
        }
    } else if (document.isArray()) {
        // Массив - несколько страниц (берем первую)
        QJsonArray pagesArray = document.array();
        if (!pagesArray.isEmpty()) {
            QJsonObject pageObj = pagesArray.first().toObject();
            m_pageName = pageObj.value("pageName").toString();

            QJsonArray itemsArray = pageObj.value("items").toArray();
            for (const QJsonValue &itemValue : itemsArray) {
                QJsonObject itemObj = itemValue.toObject();

                QVariantMap itemMap;
                itemMap["name"] = itemObj.value("name").toString();
                itemMap["text"] = itemObj.value("text").toString();
                itemMap["color"] = itemObj.value("color").toString();

                m_items.append(itemMap);
            }
        }
    }

    qDebug() << "Parsed" << m_items.count() << "items for page:" << m_pageName;
    emit dataLoaded();
    return true;
}
