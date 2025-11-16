#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include "source/PortItem/backend.h"
#include "source/JsonMessagesParser/Library/datacontroller.h"
#include "source/JsonMessagesParser/Library/jsonparser.h"

#include <QDebug>

int main(int argc, char *argv[])
{
    QCoreApplication::setAttribute(Qt::AA_EnableHighDpiScaling);
    QGuiApplication app(argc, argv);

    QQmlApplicationEngine engine;

    DataController dataController;

    Backend backend;

    JsonParser jsonParser;

    engine.rootContext()->setContextProperty("dataController", &dataController);
    engine.rootContext()->setContextProperty("backend", &backend);
    engine.rootContext()->setContextProperty("jsonParser", &jsonParser);

    jsonParser.loadFromFile(":/JsonDocuments/example.json");

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

