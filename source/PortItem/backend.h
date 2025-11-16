#ifndef BACKEND_H
#define BACKEND_H

#include <QObject>
#include <QStringList>
#include <QSerialPortInfo>
#include <QSerialPort>
#include <QDebug>
#include <QMap>

class PortSettings : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QString portName READ portName WRITE setPortName NOTIFY portNameChanged)
    Q_PROPERTY(int baudRate READ baudRate WRITE setBaudRate NOTIFY baudRateChanged)
    Q_PROPERTY(bool isOpen READ isOpen NOTIFY isOpenChanged)

public:
    explicit PortSettings(QObject *parent = nullptr) : QObject(parent), m_baudRate(9600), m_isOpen(false) {}

    QString portName() const { return m_portName; }
    void setPortName(const QString &name) {
        if (m_portName != name) {
            m_portName = name;
            emit portNameChanged();
        }
    }

    int baudRate() const { return m_baudRate; }
    void setBaudRate(int rate) {
        if (m_baudRate != rate) {
            m_baudRate = rate;
            emit baudRateChanged();
        }
    }

    bool isOpen() const { return m_isOpen; }
    void setIsOpen(bool open) {
        if (m_isOpen != open) {
            m_isOpen = open;
            emit isOpenChanged();
        }
    }

signals:
    void portNameChanged();
    void baudRateChanged();
    void isOpenChanged();

private:
    QString m_portName;
    int m_baudRate;
    bool m_isOpen;
};

class Backend : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QStringList availablePorts READ availablePorts NOTIFY availablePortsChanged)
    Q_PROPERTY(QStringList baudRates READ baudRates NOTIFY baudRatesChanged)
    Q_PROPERTY(bool anyPortOpen READ anyPortOpen NOTIFY anyPortOpenChanged)

public:
    explicit Backend(QObject *parent = nullptr);
    ~Backend();

    QStringList availablePorts() const;
    QStringList baudRates() const;
    bool anyPortOpen() const;

    Q_INVOKABLE void refreshPorts();
    Q_INVOKABLE QStringList getBaudRates();

    // Управление портами
    Q_INVOKABLE void setPortSettings(int index, const QString &portName, int baudRate);
    Q_INVOKABLE bool openPort(int index);
    Q_INVOKABLE void closePort(int index);
    Q_INVOKABLE void closeAllPorts();
    Q_INVOKABLE bool isPortOpen(int index);

    // Отправка данных
    Q_INVOKABLE bool sendData(int index, const QString &data);
    Q_INVOKABLE bool sendDataToAll(const QString &data);

    Q_INVOKABLE QString shitten();

signals:
    void availablePortsChanged();
    void baudRatesChanged();
    void anyPortOpenChanged();
    void dataSent(const QString &portName, const QString &data);
    void errorOccurred(const QString &portName, const QString &error);
    void portOpened(const QString &portName);
    void portClosed(const QString &portName);

private:
    QStringList m_availablePorts;
    QStringList m_baudRates;
    QMap<int, QSerialPort*> m_serialPorts;
    QMap<int, PortSettings*> m_portSettings;
    QString specialAbilities;
};

#endif // BACKEND_H
