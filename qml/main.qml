import QtQuick 1.1
import com.nokia.symbian 1.1
import com.nokia.extras 1.1
import "functions.js" as ExtFunc
import tessera 1.0

PageStackWindow {
    id: mainWindow
    Component.onCompleted: {
        database.initDB();
    }

    property string accountName : ""
    property string secretkey   : ""
    property string oneTPass    : ""
    property int    accountId   : 0

    Database { id: database }
    Clipboard { id: clipboard }

    Component {
        id: accountDelegate

        Item {
            id: wrapper
            ListView.onRemove: SequentialAnimation {
                         PropertyAction { target: wrapper; property: "ListView.delayRemove"; value: true }
                         NumberAnimation { target: wrapper; property: "scale"; to: 0; duration: 250; easing.type: Easing.InOutQuad }
                         PropertyAction { target: wrapper; property: "ListView.delayRemove"; value: false }
                     }
            width: parent.width; height: data.height + line.height
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
                Column {
                    width: parent.width
                    Text {
                        text: '<font size="3" color="#ffffff"><b>' + service + '</b> - <font size="3" color="#bbbbbb">' + name + '</font>'
                        color: "white"
                        textFormat: Text.RichText
                        font.pixelSize: 18
                    }
                    Text {
                        id: itemCode
                        text: ExtFunc.getcode(secretKey)
                        color: "white"
                        font.pixelSize: 40
                    }
                }
            }
            ToolButton {
                id: deleteButton
                anchors { verticalCenter: parent.verticalCenter; right: parent.right }
                iconSource: "toolbar-menu"
                onClicked: {
                    mainWindow.accountName = service
                    mainWindow.accountId   = id
                    mainWindow.secretkey   = secretkey
                    mainWindow.oneTPass    = itemCode.text
                    accountMenu.open()
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

    Menu {
        id: accountMenu

        // define the items in the menu and corresponding actions
        content: MenuLayout {
            MenuItem {
                text: qsTr("Delete")
                onClicked: deleteAccountDialog.open()
            }
            MenuItem {
                text: qsTr("Copy to clipboard")
                onClicked: clipboard.setText(mainWindow.oneTPass);
            }
        }
    }

    StatusBar { id: sbar; x: 0; y: 0;
        Rectangle {
                  anchors { left: parent.left; leftMargin: 6; verticalCenter: parent.verticalCenter }
                  width: sbar.width - 183; height: parent.height
                  clip: true;
                  color: "#00000000"

                  Text{
                      id: statusBarText
                      anchors.verticalCenter: parent.verticalCenter
                      maximumLineCount: 1
                      x: 0
                      text: "Tessera"
                      color: "white"
                      font.pointSize: 6
                    }
                }
    }


    initialPage: Page {
        ListView {
            id: accounts
            anchors { top: information.bottom; left: parent.left; right: parent.right; bottom: parent.bottom; topMargin: 5 }
            model: database.accounts
            delegate: accountDelegate
            focus: true
            highlightRangeMode:  ListView.StrictlyEnforceRange
        }

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

        CommonDialog {
            id: appInfo
            buttonTexts: [qsTr("Ok")]
            titleText: "Tessera 1.1"

            content: Text {
                color: "white"
                font.pixelSize: 18
                id: dialogInfoLabel;
                wrapMode: Text.Wrap;
                anchors { left: parent.left; right: parent.right; top: parent.top; leftMargin: 10; topMargin: 5; rightMargin:10 }
                text: qsTr("by Maciej Janiszewski (pisarz1958)\n\nOpen-source app for time-based OTP authentication. Inspired by CuteAuthenticator (Juhapekka Piiroinen).\n\nDuring development of this software, no mobile device was harmed.\n\nThis program comes with ABSOLUTELY NO WARRANTY. This is free software, and you are welcome to redistribute it under certain conditions. See GPL v3 license for details.");
            }
        }

        CommonDialog {
            id: deleteAccountDialog
            buttonTexts: [qsTr("Yes"), qsTr("No")]
            titleText: "Confirmation"

            onButtonClicked: {
                if (index === 0) database.deleteAccount(mainWindow.accountId);
            }

            content: Text {
                color: "white"
                id: dialogQueryLabel;
                wrapMode: Text.Wrap;
                anchors { left: parent.left; right: parent.right; leftMargin: 10; rightMargin:10; verticalCenter: parent.verticalCenter }
                text: qsTr("Are you sure you want to remove your credentials for ") + mainWindow.accountName + qsTr("?");
            }
        }

        CommonDialog {
            id: addAccountDialog
            titleText: qsTr("Add account")

            buttonTexts: [qsTr("OK"), qsTr("Cancel")]

            onButtonClicked: {
                if (index === 0) {
                    if(( addService.text != "" ) && (addName.text != "" ) && (addKey.text != "") ) database.insertAccount(addService.text,addName.text,addKey.text);
                    addService.text = "";
                    addName.text = "";
                    addKey.text = "";
                }
            }

            content: Rectangle {
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

        tools: ToolBarLayout {
            ToolButton {
                iconSource: "toolbar-back"
                smooth: true
                onClicked: {
                    Qt.quit()
                }
            }
            ToolButton {
                iconSource: "toolbar-add"
                smooth: true
                onClicked: {
                    addAccountDialog.open()
                }
            }
            ToolButton {
                iconSource: "qrc:/toolbar_info"
                smooth: true
                onClicked: {
                    appInfo.open()
                }
            }
        }
    }

}

