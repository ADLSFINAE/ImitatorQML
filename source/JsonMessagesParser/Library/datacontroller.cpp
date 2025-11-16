#include "datacontroller.h"
#include <QDateTime>
#include <QDebug>
#include <QVariantMap>
#include <QVariantList>
#include "source/JsonMessagesParser/Library/jsonparser.h"

DataController::DataController(QObject* parent) : QObject(parent)
{
    // Создаем пустые структуры (данные будут заполнены из JSON)
    ADJ obj1;
    DBT obj2;
    DPT obj3;
    DTM obj4;
    ELH obj5;
    ERR obj6;
    GBS obj7;
    GCA obj8;
    GLL obj9;
    GNS obj10;

    QVector<BasePageStruct> vector = {obj1, obj2, obj3, obj4, obj5, obj6, obj7, obj8, obj9, obj10};

    for (int i = 1; i <= 10; i++)
    {
        m_pageStructs["page" + QString::number(i)] = vector[i - 1];
    }
}

void DataController::initializeFromJsonParser(JsonParser* jsonParser)
{
    if (!jsonParser) {
        qDebug() << "JsonParser is null!";
        return;
    }

    // Получаем все страницы из JSON
    QVariantMap pagesData = jsonParser->pagesData();

    for (auto it = pagesData.begin(); it != pagesData.end(); ++it) {
        QString pageName = it.key();

        if (m_pageStructs.contains(pageName)) {
            qDebug() << "Initializing page:" << pageName;

            QVariantMap pageData = it.value().toMap();
            m_pageStructs[pageName].initializeFromJson(pageData);

            // Выводим информацию о заполненной структуре
            m_pageStructs[pageName].printInfo();
        } else {
            qDebug() << "Page not found in structures:" << pageName;
        }
    }

    qDebug() << "DataController initialized from JSON parser";
}

void BasePageStruct::initializeFromJson(const QVariantMap& jsonData)
{
    if (jsonData.contains("items") && jsonData["items"].canConvert<QVariantList>()) {
        QVariantList items = jsonData["items"].toList();

        // Рекурсивно обрабатываем все элементы
        for (const QVariant& item : items) {
            if (item.canConvert<QVariantMap>()) {
                QVariantMap itemMap = item.toMap();

                // Обрабатываем обычные элементы
                if (itemMap.contains("name") && itemMap.contains("type")) {
                    QString name = itemMap["name"].toString();
                    QString type = itemMap["type"].toString();

                    // Устанавливаем значение по умолчанию в зависимости от типа
                    QString defaultValue = "";
                    if (type == "combobox" || type == "radiobutton") {
                        if (itemMap.contains("default")) {
                            defaultValue = itemMap["default"].toString();
                        } else if (itemMap.contains("options") &&
                                  itemMap["options"].canConvert<QVariantList>()) {
                            QVariantList options = itemMap["options"].toList();
                            if (!options.isEmpty()) {
                                defaultValue = options.first().toString();
                            }
                        }
                    } else if (type == "textfield") {
                        defaultValue = "0"; // Для текстовых полей по умолчанию "0"
                    }

                    if (!name.isEmpty()) {
                        _map[name] = defaultValue;
                        qDebug() << "  - Added:" << name << "=" << defaultValue;
                    }
                }

                // Рекурсивно обрабатываем вложенные элементы (для group)
                if (itemMap.contains("items") && itemMap["items"].canConvert<QVariantList>()) {
                    QVariantList nestedItems = itemMap["items"].toList();
                    for (const QVariant& nestedItem : nestedItems) {
                        if (nestedItem.canConvert<QVariantMap>()) {
                            QVariantMap nestedItemMap = nestedItem.toMap();
                            if (nestedItemMap.contains("name") && nestedItemMap.contains("type")) {
                                QString nestedName = nestedItemMap["name"].toString();
                                QString nestedType = nestedItemMap["type"].toString();

                                QString nestedDefault = "";
                                if (nestedType == "combobox" || nestedType == "radiobutton") {
                                    if (nestedItemMap.contains("default")) {
                                        nestedDefault = nestedItemMap["default"].toString();
                                    } else if (nestedItemMap.contains("options") &&
                                              nestedItemMap["options"].canConvert<QVariantList>()) {
                                        QVariantList options = nestedItemMap["options"].toList();
                                        if (!options.isEmpty()) {
                                            nestedDefault = options.first().toString();
                                        }
                                    }
                                } else if (nestedType == "textfield") {
                                    nestedDefault = "0";
                                }

                                if (!nestedName.isEmpty()) {
                                    _map[nestedName] = nestedDefault;
                                    qDebug() << "  - Added nested:" << nestedName << "=" << nestedDefault;
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}

void DataController::processJsonItems(const QVariantList& items, BasePageStruct& pageStruct)
{
    for (const QVariant& item : items) {
        if (item.canConvert<QVariantMap>()) {
            QVariantMap itemMap = item.toMap();

            if (itemMap.contains("name") && itemMap.contains("type")) {
                QString name = itemMap["name"].toString();
                QString type = itemMap["type"].toString();

                QString defaultValue = "";
                if (type == "combobox" || type == "radiobutton") {
                    if (itemMap.contains("default")) {
                        defaultValue = itemMap["default"].toString();
                    }
                } else if (type == "textfield") {
                    defaultValue = "0";
                }

                if (!name.isEmpty()) {
                    pageStruct._map[name] = defaultValue;
                }
            }

            // Рекурсивно обрабатываем вложенные элементы
            if (itemMap.contains("items") && itemMap["items"].canConvert<QVariantList>()) {
                processJsonItems(itemMap["items"].toList(), pageStruct);
            }
        }
    }
}

void DataController::addDataChange(const QString& pageName, const QString& componentName, const QString& componentType,
                                   const QString& newValue)
{
    if (pageName.isEmpty() || componentName.isEmpty())
    {
        return;
    }

    // Обновляем значение в структуре
    if (m_pageStructs.contains(pageName)) {
        m_pageStructs[pageName]._map[componentName] = newValue;
        m_pageStructs[pageName].printInfo();
    }

    QString timestamp = QDateTime::currentDateTime().toString("hh:mm:ss.zzz");
    QString dataString =
        QString("[%1] %2 (%3) = %4").arg(timestamp).arg(componentName).arg(componentType).arg(newValue);

    m_pageData[pageName].append(dataString);

    if (m_pageData[pageName].size() > 1000)
    {
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
    qDebug() << "DataController: Cleared data for page" << pageName;
}

void DataController::clearAllData()
{
    m_pageData.clear();
    qDebug() << "DataController: Cleared all data";
}

QString DataController::getAllDataAsString() const
{
    QString result;

    for (auto it = m_pageData.begin(); it != m_pageData.end(); ++it)
    {
        result += "=== " + it.key() + " ===\n";
        const QVector<QString>& pageData = it.value();
        for (const QString& data : pageData)
        {
            result += data + "\n";
        }
        result += "\n";
    }

    return result;
}

// Новые методы для работы со структурами
QVector<QString> DataController::getPageKeys(const QString& pageName) const
{
    if (m_pageStructs.contains(pageName)) {
        return m_pageStructs[pageName]._map.keys().toVector();
    }
    return QVector<QString>();
}

QString DataController::getPageValue(const QString& pageName, const QString& key) const
{
    if (m_pageStructs.contains(pageName)) {
        return m_pageStructs[pageName]._map.value(key, "");
    }
    return "";
}

void DataController::setPageValue(const QString& pageName, const QString& key, const QString& value)
{
    if (m_pageStructs.contains(pageName)) {
        m_pageStructs[pageName]._map[key] = value;
        emit dataChanged(pageName, key, value);
    }
}
