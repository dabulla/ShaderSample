#ifndef HELPER_H
#define HELPER_H

#include <QObject>

class Helper : public QObject
{
    Q_OBJECT
public:
    Helper(QObject *parent=nullptr);
    Q_INVOKABLE QString readFile(QString filename);
};

#endif // HELPER_H
