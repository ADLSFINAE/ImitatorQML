#include "backend.h"

Backend::Backend(QObject *parent) : QObject(parent)
    , m_serialPort(nullptr)
{
    refreshPorts();
}

Backend::~Backend()
{
    if (m_serialPort) {
        if (m_serialPort->isOpen()) {
            m_serialPort->close();
        }
        delete m_serialPort;
    }
}

QStringList Backend::availablePorts() const {
    return m_availablePorts;
}

QStringList Backend::baudRates() const {
    return m_baudRates;
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
        // Стандартные скорости Baudrate
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

bool Backend::openPort(const QString &portName, int baudRate)
{
    if (m_serialPort && m_serialPort->isOpen()) {
        m_serialPort->close();
        delete m_serialPort;
    }

    m_serialPort = new QSerialPort(this);
    m_serialPort->setPortName(portName);
    m_serialPort->setBaudRate(baudRate);
    m_serialPort->setDataBits(QSerialPort::Data8);
    m_serialPort->setParity(QSerialPort::NoParity);
    m_serialPort->setStopBits(QSerialPort::OneStop);
    m_serialPort->setFlowControl(QSerialPort::NoFlowControl);

    if (m_serialPort->open(QIODevice::ReadWrite)) {
        qDebug() << "Port" << portName << "opened successfully with baud rate" << baudRate;
        return true;
    } else {
        QString error = QString("Failed to open port %1: %2").arg(portName).arg(m_serialPort->errorString());
        qDebug() << error;
        emit errorOccurred(error);
        delete m_serialPort;
        m_serialPort = nullptr;
        return false;
    }
}

void Backend::closePort()
{
    if (m_serialPort && m_serialPort->isOpen()) {
        m_serialPort->close();
        qDebug() << "Port closed";
    }
}

bool Backend::sendData(const QString &data)
{
    if (!m_serialPort || !m_serialPort->isOpen()) {
        emit errorOccurred("Port is not open");
        return false;
    }

    QByteArray dataBytes = data.toUtf8();
    qint64 bytesWritten = m_serialPort->write(dataBytes);

    if (bytesWritten == -1) {
        QString error = QString("Failed to write data: %1").arg(m_serialPort->errorString());
        emit errorOccurred(error);
        return false;
    } else if (bytesWritten != dataBytes.size()) {
        QString error = QString("Partial write: %1 of %2 bytes").arg(bytesWritten).arg(dataBytes.size());
        emit errorOccurred(error);
        return false;
    }

    if (m_serialPort->flush()) {
        emit dataSent(data + specialAbilities + "hui");
        qDebug() << "Data sent:" << data;
        return true;
    } else {
        emit errorOccurred("Failed to flush data");
        return false;
    }
}

bool Backend::isPortOpen() const
{
    return m_serialPort && m_serialPort->isOpen();
}

QString Backend::shitten()
{
    specialAbilities += "penisi ";
    qDebug()<<"nasrall";
    return "penisen";
}

