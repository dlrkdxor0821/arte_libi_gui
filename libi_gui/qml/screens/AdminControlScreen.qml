import QtQuick 2.15
import QtQuick.Controls 2.15
import "../Style.js" as S
import "../components"

Item {
    id: root
    property real speed: 0.4

    function doAction(a) {
        if (a === "fwd")        controller.drive(speed, 0);
        else if (a === "back")  controller.drive(-speed, 0);
        else if (a === "left")  controller.drive(0, speed * 1.5);
        else if (a === "right") controller.drive(0, -speed * 1.5);
        else if (a === "stop")  controller.stopDrive();
    }

    ScreenHeader {
        id: header
        anchors { left: parent.left; top: parent.top; margins: 28 }
        width: parent.width - 56
        emoji: "🔧"; title: "관리자 수동조작"
        onBack: controller.setMode("home")
    }
    BigButton {
        anchors { right: parent.right; top: parent.top; rightMargin: 28; topMargin: 28 }
        implicitWidth: 150; implicitHeight: 56
        text: "로그아웃"; color: S.bgAlt; textColor: S.textSoft
        onClicked: controller.logout()
    }

    // 비상정지 배너
    Rectangle {
        id: banner
        visible: controller.emergencyStopped
        anchors { left: parent.left; right: parent.right; top: header.bottom; margins: 28; topMargin: 10 }
        height: visible ? 72 : 0
        radius: 18
        color: Qt.rgba(1, 0.42, 0.42, 0.18)
        border.color: S.danger; border.width: 2
        Text {
            anchors { left: parent.left; leftMargin: 22; verticalCenter: parent.verticalCenter }
            text: "⛔ 비상정지 상태 — 동작이 잠겨 있습니다"
            font.family: S.fontFamily; font.pixelSize: 20; font.bold: true; color: S.danger
        }
        BigButton {
            anchors { right: parent.right; rightMargin: 16; verticalCenter: parent.verticalCenter }
            implicitWidth: 150; implicitHeight: 52
            text: "해제"; color: S.success
            onClicked: controller.clearEmergencyStop()
        }
    }

    Row {
        anchors { left: parent.left; right: parent.right
                  top: banner.visible ? banner.bottom : header.bottom; bottom: parent.bottom
                  leftMargin: 28; rightMargin: 28; topMargin: 14; bottomMargin: 28 }
        spacing: 20

        // 왼쪽: 주행
        Card {
            width: (parent.width - 20) * 0.5
            height: parent.height
            Column {
                anchors { fill: parent; margins: 24 }
                spacing: 16

                Text { text: "🚗  주행"; font.family: S.fontFamily; font.pixelSize: 22; font.bold: true; color: S.text }

                Grid {
                    anchors.horizontalCenter: parent.horizontalCenter
                    columns: 3; spacing: 12
                    Repeater {
                        model: [
                            {l:"",  a:""},     {l:"▲", a:"fwd"},  {l:"",  a:""},
                            {l:"◀", a:"left"}, {l:"■", a:"stop"}, {l:"▶", a:"right"},
                            {l:"",  a:""},     {l:"▼", a:"back"}, {l:"",  a:""}
                        ]
                        delegate: Item {
                            width: 90; height: 74
                            Rectangle {
                                visible: modelData.a !== ""
                                anchors.fill: parent; radius: 16
                                color: modelData.a === "stop" ? S.danger : S.bgAlt
                                border.color: S.borderStrong; border.width: 1.5
                                Text {
                                    anchors.centerIn: parent; text: modelData.l
                                    font.pixelSize: 30; font.bold: true
                                    color: modelData.a === "stop" ? "white" : S.text
                                }
                                scale: dm.pressed ? 0.93 : 1.0
                                Behavior on scale { NumberAnimation { duration: 70 } }
                                MouseArea { id: dm; anchors.fill: parent; enabled: !controller.emergencyStopped; onClicked: root.doAction(modelData.a) }
                            }
                        }
                    }
                }

                Row {
                    width: parent.width; spacing: 12
                    Text { text: "속도"; font.family: S.fontFamily; font.pixelSize: 16; color: S.textSoft; anchors.verticalCenter: parent.verticalCenter }
                    Slider { id: speedSlider; width: parent.width - 120; from: 0.1; to: 1.0; value: root.speed; onMoved: root.speed = value; anchors.verticalCenter: parent.verticalCenter }
                    Text { text: root.speed.toFixed(1); font.family: S.fontFamily; font.pixelSize: 16; font.bold: true; color: S.text; anchors.verticalCenter: parent.verticalCenter }
                }

                Rectangle {
                    width: parent.width; height: 54; radius: 12; color: S.bgAlt
                    Text {
                        anchors.centerIn: parent
                        text: "선속도 " + controller.linVel.toFixed(2) + " m/s    ·    각속도 " + controller.angVel.toFixed(2) + " rad/s"
                        font.family: S.fontFamily; font.pixelSize: 16; color: S.textSoft
                    }
                }
            }
        }

        // 오른쪽: 팔 관절 + 주변장치 + 로그
        Card {
            width: (parent.width - 20) * 0.5
            height: parent.height

            Column {
                id: rightTop
                anchors { left: parent.left; right: parent.right; top: parent.top; margins: 24 }
                spacing: 12

                Text { text: "🦾  팔 관절"; font.family: S.fontFamily; font.pixelSize: 22; font.bold: true; color: S.text }

                Column {
                    width: parent.width; spacing: 4
                    Text { text: "관절 1 (Dynamixel)   " + controller.joint1.toFixed(0) + "°"; font.family: S.fontFamily; font.pixelSize: 15; color: S.textSoft }
                    Slider { width: parent.width; from: -90; to: 90; value: controller.joint1; enabled: !controller.emergencyStopped; onMoved: controller.setJoint1(value) }
                }
                Column {
                    width: parent.width; spacing: 4
                    Text { text: "관절 2 (Dynamixel)   " + controller.joint2.toFixed(0) + "°"; font.family: S.fontFamily; font.pixelSize: 15; color: S.textSoft }
                    Slider { width: parent.width; from: -90; to: 90; value: controller.joint2; enabled: !controller.emergencyStopped; onMoved: controller.setJoint2(value) }
                }
                Column {
                    width: parent.width; spacing: 4
                    Text { text: "그리퍼   " + controller.gripper.toFixed(0) + "%"; font.family: S.fontFamily; font.pixelSize: 15; color: S.textSoft }
                    Slider { width: parent.width; from: 0; to: 100; value: controller.gripper; enabled: !controller.emergencyStopped; onMoved: controller.setGripper(value) }
                }

                Rectangle { width: parent.width; height: 1; color: S.border }

                Text { text: "🔌  주변장치"; font.family: S.fontFamily; font.pixelSize: 20; font.bold: true; color: S.text }
                Row {
                    spacing: 14
                    BigButton {
                        implicitWidth: 160; implicitHeight: 92
                        icon: "💡"; text: controller.led ? "LED 끄기" : "LED 켜기"
                        color: controller.led ? S.sun : S.bgAlt; textColor: S.text
                        enabledLook: !controller.emergencyStopped
                        onClicked: controller.setLed(!controller.led)
                    }
                    BigButton {
                        implicitWidth: 160; implicitHeight: 92
                        icon: "🔔"; text: "부저"
                        color: S.bgAlt; textColor: S.text
                        enabledLook: !controller.emergencyStopped
                        onClicked: controller.buzz()
                    }
                }
            }

            Text {
                id: logTitle
                anchors { left: parent.left; top: rightTop.bottom; margins: 24; topMargin: 16 }
                text: "📜  로그"
                font.family: S.fontFamily; font.pixelSize: 20; font.bold: true; color: S.text
            }
            ListView {
                anchors { left: parent.left; right: parent.right; top: logTitle.bottom; bottom: parent.bottom
                          leftMargin: 24; rightMargin: 24; topMargin: 8; bottomMargin: 20 }
                clip: true; spacing: 5
                model: controller.logs
                delegate: Text { width: ListView.view.width; text: modelData; font.family: S.fontFamily; font.pixelSize: 13; color: S.textSoft; elide: Text.ElideRight }
            }
        }
    }
}
