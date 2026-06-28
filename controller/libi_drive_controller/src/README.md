# libi_drive_controller / src

Libi 주행 컨트롤러(ROS2) 워크스페이스의 소스 디렉토리.

## pinky_pro (git 미추적)

`pinky_pro/` 는 Pinky Pro 로봇의 ROS2 패키지 모음으로, **자체 git 저장소**를 가집니다.
이 저장소에서는 추적하지 않습니다 (`.gitignore` 에 `pinky_pro/` 등록).
필요 시 별도로 클론해서 이 위치에 둡니다.

주요 패키지: `pinky_bringup`, `pinky_navigation`, `pinky_emotion`, `pinky_led`,
`pinky_description`, `pinky_gz_sim`, `pinky_interfaces`, `pinky_imu_bno055`,
`pinky_lamp_control`, `pinky_sensor_adc`.

### 표정(emotion)

`pinky_pro/pinky_emotion/emotion/*.gif` 에 로봇 표정 GIF가 있습니다
(`basic`, `happy`, `hello`, `fun`, `interest`, `sad`, `angry`, `bored`).
GUI(`libi_gui`)는 이 표정을 자체 `qml/assets/emotion/` 으로 복사해 사용합니다.
