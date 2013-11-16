# Add more folders to ship with the application, here
#folder_01.source = qml
#folder_01.target = qml
#DEPLOYMENTFOLDERS = folder_01

# Additional import path used to resolve QML modules in Creator's code model
#QML_IMPORT_PATH =

VERSION = 1.0.0

QT += declarative \
      network \
      sql

symbian {
    TARGET.UID3 = 0xEC338740
    TARGET.CAPABILITY += NetworkServices
    CONFIG += qt-components

    vendorinfo += "%{\"n1958 Apps\"}" ":\"n1958 Apps\""
    my_deployment.pkg_prerules = vendorinfo
    DEPLOYMENT += my_deployment
    DEPLOYMENT.display_name = Tessera

    DEFINES += APP_VERSION=\"$$VERSION\"
}

# Define QMLJSDEBUGGER to allow debugging of QML in debug builds
# (This might significantly increase build time)
# DEFINES += QMLJSDEBUGGER

# If your application uses the Qt Mobility libraries, uncomment
# the following lines and add the respective components to the 
# MOBILITY variable. 
# CONFIG += mobility
# MOBILITY +=

# The .cpp file which was generated for your project. Feel free to hack it.
SOURCES += main.cpp \
    DatabaseManager.cpp

OTHER_FILES += qml/main.qml \
               qml/function.js

# Please do not modify the following two lines. Required for deployment.
include(qmlapplicationviewer/qmlapplicationviewer.pri)
qtcAddDeployment()

RESOURCES += \
    resources.qrc

HEADERS += QAvkonHelper.h \
    DatabaseManager.h
