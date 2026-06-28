import QtQuick 2.15
import "../Style.js" as S

// Libi 로봇 얼굴 — OLED 디바이스 위에 Canvas 로 눈/눈썹/입/볼을 그린다.
// (QtQuick.Shapes 미설치 환경 → Canvas 사용). 감정 프리셋 간 트윈 + 깜빡임 + idle bob.
Item {
    id: face
    width: 360
    height: 360

    // 감정: 기본값은 전역 controller 와 연동 (부모가 덮어쓸 수 있음)
    property string emotion: (typeof controller !== "undefined") ? controller.emotion : "basic"
    property color deviceColor: "#0E1320"      // OLED 화면(어두운 네이비)
    property color featureColor: "#8CE0FF"     // 빛나는 시안 이목구비
    property color blushColor: "#FF9DB0"

    // 트윈되는 표정 파라미터
    property real pEyeOpen: 1.0
    property real pEyeSmile: 0.1
    property real pBrow: 0.0
    property real pMouthBow: 0.3
    property real pMouthOpen: 0.05
    property real pCheeks: 0.0
    property real blink: 1.0
    property real idleBob: 0.0
    property real gestureBob: 0.0

    function preset(e) {
        switch (e) {
        case "happy":    return {o:0.85, s:0.60, b:-0.10, mb: 0.90, mo:0.15, c:1};
        case "hello":    return {o:1.00, s:0.40, b:-0.20, mb: 0.80, mo:0.35, c:1};
        case "fun":      return {o:0.70, s:0.80, b:-0.10, mb: 1.00, mo:0.45, c:1};
        case "interest": return {o:1.00, s:0.20, b:-0.30, mb: 0.50, mo:0.20, c:1};
        case "thinking": return {o:0.90, s:0.00, b: 0.15, mb: 0.10, mo:0.05, c:0};
        case "sad":      return {o:0.80, s:0.00, b:-0.45, mb:-0.60, mo:0.10, c:0};
        case "sleep":    return {o:0.06, s:0.00, b: 0.00, mb: 0.20, mo:0.10, c:0};
        case "angry":    return {o:0.80, s:0.00, b: 0.60, mb:-0.40, mo:0.10, c:0};
        default:         return {o:1.00, s:0.10, b: 0.00, mb: 0.30, mo:0.05, c:0};
        }
    }
    function applyEmotion(e) {
        var p = preset(e);
        pEyeOpen = p.o; pEyeSmile = p.s; pBrow = p.b;
        pMouthBow = p.mb; pMouthOpen = p.mo; pCheeks = p.c;
    }
    onEmotionChanged: applyEmotion(emotion)
    Component.onCompleted: applyEmotion(emotion)

    Behavior on pEyeOpen  { NumberAnimation { duration: 280; easing.type: Easing.InOutQuad } }
    Behavior on pEyeSmile { NumberAnimation { duration: 280 } }
    Behavior on pBrow     { NumberAnimation { duration: 280 } }
    Behavior on pMouthBow { NumberAnimation { duration: 280 } }
    Behavior on pMouthOpen{ NumberAnimation { duration: 280 } }
    Behavior on pCheeks   { NumberAnimation { duration: 280 } }

    onPEyeOpenChanged:  canvas.requestPaint()
    onPEyeSmileChanged: canvas.requestPaint()
    onPBrowChanged:     canvas.requestPaint()
    onPMouthBowChanged: canvas.requestPaint()
    onPMouthOpenChanged:canvas.requestPaint()
    onPCheeksChanged:   canvas.requestPaint()
    onBlinkChanged:     canvas.requestPaint()

    // 깜빡임
    Timer { interval: 3200; running: true; repeat: true; onTriggered: blinkAnim.restart() }
    SequentialAnimation {
        id: blinkAnim
        NumberAnimation { target: face; property: "blink"; to: 0.08; duration: 90 }
        NumberAnimation { target: face; property: "blink"; to: 1.0;  duration: 130 }
    }

    // idle bob (위아래 둥실)
    SequentialAnimation on idleBob {
        running: true; loops: Animation.Infinite
        NumberAnimation { to: -6; duration: 1600; easing.type: Easing.InOutSine }
        NumberAnimation { to:  0; duration: 1600; easing.type: Easing.InOutSine }
    }

    // 제스처
    function playGesture(kind) {
        if (kind === "bow") bowAnim.restart();
        else if (kind === "wave") waveAnim.restart();
        else nodAnim.restart();
    }
    Connections {
        target: (typeof controller !== "undefined") ? controller : null
        ignoreUnknownSignals: true
        function onFaceGesture(kind) { face.playGesture(kind) }
    }

    Item {
        id: wrapper
        anchors.fill: parent
        transform: Translate { y: face.idleBob + face.gestureBob }

        Rectangle {
            id: device
            anchors.fill: parent
            radius: width * 0.16
            color: face.deviceColor
            border.color: Qt.lighter(face.deviceColor, 1.6)
            border.width: 2

            Canvas {
                id: canvas
                anchors.fill: parent
                onWidthChanged: requestPaint()
                onHeightChanged: requestPaint()
                onPaint: {
                    var ctx = getContext("2d");
                    var w = width, h = height;
                    ctx.reset();
                    ctx.clearRect(0, 0, w, h);

                    var cx = w/2, cy = h/2;
                    var eyeDX = w*0.20;
                    var eyeY = cy - h*0.04;
                    var eyeR = w*0.085;
                    var col = face.featureColor;

                    // 볼 (blush)
                    if (face.pCheeks > 0.01) {
                        ctx.globalAlpha = 0.55*face.pCheeks;
                        ctx.fillStyle = face.blushColor;
                        ctx.beginPath(); ctx.ellipse(cx-eyeDX-eyeR*0.9, eyeY+eyeR*1.5, eyeR*1.8, eyeR*1.1); ctx.fill();
                        ctx.beginPath(); ctx.ellipse(cx+eyeDX-eyeR*0.9, eyeY+eyeR*1.5, eyeR*1.8, eyeR*1.1); ctx.fill();
                        ctx.globalAlpha = 1.0;
                    }

                    ctx.fillStyle = col;
                    ctx.strokeStyle = col;
                    ctx.lineWidth = Math.max(6, w*0.024);
                    ctx.lineCap = "round";
                    ctx.shadowColor = col;
                    ctx.shadowBlur = w*0.025;

                    // 눈
                    function drawEye(ex) {
                        if (face.pEyeSmile > 0.45) {
                            ctx.beginPath();
                            ctx.arc(ex, eyeY+eyeR*0.35, eyeR, Math.PI*1.15, Math.PI*1.85, false);
                            ctx.stroke();
                        } else {
                            var open = Math.max(0.06, face.pEyeOpen*face.blink);
                            var rh = eyeR*open;
                            ctx.beginPath();
                            ctx.ellipse(ex-eyeR*0.7, eyeY-rh, eyeR*1.4, rh*2);
                            ctx.fill();
                        }
                    }
                    drawEye(cx-eyeDX);
                    drawEye(cx+eyeDX);

                    // 눈썹
                    if (Math.abs(face.pBrow) > 0.05) {
                        var bw = eyeR*1.3;
                        var by = eyeY - eyeR*1.7;
                        function drawBrow(ex, right) {
                            var inner = face.pBrow * eyeR*0.9;
                            ctx.beginPath();
                            if (!right) { ctx.moveTo(ex-bw/2, by); ctx.lineTo(ex+bw/2, by+inner); }
                            else        { ctx.moveTo(ex+bw/2, by); ctx.lineTo(ex-bw/2, by+inner); }
                            ctx.stroke();
                        }
                        drawBrow(cx-eyeDX, false);
                        drawBrow(cx+eyeDX, true);
                    }

                    // 입
                    var my = cy + h*0.24;
                    var mw = w*0.20;
                    if (face.pMouthOpen > 0.25) {
                        ctx.beginPath();
                        ctx.ellipse(cx-mw*0.6, my-mw*0.35, mw*1.2, mw*0.75*Math.max(0.4, face.pMouthOpen));
                        ctx.fill();
                    } else {
                        var bow = face.pMouthBow * mw*0.75;
                        ctx.beginPath();
                        ctx.moveTo(cx-mw, my);
                        ctx.quadraticCurveTo(cx, my+bow, cx+mw, my);
                        ctx.stroke();
                    }
                    ctx.shadowBlur = 0;
                }
            }

            // 잠잘 때 zzz
            Text {
                id: zzz
                visible: face.emotion === "sleep"
                anchors { right: parent.right; top: parent.top; margins: parent.width*0.12 }
                text: "z Z z"
                color: face.featureColor
                font.family: S.fontFamily
                font.pixelSize: parent.width*0.09
                font.bold: true
                opacity: 0.9
                SequentialAnimation on anchors.topMargin {
                    running: zzz.visible; loops: Animation.Infinite
                    NumberAnimation { to: device.width*0.09; duration: 1200 }
                    NumberAnimation { to: device.width*0.12; duration: 1200 }
                }
            }

            // 손인사 이모지
            Text {
                id: waveEmoji
                text: "👋"
                opacity: 0
                anchors { right: parent.right; bottom: parent.bottom; margins: parent.width*0.08 }
                font.pixelSize: parent.width*0.18
                transformOrigin: Item.Bottom
            }
        }
    }

    // 제스처 애니메이션
    SequentialAnimation {
        id: waveAnim
        PropertyAction { target: waveEmoji; property: "opacity"; value: 1 }
        SequentialAnimation {
            loops: 3
            RotationAnimation { target: waveEmoji; to:  18; duration: 120 }
            RotationAnimation { target: waveEmoji; to: -18; duration: 120 }
        }
        RotationAnimation { target: waveEmoji; to: 0; duration: 100 }
        NumberAnimation { target: waveEmoji; property: "opacity"; to: 0; duration: 300 }
    }
    SequentialAnimation {
        id: bowAnim
        NumberAnimation { target: face; property: "gestureBob"; to: 26; duration: 260; easing.type: Easing.InQuad }
        PauseAnimation { duration: 120 }
        NumberAnimation { target: face; property: "gestureBob"; to: 0; duration: 360; easing.type: Easing.OutQuad }
    }
    SequentialAnimation {
        id: nodAnim
        NumberAnimation { target: face; property: "gestureBob"; to: 12; duration: 160 }
        NumberAnimation { target: face; property: "gestureBob"; to: 0; duration: 200 }
    }
}
