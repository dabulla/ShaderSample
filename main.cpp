#include <QGuiApplication>
#include <QQuickView>
#include "shadermodel.h"
#include <QOpenGLDebugLogger>

int main(int argc, char **argv)
{
    QGuiApplication app(argc, argv);

    QQuickView view;
    qmlRegisterType<ShaderModel>("fhac", 1, 0, "ShaderModel");
            qmlRegisterType<ShaderParameterInfo>("fhac", 1, 0, "ShaderParameterInfo");
    view.resize(500, 500);
    view.setResizeMode(QQuickView::SizeRootObjectToView);
    view.setSource(QUrl("qrc:/main.qml"));
    view.show();

    return app.exec();
}
