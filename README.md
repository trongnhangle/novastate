# NovaState

## Giải pháp quản lý state nhẹ, hiệu quả cho Flutter

NovaState là một package quản lý state nhẹ và hiệu quả cho Flutter. Package này không phụ thuộc vào bất kỳ package state management nào khác trên pub.dev và được thiết kế để dễ dàng tích hợp vào các ứng dụng Flutter với nhiều quy mô khác nhau.

## Giới thiệu

NovaState được phát triển để đáp ứng nhu cầu về một giải pháp quản lý state vừa đơn giản vừa mạnh mẽ cho các ứng dụng Flutter. Tên gọi NovaState lấy cảm hứng từ tên nhóm startup của tôi - NOVA.

Dự án này được hoàn thành trong thời gian ngắn nhờ sự kết hợp giữa kiến thức chuyên môn về Flutter và tối ưu hóa quy trình phát triển. Trong quá trình thực hình package này tôi có sử dụng Chatgpt cho vài phần tôi chưa rõ để tiến độ làm việc trở nên nhanh nhất 😅.

## Các thành phần chính

NovaState bao gồm 6 thành phần chính:

1. **Store**: Trung tâm lưu trữ và quản lý state, hỗ trợ các hoạt động đồng bộ và bất đồng bộ
2. **StateProvider**: Cung cấp state cho cây widget thông qua InheritedWidget
3. **StateBuilder**: Tự động xây dựng lại UI khi state thay đổi
4. **StateSelector**: Tối ưu hiệu suất bằng cách chỉ rebuild khi phần được chọn thay đổi
5. **StateConsumer**: Kết hợp khả năng đọc state và xây dựng lại UI
6. **NestedStateExtension**: Xử lý state phức tạp dạng lồng nhau

## Đáp ứng yêu cầu

### 1. Cấu trúc và Tổ chức

- ✓ **Kiến trúc rõ ràng**: Package được chia thành các module riêng biệt, mỗi module đảm nhiệm một chức năng cụ thể
- ✓ **Dễ mở rộng**: Thiết kế theo nguyên tắc đơn trách nhiệm, dễ dàng mở rộng thêm tính năng
- ✓ **Hỗ trợ state đơn giản và phức tạp**: 
  - State đơn giản: String, int, bool, ...
  - State phức tạp: List, Map, Object lồng nhau
  - Có tiện ích NestedStateExtension để xử lý state lồng nhau

### 2. API và Giao diện sử dụng

- ✓ **API thân thiện**: Cú pháp đơn giản, dễ hiểu, tương tự với các state management phổ biến
- ✓ **Phương thức cơ bản**:
  - Khởi tạo state: `Store<T>(initialState)` hoặc `Store.builder(() => initialState)`
  - Cập nhật state: `store.update((state) => newState)` 
  - Theo dõi state: `StateBuilder`, `StateSelector`, `StateConsumer`
- ✓ **Tối ưu hiệu suất**: StateSelector giúp chỉ rebuild khi phần được chọn từ state thay đổi

### 3. Hỗ trợ đồng bộ và bất đồng bộ

- ✓ **Cập nhật đồng bộ**: Thông qua phương thức `update` và `state` setter
- ✓ **Cập nhật bất đồng bộ**: Thông qua phương thức `updateAsync` để xử lý các tác vụ API hoặc bất đồng bộ khác
- ✓ **Xử lý lỗi**: Tích hợp xử lý lỗi cho các tác vụ bất đồng bộ

### 4. Hiệu suất và Quản lý bộ nhớ

- ✓ **Tránh rebuild không cần thiết**: StateSelector đảm bảo chỉ rebuild khi cần
- ✓ **Dọn dẹp tài nguyên**: Tự động hủy subscription để tránh rò rỉ bộ nhớ
- ✓ **Tương thích với ứng dụng lớn**: Kiến trúc được thiết kế để hoạt động ổn định với ứng dụng quy mô lớn

## Cách sử dụng

### Khởi tạo Store và StateProvider

```dart
// Định nghĩa kiểu state
class CounterState {
  final int value;
  
  const CounterState({this.value = 0});
  
  CounterState copyWith({int? value}) {
    return CounterState(value: value ?? this.value);
  }
}

// Khởi tạo Store
final counterStore = Store<CounterState>(const CounterState());

// Cung cấp Store cho cây widget
Widget build(BuildContext context) {
  return StateProvider<CounterState>(
    store: counterStore,
    child: const MyApp(),
  );
}
```

### Lắng nghe state và cập nhật UI

```dart
// Lắng nghe toàn bộ state
StateBuilder<CounterState>(
  builder: (context, state) {
    return Text('${state.value}');
  },
)

// Tối ưu hiệu suất với StateSelector
StateSelector<CounterState, int>(
  selector: (state) => state.value,
  builder: (context, value) {
    return Text('$value');
  },
)
```

### Cập nhật state

```dart
// Lấy store
final store = StateProvider.storeOf<CounterState>(context);

// Cập nhật đồng bộ
store.update((state) => state.copyWith(value: state.value + 1));

// Cập nhật bất đồng bộ
await store.updateAsync((state) async {
  final result = await fetchDataFromApi();
  return state.copyWith(value: result);
});
```

### Xử lý state lồng nhau

```dart
// Định nghĩa state phức tạp
class UserState {
  final String name;
  final Map<String, dynamic> profile;
  
  const UserState({required this.name, required this.profile});
}

// Sử dụng NestedStateExtension
final userState = UserState(...);
final updatedState = userState.updateNestedField('profile.address.city', 'Hà Nội');
```

---

  2025 Nguyen Le Trong Nhan
