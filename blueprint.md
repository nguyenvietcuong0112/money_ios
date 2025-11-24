# Blueprint: Money Manager App

## I. Tổng quan

Money Manager là một ứng dụng di động đa nền tảng giúp người dùng quản lý tài chính cá nhân một cách hiệu quả. Ứng dụng cho phép theo dõi các giao dịch thu chi, quản lý nhiều ví tiền, đặt ngân sách và xem báo cáo thống kê chi tiết.

### Chức năng cốt lõi:
- **Quản lý giao dịch:** Ghi chép các khoản thu, chi, vay và cho vay.
- **Quản lý ví:** Hỗ trợ nhiều loại ví khác nhau (tiền mặt, ngân hàng, ví điện tử).
- **Quản lý ngân sách:** Thiết lập ngân sách cho các hạng mục chi tiêu cụ thể.
- **Báo cáo và Thống kê:** Cung cấp biểu đồ trực quan về tình hình tài chính.
- **Đa ngôn ngữ & Đa tiền tệ:** Hỗ trợ nhiều ngôn ngữ và loại tiền tệ.

### Công nghệ sử dụng:
- **Framework:** Flutter
- **Quản lý trạng thái:** GetX
- **Lưu trữ cục bộ:** SharedPreferences
- **Fonts:** Google Fonts

---

## II. Thiết kế & Phong cách

- **UI/UX:** Giao diện sạch sẽ, hiện đại và trực quan, tập trung vào trải nghiệm người dùng mượt mà.
- **Màu sắc:** Sử dụng màu xanh lá cây làm màu chủ đạo, tạo cảm giác tích cực và liên quan đến tài chính.
- **Typography:** Sử dụng font "Lato" từ Google Fonts để đảm bảo tính nhất quán và dễ đọc.

---

## III. Kế hoạch hiện tại: Tái cấu trúc TextStyle với Google Fonts

**Mục tiêu:** Tạo một hệ thống TextStyle tập trung sử dụng Google Fonts để đảm bảo tính nhất quán trong toàn bộ ứng dụng và dễ dàng cho việc bảo trì, cập nhật sau này.

**Các bước thực hiện:**

1.  **Thêm package `google_fonts`:** Tích hợp thư viện Google Fonts vào dự án.
2.  **Tạo file `text_styles.dart`:** Tạo một file mới tại `lib/common/text_styles.dart`.
3.  **Định nghĩa các TextStyle với font Lato:**
    - Trong lớp `AppTextStyles`, định nghĩa các `TextStyle` tĩnh sử dụng `GoogleFonts.lato()`.
    - Các style bao gồm: `heading1Black`, `heading2`, `title`, `subtitle`, `body`, `button`, `incomeAmount`, `expenseAmount`, v.v.
4.  **Tái cấu trúc (Refactor) mã nguồn:**
    - Bắt đầu với `home_screen.dart`.
    - Thay thế các `TextStyle` inline bằng cách tham chiếu đến style trong `AppTextStyles`.
5.  **Kiểm tra và xác nhận:** Đảm bảo giao diện hiển thị đúng font chữ Lato và không bị lỗi.
