#include <QGuiApplication>
#include <QQuickView>
#include "shadermodel.h"
#include <QOpenGLDebugLogger>
#include <QQmlContext>

QString readFile(QString filename){
    QFile file(filename);

    if (!file.open(QFile::ReadOnly | QFile::Text)) {
        qDebug() << "could not open file for read";
        return "";
    }
    QTextStream in(&file);
    QString text = in.readAll();
    file.close();
    return text;
}

int main(int argc, char **argv)
{
    QGuiApplication app(argc, argv);

    QQuickView view;
    qmlRegisterType<ShaderModel>("fhac", 1, 0, "ShaderModel");
    qmlRegisterType<ShaderParameterInfo>("fhac", 1, 0, "ShaderParameterInfo");

    view.rootContext()->setContextProperty("sceneTemplate", readFile(":/SampleScene.qml"));
    view.resize(500, 500);
    view.setResizeMode(QQuickView::SizeRootObjectToView);
    view.setSource(QUrl("qrc:/main.qml"));
    view.show();

    return app.exec();
}
