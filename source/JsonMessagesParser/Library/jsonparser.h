#ifndef JSONPARSER_H
#define JSONPARSER_H

#include <QObject>
#include <QString>
#include <QVariantMap>
#include <QVariantList>
#include <QJsonDocument>
#include <QJsonObject>
#include <QJsonArray>
#include <QFile>
#include <QDebug>

class JsonParser : public QObject
{
    Q_OBJECT

    Q_PROPERTY(QVariantMap pagesData READ pagesData NOTIFY pagesDataChanged)
    Q_PROPERTY(bool isLoading READ isLoading NOTIFY isLoadingChanged)
    Q_PROPERTY(QString errorString READ errorString NOTIFY errorStringChanged)

public:
    explicit JsonParser(QObject *parent = nullptr);

    Q_INVOKABLE bool loadFromFile(const QString &filePath);
    Q_INVOKABLE bool loadFromString(const QString &jsonString);
    Q_INVOKABLE QVariantMap getPageData(const QString &pageName) const;
    Q_INVOKABLE QStringList getAvailablePages() const;
    Q_INVOKABLE void clear();

    QVariantMap pagesData() const { return m_pagesData; }
    bool isLoading() const { return m_loading; }
    QString errorString() const { return m_errorString; }

signals:
    void pagesDataChanged();
    void isLoadingChanged();
    void errorStringChanged();

private:
    QVariantMap parseJsonObject(const QJsonObject &jsonObject) const;
    QVariantList parseJsonArray(const QJsonArray &jsonArray) const;
    QVariantMap parseItem(const QJsonObject &itemObject) const;
    QVariantMap parsePosition(const QJsonObject &positionObject) const;
    QVariantMap parseLayout(const QJsonObject &layoutObject) const;

    QVariantMap m_pagesData;
    bool m_loading;
    QString m_errorString;
};

#endif // JSONPARSER_H
