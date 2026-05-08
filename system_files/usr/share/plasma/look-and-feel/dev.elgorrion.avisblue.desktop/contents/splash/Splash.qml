// Avisblue Plasma splash. Shows centred mark + busy indicator on a deep-blue
// field while Plasma starts up. Five-stage handler emits stages via context.
import QtQuick
import QtQuick.Window

Image {
    id: root
    source: "images/background.png"
    fillMode: Image.PreserveAspectCrop
    width: Window.width
    height: Window.height

    property int stage

    Rectangle {
        anchors.fill: parent
        color: "#11243B"
    }

    Image {
        id: logo
        anchors.centerIn: parent
        source: "images/avisblue_logo.svgz"
        sourceSize.width: 256
        sourceSize.height: 256
        fillMode: Image.PreserveAspectFit
        opacity: 0
        Behavior on opacity { NumberAnimation { duration: 600 } }
    }

    Rectangle {
        id: dotRow
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: logo.bottom
        anchors.topMargin: 48
        width: 96
        height: 8
        color: "transparent"

        Row {
            anchors.fill: parent
            spacing: 12

            Repeater {
                model: 5
                Rectangle {
                    width: 8
                    height: 8
                    radius: 4
                    color: index < root.stage ? "#5BA0D9" : "#2A4A6E"
                    Behavior on color { ColorAnimation { duration: 300 } }
                }
            }
        }
    }

    onStageChanged: {
        if (stage === 1) {
            logo.opacity = 1
        }
    }
}
