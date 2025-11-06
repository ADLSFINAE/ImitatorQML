#ifndef JSONPARSERMODEL_H
#define JSONPARSERMODEL_H

#include <QObject>
#include <QJsonDocument>
#include <QJsonArray>
#include <QJsonObject>
#include <QVariant>

class JsonParserModel : public QObject
{
    Q_OBJECT

public:
    explicit JsonParserModel(QObject *parent = nullptr);

    Q_INVOKABLE bool loadJson(const QString &jsonString);
    Q_INVOKABLE bool loadJsonFromFile(const QString &filePath);

    Q_INVOKABLE QVariantList getItems() const { return m_items; }
    Q_INVOKABLE QString getPageName() const { return m_pageName; }

signals:
    void dataLoaded();

private:
    bool parseJson(const QJsonDocument &document);
    QVariantList m_items;
    QString m_pageName;
};

#endif // JSONPARSERMODEL_H
