import QtQuick 2.15
import "../Style.js" as S
import "../components"

Item {
    id: root

    // 왼쪽: 얼굴 + 인사 + 친밀감
    Card {
        id: leftPanel
        anchors { left: parent.left; top: parent.top; bottom: parent.bottom; margins: 28 }
        width: root.width * 0.43

        Column {
            anchors.centerIn: parent
            width: parent.width - 48
            spacing: 18

            RobotFace {
                anchors.horizontalCenter: parent.horizontalCenter
                width: 300; height: 300
            }

            Text {
                anchors.horizontalCenter: parent.horizontalCenter
                text: "안녕하세요, 리비예요!"
                font.family: S.fontFamily; font.pixelSize: 30; font.bold: true; color: S.text
            }

            StatusPill {
                anchors.horizontalCenter: parent.horizontalCenter
                visible: controller.patrolActive
                pillColor: S.sky
                text: "순찰 중 · 도움이 필요하면 불러주세요"
            }

            Row {
                anchors.horizontalCenter: parent.horizontalCenter
                spacing: 14
                BigButton {
                    icon: "👋"; text: "손인사"; color: S.accent; textColor: S.text
                    implicitWidth: 150; implicitHeight: 92
                    onClicked: controller.waveHand()
                }
                BigButton {
                    icon: "🙇"; text: "배꼽인사"; color: S.mint; textColor: S.text
                    implicitWidth: 150; implicitHeight: 92
                    onClicked: controller.bow()
                }
            }
        }
    }

    // 오른쪽: 주요 기능 버튼
    Item {
        id: rightPanel
        anchors { left: leftPanel.right; right: parent.right; top: parent.top; bottom: parent.bottom
                  leftMargin: 24; rightMargin: 28; topMargin: 28; bottomMargin: 28 }

        Text {
            id: title
            anchors { left: parent.left; top: parent.top }
            text: "무엇을 도와드릴까요?"
            font.family: S.fontFamily; font.pixelSize: 34; font.bold: true; color: S.text
        }

        Grid {
            id: grid
            anchors { left: parent.left; right: parent.right; top: title.bottom; topMargin: 22 }
            columns: 2
            spacing: 18
            property real cellW: (width - spacing) / 2

            BigButton { width: grid.cellW; implicitHeight: 150; icon: "🧭"; text: "길잡이";   color: S.primary; onClicked: controller.setMode("guide") }
            BigButton { width: grid.cellW; implicitHeight: 150; icon: "🔎"; text: "검색";     color: S.sky;     textColor: S.text; onClicked: controller.setMode("search") }
            BigButton { width: grid.cellW; implicitHeight: 150; icon: "✨"; text: "추천";     color: S.lavender;textColor: S.text; onClicked: controller.setMode("recommend") }
            BigButton { width: grid.cellW; implicitHeight: 150; icon: "📋"; text: "작업 상태"; color: S.sun;     textColor: S.text; onClicked: controller.setMode("status") }
        }

        BigButton {
            anchors { left: parent.left; right: parent.right; bottom: parent.bottom }
            implicitHeight: 84
            icon: "🔧"; text: "관리자 모드"
            color: S.surface; textColor: S.textSoft
            borderColor: S.borderStrong; borderWidth: 1.5
            onClicked: controller.setMode("adminLogin")
        }
    }
}
