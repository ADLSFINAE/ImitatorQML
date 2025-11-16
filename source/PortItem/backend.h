#ifndef BACKEND_H
#define BACKEND_H

#include <QObject>
#include <QStringList>
#include <QSerialPortInfo>
#include <QSerialPort>
#include <QDebug>

class Backend : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QStringList availablePorts READ availablePorts NOTIFY availablePortsChanged)
    Q_PROPERTY(QStringList baudRates READ baudRates NOTIFY baudRatesChanged)

public:
    explicit Backend(QObject *parent = nullptr);
    ~Backend();

    QStringList availablePorts() const;
    QStringList baudRates() const;

    Q_INVOKABLE void refreshPorts();
    Q_INVOKABLE QStringList getBaudRates();
    Q_INVOKABLE bool openPort(const QString &portName, int baudRate);
    Q_INVOKABLE void closePort();
    Q_INVOKABLE bool sendData(const QString &data);
    Q_INVOKABLE bool isPortOpen() const;
    Q_INVOKABLE QString shitten();

signals:
    void availablePortsChanged();
    void baudRatesChanged();
    void dataSent(const QString &data);
    void errorOccurred(const QString &error);

private:
    QStringList m_availablePorts;
    QStringList m_baudRates;
    QSerialPort *m_serialPort;
    QString specialAbilities;
};

#endif // BACKEND_H
