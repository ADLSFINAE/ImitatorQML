#include "jsonparser.h"

JsonParser::JsonParser(QObject *parent)
    : QObject(parent)
    , m_loading(false)
{
}

bool JsonParser::loadFromFile(const QString &filePath)
{
    if (m_loading) {
        return false;
    }

    m_loading = true;
    emit isLoadingChanged();

    m_errorString.clear();
    emit errorStringChanged();

    // Очищаем предыдущие данные
    m_pagesData.clear();

    // Обработка QRC путей
    QString resolvedPath = filePath;
    if (filePath.startsWith("qrc:/")) {
        resolvedPath = ":" + filePath.mid(4);
    }

    QFile file(resolvedPath);
    if (!file.open(QIODevice::ReadOnly | QIODevice::Text)) {
        m_errorString = QString("Cannot open file: %1").arg(filePath);
        emit errorStringChanged();

        m_loading = false;
        emit isLoadingChanged();
        return false;
    }

    QByteArray jsonData = file.readAll();
    file.close();

    QJsonParseError parseError;
    QJsonDocument jsonDoc = QJsonDocument::fromJson(jsonData, &parseError);

    if (parseError.error != QJsonParseError::NoError) {
        m_errorString = QString("JSON parse error: %1").arg(parseError.errorString());
        emit errorStringChanged();

        m_loading = false;
        emit isLoadingChanged();
        return false;
    }

    if (!jsonDoc.isObject()) {
        m_errorString = "JSON root is not an object";
        emit errorStringChanged();

        m_loading = false;
        emit isLoadingChanged();
        return false;
    }

    QJsonObject rootObject = jsonDoc.object();
    m_pagesData = parseJsonObject(rootObject);

    qDebug() << "Successfully loaded JSON data, pages count:" << m_pagesData.size();

    m_loading = false;
    emit isLoadingChanged();
    emit pagesDataChanged();

    return true;
}

bool JsonParser::loadFromString(const QString &jsonString)
{
    if (m_loading) {
        return false;
    }

    m_loading = true;
    emit isLoadingChanged();

    m_errorString.clear();
    emit errorStringChanged();

    m_pagesData.clear();

    QJsonParseError parseError;
    QJsonDocument jsonDoc = QJsonDocument::fromJson(jsonString.toUtf8(), &parseError);

    if (parseError.error != QJsonParseError::NoError) {
        m_errorString = QString("JSON parse error: %1").arg(parseError.errorString());
        emit errorStringChanged();

        m_loading = false;
        emit isLoadingChanged();
        return false;
    }

    if (!jsonDoc.isObject()) {
        m_errorString = "JSON root is not an object";
        emit errorStringChanged();

        m_loading = false;
        emit isLoadingChanged();
        return false;
    }

    QJsonObject rootObject = jsonDoc.object();
    m_pagesData = parseJsonObject(rootObject);

    qDebug() << "Successfully loaded JSON from string, pages count:" << m_pagesData.size();

    m_loading = false;
    emit isLoadingChanged();
    emit pagesDataChanged();

    return true;
}

QVariantMap JsonParser::getPageData(const QString &pageName) const
{
    return m_pagesData.value(pageName).toMap();
}

QStringList JsonParser::getAvailablePages() const
{
    return m_pagesData.keys();
}

void JsonParser::clear()
{
    m_pagesData.clear();
    m_errorString.clear();
    emit pagesDataChanged();
    emit errorStringChanged();
}

QVariantMap JsonParser::parseJsonObject(const QJsonObject &jsonObject) const
{
    QVariantMap result;

    for (auto it = jsonObject.begin(); it != jsonObject.end(); ++it) {
        QString key = it.key();
        QJsonValue value = it.value();

        if (value.isObject()) {
            // Особый случай для страниц - парсим с дополнительной структурой
            if (key.startsWith("page")) {
                QJsonObject pageObject = value.toObject();
                QVariantMap pageData;

                // Базовые поля страницы
                if (pageObject.contains("pageName")) {
                    pageData["pageName"] = pageObject["pageName"].toString();
                }

                // Layout страницы
                if (pageObject.contains("layout") && pageObject["layout"].isObject()) {
                    pageData["layout"] = parseLayout(pageObject["layout"].toObject());
                }

                // Items страницы
                if (pageObject.contains("items") && pageObject["items"].isArray()) {
                    QVariantList itemsList;
                    QJsonArray itemsArray = pageObject["items"].toArray();
                    for (const QJsonValue &itemValue : itemsArray) {
                        if (itemValue.isObject()) {
                            itemsList.append(parseItem(itemValue.toObject()));
                        }
                    }
                    pageData["items"] = itemsList;
                }

                result[key] = pageData;
            } else {
                result[key] = parseJsonObject(value.toObject());
            }
        } else if (value.isArray()) {
            result[key] = parseJsonArray(value.toArray());
        } else if (value.isBool()) {
            result[key] = value.toBool();
        } else if (value.isDouble()) {
            double doubleValue = value.toDouble();
            if (doubleValue == static_cast<int>(doubleValue)) {
                result[key] = static_cast<int>(doubleValue);
            } else {
                result[key] = doubleValue;
            }
        } else if (value.isString()) {
            result[key] = value.toString();
        } else if (value.isNull()) {
            result[key] = QVariant();
        }
    }

    return result;
}

QVariantList JsonParser::parseJsonArray(const QJsonArray &jsonArray) const
{
    QVariantList result;

    for (const QJsonValue &value : jsonArray) {
        if (value.isObject()) {
            result.append(parseJsonObject(value.toObject()));
        } else if (value.isArray()) {
            result.append(parseJsonArray(value.toArray()));
        } else if (value.isBool()) {
            result.append(value.toBool());
        } else if (value.isDouble()) {
            double doubleValue = value.toDouble();
            if (doubleValue == static_cast<int>(doubleValue)) {
                result.append(static_cast<int>(doubleValue));
            } else {
                result.append(doubleValue);
            }
        } else if (value.isString()) {
            result.append(value.toString());
        } else if (value.isNull()) {
            result.append(QVariant());
        }
    }

    return result;
}

QVariantMap JsonParser::parseItem(const QJsonObject &itemObject) const
{
    QVariantMap itemData;

    // Базовые поля элемента
    if (itemObject.contains("type")) {
        itemData["type"] = itemObject["type"].toString();
    }
    if (itemObject.contains("name")) {
        itemData["name"] = itemObject["name"].toString();
    }
    if (itemObject.contains("label")) {
        itemData["label"] = itemObject["label"].toString();
    }
    if (itemObject.contains("description")) {
        itemData["description"] = itemObject["description"].toString();
    }
    if (itemObject.contains("enabled")) {
        itemData["enabled"] = itemObject["enabled"].toBool();
    }
    if (itemObject.contains("default")) {
        QJsonValue defaultValue = itemObject["default"];
        if (defaultValue.isBool()) {
            itemData["default"] = defaultValue.toBool();
        } else if (defaultValue.isDouble()) {
            itemData["default"] = defaultValue.toDouble();
        } else if (defaultValue.isString()) {
            itemData["default"] = defaultValue.toString();
        }
    }
    if (itemObject.contains("options") && itemObject["options"].isArray()) {
        itemData["options"] = parseJsonArray(itemObject["options"].toArray());
    }
    if (itemObject.contains("position") && itemObject["position"].isObject()) {
        itemData["position"] = parsePosition(itemObject["position"].toObject());
    }
    if (itemObject.contains("pageName")) {
        itemData["pageName"] = itemObject["pageName"].toString();
    }

    // Обработка вложенных items для group
    if (itemObject.contains("items") && itemObject["items"].isArray()) {
        QVariantList nestedItems;
        QJsonArray nestedArray = itemObject["items"].toArray();
        for (const QJsonValue &nestedValue : nestedArray) {
            if (nestedValue.isObject()) {
                nestedItems.append(parseItem(nestedValue.toObject()));
            }
        }
        itemData["items"] = nestedItems;
    }

    return itemData;
}

QVariantMap JsonParser::parsePosition(const QJsonObject &positionObject) const
{
    QVariantMap positionData;

    if (positionObject.contains("x")) {
        positionData["x"] = positionObject["x"].toInt();
    }
    if (positionObject.contains("y")) {
        positionData["y"] = positionObject["y"].toInt();
    }
    if (positionObject.contains("width")) {
        positionData["width"] = positionObject["width"].toInt();
    }
    if (positionObject.contains("height")) {
        positionData["height"] = positionObject["height"].toInt();
    }

    return positionData;
}

QVariantMap JsonParser::parseLayout(const QJsonObject &layoutObject) const
{
    QVariantMap layoutData;

    if (layoutObject.contains("columns")) {
        layoutData["columns"] = layoutObject["columns"].toInt();
    }
    if (layoutObject.contains("rows")) {
        layoutData["rows"] = layoutObject["rows"].toInt();
    }
    if (layoutObject.contains("cellWidth")) {
        layoutData["cellWidth"] = layoutObject["cellWidth"].toInt();
    }
    if (layoutObject.contains("cellHeight")) {
        layoutData["cellHeight"] = layoutObject["cellHeight"].toInt();
    }

    return layoutData;
}
