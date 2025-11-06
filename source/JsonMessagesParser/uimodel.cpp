#include "source/JsonMessagesParser/uimodel.h"
#include <QDebug>

DisplayModel::DisplayModel(QObject *parent)
    : QAbstractListModel(parent)
{
}

void DisplayModel::loadFromJsonParser(JsonParserModel *jsonParser)
{
    if (jsonParser) {
        setItems(jsonParser->getItems(), jsonParser->getPageName());
    }
}

void DisplayModel::clear()
{
    beginResetModel();
    m_items.clear();
    m_pageName = "";
    endResetModel();
    emit pageNameChanged();
}


int DisplayModel::rowCount(const QModelIndex &parent) const
{
    if (parent.isValid())
        return 0;

    return m_items.count();
}

QVariant DisplayModel::data(const QModelIndex &index, int role) const
{
    if (!index.isValid() || index.row() >= m_items.size())
        return QVariant();

    const QVariantMap &item = m_items.at(index.row());

    switch (role) {
    case NameRole:
        return item.value("name");
    case TextRole:
        return item.value("text");
    case ColorRole:
        return item.value("color");
    default:
        return QVariant();
    }
}

QHash<int, QByteArray> DisplayModel::roleNames() const
{
    QHash<int, QByteArray> roles;
    roles[NameRole] = "name";
    roles[TextRole] = "text";
    roles[ColorRole] = "color";
    return roles;
}

void DisplayModel::setItems(const QVariantList &items, const QString &pageName)
{
    beginResetModel();

    m_items.clear();
    for (const QVariant &item : items) {
        m_items.append(item.toMap());
    }

    if (m_pageName != pageName) {
        m_pageName = pageName;
        emit pageNameChanged();
    }

    endResetModel();

    qDebug() << "DisplayModel: loaded" << m_items.count() << "items for page:" << pageName;
}
