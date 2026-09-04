/****************************************************************************
 *
 * (c) 2009-2026 QGROUNDCONTROL PROJECT <http://www.qgroundcontrol.org>
 *
 * QGroundControl is licensed according to the terms in the file
 * COPYING.md in the root of the source code directory.
 *
 ****************************************************************************/

import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import QGroundControl
import QGroundControl.Controls
import QGroundControl.Palette
import QGroundControl.ScreenTools

// Custom build: on-map tool for live-adjusting the vehicle icon color and size while flying
Rectangle {
    id:             control
    implicitWidth:  expanded ? expandedColumn.implicitWidth + _margins * 2 : collapsedButton.width
    implicitHeight: expanded ? expandedColumn.implicitHeight + _margins * 2 : collapsedButton.height
    radius:         ScreenTools.defaultFontPixelHeight / 3
    color:  expanded ? qgcPal.window : Qt.rgba(qgcPal.window.r, qgcPal.window.g, qgcPal.window.b, 0.75)

    property bool expanded: false

    property real _margins:         ScreenTools.defaultFontPixelWidth
    property var  _flyViewSettings: QGroundControl.settingsManager.flyViewSettings
    property var  _colorFact:       _flyViewSettings.vehicleIconColor
    property var  _scaleFact:       _flyViewSettings.vehicleIconSizeScale
    property real _swatchSize:      ScreenTools.defaultFontPixelHeight * 1.5

    // First entry (empty string) means "standard icon colors"
    readonly property var _iconColors: [ "", "#ffffff", "#ff3b30", "#ff9500", "#ffee00", "#2ecc40", "#00e5ff", "#3478f6", "#e040fb", "#000000" ]

    QGCPalette { id: qgcPal; colorGroupEnabled: control.enabled }

    // Collapsed state: single button previewing the current icon color
    Item {
        id:      collapsedButton
        width:   ScreenTools.defaultFontPixelHeight * 2.2
        height:  width
        visible: !control.expanded

        QGCColoredImage {
            anchors.centerIn:   parent
            width:              parent.width * 0.7
            height:             width
            source:             "/qmlimages/vehicleArrowOpaque.svg"
            fillMode:           Image.PreserveAspectFit
            color:              _colorFact.rawValue !== "" ? _colorFact.rawValue : qgcPal.text
        }

        QGCMouseArea {
            fillItem:   parent
            onClicked:  control.expanded = true
        }
    }

    // Expanded state: color swatches plus size slider
    ColumnLayout {
        id:       expandedColumn
        x:        _margins
        y:        _margins
        spacing:  _margins
        visible:  control.expanded

        RowLayout {
            Layout.fillWidth:   true
            spacing:            _margins

            QGCLabel {
                Layout.fillWidth:   true
                text:               qsTr("Aircraft Icon")
                font.bold:          true
            }

            QGCLabel {
                text: "✕"
                QGCMouseArea {
                    fillItem:   parent
                    onClicked:  control.expanded = false
                }
            }
        }

        GridLayout {
            columns:        5
            columnSpacing:  _margins / 2
            rowSpacing:     _margins / 2

            Repeater {
                model: control._iconColors

                Rectangle {
                    width:          _swatchSize
                    height:         _swatchSize
                    radius:         _swatchSize / 4
                    color:          modelData === "" ? "transparent" : modelData
                    border.width:   _colorFact.rawValue === modelData ? 2 : 1
                    border.color:   _colorFact.rawValue === modelData ? qgcPal.colorGreen : qgcPal.text

                    // "Standard colors" swatch shows the stock vehicle arrow
                    QGCColoredImage {
                        anchors.centerIn:   parent
                        width:              parent.width * 0.75
                        height:             width
                        visible:            modelData === ""
                        source:             "/qmlimages/vehicleArrowOpaque.svg"
                        fillMode:           Image.PreserveAspectFit
                        color:              qgcPal.text
                    }

                    // Plain MouseArea: swatches are adjacent, so no expanded touch margins
                    MouseArea {
                        anchors.fill:   parent
                        onClicked:      _colorFact.rawValue = modelData
                    }
                }
            }
        }

        RowLayout {
            Layout.fillWidth:   true
            spacing:            _margins

            QGCLabel { text: qsTr("Size") }

            QGCSlider {
                id:                 sizeSlider
                Layout.fillWidth:   true
                Layout.preferredWidth: ScreenTools.defaultFontPixelWidth * 20
                from:               0.4
                to:                 3.0
                stepSize:           0.1
                onMoved:            _scaleFact.rawValue = value

                Component.onCompleted: value = _scaleFact.rawValue

                Connections {
                    target: _scaleFact
                    function onRawValueChanged() {
                        if (!sizeSlider.pressed) {
                            sizeSlider.value = _scaleFact.rawValue
                        }
                    }
                }
            }

            QGCLabel { text: _scaleFact.rawValue.toFixed(1) + "x" }
        }
    }
}
