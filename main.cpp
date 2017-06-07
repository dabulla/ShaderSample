#include <QGuiApplication>
#include <QQmlEngine>
#include <QQmlComponent>
#include <QQmlContext>
#include <QDebug>
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
    app.setOrganizationName("FH Aachen - University of Applied Sciences");
    app.setOrganizationDomain("fh-aachen.de");
    app.setApplicationName("Shader Inspector");


    QQmlEngine engine;
    QQmlComponent component(&engine);

    qmlRegisterType<ShaderModel>("fhac", 1, 0, "ShaderModel");
    qmlRegisterType<ShaderParameterInfo>("fhac", 1, 0, "ShaderParameterInfo");
    helper = new Helper(&engine);
    qmlRegisterSingletonType<Helper>("fhac", 1, 0, "Helper", provider);
    engine.rootContext()->setContextProperty("sceneTemplate", helper->readFile(":/SampleScene.qml"));

    component.loadUrl(QUrl("qrc:/main.qml"));
    if ( component.isReady() )
        component.create();
    else
        qWarning() << component.errorString();
//    QQuickView view;
//    view.resize(500, 500);
//    view.setResizeMode(QQuickView::SizeRootObjectToView);
//    view.setSource(QUrl("qrc:/main.qml"));
//    view.show();

    return app.exec();
}
