import QtQuick 2.2
import QtQuick.Controls 1.1
import QtQuick.Dialogs 1.2

import tessera 1.0
import "functions.js" as ExtFunc

ApplicationWindow {
    visible: true
    width: 320
    minimumWidth: 320
    height: 480
    minimumHeight: 200
    title: qsTr("Tessera")

    Component.onCompleted: database.initDB();

    property string accountName
    property string secretkey
    property string oneTPass
    property int    accountId: 0

    Database { id: database }
    Clipboard { id: clipboard }

    Component {
        id: accountDelegate

        Item {
            id: wrapper

            property bool isOpen: false;
            property int secondsLeft: 30
            property int millisecondsLeft: 0

            MouseArea {
                acceptedButtons: Qt.RightButton
                anchors.fill: parent;
                onClicked: {
                    accountName = service
                    accountId   = id
                    secretkey   = secretkey
                    oneTPass    = itemCode.text
                    accountMenu.popup()
                }
            }

            ListView.onRemove: SequentialAnimation {
                         PropertyAction { target: wrapper; property: "ListView.delayRemove"; value: true }
                         NumberAnimation { target: wrapper; property: "scale"; to: 0; duration: 250; easing.type: Easing.InOutQuad }
                         PropertyAction { target: wrapper; property: "ListView.delayRemove"; value: false }
                     }
            height: header.height + data.height + (isOpen ? 9 : 0) -1
            anchors { left: parent.left; right: parent.right }
            Timer {
                interval: 10
                running: true
                repeat: true
                onTriggered: {
                    if (millisecondsLeft <= 0) {
                        millisecondsLeft = 99;
                        secondsLeft--;
                    } else millisecondsLeft--;

                    if (secondsLeft <=0) {
                        itemCode.text = ExtFunc.getcode(secretKey);
                        secondsLeft = 30;
                        millisecondsLeft = 0;
                    }
                }
            }
            MouseArea {
                id: header
                Rectangle {
                    anchors.top: parent.top;
                    height: 1
                    width: parent.width
                    color: "gray"
                }

                Image {
                    source: isOpen ? "qrc:/desktopGfx/arrowExpanded" : "qrc:/desktopGfx/arrowCollapsed"
                    anchors { verticalCenter: parent.verticalCenter; leftMargin: 11; left: parent.left; }
                }

                Text {
                    font.pointSize: 9
                    text: name
                    font.family: "Segoe UI Semilight"
                    anchors { verticalCenter: parent.verticalCenter; leftMargin: 23; left: parent.left }
                }
                Text {
                    font.pointSize: 9
                    text: service
                    font.family: "Segoe UI"
                    anchors { verticalCenter: parent.verticalCenter; rightMargin: 8; right: parent.right }
                }

                height: 27
                width: parent.width

                acceptedButtons: Qt.LeftButton
                onClicked: wrapper.isOpen = !wrapper.isOpen

                Rectangle {
                    anchors { bottom: parent.bottom; horizontalCenter: parent.horizontalCenter }
                    width: parent.width - 8
                    height: 1
                    color: "#bbbbbb"
                    visible: isOpen
                }
            }

            Row {
                id: data
                width: parent.width
                anchors { top: header.bottom; topMargin: 5; left: parent.left; leftMargin: 23; right: parent.right; rightMargin: 23; }
                visible: isOpen
                spacing: 16
                Column {
                    spacing: -5
                    Text {
                        text: "Current code:"
                        font.pointSize: 9
                        font.family: "Segoe UI Semilight"
                        visible: isOpen
                    }
                    Text {
                        id: itemCode
                        text: ExtFunc.getcode(secretKey)
                        font.pointSize: 26
                        visible: isOpen
                    }
                }
                Column {
                    spacing: -5
                    Text {
                        text: "Changing in:"
                        font.pointSize: 9
                        font.family: "Segoe UI Semilight"
                        visible: isOpen
                    }
                    Text {
                        text: "00:" + (secondsLeft < 10 ? "0"+secondsLeft : secondsLeft) + ":" + (millisecondsLeft < 10 ? "0"+millisecondsLeft : millisecondsLeft)
                        font.pointSize: 26
                        visible: isOpen
                    }
                }
            }

            Rectangle {
                anchors { bottom: parent.bottom; bottomMargin: -1 }
                height: 1
                width: parent.width
                color: "gray"
            }
        }
    }

    ScrollView {
        anchors { bottom: parent.bottom; left: parent.left; right: parent.right; top: toolBar.bottom }
        ListView {
            id: accounts
            anchors { fill: parent; topMargin: -2; }
            model: database.accounts
            delegate: accountDelegate
            focus: true
        }
    }

    MessageDialog {
        id: appInfo
        title: "About Tessera..."
        text: "Tessera 1.2 by Maciej Janiszewski (pisarz1958)\n\nOpen-source app for time-based OTP authentication. Inspired by CuteAuthenticator (Juhapekka Piiroinen).\n\nDuring development of this software, no mobile device was harmed.\n\nDesktop UI designed by Tomek Cichoń (Ciastex) ^^\n\nThis program comes with ABSOLUTELY NO WARRANTY. This is free software, and you are welcome to redistribute it under certain conditions. See GPL v3 license for details."
    }


    MessageDialog {
        id: deleteAccountDialog
        title: "Confirmation"
        standardButtons: StandardButton.Ok | StandardButton.Cancel

        onAccepted: database.deleteAccount(accountId);

        text: "Are you sure you want to remove your credentials for " + accountName + "?";
    }

    Dialog {
        id: addAccountDialog
        title: qsTr("Add account")

        standardButtons: StandardButton.Ok | StandardButton.Cancel

        onAccepted:  {
            if(( addService.text != "" ) && (addName.text != "" ) && (addKey.text != "") )
                database.insertAccount(addService.text,addName.text,addKey.text);
            addService.text = "";
            addName.text = "";
            addKey.text = "";
        }

        Rectangle {
            width: parent.width
            height: addService.height + addName.height + addKey.height + 2*label.height
            anchors.horizontalCenter: parent.horizontalCenter
            color: "transparent"

            Column {
                id: column
                spacing: 2
                width: parent.width
                Label { id: label; anchors.horizontalCenter: parent.horizontalCenter; text: qsTr("Service name:")}
                TextField {
                    id: addService
                    anchors { left: parent.left; right: parent.right }
                    placeholderText: qsTr("ex. Google, Evernote...")
                }
                Label { anchors.horizontalCenter: parent.horizontalCenter; text: qsTr("Account name:")}
                TextField {
                    id: addName
                    anchors { left: parent.left; right: parent.right }
                    placeholderText: qsTr("Name")
                }
                Label { anchors.horizontalCenter: parent.horizontalCenter; text: "Secret key:"}
                TextField {
                    id: addKey
                    anchors { left: parent.left; right: parent.right }
                    placeholderText: qsTr("Secret key")
                }

            }
        }
    }

    Rectangle {
        id: toolBar
        color: "white"
        anchors { top: parent.top; left: parent.left; margins: -1; right: parent.right }
        height: 25
        border.color: "#dadbdc"
        border.width: 1

        Row {
            spacing: 10
            anchors { top: parent.top; topMargin: 1; }
            Rectangle {
                width: 83
                height: 23
                color: "#1979ca"
                MouseArea { anchors.fill: parent; onClicked: addAccountDialog.open(); }
                Label { anchors.centerIn: parent; text: "Add account"; color: "white" }
            }
            ToolButton {
                text: qsTr("About Tesera...")
                anchors { verticalCenter: parent.verticalCenter }
                onClicked: appInfo.open()
            }
            ToolButton {
                text: qsTr("Exit")
                anchors { verticalCenter: parent.verticalCenter }
                onClicked: Qt.quit();
            }
        }
    }

    Menu {
        id: accountMenu

        // define the items in the menu and corresponding actions
        MenuItem {
          text: qsTr("Delete")
          onTriggered: deleteAccountDialog.open()
        }
        MenuItem {
          text: qsTr("Copy to clipboard")
          onTriggered: clipboard.setText(oneTPass);
        }
    }

}
