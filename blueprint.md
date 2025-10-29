
# Kế hoạch chi tiết ứng dụng "Money Manager"

## Tổng quan

Tài liệu này mô tả kiến trúc và kế hoạch triển khai cho ứng dụng Flutter "Money Manager". Ứng dụng được thiết kế để giúp người dùng quản lý tài chính cá nhân, với các tính năng theo dõi giao dịch, quản lý ngân sách, và cung cấp cái nhìn tổng quan về thói quen chi tiêu.

## Các tính năng chính

*   **Onboarding / Chọn ngôn ngữ:** Người dùng mới sẽ thấy màn hình chọn ngôn ngữ khi mở ứng dụng lần đầu.
*   **Đa ngôn ngữ và Đa tiền tệ:** Hỗ trợ tiếng Anh, tiếng Việt, và tiếng Pháp, cùng với khả năng thay đổi đơn vị tiền tệ.
*   **Màn hình chính (Dashboard):** Cung cấp tóm tắt về thu nhập, chi tiêu, các khoản vay và cho vay.
*   **Quản lý giao dịch:** Đầy đủ các chức năng CRUD (Thêm, Đọc, Cập nhật, Xóa) cho các giao dịch.
*   **Ngân sách:** Cho phép người dùng tạo và theo dõi ngân sách cho từng hạng mục chi tiêu.
*   **Thống kê:** Biểu đồ và đồ thị trực quan để phân tích dữ liệu tài chính.
*   **Quản lý trạng thái:** Sử dụng Provider để quản lý trạng thái ứng dụng, bao gồm cả `MultiProvider` để kết hợp nhiều provider.
*   **UI/UX:** Giao diện hiện đại, sạch sẽ theo phong cách Material 3, có chế độ sáng và tối (dark/light mode).

## Kiến trúc

Ứng dụng sẽ tuân theo kiến trúc phân lớp, với sự tách biệt rõ ràng giữa các tầng UI, business logic, và data.

*   **`lib/`**
    *   **`main.dart`**: Điểm khởi đầu của ứng dụng.
    *   **`models/`**: Chứa các data model (ví dụ: `transaction_model.dart`, `budget_model.dart`).
    *   **`providers/`**: Chứa các Provider để quản lý trạng thái (ví dụ: `app_provider.dart`, `budget_provider.dart`).
    *   **`screens/`**: Chứa giao diện cho từng màn hình của ứng dụng.
    *   **`widgets/`**: Chứa các thành phần UI có thể tái sử dụng.
    *   **`utils/`**: Chứa các tệp tiện ích như hằng số và các hàm hỗ trợ.

## Kế hoạch triển khai

1.  **Thiết lập dự án:**
    *   Tạo cấu trúc thư mục cần thiết.
    *   Thêm các dependencies vào tệp `pubspec.yaml`.
    *   Tạo tệp `blueprint.md`.

2.  **Bản địa hóa (Localization):**
    *   Tạo thư mục `assets/translations` cùng các tệp `en.json`, `vi.json`, và `fr.json`.

3.  **Triển khai lõi:**
    *   Viết mã trong `main.dart` để khởi tạo ứng dụng và `MultiProvider` để cung cấp `AppProvider` và `BudgetProvider`.
    *   Tạo `TransactionModel` và `BudgetModel`.
    *   Triển khai các provider để quản lý trạng thái cho giao dịch, cài đặt và ngân sách.

4.  **Phát triển giao diện (UI):**
    *   Xây dựng màn hình chọn ngôn ngữ cho người dùng mới.
    *   Xây dựng các màn hình chính: Home, Transactions, Budget, Statistics và Settings.
    *   Triển khai thanh điều hướng dưới cùng (bottom navigation bar).
    *   Tạo các widget có thể tái sử dụng để hiển thị giao dịch và tiến độ ngân sách.

5.  **Hoàn thiện:**
    *   Đảm bảo ứng dụng hoạt động đầy đủ và có thể chạy bằng `flutter run`.
    *   Định dạng mã nguồn bằng `dart format .`.

## Cấu trúc tệp hiện tại

```
lib
├── main.dart
├── models
│   ├── transaction_model.dart
│   └── budget_model.dart
├── providers
│   ├── app_provider.dart
│   └── budget_provider.dart
├── screens
│   ├── budget_screen.dart
│   ├── home_screen.dart
│   ├── settings_screen.dart
│   ├── statistics_screen.dart
│   ├── transactions_screen.dart
│   ├── language_selection_screen.dart
│   ├── currency_selection_screen.dart
│   └── add_budget_screen.dart
├── screens.dart
└── utils
    ├── constants.dart
    └── helpers.dart
```
