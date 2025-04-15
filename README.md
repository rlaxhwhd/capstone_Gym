# 🏋 공공체육관 예약 어플리케이션

Flutter와 Firebase를 기반으로 한 공공체육관 예약 앱입니다.  
이 프로젝트는 **MVVM (Model - View - ViewModel)** 아키텍처를 따르며, 각 계층별 역할을 명확하게 분리하여 유지보수성과 확장성을 극대화했습니다.

---

## 📁 프로젝트 구조

아래는 프로젝트의 전체 폴더 구조와 각 파일 및 폴더의 역할에 대한 설명입니다.

```plaintext
프로젝트 루트
├── firebase_options.dart            // Firebase 초기 설정 파일
├── main.dart                        // 앱 시작 지점 (Provider 및 MaterialApp 설정)
├── routes.dart                      // 페이지 이동(라우팅) 설정
│
├── data                             // Model 및 Repository 계층
│   ├── models
│   │   ├── auth_service.dart        // Firebase 인증 기능 래퍼
│   │   ├── gym_info_model.dart      // 체육관 정보 데이터 모델
│   │   └── user_model.dart          // 사용자 정보 데이터 모델
│   │
│   └── repositories
│       ├── auth_repository.dart     // 로그인, 회원가입 등 인증 관련 로직 처리
│       ├── gym_info_repository.dart // 체육관 관련 데이터 로직 처리
│       ├── text_repository.dart     // 텍스트 데이터 처리 (예: 설명, 규칙 등)
│       └── user_repository.dart     // 사용자 정보 로직 처리
│
├── utils
│   └── distance_calculator.dart     // 위도/경도 기반 거리 계산 유틸 함수
│
├── views                            // View 계층 (UI 구성)
│   ├── common_widgets               // 여러 화면에서 재사용되는 공통 위젯
│   │   ├── custom_back_button.dart  // 커스텀 뒤로가기 버튼
│   │   ├── round_button_style.dart  // 둥근 스타일 버튼
│   │   └── tag_widget.dart          // 태그 형태의 UI 요소
│   │
│   └── screens
│       ├── main_screen.dart         // 앱의 메인 화면 (BottomNavigation 등)
│       │
│       ├── gym_booking              // 체육관 예약 관련 화면
│       │   └── gym_booking_page.dart  // 체육관 예약 페이지
│       │
│       ├── gym_detail             // 체육관 상세 정보 관련 화면
│       │   ├── gym_detail_page.dart   // 체육관 상세 정보 페이지
│       │   └── components           // 상세 페이지 구성 요소들
│       │       ├── gym_booking_button.dart  // 예약 버튼 위젯
│       │       ├── gym_header.dart            // 체육관 헤더 위젯
│       │       ├── gym_info_section.dart      // 체육관 세부 정보 위젯
│       │       ├── gym_tab_bar.dart           // 탭 바 위젯
│       │       └── gym_tabs                   // 세부 탭별 화면
│       │           ├── info_tab.dart          // 정보 탭
│       │           ├── map_tab.dart           // 지도 탭
│       │           └── rules_tab.dart         // 이용 규칙 탭
│       │
│       ├── home                   // 홈 화면 관련
│       │   ├── home_page.dart         // 홈 화면
│       │   └── components             // 홈 화면 구성 요소
│       │       ├── background_img.dart        // 배경 이미지 위젯
│       │       ├── home_events_card.dart      // 이벤트 카드 위젯
│       │       ├── sliderWithIndicator.dart   // 슬라이더 및 인디케이터
│       │       └── sports_select_form.dart      // 스포츠 선택 폼
│       │
│       ├── login                  // 로그인/회원가입 관련 화면
│       │   ├── find_password_screen.dart  // 비밀번호 찾기 화면
│       │   ├── login_screen.dart          // 로그인 화면
│       │   ├── login_success.dart         // 로그인 성공 화면
│       │   └── sign_up_screen.dart        // 회원가입 화면
│       │
│       ├── meetup                 // 모임 관련 화면
│       │   └── meetup_page.dart
│       │
│       ├── profile                // 내 정보 및 계정 관리 화면
│       │   ├── delete_account_screen.dart  // 계정 삭제 화면
│       │   └── profile_page.dart           // 프로필 페이지
│       │
│       ├── qrcode                 // 바코드/QR코드 관련 화면
│       │   └── qrcode_page.dart
│       │
│       ├── schedule               // 내 일정 관리 화면
│       │   └── schedule_page.dart
│       │
│       └── unsorted               // 선택한 종목 모두보유한 체육관 보이게하기
│           └── selected_sports_list.dart
│
└── view_models                    // ViewModel 계층 (상태 관리 및 로직 처리)
    ├── background_view_model.dart         // 배경 이미지 관련 상태 관리
    ├── delete_account_viewmodel.dart      // 계정 삭제 관련 상태 관리
    ├── find_password_viewmodel.dart       // 비밀번호 찾기 로직 처리
    ├── gym_booking_view_model.dart        // 체육관 예약 프로세스를 관리
    ├── gym_detail_view_model.dart         // 체육관 상세 정보 관련 상태 관리
    ├── liked_gym_view_model.dart          // 즐겨찾기 기능 상태 관리
    ├── login_viewmodel.dart               // 로그인/로그아웃 상태 관리
    ├── main_view_model.dart               // 메인 화면 상태 (탭 이동 등) 관리
    ├── selected_sports_list_view_model.dart //선택한 종목 보유 체육관 관리               
    └── sign_up_viewmodel.dart             // 회원가입 로직 처리


```

---

## MVVM 아키텍처 설명

### Model (`data`)
- **역할:**  
  - 앱의 데이터 구조를 정의하고, Firebase와의 통신을 담당합니다.  
  - `models` 폴더에서는 체육관 정보, 사용자 정보 등 데이터 타입을 정의합니다.  
  - `repositories` 폴더는 데이터를 가져오고 처리하는 비즈니스 로직을 포함합니다.

### View (`views`)
- **역할:**  
  - 사용자 인터페이스(UI)를 구성하는 모든 요소를 포함합니다.  
  - `screens` 폴더는 기능별 화면(예: 메인, 로그인, 체육관 예약 등)으로 나뉘어 있습니다.  
  - `common_widgets` 폴더는 여러 화면에서 재사용되는 위젯(예: 버튼, 태그 등)을 관리하여 코드의 재사용성을 높입니다.

### ViewModel (`view_models`)
- **역할:**  
  - Model과 View 사이의 중간 다리 역할을 하며, 상태 관리를 담당합니다.  
  - View에서 발생하는 이벤트를 처리하고, 필요한 데이터를 Model에서 받아와 가공하여 View에 전달합니다.  
  - 주로 `ChangeNotifier`를 기반으로 UI와의 연동을 처리합니다.

---

## 📜 업데이트 내역

### 2025.04.06

#### 데이터 계층 (data)
- **repositories**
  - `text_repository.dart` 파일 추가  
    *에셋에 있는 텍스트 파일을 불러오기 위해 추가함.*

#### 유틸리티 계층 (utils)
- 새로운 폴더 `utils` 추가 및 `distance_calculator.dart` 파일 추가  
  *위도/경도 기반 거리 계산 유틸리티 함수 제공을 위해 추가함.*

#### 뷰 계층 (views)
- **common_widgets**
  - 새로운 위젯 컴포넌트 추가
    - `custom_back_button.dart`: 커스텀 뒤로가기 버튼  
    - `round_button_style.dart`: 둥근 버튼 스타일  
    - `tag_widget.dart`: 태그 UI 요소  
    *여러 화면에서 재사용되는 UI 컴포넌트를 모아두어 재사용성을 높임.*

- **screens**
  - **gym_booking** 
    - 폴더 추가 및 `gym_booking_page.dart` 파일 추가  
      *체육관 예약 관련 전용 화면 추가 (현재는 시험용으로 체육관 ID 전송 기능만 구현됨; 디자인 및 데이터 불러오기 작업 필요).*

  - **gym_detail**
    - 기존 `gym_detail_page.dart` 수정 
    - **components** 폴더 생성하여 세부 컴포넌트 분리  
      - `gym_booking_button.dart`: 예약 버튼 위젯
      - `gym_header.dart`: 체육관 헤더 정보 위젯
      - `gym_info_section.dart`: 체육관 세부 정보 위젯
      - `gym_tab_bar.dart`: 탭 바 위젯
    - **components/gym_tabs** 하위 폴더 생성  
      - `info_tab.dart`: 정보 탭
      - `map_tab.dart`: 지도 탭
      - `rules_tab.dart`: 이용 규칙 탭  
      *화면 구성을 세분화하여 유지보수와 확장성을 고려함.*

  - **home**
    - `home_page.dart` 수정  
      - 이벤트 카드 디자인 변경 및 체육관 데이터 요소 수정
      - 당겨서 새로고침 기능 추가
      - **개선 필요 사항**: 스포츠 선택 디자인 및 상단바 이미지 표시 문제, 전체 간격 조정, 알림 버튼 추가 필요.
