#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include "source/PortItem/backend.h"
#include "source/JsonMessagesParser/Library/datacontroller.h"
#include "source/JsonMessagesParser/Library/jsonparser.h"
#include "source/JsonMessagesParser/Library/uimodel.h"

#include <QDebug>

int main(int argc, char *argv[])
{
    QCoreApplication::setAttribute(Qt::AA_EnableHighDpiScaling);
    QGuiApplication app(argc, argv);

    QQmlApplicationEngine engine;

    DataController dataController;
    Backend backend;

    // Создаем модели
    JsonParser *jsonParser = new JsonParser(&app);
    UiModel *uiModel = new UiModel(&app);

    // Связываем модели
    uiModel->setJsonParser(jsonParser);

    // Загружаем JSON
    bool loaded = jsonParser->loadFromFile(":/JsonDocuments/example.json");
    if (!loaded) {
        qDebug() << "Failed to load JSON from resources, using fallback";
        // Можно загрузить демо данные через loadFromString
    } else {
        // Инициализируем DataController данными из JSON
        dataController.initializeFromJsonParser(jsonParser);
    }

    engine.rootContext()->setContextProperty("dataController", &dataController);
    engine.rootContext()->setContextProperty("backend", &backend);
    engine.rootContext()->setContextProperty("jsonParser", jsonParser);
    engine.rootContext()->setContextProperty("uiModel", uiModel);

    qmlRegisterType<DataController>("DataController", 1, 0, "DataController");

    const QUrl url(QStringLiteral("qrc:/main.qml"));
    QObject::connect(&engine, &QQmlApplicationEngine::objectCreated,
                     &app, [url](QObject *obj, const QUrl &objUrl) {
        if (!obj && url == objUrl)
            QCoreApplication::exit(-1);
    }, Qt::QueuedConnection);

    engine.load(url);

    // Инициализируем UI модель после загрузки QML
    QObject::connect(&engine, &QQmlApplicationEngine::objectCreated, [uiModel](QObject *obj, const QUrl &objUrl) {
        if (obj) {
            uiModel->initialize();
        }
    });

    return app.exec();
}
