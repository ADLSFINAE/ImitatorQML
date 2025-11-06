#ifndef DISPLAYMODEL_H
#define DISPLAYMODEL_H

#include <QObject>
#include <QAbstractListModel>
#include <QVariant>

class DisplayModel : public QAbstractListModel
{
    Q_OBJECT
    Q_PROPERTY(QString pageName READ pageName NOTIFY pageNameChanged)

public:
    enum DisplayRoles {
        NameRole = Qt::UserRole + 1,
        TextRole,
        ColorRole
    };

    explicit DisplayModel(QObject *parent = nullptr);

    // QAbstractListModel interface
    int rowCount(const QModelIndex &parent = QModelIndex()) const override;
    QVariant data(const QModelIndex &index, int role = Qt::DisplayRole) const override;
    QHash<int, QByteArray> roleNames() const override;

    QString pageName() const { return m_pageName; }

    Q_INVOKABLE void setItems(const QVariantList &items, const QString &pageName);

signals:
    void pageNameChanged();

private:
    QVector<QVariantMap> m_items;
    QString m_pageName;
};

#endif // DISPLAYMODEL_H
