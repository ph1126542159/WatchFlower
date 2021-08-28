import QtQuick 2.12
import QtQuick.Controls 2.12
import QtGraphicalEffects 1.12

import ThemeEngine 1.0
import "qrc:/js/UtilsNumber.js" as UtilsNumber

Button {
    id: control
    implicitWidth: contentRow.width + 16 + ((source && !text) ? 0 : 16)
    implicitHeight: Theme.componentHeight

    font.pixelSize: Theme.fontSizeComponent
    font.bold: fullColor ? true : false

    focusPolicy: Qt.NoFocus

    // actions
    signal clicked()
    signal pressed()
    signal pressAndHold()

    // settings
    property alias source: contentImage.source
    property bool sourceRightToLeft: false
    property int imgSize: UtilsNumber.alignTo(height * 0.666, 2)

    // colors
    property bool fullColor: false
    property string fulltextColor: "white"
    property string primaryColor: Theme.colorPrimary
    property string secondaryColor: Theme.colorComponentBackground

    // animation
    property bool hoverAnimation: isDesktop

    ////////////////////////////////////////////////////////////////////////////

    background: Rectangle {
        radius: Theme.componentRadius
        opacity: enabled ? (control.down && !hoverAnimation ? 0.8 : 1.0) : 0.33
        color: fullColor ? control.primaryColor : control.secondaryColor
        border.width: Theme.componentBorderWidth
        border.color: fullColor ? control.primaryColor : Theme.colorComponentBorder

        MouseArea {
            anchors.fill: parent
            propagateComposedEvents: false
            hoverEnabled: hoverAnimation

            onClicked: {
                control.clicked()
            }
            onPressed: {
                control.pressed()
                control.down = true
                mouseBackground.width = background.width*2
                mouseBackground.opacity = 0.16
            }
            onPressAndHold: {
                control.pressAndHold()
                control.down = true
            }
            onReleased: {
                control.released()
                control.down = false
                mouseBackground.width = 0
                mouseBackground.opacity = 0
            }
            onEntered: {
                mouseBackground.width = 72
                mouseBackground.opacity = 0.16
            }
            onExited: {
                control.down = false
                mouseBackground.width = 0
                mouseBackground.opacity = 0
            }
            onCanceled: {
                control.down = false
                mouseBackground.width = 0
                mouseBackground.opacity = 0
            }

            Rectangle {
                id: mouseBackground
                width: 0; height: width; radius: width;
                x: parent.mouseX - (mouseBackground.width / 2)
                y: parent.mouseY - (mouseBackground.width / 2)

                visible: hoverAnimation
                color: "white"
                opacity: 0
                Behavior on opacity { NumberAnimation { duration: 200 } }
                Behavior on width { NumberAnimation { duration: 200 } }
            }

            layer.enabled: hoverAnimation
            layer.effect: OpacityMask {
                maskSource: Rectangle {
                    x: background.x
                    y: background.y
                    width: background.width
                    height: background.height
                    radius: background.radius
                }
            }
        }
    }

    ////////////////////////////////////////////////////////////////////////////

    contentItem: Item {
        Row {
            id: contentRow
            height: parent.height
            anchors.horizontalCenter: parent.horizontalCenter

            layoutDirection: (control.sourceRightToLeft) ? Qt.RightToLeft : Qt.LeftToRight
            spacing: 8

            ImageSvg {
                id: contentImage
                width: imgSize
                height: imgSize
                anchors.verticalCenter: parent.verticalCenter

                opacity: enabled ? 1.0 : 0.33
                color: fullColor ? fulltextColor : control.primaryColor
            }
            Text {
                id: contentText
                height: parent.height

                text: control.text
                textFormat: Text.PlainText
                font: control.font
                opacity: enabled ? (control.down && !hoverAnimation ? 0.8 : 1.0) : 0.33
                color: fullColor ? fulltextColor : control.primaryColor
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
                elide: Text.ElideRight
            }
        }
    }
}
