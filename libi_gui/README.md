# libi_gui

**Libi(리비)** 도서관 사서 로봇의 **온보드 터치패널 GUI** (= System Architecture 상의 `Libi GUI`, Libi Drive Board 탑재).

- **스택:** C++ / Qt 5.15 (Qt Quick · QML) / CMake
- **대상:** 풀스크린 터치 패널 (태블릿/터치 디스플레이, 입력은 단순 탭/클릭)
- **언어:** 한국어 UI

> 버전 선택 근거: 빌드 환경(Ubuntu 24.04)에 Qt 5.15 LTS가 완비(Qt6 미설치)되어, 별도 설치 없이 가장 안정적으로 빌드·실행 가능. Qt5는 `ShaderEffect` 등에서도 단순.

## 기능 (로봇 터치패널 범위)
1. 대기/홈 — 인사, **표정(감정) 얼굴**, 순찰 표시
2. 친밀감 인터랙션 — 손인사 👋 / 배꼽인사 🙇 (SR-17)
3. **길잡이** — 목적지 선택 → 안내 중 지도·남은거리·상태 (SR-11, 시나리오 문구 반영)
4. **검색** — 도서/시설 검색 → 위치 지도 표시 (SR-09)
5. **추천** — 목적·관심분야 기반 도서 추천 (SR-05)
6. 작업/안내 **상태 표시** (SR-14)
7. **비상정지** — 즉시 정지·전 명령 무시, 관리자만 해제 (SR-20)
8. **관리자 모드** (PIN) → **수동조작**: 주행(D-pad)·팔 관절·주변장치 + 로그 (SR-21)

## 빌드 & 실행
```bash
cmake -S . -B build -DCMAKE_BUILD_TYPE=Release
cmake --build build -j
./build/libi_gui
```

### 화면 캡처(검증용)
각 화면을 순회하며 PNG로 저장 (live 디스플레이 필요):
```bash
./build/libi_gui --shots /tmp/libi_shots
```

## 구조
```
libi_gui/
├── CMakeLists.txt
├── resources.qrc            # 모든 QML/JS 번들
├── src/
│   ├── main.cpp             # 엔진 + controller 등록 + --shots 캡처
│   ├── RobotController.h/.cpp   # 백엔드 파사드(QObject→QML)
└── qml/
    ├── Main.qml             # 윈도우/네비/비상정지/토스트
    ├── Style.js             # 디자인 토큰(파스텔 테마)
    ├── components/          # RobotFace, BigButton, Card, MapView, TopBar ...
    └── screens/             # Home/Guide/Search/Recommend/Status/AdminLogin/AdminControl
```

## ROS2 연동 (TODO)
실제 시스템에서 Libi GUI 의 **유일한 통신 상대는 `Libi Drive Controller` (ROS2 / DDS)** 이다.
현재 `RobotController` 는 동작 확인용 **목(mock) 데이터**로 구현되어 있고, ROS2 연결 지점은
`RobotController.cpp` 의 슬롯/시그널(`// ROS2-SEAM` 주석)이다.

### 연결 구조 (seam)
화면(QML)은 하드웨어를 직접 만지지 않고 **오직 `controller` 한 곳**을 통해서만 동작한다.
따라서 연동 시 **`RobotController` 내부만 교체**하면 되고 UI 코드는 그대로 둔다.

```
QML 화면들  ──(controller.setMode/drive/setEmotion…)──▶  RobotController
              ◀──(battery/robotState/emotion… 프로퍼티)──        │
                                                                 │
                              지금 ─ mock 값으로 채움             │
                              나중 ─ 이 내부만 ROS2 pub/sub/srv 로 교체
```

연동 시 손볼 곳 (전부 `RobotController.cpp` 한 파일):

- `drive()/setJointN()/setGripper()/setLed()` → cmd_vel·관절·주변장치 토픽 **publish**
- 상태 프로퍼티(`robotState/battery/guidePhase/distanceToGoal/taskStatus`) → 컨트롤러 토픽 **subscribe** 후 갱신 (프로퍼티만 바꾸면 데이터 바인딩으로 UI 자동 반영)
- `searchBooks()/recommend()/facilities()` → Drive Controller 경유 ABA Service 조회로 대체

### 표정(emotion)
얼굴(`RobotFace.qml`)은 **pinky_pro 로봇의 실제 표정 GIF**를 재생한다
(`controller/libi_drive_controller/src/pinky_pro/pinky_emotion/emotion/*.gif` 원본을
`qml/assets/emotion/` 으로 480px 다운스케일 복사 → qrc 번들).

GUI 감정 이름과 GIF 파일명이 **1:1로 일치**하므로, 로봇의 `set_emotion` 서비스
(`pinky_emotion/emotion_server.py`)와 그대로 맞물린다 → **화면 얼굴 = 실제 로봇 LCD 얼굴**.
연동 시 `setEmotion()` 안에서 이 서비스를 함께 호출하면 된다.

| GUI 감정 | 사용 GIF | 비고 |
|---|---|---|
| happy / interest / fun / sad / angry / basic / hello / bored | 동일 이름 | 보유 GIF 그대로 |
| thinking | interest | 대응 GIF 없어 근사 매핑 |
| sleep | bored | 대응 GIF 없어 근사 매핑 |

> 문서(기획/SRS/아키텍처)에 ROS2 토픽·서비스 이름이 정의돼 있지 않아, 위 인터페이스는 GUI 요구에 맞춰 잠정 정의한 것이다. 실제 메시지 계약 확정 시 맞추면 된다.
