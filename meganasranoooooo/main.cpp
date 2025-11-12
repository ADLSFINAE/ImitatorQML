#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include "source/PortItem/backend.h"
#include "source/JsonMessagesParser/Library/datacontroller.h"

#include <QDebug>

int main(int argc, char *argv[])
{
    QCoreApplication::setAttribute(Qt::AA_EnableHighDpiScaling);
    QGuiApplication app(argc, argv);

    DataController dataController;

    Backend backend;

    QQmlApplicationEngine engine;

    engine.rootContext()->setContextProperty("dataController", &dataController);
    engine.rootContext()->setContextProperty("backend", &backend);

    qmlRegisterType<DataController>("DataController", 1, 0, "DataController");

    const QUrl url(QStringLiteral("qrc:/main.qml"));
    QObject::connect(&engine, &QQmlApplicationEngine::objectCreated,
                     &app, [url](QObject *obj, const QUrl &objUrl) {
        if (!obj && url == objUrl)
            QCoreApplication::exit(-1);
    }, Qt::QueuedConnection);

    engine.load(url);

    return app.exec();
}

