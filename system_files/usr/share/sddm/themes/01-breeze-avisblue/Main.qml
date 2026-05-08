// Avisblue SDDM theme. Minimum-viable Qt6 greeter.
// Background = signature wallpaper; centred panel with user picker + password.
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Rectangle {
    id: root
    width: 1920
    height: 1080
    color: "#11243B"

    Image {
        id: background
        anchors.fill: parent
        source: config.stringValue("background")
        fillMode: Image.PreserveAspectCrop
        cache: true
    }

    Rectangle {
        id: panel
        anchors.centerIn: parent
        width: 420
        radius: 8
        color: "#1c2f47"
        opacity: 0.92
        border.width: 1
        border.color: "#2A4A6E"
        implicitHeight: panelLayout.implicitHeight + 48

        ColumnLayout {
            id: panelLayout
            anchors.fill: parent
            anchors.margins: 24
            spacing: 16

            Image {
                Layout.alignment: Qt.AlignHCenter
                source: config.stringValue("logo")
                sourceSize.width: 96
                sourceSize.height: 96
                fillMode: Image.PreserveAspectFit
            }

            Label {
                Layout.alignment: Qt.AlignHCenter
                text: "Avisblue"
                color: "#ECF1F8"
                font.pixelSize: 22
                font.weight: Font.Light
            }

            Label {
                Layout.alignment: Qt.AlignHCenter
                text: sddm.hostName
                color: "#8AA0BC"
                font.pixelSize: 12
            }

            ComboBox {
                id: userBox
                Layout.fillWidth: true
                model: userModel
                textRole: "name"
                currentIndex: userModel.lastIndex
            }

            TextField {
                id: passwordField
                Layout.fillWidth: true
                placeholderText: "Password"
                echoMode: TextInput.Password
                onAccepted: loginButton.clicked()
            }

            ComboBox {
                id: sessionBox
                Layout.fillWidth: true
                model: sessionModel
                textRole: "name"
                currentIndex: sessionModel.lastIndex
            }

            Button {
                id: loginButton
                Layout.fillWidth: true
                text: "Sign in"
                onClicked: sddm.login(
                    userModel.data(userModel.index(userBox.currentIndex, 0), Qt.UserRole + 1),
                    passwordField.text,
                    sessionBox.currentIndex
                )
            }

            Label {
                id: errorLabel
                Layout.alignment: Qt.AlignHCenter
                text: ""
                color: "#D8854A"
                font.pixelSize: 12
                visible: text.length > 0
            }
        }
    }

    Connections {
        target: sddm
        function onLoginFailed() {
            errorLabel.text = "Login failed."
            passwordField.text = ""
            passwordField.focus = true
        }
        function onLoginSucceeded() {
            errorLabel.text = ""
        }
    }

    Component.onCompleted: passwordField.focus = true
}
