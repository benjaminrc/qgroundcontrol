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
import QtPositioning

import QGroundControl
import QGroundControl.Controls
import QGroundControl.Palette
import QGroundControl.ScreenTools

// Custom build: side panel listing picked map points with live horizontal distance from the vehicle
Rectangle {
    id:             control
    implicitWidth:  panelColumn.implicitWidth + _margins * 2
    implicitHeight: panelColumn.implicitHeight + _margins * 2
    radius:         ScreenTools.defaultFontPixelHeight / 3
    color:          Qt.rgba(qgcPal.window.r, qgcPal.window.g, qgcPal.window.b, 0.85)
    visible:        mapControl ? mapControl.distancePointsModel.count > 0 : false

    property var mapControl     ///< FlyViewMap instance which owns the distance points model

    property real _margins:                 ScreenTools.defaultFontPixelWidth
    property var  _activeVehicle:           QGroundControl.multiVehicleManager.activeVehicle
    property var  _activeVehicleCoordinate: _activeVehicle ? _activeVehicle.coordinate : QtPositioning.coordinate()

    QGCPalette { id: qgcPal; colorGroupEnabled: control.enabled }

    function distanceText(lat, lon) {
        if (!_activeVehicleCoordinate.isValid) {
            return qsTr("no vehicle")
        }
        var meters = _activeVehicleCoordinate.distanceTo(QtPositioning.coordinate(lat, lon))
        var converted = QGroundControl.unitsConversion.metersToAppSettingsHorizontalDistanceUnits(meters)
        return converted.toFixed(converted < 100 ? 1 : 0) + " " + QGroundControl.unitsConversion.appSettingsHorizontalDistanceUnitsString
    }

    ColumnLayout {
        id:      panelColumn
        x:       _margins
        y:       _margins
        spacing: _margins / 2

        RowLayout {
            Layout.fillWidth:   true
            spacing:            _margins

            QGCLabel {
                Layout.fillWidth:   true
                text:               qsTr("Distance Points")
                font.bold:          true
            }

            QGCLabel {
                text: qsTr("Clear all")
                color: qgcPal.colorOrange

                QGCMouseArea {
                    fillItem:   parent
                    onClicked:  mapControl.clearDistancePoints()
                }
            }
        }

        Repeater {
            model: mapControl ? mapControl.distancePointsModel : 0

            RowLayout {
                Layout.fillWidth:   true
                spacing:            _margins

                Rectangle {
                    width:  ScreenTools.defaultFontPixelHeight * 1.25
                    height: width
                    radius: width / 2
                    color:  "#ffb300"

                    QGCLabel {
                        anchors.centerIn:   parent
                        text:               (index + 1).toString()
                        color:              "black"
                        font.bold:          true
                    }
                }

                QGCLabel {
                    Layout.fillWidth:       true
                    Layout.minimumWidth:    ScreenTools.defaultFontPixelWidth * 14
                    text:                   control.distanceText(model.lat, model.lon)
                }

                QGCLabel {
                    text: "✕"

                    QGCMouseArea {
                        fillItem:   parent
                        onClicked:  mapControl.removeDistancePoint(index)
                    }
                }
            }
        }
    }
}
