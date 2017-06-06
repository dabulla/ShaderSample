#include <QGuiApplication>
#include <QQuickView>
#include <QQmlContext>
#include "shadermodel.h"
#include "helper.h"

static Helper* helper;
QObject *provider(QQmlEngine *engine, QJSEngine *scriptEngine)
{
    Q_UNUSED(engine)
    Q_UNUSED(scriptEngine)
    return helper;
}

int main(int argc, char **argv)
{
    QGuiApplication app(argc, argv);

    QQuickView view;
    qmlRegisterType<ShaderModel>("fhac", 1, 0, "ShaderModel");
    qmlRegisterType<ShaderParameterInfo>("fhac", 1, 0, "ShaderParameterInfo");
    helper = new Helper(&view);
    qmlRegisterSingletonType<Helper>("fhac", 1, 0, "Helper", provider);

    view.rootContext()->setContextProperty("sceneTemplate", helper->readFile(":/SampleScene.qml"));
    view.resize(500, 500);
    view.setResizeMode(QQuickView::SizeRootObjectToView);
    view.setSource(QUrl("qrc:/main.qml"));
    view.show();

    return app.exec();
}
