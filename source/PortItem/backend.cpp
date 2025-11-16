#include "backend.h"

Backend::Backend(QObject *parent) : QObject(parent)
{
    refreshPorts();
}

Backend::~Backend()
{
    closeAllPorts();
    qDeleteAll(m_portSettings);
}

QStringList Backend::availablePorts() const {
    return m_availablePorts;
}

QStringList Backend::baudRates() const {
    return m_baudRates;
}

bool Backend::anyPortOpen() const {
    for (auto port : m_serialPorts) {
        if (port && port->isOpen()) {
            return true;
        }
    }
    return false;
}

void Backend::refreshPorts() {
    m_availablePorts.clear();
    auto ports = QSerialPortInfo::availablePorts();

    for (const auto &port : ports) {
        m_availablePorts.append(port.portName());
    }

    emit availablePortsChanged();
}

QStringList Backend::getBaudRates() {
    if (m_baudRates.isEmpty()) {
        QList<int> standardRates = {50, 75, 110, 134, 150, 200, 300, 600, 1200,
                                    1800, 2400, 4800, 9600, 19200, 38400, 57600,
                                    115200, 230400, 460800, 500000, 576000,
                                    921600};

        for (int rate : standardRates) {
            m_baudRates.append(QString::number(rate));
        }
    }
    return m_baudRates;
}

void Backend::setPortSettings(int index, const QString &portName, int baudRate) {
    if (!m_portSettings.contains(index)) {
        m_portSettings[index] = new PortSettings(this);
    }

    m_portSettings[index]->setPortName(portName);
    m_portSettings[index]->setBaudRate(baudRate);

    qDebug() << "Port settings set for index" << index << ":" << portName << "at" << baudRate;
}

bool Backend::openPort(int index) {
    if (!m_portSettings.contains(index)) {
        emit errorOccurred("", QString("No settings for port index %1").arg(index));
        return false;
    }

    PortSettings* settings = m_portSettings[index];
    QString portName = settings->portName();
    int baudRate = settings->baudRate();

    // Закрываем порт если уже открыт
    if (m_serialPorts.contains(index) && m_serialPorts[index]->isOpen()) {
        m_serialPorts[index]->close();
        delete m_serialPorts[index];
    }

    m_serialPorts[index] = new QSerialPort(this);
    m_serialPorts[index]->setPortName(portName);
    m_serialPorts[index]->setBaudRate(baudRate);
    m_serialPorts[index]->setDataBits(QSerialPort::Data8);
    m_serialPorts[index]->setParity(QSerialPort::NoParity);
    m_serialPorts[index]->setStopBits(QSerialPort::OneStop);
    m_serialPorts[index]->setFlowControl(QSerialPort::NoFlowControl);

    if (m_serialPorts[index]->open(QIODevice::ReadWrite)) {
        settings->setIsOpen(true);
        emit portOpened(portName);
        emit anyPortOpenChanged();
        qDebug() << "Port" << portName << "opened successfully with baud rate" << baudRate;
        return true;
    } else {
        QString error = QString("Failed to open port %1: %2").arg(portName).arg(m_serialPorts[index]->errorString());
        qDebug() << error;
        emit errorOccurred(portName, error);
        delete m_serialPorts[index];
        m_serialPorts.remove(index);
        settings->setIsOpen(false);
        return false;
    }
}

void Backend::closePort(int index) {
    if (m_serialPorts.contains(index) && m_serialPorts[index]->isOpen()) {
        QString portName = m_serialPorts[index]->portName();
        m_serialPorts[index]->close();
        if (m_portSettings.contains(index)) {
            m_portSettings[index]->setIsOpen(false);
        }
        emit portClosed(portName);
        emit anyPortOpenChanged();
        qDebug() << "Port" << portName << "closed";
    }
}

void Backend::closeAllPorts() {
    for (auto it = m_serialPorts.begin(); it != m_serialPorts.end(); ++it) {
        if (it.value()->isOpen()) {
            it.value()->close();
            if (m_portSettings.contains(it.key())) {
                m_portSettings[it.key()]->setIsOpen(false);
            }
        }
        delete it.value();
    }
    m_serialPorts.clear();
    emit anyPortOpenChanged();
}

bool Backend::isPortOpen(int index) {
    return m_serialPorts.contains(index) && m_serialPorts[index]->isOpen();
}

bool Backend::sendData(int index, const QString &data) {
    if (!m_serialPorts.contains(index) || !m_serialPorts[index]->isOpen()) {
        emit errorOccurred("", "Port is not open");
        return false;
    }

    QByteArray dataBytes = data.toUtf8();
    qint64 bytesWritten = m_serialPorts[index]->write(dataBytes);

    if (bytesWritten == -1) {
        QString error = QString("Failed to write data: %1").arg(m_serialPorts[index]->errorString());
        emit errorOccurred(m_serialPorts[index]->portName(), error);
        return false;
    } else if (bytesWritten != dataBytes.size()) {
        QString error = QString("Partial write: %1 of %2 bytes").arg(bytesWritten).arg(dataBytes.size());
        emit errorOccurred(m_serialPorts[index]->portName(), error);
        return false;
    }

    if (m_serialPorts[index]->flush()) {
        emit dataSent(m_serialPorts[index]->portName(), data + specialAbilities);
        qDebug() << "Data sent to" << m_serialPorts[index]->portName() << ":" << data;
        return true;
    } else {
        emit errorOccurred(m_serialPorts[index]->portName(), "Failed to flush data");
        return false;
    }
}

bool Backend::sendDataToAll(const QString &data) {
    bool success = true;
    for (auto it = m_serialPorts.begin(); it != m_serialPorts.end(); ++it) {
        if (it.value()->isOpen()) {
            if (!sendData(it.key(), data)) {
                success = false;
            }
        }
    }
    return success;
}

QString Backend::shitten()
{
    specialAbilities += "penisi ";
    qDebug()<<"nasrall";
    return "penisen";
}
