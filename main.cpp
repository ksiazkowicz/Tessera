#include <QApplication>

#include "DatabaseManager.h"
#include "QAvkonHelper.h"

// import different QML stuff for Qt 5 and Qt 4
#if QT_VERSION < 0x050000
#include <qdeclarative.h>
#include <qmlapplicationviewer.h>
#else
#include <QQmlApplicationEngine>
#include <QtQml>
#endif

Q_DECL_EXPORT int main(int argc, char *argv[]) {
    QApplication app(argc, argv);

    // register types
    qmlRegisterType<DatabaseManager>("tessera", 1, 0, "Database" );
    qmlRegisterType<ClipboardAdapter>("tessera", 1, 0, "Clipboard" );
    qmlRegisterUncreatableType<SqlQueryModel>("tessera", 1, 0, "SqlQuery", "");

    // do my cool qt4 stuff
    #if QT_VERSION < 0x050000
    QmlApplicationViewer viewer;
    viewer.setSource( QUrl(QLatin1String("qrc:/qml/Symbian.qml")) );
    viewer.showFullScreen();
    #else
    // Qt5 cool stuff
    QQmlApplicationEngine engine;
    engine.load(QUrl(QStringLiteral("qrc:///qml/Desktop.qml")));
    #endif
    return app.exec();
}

