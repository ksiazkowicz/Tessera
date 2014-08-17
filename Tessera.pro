VERSION = 1.2.0

TEMPLATE = app
QT += sql declarative

# Default rules for deployment.
include(deployment.pri)

symbian {
    TARGET.UID3 = 0xEC338740
    TARGET.CAPABILITY += NetworkServices
    CONFIG += qt-components

    vendorinfo += "%{\"n1958 Apps\"}" ":\"n1958 Apps\""
    my_deployment.pkg_prerules = vendorinfo
    DEPLOYMENT += my_deployment
    DEPLOYMENT.display_name = Tessera

    DEFINES += APP_VERSION=\"$$VERSION\"

    include(qmlapplicationviewer/qmlapplicationviewer.pri)
    qtcAddDeployment()
} else {
    QT += qml quick widgets
}

SOURCES += main.cpp \
    DatabaseManager.cpp

RESOURCES += resources.qrc

HEADERS += QAvkonHelper.h \
    DatabaseManager.h
