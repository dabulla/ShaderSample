TEMPLATE = app

QT += qml quick
QT += 3dcore 3drender 3dinput 3dquick 3dlogic qml quick 3dquickextras

CONFIG += c++11

SOURCES += main.cpp \
    shadermodel.cpp \
    shaderparameterinfo.cpp \
    helper.cpp

RESOURCES += qml.qrc

OTHER_FILES += shader/*.frag \
               shader/*.vert \
               shader/*.geom \
               shader/*.comp \
               shader/*.tcs \
               shader/*.tes \
               shader/*.vs \
               shader/*.fs \
               shader/*.gs \
               shader/*.cs \
               shader/*.glsl \

# Additional import path used to resolve QML modules in Qt Creator's code model
QML_IMPORT_PATH =

# Additional import path used to resolve QML modules just for Qt Quick Designer
QML_DESIGNER_IMPORT_PATH =

# The following define makes your compiler emit warnings if you use
# any feature of Qt which as been marked deprecated (the exact warnings
# depend on your compiler). Please consult the documentation of the
# deprecated API in order to know how to port your code away from it.
DEFINES += QT_DEPRECATED_WARNINGS

# You can also make your code fail to compile if you use deprecated APIs.
# In order to do so, uncomment the following line.
# You can also select to disable deprecated APIs only up to a certain version of Qt.
#DEFINES += QT_DISABLE_DEPRECATED_BEFORE=0x060000    # disables all the APIs deprecated before Qt 6.0.0

# Default rules for deployment.
qnx: target.path = /tmp/$${TARGET}/bin
else: unix:!android: target.path = /opt/$${TARGET}/bin
!isEmpty(target.path): INSTALLS += target

HEADERS += \
    shadermodel.h \
    shaderparameterinfo.h \
    helper.h
