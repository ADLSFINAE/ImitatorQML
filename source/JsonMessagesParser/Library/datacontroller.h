#ifndef DATACONTROLLER_H
#define DATACONTROLLER_H

#include <QObject>
#include <QString>
#include <QVector>
#include <QMap>
#include <QDebug>

struct BasePageStruct{
    QString pageNumber;
    QMap<QString, QString> _map;

    void printInfo(){
        qDebug() << "=== " << pageNumber << " ===";
        for(auto& elem : _map.keys()){
            qDebug() << elem << ":" << _map[elem];
        }
        qDebug() << "==================";
    }

    // Метод для автоматического заполнения из JSON данных
    void initializeFromJson(const QVariantMap& jsonData);
};

struct ADJ : public BasePageStruct{
    ADJ(){
        pageNumber = "page1";
    }
};

struct DBT : public BasePageStruct{
    DBT(){
        pageNumber = "page2";
    }
};

struct DPT : public BasePageStruct{
    DPT(){
        pageNumber = "page3";
    }
};

struct DTM : public BasePageStruct{
    DTM(){
        pageNumber = "page4";
    }
};

struct ELH : public BasePageStruct{
    ELH(){
        pageNumber = "page5";
    }
};

struct ERR : public BasePageStruct{
    ERR(){
        pageNumber = "page6";
    }
};

struct GBS : public BasePageStruct{
    GBS(){
        pageNumber = "page7";
    }
};

struct GCA : public BasePageStruct{
    GCA(){
        pageNumber = "page8";
    }
};

struct GLL : public BasePageStruct{
    GLL(){
        pageNumber = "page9";
    }
};

struct GNS : public BasePageStruct{
    GNS(){
        pageNumber = "page10";
    }
};

class DataController : public QObject
{
    Q_OBJECT

public:
    explicit DataController(QObject *parent = nullptr);

    // Новый метод для инициализации данных из JSON парсера
    Q_INVOKABLE void initializeFromJsonParser(class JsonParser* jsonParser);

    Q_INVOKABLE void addDataChange(const QString& pageName, const QString& componentName,
                                  const QString& componentType, const QString& newValue);
    Q_INVOKABLE QVector<QString> getPageData(const QString& pageName) const;
    Q_INVOKABLE void clearPageData(const QString& pageName);
    Q_INVOKABLE void clearAllData();

    Q_INVOKABLE QString getAllDataAsString() const;

    // Новые методы для работы со структурами
    Q_INVOKABLE QVector<QString> getPageKeys(const QString& pageName) const;
    Q_INVOKABLE QString getPageValue(const QString& pageName, const QString& key) const;
    Q_INVOKABLE void setPageValue(const QString& pageName, const QString& key, const QString& value);

signals:
    void dataChanged(const QString& pageName, const QString& componentName,
                    const QString& newValue);

private:
    QMap<QString, QVector<QString>> m_pageData;
    QMap<QString, BasePageStruct> m_pageStructs;

    // Вспомогательный метод для рекурсивного обхода items
    void processJsonItems(const QVariantList& items, BasePageStruct& pageStruct);
};

#endif // DATACONTROLLER_H
