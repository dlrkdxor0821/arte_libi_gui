# arte_libi_gui

**Libi(리비)** 도서관 사서 로봇 프로젝트.

- [`libi_gui/`](libi_gui/) — 온보드 터치패널 GUI (C++ / Qt 5.15 / QML). 빌드·실행은 해당 폴더 README 참고.
- [`controller/`](controller/) — Libi 주행 컨트롤러(ROS2) 워크스페이스. `pinky_pro`(Pinky 로봇 ROS2 패키지)는 자체 git 저장소라 추적하지 않음(`.gitignore`).

## 연결 구조 (GUI ↔ 로봇)

화면(QML)은 하드웨어를 직접 만지지 않고 **오직 `RobotController` 한 곳**을 통해서만 동작한다.
따라서 실제 로봇 연동 시 **`RobotController` 내부만 교체**하면 되고 UI 코드는 그대로 둔다.

```
QML 화면들  ──(controller.setMode/drive/setEmotion…)──▶  RobotController
              ◀──(battery/robotState/emotion… 프로퍼티)──        │
                                                                 │
                              지금 ─ mock 값으로 채움             │
                              나중 ─ 이 내부만 ROS2 pub/sub/srv 로 교체
```

연동 시 손볼 곳 (전부 `libi_gui/src/RobotController.cpp` 한 파일):

- `drive()/setJointN()/setGripper()/setLed()` → cmd_vel·관절·주변장치 토픽 **publish**
- 상태 프로퍼티(`robotState/battery/guidePhase/distanceToGoal/taskStatus`) → 컨트롤러 토픽 **subscribe** 후 갱신 (프로퍼티만 바꾸면 데이터 바인딩으로 UI 자동 반영)
- `searchBooks()/recommend()/facilities()` → Drive Controller 경유 ABA Service 조회로 대체

## 표정(emotion)

얼굴(`RobotFace.qml`)은 **pinky_pro 로봇의 실제 표정 GIF**를 재생한다
(`controller/libi_drive_controller/src/pinky_pro/pinky_emotion/emotion/*.gif` 원본을
`libi_gui/qml/assets/emotion/` 으로 480px 다운스케일 복사 → qrc 번들).

GUI 감정 이름과 GIF 파일명이 **1:1로 일치**하므로, 로봇의 `set_emotion` 서비스
(`pinky_emotion/emotion_server.py`)와 그대로 맞물린다 → **화면 얼굴 = 실제 로봇 LCD 얼굴**.
연동 시 `setEmotion()` 안에서 이 서비스를 함께 호출하면 된다.

| GUI 감정 | 사용 GIF | 비고 |
|---|---|---|
| happy / interest / fun / sad / angry / basic / hello / bored | 동일 이름 | 보유 GIF 그대로 |
| thinking | interest | 대응 GIF 없어 근사 매핑 |
| sleep | bored | 대응 GIF 없어 근사 매핑 |

> 문서(기획/SRS/아키텍처)에 ROS2 토픽·서비스 이름이 정의돼 있지 않아, 위 인터페이스는 GUI 요구에 맞춰 잠정 정의한 것이다. 실제 메시지 계약 확정 시 맞추면 된다.
