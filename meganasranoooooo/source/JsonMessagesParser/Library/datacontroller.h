#ifndef DATACONTROLLER_H
#define DATACONTROLLER_H

#include <QObject>
#include <QString>
#include <QVector>
#include <QMap>

class DataController : public QObject
{
    Q_OBJECT

public:
    explicit DataController(QObject *parent = nullptr);

    Q_INVOKABLE void addDataChange(const QString& pageName, const QString& componentName,
                                  const QString& componentType, const QString& newValue);
    Q_INVOKABLE QVector<QString> getPageData(const QString& pageName) const;
    Q_INVOKABLE void clearPageData(const QString& pageName);
    Q_INVOKABLE void clearAllData();

    Q_INVOKABLE QString getAllDataAsString() const;

signals:
    void dataChanged(const QString& pageName, const QString& componentName,
                    const QString& newValue);

private:
    QMap<QString, QVector<QString>> m_pageData;
};

#endif // DATACONTROLLER_H
