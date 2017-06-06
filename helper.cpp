#include "helper.h"
#include <QFile>
#include <QTextStream>
#include <QDebug>

Helper::Helper(QObject *parent)
    :QObject(parent)
{

}

QString Helper::readFile(QString filename)
{
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
