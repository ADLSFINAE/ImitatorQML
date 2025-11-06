#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include "jsonmodel.h"
#include "uimodel.h"

#include <QDebug>

int main(int argc, char *argv[])
{
    QCoreApplication::setAttribute(Qt::AA_EnableHighDpiScaling);
    QGuiApplication app(argc, argv);

    // Регистрируем модели
    qmlRegisterType<JsonParserModel>("AppModels", 1, 0, "JsonParserModel");
    qmlRegisterType<DisplayModel>("AppModels", 1, 0, "DisplayModel");

    // Создаем экземпляры моделей
    JsonParserModel jsonParser;

    // Вместо фиксированных моделей, будем создавать их динамически в QML
    // Оставляем только jsonParser в контексте

    QQmlApplicationEngine engine;

    // Передаем только jsonParser в QML контекст
    engine.rootContext()->setContextProperty("jsonParser", &jsonParser);

    const QUrl url(QStringLiteral("qrc:/main.qml"));
    QObject::connect(&engine, &QQmlApplicationEngine::objectCreated,
                     &app, [url](QObject *obj, const QUrl &objUrl) {
        if (!obj && url == objUrl)
            QCoreApplication::exit(-1);
    }, Qt::QueuedConnection);

    engine.load(url);

    return app.exec();
}
