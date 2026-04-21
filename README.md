# Live Moment

> **"지도 위에서 펼쳐지는 생생한 순간들"** \> Live Moment는 Google Maps API와 Supabase 실시간 스트림을 결합하여, 현재 위치의 소중한 찰나를 10초 영상으로 공유하고 탐험하는 위치 기반 숏폼 소셜 플랫폼입니다.

-----

## Project Overview

사용자의 현재 위치를 기반으로 짧은 영상(Moment)을 지도 위에 즉시 기록합니다. 전 세계 어디서든 다른 사용자가 올린 실시간 일상을 지도 인터페이스를 통해 탐험하며, 위치와 영상이 결합된 새로운 형태의 소통 경험을 제공합니다.

## Key Features

  * **실시간 지도 인터페이스 (Real-time Map):** Supabase Realtime을 연동하여 새로운 영상이 업로드되는 즉시 지도 위에 마커가 생성됩니다.
  * **위치 기반 영상 업로드:** `Geolocator`를 통해 정확한 GPS 좌표를 획득, 영상과 함께 메타데이터를 저장합니다.
  * **10초 숏폼 카메라:** 앱 내 커스텀 카메라 인터페이스를 통해 10초간의 생생한 순간을 간편하게 녹화합니다.
  * **심리스한 영상 재생:** 지도 위 마커 클릭 시 바텀 시트(Bottom Sheet)에서 영상이 즉시 루프 재생되어 몰입감을 높였습니다.

## Tech Stack

### Frontend

  * **Framework:** Flutter
  * **State Management:** Riverpod (Declarative & Testable state)
  * **Map & Location:** Google Maps Flutter, Geolocator
  * **Media:** Camera, Video Player

### Backend

  * **Database & Storage:** Supabase (PostgreSQL, Realtime Stream, Buckets)

## Architecture

본 프로젝트는 **MVP 패턴 기반의 클린한 구조**를 지향하며, 비즈니스 로직과 UI 레이어를 분리하여 유지보수성과 확장성을 확보했습니다.

  * **Data Layer:** Supabase 클라이언트 및 API 통신 담당
  * **Domain Layer (State):** Riverpod을 활용한 전역 상태 및 로직 관리
  * **Presentation Layer:** 원활한 UX를 위한 반응형 UI 컴포넌트

-----

## Screenshots

빠른 시일내에 올라옵니다.

| Map View | Camera | Video Play |
| :---: | :---: | :---: |
| <img width="360" height="800" alt="Screenshot_20260419-205536 live_moment" src="https://github.com/user-attachments/assets/a2f32d56-7433-481f-842d-e45317191149" /> | <img width="360" height="800" alt="Screenshot_20260419-205651 live_moment" src="https://github.com/user-attachments/assets/8f8bc02c-28d4-481f-8632-711de696a1aa" /> | <img width="360" height="800" alt="Screenshot_20260419-205542 live_moment" src="https://github.com/user-attachments/assets/122bc8a6-3355-4a26-9719-87dfaad521fc" /> |

-----

## 제작 기간

- **개발 기간:** 2026.04.11 ~ 2026.04.17


-----

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](https://www.google.com/search?q=LICENSE) file for details.
