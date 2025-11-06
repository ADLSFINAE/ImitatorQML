#include "backend.h"

Backend::Backend(QObject *parent) : QObject(parent)
{
    refreshPorts();
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
