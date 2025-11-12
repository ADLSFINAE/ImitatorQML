#include "datacontroller.h"
#include <QDateTime>
#include <QDebug>

DataController::DataController(QObject *parent) : QObject(parent)
{
}

void DataController::addDataChange(const QString& pageName, const QString& componentName,
                                 const QString& componentType, const QString& newValue)
{
    if (pageName.isEmpty() || componentName.isEmpty()) {
        return;
    }

    QString timestamp = QDateTime::currentDateTime().toString("hh:mm:ss.zzz");
    QString dataString = QString("[%1] %2 (%3) = %4")
                            .arg(timestamp)
                            .arg(componentName)
                            .arg(componentType)
                            .arg(newValue);

    m_pageData[pageName].append(dataString);

    if (m_pageData[pageName].size() > 1000) {
        m_pageData[pageName].removeFirst();
    }

    qDebug() << "DataController:" << pageName << "-" << dataString;

    emit dataChanged(pageName, componentName, newValue);
}

QVector<QString> DataController::getPageData(const QString& pageName) const
{
    return m_pageData.value(pageName, QVector<QString>());
}

void DataController::clearPageData(const QString& pageName)
{
    m_pageData.remove(pageName);
    qDebug() << "🧹 DataController: Cleared data for page" << pageName;
}

void DataController::clearAllData()
{
    m_pageData.clear();
    qDebug() << "🧹 DataController: Cleared all data";
}

QString DataController::getAllDataAsString() const
{
    QString result;

    for (auto it = m_pageData.begin(); it != m_pageData.end(); ++it) {
        result += "=== " + it.key() + " ===\n";
        const QVector<QString>& pageData = it.value();
        for (const QString& data : pageData) {
            result += data + "\n";
        }
        result += "\n";
    }

    return result;
}
