import QtQuick

import ThemeEngine

Rectangle {
    id: appHeader
    anchors.top: parent.top
    anchors.left: parent.left
    anchors.right: parent.right

    height: headerHeight
    color: Theme.colorHeader
    z: 10

    property int headerHeight: isHdpi ? 58 : 64

    property int headerPosition:  64

    property string headerTitle: "WatchFlower"

    property bool headerCompact: singleColumn

    ////////////////////////////////////////////////////////////////////////////

    signal backButtonClicked()
    signal rightMenuClicked() // mobile header compatibility

    signal refreshButtonClicked()
    signal syncButtonClicked()
    signal scanButtonClicked()

    signal deviceRebootButtonClicked()
    signal deviceCalibrateButtonClicked()
    signal deviceWateringButtonClicked()
    signal deviceLedButtonClicked()
    signal deviceRefreshButtonClicked()
    signal deviceRefreshRealtimeButtonClicked()
    signal deviceRefreshHistoryButtonClicked()
    signal deviceClearButtonClicked()

    signal plantsButtonClicked()
    signal settingsButtonClicked()
    signal aboutButtonClicked()

    signal deviceDataButtonClicked()
    signal deviceHistoryButtonClicked()
    signal devicePlantButtonClicked()
    signal deviceSettingsButtonClicked()

    function setActiveMenu() {
        if (appContent.state === "Tutorial") {
            headerTitle = qsTr("Welcome")
            menus.visible = false

            buttonBack.source = "qrc:/assets/menus/menu_close.svg"
        } else {
            headerTitle = "WatchFlower"
            menus.visible = true

            if (appContent.state === "DeviceList") {
                buttonBack.source = "qrc:/assets/menus/menu_logo_large.svg"
            } else {
                buttonBack.source = "qrc:/assets/menus/menu_back.svg"
            }
        }
    }

    function setActiveDeviceData() {
        menuDeviceData.selected = true
        menuDeviceHistory.selected = false
        menuDevicePlant.selected = false
        menuDeviceSettings.selected = false
    }
    function setActiveDeviceHistory() {
        menuDeviceData.selected = false
        menuDeviceHistory.selected = true
        menuDevicePlant.selected = false
        menuDeviceSettings.selected = false
    }
    function setActiveDevicePlant() {
        menuDeviceData.selected = false
        menuDeviceHistory.selected = false
        menuDevicePlant.selected = true
        menuDeviceSettings.selected = false
    }
    function setActiveDeviceSettings() {
        menuDeviceData.selected = false
        menuDeviceHistory.selected = false
        menuDevicePlant.selected = false
        menuDeviceSettings.selected = true
    }

    ////////////////////////////////////////////////////////////////////////////

    DragHandler {
        // make that surface draggable
        // also, prevent clicks below this area
        onActiveChanged: if (active) appWindow.startSystemMove()
        target: null
    }

    ////////////////////////////////////////////////////////////////////////////

    MouseArea { // left button
        width: 40
        height: 40
        anchors.left: parent.left
        anchors.leftMargin: 12
        anchors.verticalCenter: parent.verticalCenter

        hoverEnabled: (buttonBack.source !== "qrc:/assets/menus/menu_logo_large.svg")
        onEntered: { buttonBackBg.opacity = 0.5; }
        onExited: { buttonBackBg.opacity = 0; buttonBack.width = 24; }

        onPressed: buttonBack.width = 20
        onReleased: buttonBack.width = 24
        onClicked: backButtonClicked()

        enabled: (buttonBack.source !== "qrc:/assets/menus/menu_logo_large.svg" || wideMode)
        visible: enabled

        Rectangle {
            id: buttonBackBg
            anchors.fill: parent
            radius: height
            z: -1
            color: Theme.colorHeaderHighlight
            opacity: 0
            Behavior on opacity { OpacityAnimator { duration: 333 } }
        }

        IconSvg {
            id: buttonBack
            width: 24
            height: width
            anchors.centerIn: parent

            source: "qrc:/assets/menus/menu_logo_large.svg"
            color: Theme.colorHeaderContent
        }
    }

    Text { // header title
        anchors.left: parent.left
        anchors.leftMargin: headerPosition
        anchors.right: menus.left
        anchors.rightMargin: 8
        anchors.verticalCenter: parent.verticalCenter

        visible: wideMode

        text: headerTitle
        font.bold: true
        font.pixelSize: Theme.fontSizeHeader
        color: Theme.colorHeaderContent
        elide: Text.ElideRight
    }

    ////////////////////////////////////////////////////////////////////////////

    Row {
        id: menus
        anchors.top: parent.top
        anchors.right: parent.right
        anchors.bottom: parent.bottom

        visible: true
        spacing: isHdpi ? 8 : 12

        // DEVICE ACTIONS //////////

        ButtonCompactable {
            id: buttonThermoChart
            height: compact ? 36 : 34
            anchors.verticalCenter: parent.verticalCenter

            compact: headerCompact
            visible: (appContent.state === "DeviceThermometer")

            source: (settingsManager.graphThermometer === "lines") ? "qrc:/assets/icons_material/duotone-insert_chart-24px.svg" : "qrc:/assets/icons_material/baseline-timeline-24px.svg";
            tooltipText: qsTr("Switch graph")
            iconColor: Theme.colorHeaderContent
            textColor: Theme.colorHeaderContent
            backgroundColor: Theme.colorHeaderHighlight

            onClicked: {
                if (settingsManager.graphThermometer === "lines")
                    settingsManager.graphThermometer = "minmax"
                else
                    settingsManager.graphThermometer = "lines"
            }
        }
        ButtonCompactable {
            id: buttonWatering
            height: compact ? 36 : 34
            anchors.verticalCenter: parent.verticalCenter

            compact: headerCompact
            visible: (deviceManager.bluetooth &&
                      (selectedDevice && selectedDevice.hasWaterTank) &&
                      (appContent.state === "DevicePlantSensor"))

            source: "qrc:/assets/icons_material/duotone-local_drink-24px.svg"
            tooltipText: qsTr("Watering")
            iconColor: Theme.colorHeaderContent
            textColor: Theme.colorHeaderContent
            backgroundColor: Theme.colorHeaderHighlight

            onClicked: deviceWateringButtonClicked()
        }
        ButtonCompactable {
            id: buttonCalibrate
            height: compact ? 36 : 34
            anchors.verticalCenter: parent.verticalCenter

            compact: headerCompact
            visible: (deviceManager.bluetooth &&
                      (selectedDevice && selectedDevice.hasCalibration) &&
                      (appContent.state === "DevicePlantSensor" ||
                       appContent.state === "DeviceThermometer" ||
                       appContent.state === "DeviceEnvironmental"))

            source: "qrc:/assets/icons_material/duotone-model_training-24px.svg"
            tooltipText: qsTr("Calibrate")
            iconColor: Theme.colorHeaderContent
            textColor: Theme.colorHeaderContent
            backgroundColor: Theme.colorHeaderHighlight

            onClicked: deviceCalibrateButtonClicked()
        }
        ButtonCompactable {
            id: buttonReboot
            height: compact ? 36 : 34
            anchors.verticalCenter: parent.verticalCenter

            compact: headerCompact
            visible: (deviceManager.bluetooth &&
                      (selectedDevice && selectedDevice.hasReboot) &&
                      (appContent.state === "DevicePlantSensor" ||
                       appContent.state === "DeviceThermometer" ||
                       appContent.state === "DeviceEnvironmental"))

            source: "qrc:/assets/icons_material/duotone-restart_alt-24px.svg"
            tooltipText: qsTr("Reboot")
            iconColor: Theme.colorHeaderContent
            textColor: Theme.colorHeaderContent
            backgroundColor: Theme.colorHeaderHighlight

            onClicked: deviceRebootButtonClicked()
        }
        ButtonCompactable {
            id: buttonLed
            height: compact ? 36 : 34
            anchors.verticalCenter: parent.verticalCenter

            compact: headerCompact
            visible: (deviceManager.bluetooth &&
                      (selectedDevice && selectedDevice.hasLED) &&
                      (appContent.state === "DevicePlantSensor" ||
                       appContent.state === "DeviceThermometer" ||
                       appContent.state === "DeviceEnvironmental"))

            source: "qrc:/assets/icons_material/duotone-emoji_objects-24px.svg"
            tooltipText: qsTr("Blink LED")
            iconColor: Theme.colorHeaderContent
            textColor: Theme.colorHeaderContent
            backgroundColor: Theme.colorHeaderHighlight

            onClicked: deviceLedButtonClicked()
        }

        ////////////

        Rectangle { // separator
            anchors.verticalCenter: parent.verticalCenter
            height: 40
            width: Theme.componentBorderWidth
            color: Theme.colorHeaderHighlight
            visible: (!singleColumn &&
                      (buttonThermoChart.visible || buttonWatering.visible ||
                       buttonCalibrate.visible || buttonReboot.visible ||
                       buttonLed.visible))
        }

        ////////////

        ButtonCompactable {
            id: buttonRefreshHistory
            height: compact ? 36 : 34
            anchors.verticalCenter: parent.verticalCenter

            compact: headerCompact
            visible: (deviceManager.bluetooth &&
                      (selectedDevice && selectedDevice.hasHistory) &&
                      (appContent.state === "DevicePlantSensor" ||
                       appContent.state === "DeviceThermometer" ||
                       appContent.state === "DeviceEnvironmental"))

            source: "qrc:/assets/icons_material/duotone-date_range-24px.svg"
            tooltipText: qsTr("Synchronize history")
            iconColor: Theme.colorHeaderContent
            textColor: Theme.colorHeaderContent
            backgroundColor: Theme.colorHeaderHighlight

            onClicked: deviceRefreshHistoryButtonClicked()
        }
        ButtonCompactable {
            id: buttonClearHistory
            height: compact ? 36 : 34
            anchors.verticalCenter: parent.verticalCenter

            compact: headerCompact
            visible: buttonRefreshHistory.visible

            source: "qrc:/assets/icons_material/duotone-date_clear-24px.svg"
            tooltipText: qsTr("Clear history")
            iconColor: Theme.colorHeaderContent
            textColor: Theme.colorHeaderContent
            backgroundColor: Theme.colorHeaderHighlight

            onClicked: deviceClearButtonClicked()
        }

        ////////////

        Rectangle { // separator
            anchors.verticalCenter: parent.verticalCenter
            height: 40
            width: Theme.componentBorderWidth
            color: Theme.colorHeaderHighlight
            visible: (!singleColumn && buttonRefreshHistory.visible)
        }

        ////////////

        ButtonCompactable {
            id: buttonRefreshRealtime
            height: compact ? 36 : 34
            anchors.verticalCenter: parent.verticalCenter

            compact: headerCompact
            visible: (deviceManager.bluetooth &&
                      (selectedDevice && selectedDevice.hasRealTime) &&
                      (appContent.state === "DevicePlantSensor" ||
                       appContent.state === "DeviceThermometer" ||
                       appContent.state === "DeviceEnvironmental"))

            source: "qrc:/assets/icons_material/duotone-update-24px.svg"
            tooltipText: qsTr("Real time data")
            iconColor: Theme.colorHeaderContent
            textColor: Theme.colorHeaderContent
            backgroundColor: Theme.colorHeaderHighlight

            onClicked: deviceRefreshRealtimeButtonClicked()
        }
        ButtonCompactable {
            id: buttonRefreshData
            height: compact ? 36 : 34
            anchors.verticalCenter: parent.verticalCenter

            compact: headerCompact
            visible: (deviceManager.bluetooth &&
                      (selectedDevice && selectedDevice.hasBluetoothConnection) &&
                      (appContent.state === "DevicePlantSensor" ||
                       appContent.state === "DeviceThermometer" ||
                       appContent.state === "DeviceEnvironmental"))

            source: "qrc:/assets/icons_material/baseline-refresh-24px.svg"
            tooltipText: qsTr("Refresh sensor")
            iconColor: Theme.colorHeaderContent
            textColor: Theme.colorHeaderContent
            backgroundColor: Theme.colorHeaderHighlight

            onClicked: deviceRefreshButtonClicked()

            animation: "rotate"
            animationRunning: selectedDevice ? selectedDevice.updating : false
        }

        ////////////

        Rectangle { // separator
            anchors.verticalCenter: parent.verticalCenter
            height: 40
            width: Theme.componentBorderWidth
            color: Theme.colorHeaderHighlight
            visible: (!singleColumn && menuDevice.visible &&
                      (buttonRefreshHistory.visible ||
                       buttonRefreshRealtime.visible ||
                       buttonRefreshData.visible))
        }

        // DEVICE MENU //////////

        Row {
            id: menuDevice
            spacing: 0

            visible: (appContent.state === "DevicePlantSensor" ||
                      appContent.state === "DeviceThermometer" ||
                      appContent.state === "DeviceEnvironmental")

            DesktopHeaderItem {
                id: menuDeviceData
                height: headerHeight

                text: headerCompact ? "" : qsTr("Data")
                source: "qrc:/assets/icons_material/duotone-insert_chart-24px.svg"
                colorContent: Theme.colorHeaderContent
                colorHighlight: Theme.colorHeaderHighlight

                onClicked: deviceDataButtonClicked()
            }
            DesktopHeaderItem {
                id: menuDeviceHistory
                height: headerHeight

                visible: (appContent.state === "DevicePlantSensor")

                text: headerCompact ? "" : qsTr("History")
                source: "qrc:/assets/icons_material/duotone-date_range-24px.svg"
                colorContent: Theme.colorHeaderContent
                colorHighlight: Theme.colorHeaderHighlight

                onClicked: deviceHistoryButtonClicked()
            }
            DesktopHeaderItem {
                id: menuDevicePlant
                height: headerHeight

                visible: (appContent.state === "DevicePlantSensor")

                text: headerCompact ? "" : qsTr("Plant")
                source: "qrc:/assets/icons_custom/duotone-plant_care-24px.svg"
                colorContent: Theme.colorHeaderContent
                colorHighlight: Theme.colorHeaderHighlight

                onClicked: devicePlantButtonClicked()
            }
            DesktopHeaderItem {
                id: menuDeviceSettings
                height: headerHeight

                text: headerCompact ? "" : qsTr("Sensor")
                source: "qrc:/assets/icons_material/duotone-memory-24px.svg"
                colorContent: Theme.colorHeaderContent
                colorHighlight: Theme.colorHeaderHighlight

                onClicked: deviceSettingsButtonClicked()
            }
        }

        // MAIN MENU ACTIONS //////////

        ButtonCompactable {
            id: buttonSort
            height: compact ? 36 : 34
            anchors.verticalCenter: parent.verticalCenter

            compact: headerCompact
            visible: (appContent.state === "DeviceList")
            enabled: visible

            source: "qrc:/assets/icons_material/baseline-filter_list-24px.svg"
            iconColor: Theme.colorHeaderContent
            textColor: Theme.colorHeaderContent
            backgroundColor: Theme.colorHeaderHighlight

            function setText() {
                var txt = qsTr("Order by:") + " "
                if (settingsManager.orderBy === "waterlevel") {
                    txt += qsTr("water level")
                } else if (settingsManager.orderBy === "plant") {
                    txt += qsTr("plant name")
                } else if (settingsManager.orderBy === "model") {
                    txt += qsTr("sensor model")
                } else if (settingsManager.orderBy === "location") {
                    txt += qsTr("location")
                }
                buttonSort.tooltipText = txt
            }

            Component.onCompleted: buttonSort.setText()
            Connections {
                target: settingsManager
                function onOrderByChanged() { buttonSort.setText() }
                function onAppLanguageChanged() { buttonSort.setText() }
            }

            property var sortmode: {
                if (settingsManager.orderBy === "waterlevel") {
                    return 3
                } else if (settingsManager.orderBy === "plant") {
                    return 2
                } else if (settingsManager.orderBy === "model") {
                    return 1
                } else { // if (settingsManager.orderBy === "location") {
                    return 0
                }
            }

            onClicked: {
                sortmode++
                if (sortmode > 3) sortmode = 0

                if (sortmode === 0) {
                    settingsManager.orderBy = "location"
                    deviceManager.orderby_location()
                } else if (sortmode === 1) {
                    settingsManager.orderBy = "model"
                    deviceManager.orderby_model()
                } else if (sortmode === 2) {
                    settingsManager.orderBy = "plant"
                    deviceManager.orderby_plant()
                } else if (sortmode === 3) {
                    settingsManager.orderBy = "waterlevel"
                    deviceManager.orderby_waterlevel()
                }
            }
        }

        Rectangle { // separator
            anchors.verticalCenter: parent.verticalCenter
            height: 40
            width: Theme.componentBorderWidth
            color: Theme.colorHeaderHighlight
            visible: (deviceManager.bluetooth && appContent.state === "DeviceList")
        }

        ButtonCompactable {
            id: buttonScan
            height: compact ? 36 : 34
            anchors.verticalCenter: parent.verticalCenter

            compact: headerCompact
            visible: (deviceManager.bluetooth && menuMain.visible)
            enabled: (!deviceManager.syncing)

            text: qsTr("Scan")
            tooltipText: qsTr("Scan for new sensors")
            source: "qrc:/assets/icons_material/baseline-search-24px.svg"
            iconColor: Theme.colorHeaderContent
            textColor: Theme.colorHeaderContent
            backgroundColor: Theme.colorHeaderHighlight

            onClicked: scanButtonClicked()

            animation: "fade"
            animationRunning: deviceManager.scanning
        }
        ButtonCompactable {
            id: buttonSyncAll
            height: compact ? 36 : 34
            anchors.verticalCenter: parent.verticalCenter

            compact: headerCompact
            visible: (deviceManager.bluetooth && menuMain.visible)
            enabled: (!deviceManager.scanning)

            text: qsTr("Sync history")
            tooltipText: qsTr("Sync sensors history")
            source: "qrc:/assets/icons_custom/duotone-date_all-24px.svg"
            iconColor: Theme.colorHeaderContent
            textColor: Theme.colorHeaderContent
            backgroundColor: Theme.colorHeaderHighlight

            onClicked: syncButtonClicked()

            animation: "fade"
            animationRunning: deviceManager.syncing
        }
        ButtonCompactable {
            id: buttonRefreshAll
            height: compact ? 36 : 34
            anchors.verticalCenter: parent.verticalCenter

            compact: headerCompact
            visible: (deviceManager.bluetooth && menuMain.visible)
            enabled: (!deviceManager.syncing)

            text: qsTr("Refresh data")
            tooltipText: qsTr("Refresh sensor data")
            source: "qrc:/assets/icons_material/baseline-autorenew-24px.svg"
            iconColor: Theme.colorHeaderContent
            textColor: Theme.colorHeaderContent
            backgroundColor: Theme.colorHeaderHighlight

            onClicked: refreshButtonClicked()

            animation: {
                if (deviceManager.updating && deviceManager.listening) return "both"
                if (deviceManager.updating) return "rotate"
                if (deviceManager.listening) return "fade"
                return ""
            }
            animationRunning: (deviceManager.updating || deviceManager.listening)
        }

        Rectangle { // separator
            anchors.verticalCenter: parent.verticalCenter
            height: 40
            width: Theme.componentBorderWidth
            color: Theme.colorHeaderHighlight
            visible: (deviceManager.bluetooth && menuMain.visible)
        }

        // MAIN MENU //////////

        Row {
            id: menuMain

            visible: (appContent.state === "DeviceList" ||
                      appContent.state === "DeviceBrowser" ||
                      appContent.state === "PlantBrowser" ||
                      appContent.state === "Settings" ||
                      appContent.state === "About")
            spacing: 0

            DesktopHeaderItem {
                id: menuPlants
                height: headerHeight

                text: headerCompact ? "" : qsTr("Sensor list")
                source: "qrc:/assets/logos/watchflower_tray_dark.svg"
                colorContent: Theme.colorHeaderContent
                colorHighlight: Theme.colorHeaderHighlight

                selected: (appContent.state === "DeviceList")
                onClicked: plantsButtonClicked()
            }
            DesktopHeaderItem {
                id: menuSettings
                height: headerHeight

                text: headerCompact ? "" : qsTr("Settings")
                source: "qrc:/assets/icons_material/baseline-settings-20px.svg"
                colorContent: Theme.colorHeaderContent
                colorHighlight: Theme.colorHeaderHighlight

                selected: (appContent.state === "Settings")
                onClicked: settingsButtonClicked()
            }
            DesktopHeaderItem {
                id: menuAbout
                height: headerHeight

                source: "qrc:/assets/menus/menu_infos.svg"
                colorContent: Theme.colorHeaderContent
                colorHighlight: Theme.colorHeaderHighlight

                text: headerCompact ? "" : qsTr("About")
                selected: (appContent.state === "About")
                onClicked: aboutButtonClicked()
            }
        }
    }

    ////////////////////////////////////////////////////////////////////////////

    Rectangle { // bottom separator
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom

        visible: (!headerUnicolor &&
                  appContent.state !== "DeviceThermometer" &&
                  appContent.state !== "DeviceEnvironmental" &&
                  appContent.state !== "Tutorial")

        height: 2
        opacity: 0.33
        color: Theme.colorHeaderHighlight
    }
}
