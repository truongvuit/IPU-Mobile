# IPU - Ielts Power Up Mobile Application

Ứng dụng di động quản lý trung tâm ngoại ngữ IPU (Ielts Power Up), hỗ trợ quản lý học viên, giảng viên và các hoạt động đào tạo tiếng Anh.

---

## Mục lục

1. [Giới thiệu](#giới-thiệu)
2. [Chức năng chính](#chức-năng-chính)
3. [Công nghệ sử dụng](#công-nghệ-sử-dụng)
4. [Yêu cầu hệ thống](#yêu-cầu-hệ-thống)
5. [Cài đặt](#cài-đặt)
6. [Hướng dẫn chạy](#hướng-dẫn-chạy)
7. [Cấu trúc thư mục](#cấu-trúc-thư-mục)
8. [Ảnh minh họa](#ảnh-minh-họa)
9. [Tác giả](#tác-giả)
10. [License](#license)

---

## Giới thiệu

**IPU - Ielts Power Up** là ứng dụng di động được phát triển bằng Flutter, phục vụ cho việc quản lý trung tâm ngoại ngữ. Ứng dụng hỗ trợ 3 vai trò người dùng chính:

- **Admin/Staff**: Quản lý toàn bộ hệ thống, học viên, giảng viên, lớp học, khóa học và khuyến mãi
- **Teacher (Giảng viên)**: Quản lý lớp giảng dạy, điểm danh, chấm điểm học viên
- **Student (Học viên)**: Theo dõi lịch học, điểm số, đăng ký khóa học và thanh toán

**Bối cảnh dự án**: Dự án được xây dựng nhằm số hóa quy trình quản lý trung tâm ngoại ngữ, giúp tối ưu hóa việc theo dõi tiến độ học tập và quản lý hành chính.

---

## Chức năng chính

### Module Admin/Staff
| Chức năng | Mô tả |
|-----------|-------|
| Dashboard | Thống kê tổng quan hệ thống |
| Quản lý học viên | Thêm, sửa, xóa, xem chi tiết học viên |
| Quản lý giảng viên | Quản lý thông tin giảng viên |
| Quản lý lớp học | Tạo lớp, phân công giảng viên, quản lý buổi học |
| Quản lý khóa học | Tạo và cập nhật thông tin khóa học |
| Quản lý khuyến mãi | Tạo mã giảm giá, chương trình khuyến mãi |
| Đăng ký nhanh | Hỗ trợ đăng ký học viên mới nhanh chóng |

### Module Teacher (Giảng viên)
| Chức năng | Mô tả |
|-----------|-------|
| Dashboard | Tổng quan hoạt động giảng dạy |
| Lịch dạy | Xem lịch giảng dạy theo tuần/tháng |
| Quản lý lớp | Xem danh sách lớp đang dạy |
| Điểm danh | Điểm danh học viên theo buổi học |
| Chấm điểm | Nhập và cập nhật điểm học viên |
| Hồ sơ cá nhân | Cập nhật thông tin cá nhân |

### Module Student (Học viên)
| Chức năng | Mô tả |
|-----------|-------|
| Lịch học | Xem lịch học cá nhân |
| Xem điểm | Theo dõi kết quả học tập |
| Danh sách lớp | Xem các lớp đang tham gia |
| Khóa học | Duyệt và đăng ký khóa học mới |
| Thanh toán | Thanh toán học phí qua VNPay |
| Đánh giá | Đánh giá giảng viên và khóa học |
| Hồ sơ cá nhân | Quản lý thông tin cá nhân |

---

## Công nghệ sử dụng

| Thành phần | Công nghệ |
|------------|-----------|
| Framework | Flutter SDK ^3.9.2 |
| Ngôn ngữ | Dart |
| State Management | flutter_bloc ^8.1.6 |
| Dependency Injection | get_it ^8.0.2 |
| Network | dio ^5.7.0 |
| Local Storage | shared_preferences, flutter_secure_storage |
| UI Components | flutter_screenutil, cached_network_image, shimmer |
| Calendar | table_calendar ^3.1.1 |
| Charts | fl_chart ^1.1.1 |
| Payment | webview_flutter (VNPay integration) |

---

## Yêu cầu hệ thống

### Môi trường phát triển
- Flutter SDK: ^3.9.2
- Dart SDK: ^3.9.2
- Android Studio / VS Code
- Git

### Thiết bị chạy ứng dụng
- **Android**: API 21+ (Android 5.0 trở lên)
- **iOS**: iOS 12.0 trở lên
- **Web**: Các trình duyệt hiện đại (Chrome, Firefox, Edge)

---

## Cài đặt

### Bước 1: Clone repository

```bash
git clone https://github.com/truongvuit/IPU-Mobile.git
cd IPU-Mobile/Mobile
```

### Bước 2: Cài đặt dependencies

```bash
flutter pub get
```

### Bước 3: Cấu hình API endpoint

Mở file `lib/core/config/` và cập nhật URL API backend phù hợp với môi trường của bạn.

### Bước 4: Tạo app icon (tùy chọn)

```bash
flutter pub run flutter_launcher_icons
```

---

## Hướng dẫn chạy

### Chạy trên Android Emulator hoặc thiết bị thật

```bash
flutter run
```

### Chạy trên iOS Simulator (chỉ macOS)

```bash
flutter run -d ios
```

### Chạy trên Web

```bash
flutter run -d chrome
```

### Build APK (Android)

```bash
flutter build apk --release
```

### Build iOS (chỉ macOS)

```bash
flutter build ios --release
```

---

## Cấu trúc thư mục

```
lib/
├── main.dart                 # Entry point của ứng dụng
├── app.dart                  # Cấu hình MaterialApp và BlocProviders
├── core/                     # Các thành phần dùng chung
│   ├── api/                  # API client configuration
│   ├── auth/                 # Xử lý authentication
│   ├── config/               # Cấu hình ứng dụng
│   ├── constants/            # Các hằng số
│   ├── di/                   # Dependency Injection (GetIt)
│   ├── errors/               # Xử lý lỗi
│   ├── network/              # Network utilities
│   ├── routing/              # App routing configuration
│   ├── services/             # Các service dùng chung
│   ├── theme/                # App theme (colors, typography)
│   ├── utils/                # Utility functions
│   ├── validators/           # Form validators
│   └── widgets/              # Shared widgets
├── features/                 # Các tính năng chính (Clean Architecture)
│   ├── admin/                # Module Admin/Staff
│   │   ├── data/             # Data layer (repositories, datasources)
│   │   ├── domain/           # Domain layer (entities, usecases)
│   │   └── presentation/     # UI layer (screens, blocs, widgets)
│   ├── authentication/       # Module đăng nhập/đăng ký
│   ├── payment/              # Module thanh toán VNPay
│   ├── settings/             # Module cài đặt
│   ├── splash/               # Màn hình splash
│   ├── student/              # Module học viên
│   └── teacher/              # Module giảng viên
└── shared/                   # Các component dùng chung giữa các features
```

## Tác giả

**Thông tin liên hệ**:
- GitHub: [truongvuit](https://github.com/truongvuit)

---
