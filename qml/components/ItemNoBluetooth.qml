import QtQuick

import ThemeEngine

Rectangle {
    id: itemNoBluetooth
    anchors.centerIn: parent
    anchors.verticalCenterOffset: -40

    width: singleColumn ? (parent.width*0.5) : (parent.height*0.4)
    height: width
    radius: width
    color: Theme.colorForeground

    IconSvg {
        anchors.centerIn: parent
        width: parent.width*0.8
        height: width

        source: "qrc:/assets/icons_material/baseline-bluetooth_disabled-24px.svg"
        fillMode: Image.PreserveAspectFit
        color: Theme.colorIcon
        opacity: 0.9
        smooth: true
    }

    Text {
        anchors.top: parent.bottom
        anchors.topMargin: 20
        anchors.horizontalCenter: parent.horizontalCenter

        text: qsTr("Bluetooth is not available...")
        textFormat: Text.PlainText
        font.pixelSize: Theme.fontSizeContentBig
        color: Theme.colorText

        ButtonWireframe {
            anchors.top: parent.bottom
            anchors.topMargin: 16
            anchors.horizontalCenter: parent.horizontalCenter

            fullColor: true
            text: (Qt.platform.os === "android") ? qsTr("Enable") : qsTr("Retry")
            onClicked: (Qt.platform.os === "android") ? deviceManager.enableBluetooth() : deviceManager.checkBluetooth()
        }
    }
}
