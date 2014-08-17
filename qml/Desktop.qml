import QtQuick 2.2
import QtQuick.Controls 1.1
import QtQuick.Dialogs 1.2

import tessera 1.0
import "functions.js" as ExtFunc

ApplicationWindow {
    visible: true
    width: 640
    height: 480
    title: qsTr("Tessera")

    Component.onCompleted: database.initDB();

    property string accountName : ""
    property string secretkey   : ""
    property string oneTPass    : ""
    property int    accountId   : 0

    Database { id: database }
    Clipboard { id: clipboard }

    Rectangle {
      id: information
      property alias title: titleText.text
      property alias titleColor: titleText.color
      property string themeColor: "#007dc9"

      width: parent ? parent.width : 0
      height: 72
      color: "black"

      Rectangle {
          color: parent.themeColor
          anchors.fill: parent
          radius: 8
      }

      Rectangle {
          color: parent.themeColor
          anchors { left: parent.left; right: parent.right; bottom: parent.bottom }
          height: 8
      }

      Text {
        id: titleText
        x: 16
        text: "Verification codes"
        anchors.verticalCenter: parent.verticalCenter
        color: "white"
        font.pixelSize: 32
      }

      Rectangle {
        height: 1
        width: parent.width
        anchors.bottom: parent.bottom
        color: "#10000000"
      }

      Rectangle {
        height: 1
        width: parent.width
        anchors.top: parent.bottom
        anchors.topMargin: 1
        color: "white"
      }
    }

    Component {
        id: accountDelegate

        Item {
            id: wrapper
            ListView.onRemove: SequentialAnimation {
                         PropertyAction { target: wrapper; property: "ListView.delayRemove"; value: true }
                         NumberAnimation { target: wrapper; property: "scale"; to: 0; duration: 250; easing.type: Easing.InOutQuad }
                         PropertyAction { target: wrapper; property: "ListView.delayRemove"; value: false }
                     }
            width: parent.width;
            height: data.height + line.height
            anchors { left: parent.left; right: parent.right; leftMargin: 10; rightMargin: 10 }
            Timer {
                interval: 1000
                running: true
                repeat: true
                onTriggered: {
                    itemCode.opacity -= 1/30
                    var newCode = ExtFunc.getcode(secretKey)
                    if (itemCode.text!=newCode) {
                        itemCode.text = newCode
                        codeRenewal.restart();
                        itemCode.opacity = 1
                    }
                }
            }

            Timer {
                id: codeRenewal
                  // Interval in milliseconds. It must be interval values.
                  interval: 30000
                 // Setting running to true indicates start the timer. It must be boolean  value.
                  running: true
                  //If repeat is set true, the timer will repeat at specified interval. Here it is 1000 milliseconds.
                  repeat: true
                  // This will be called when the timer is triggered. Here the
                  // subroutine changeBoxColor() will be called at every 1 seconde (1000 milliseconds)
                  onTriggered: {
                      itemCode.text = ExtFunc.getcode(secretKey)
                      itemCode.opacity = 1
                  }
              }
            Row {
                id: data
                spacing: 10
                height: itemName.paintedHeight + itemCode.paintedHeight
                Column {
                    width: parent.width
                    Text {
                        id: itemName
                        text: '<font size="3"><b>' + service + '</b> - <font size="3" color="#bbbbbb">' + name + '</font>'
                        textFormat: Text.RichText
                        font.pixelSize: 18
                    }
                    Text {
                        id: itemCode
                        text: ExtFunc.getcode(secretKey)
                        font.pixelSize: 40
                    }
                }
            }
            ToolButton {
                id: deleteButton
                anchors { verticalCenter: parent.verticalCenter; right: parent.right }
                iconSource: "toolbar-menu"
                onClicked: {
                    accountName = service
                    accountId   = id
                    secretkey   = secretkey
                    oneTPass    = itemCode.text
                    accountMenu.popup()
                }
            }
            Rectangle {
                id: line
                anchors.top: data.bottom
                height: 2
                anchors.topMargin: -2
                opacity: 0.5
                width: parent.width
                color: "gray"
            }
        }
    }

    ListView {
        id: accounts
        anchors { top: information.bottom; left: parent.left; right: parent.right; bottom: parent.bottom; topMargin: 5 }
        model: database.accounts
        delegate: accountDelegate
        focus: true
        highlightRangeMode:  ListView.StrictlyEnforceRange
    }

    MessageDialog {
        id: appInfo
        title: "About Tessera..."
        text: "Tessera 1.2 by Maciej Janiszewski (pisarz1958)\n\nOpen-source app for time-based OTP authentication. Inspired by CuteAuthenticator (Juhapekka Piiroinen).\n\nDuring development of this software, no mobile device was harmed.\n\nThis program comes with ABSOLUTELY NO WARRANTY. This is free software, and you are welcome to redistribute it under certain conditions. See GPL v3 license for details."
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
            width: parent.width-20
            height: column.height
            anchors.horizontalCenter: parent.horizontalCenter
            color: "transparent"

            Column {
                id: column
                spacing: 2
                width: parent.width
                Label { anchors.horizontalCenter: parent.horizontalCenter; text: qsTr("Service name:")}
                TextField {
                    id: addService;  height: 36
                    anchors { left: parent.left; right: parent.right }
                    placeholderText: qsTr("ex. Google, Evernote...")
                }
                Label { anchors.horizontalCenter: parent.horizontalCenter; text: qsTr("Account name:")}
                TextField {
                    id: addName;  height: 36
                    anchors { left: parent.left; right: parent.right }
                    placeholderText: qsTr("Name")
                }
                Label { anchors.horizontalCenter: parent.horizontalCenter; text: "Secret key:"}
                TextField {
                    id: addKey; height: 36
                    anchors { left: parent.left; right: parent.right }
                    placeholderText: qsTr("Secret key")
                }

            }
        }
    }

    menuBar: MenuBar {
        Menu {
            title: qsTr("File")
            MenuItem {
                text: qsTr("Add key")
                onTriggered: addAccountDialog.open()
            }
            MenuItem {
                text: qsTr("About Tesera...")
                onTriggered: appInfo.open()
            }
            MenuSeparator {}
            MenuItem {
                text: qsTr("Exit")
                onTriggered: Qt.quit();
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
