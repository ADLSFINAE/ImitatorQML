#ifndef BACKEND_H
#define BACKEND_H

#include <QObject>
#include <QStringList>
#include <QSerialPortInfo>
#include <QDebug>

class Backend : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QStringList availablePorts READ availablePorts NOTIFY availablePortsChanged)
    Q_PROPERTY(QStringList baudRates READ baudRates NOTIFY baudRatesChanged)

public:
    explicit Backend(QObject *parent = nullptr);

    QStringList availablePorts() const;

    QStringList baudRates() const;

    Q_INVOKABLE void refreshPorts();

    Q_INVOKABLE QStringList getBaudRates();

signals:
    void availablePortsChanged();
    void baudRatesChanged();

private:
    QStringList m_availablePorts;
    QStringList m_baudRates;
};

#endif // BACKEND_H
