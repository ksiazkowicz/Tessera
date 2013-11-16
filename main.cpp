#include <QtGui/QApplication>
#include <QUrl>
#include <qdeclarative.h>
#include <qmlapplicationviewer.h>

#include "DatabaseManager.h"
#include "QAvkonHelper.h"
#define TESSERA_NAMESPACE "tessera"

Q_DECL_EXPORT int main(int argc, char *argv[])
{
    QScopedPointer<QApplication> app( createApplication(argc, argv) );

    qmlRegisterType<DatabaseManager>(TESSERA_NAMESPACE, 1, 0, "Database" );
    qmlRegisterType<ClipboardAdapter>(TESSERA_NAMESPACE, 1, 0, "Clipboard" );
    qmlRegisterUncreatableType<SqlQueryModel>(TESSERA_NAMESPACE, 1, 0, "SqlQuery", "");

    QmlApplicationViewer viewer;
    viewer.setAttribute(Qt::WA_OpaquePaintEvent);
    viewer.setAttribute(Qt::WA_NoSystemBackground);
    viewer.viewport()->setAttribute(Qt::WA_OpaquePaintEvent);
    viewer.viewport()->setAttribute(Qt::WA_NoSystemBackground);
    viewer.setOrientation(QmlApplicationViewer::ScreenOrientationAuto);

    viewer.setSource( QUrl(QLatin1String("qrc:/qml/main.qml")) );
    viewer.showFullScreen();

    return app->exec();
}


