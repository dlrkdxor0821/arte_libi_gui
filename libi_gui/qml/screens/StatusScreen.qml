import QtQuick 2.15
import "../Style.js" as S
import "../components"

Item {
    id: root

    ScreenHeader {
        id: header
        anchors { left: parent.left; top: parent.top; margins: 28 }
        width: parent.width - 56
        emoji: "📋"; title: "작업 상태"
        onBack: controller.setMode("home")
    }

    // 왼쪽: 상태 카드들
    Column {
        id: leftCol
        anchors { left: parent.left; top: header.bottom; bottom: parent.bottom; margins: 28; topMargin: 12 }
        width: parent.width * 0.40
        spacing: 16

        // 로봇 상태
        Card {
            width: parent.width; height: 120
            Row {
                anchors { left: parent.left; verticalCenter: parent.verticalCenter; leftMargin: 24 }
                spacing: 20
                RobotFace { width: 84; height: 84; anchors.verticalCenter: parent.verticalCenter }
                Column {
                    anchors.verticalCenter: parent.verticalCenter
                    spacing: 6
                    Text { text: "로봇 상태"; font.family: S.fontFamily; font.pixelSize: 16; color: S.textMuted }
                    Text { text: controller.robotState; font.family: S.fontFamily; font.pixelSize: 32; font.bold: true; color: S.text }
                }
            }
        }

        // 작업 상태
        Card {
            width: parent.width; height: 110
            Column {
                anchors { left: parent.left; verticalCenter: parent.verticalCenter; leftMargin: 24 }
                spacing: 8
                Text { text: "작업 상태"; font.family: S.fontFamily; font.pixelSize: 16; color: S.textMuted }
                StatusPill {
                    pillColor: controller.taskStatus === "비상정지" ? S.danger
                               : controller.taskStatus === "명령 대기" ? S.success : S.sky
                    text: controller.taskStatus
                }
            }
        }

        // 배터리
        Card {
            width: parent.width; height: 120
            Column {
                anchors { left: parent.left; right: parent.right; verticalCenter: parent.verticalCenter; leftMargin: 24; rightMargin: 24 }
                spacing: 10
                Row {
                    width: parent.width
                    Text { text: "배터리"; font.family: S.fontFamily; font.pixelSize: 16; color: S.textMuted }
                    Item { width: parent.width - 200; height: 1 }
                    Text {
                        text: controller.battery + "%" + (controller.charging ? "  ⚡" : "")
                        font.family: S.fontFamily; font.pixelSize: 28; font.bold: true
                        color: controller.battery < 15 ? S.danger : S.text
                    }
                }
                Rectangle {
                    width: parent.width; height: 16; radius: 8; color: S.bgAlt
                    Rectangle {
                        height: parent.height; radius: 8
                        width: parent.width * Math.max(0, Math.min(1, controller.battery/100))
                        color: controller.battery < 15 ? S.danger : (controller.battery < 35 ? S.warning : S.success)
                        Behavior on width { NumberAnimation { duration: 300 } }
                    }
                }
            }
        }
    }

    // 오른쪽: 현재 작업 + 최근 기록
    Item {
        anchors { left: leftCol.right; right: parent.right; top: header.bottom; bottom: parent.bottom
                  leftMargin: 24; rightMargin: 28; topMargin: 12; bottomMargin: 28 }

        Card {
            id: currentTask
            anchors { left: parent.left; right: parent.right; top: parent.top }
            height: 110
            Row {
                anchors { left: parent.left; verticalCenter: parent.verticalCenter; leftMargin: 24 }
                spacing: 16
                Text { text: "🛎"; font.pixelSize: 36; anchors.verticalCenter: parent.verticalCenter }
                Column {
                    anchors.verticalCenter: parent.verticalCenter
                    spacing: 6
                    Text { text: "현재 작업"; font.family: S.fontFamily; font.pixelSize: 16; color: S.textMuted }
                    Text {
                        text: (controller.guidePhase === "guiding" || controller.guidePhase === "requesterLost")
                              ? (controller.guideDestination + " 안내 중 · 남은 " + controller.distanceToGoal.toFixed(1) + "m")
                              : "진행 중인 작업이 없습니다"
                        font.family: S.fontFamily; font.pixelSize: 22; font.bold: true; color: S.text
                    }
                }
            }
        }

        Card {
            anchors { left: parent.left; right: parent.right; top: currentTask.bottom; bottom: parent.bottom; topMargin: 16 }
            Text {
                id: logTitle
                anchors { left: parent.left; top: parent.top; margins: 20 }
                text: "최근 기록"
                font.family: S.fontFamily; font.pixelSize: 18; font.bold: true; color: S.text
            }
            ListView {
                anchors { left: parent.left; right: parent.right; top: logTitle.bottom; bottom: parent.bottom; margins: 20; topMargin: 10 }
                clip: true
                spacing: 6
                model: controller.logs
                delegate: Text {
                    text: modelData
                    font.family: S.fontFamily; font.pixelSize: 14; color: S.textSoft
                }
            }
        }
    }
}
