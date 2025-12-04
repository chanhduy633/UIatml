// ============================================
// FILE: lib/data/rescue_data.dart
// ============================================
import 'package:latlong2/latlong.dart';
import 'dart:math' as math;
import '../models/rescue_point.dart';

class RescueData {
  static List<RescuePoint> getSampleData() {
    final random = math.Random();
    final now = DateTime.now();

    return [
      // Điểm cần trợ giúp - Hà Nội
      RescuePoint(
        id: 'HAN-001',
        position: const LatLng(21.0285, 105.8542),
        name: 'Nguyễn Văn A',
        phone: '0912345001',
        isSafe: false,
        adults: 2,
        children: 1,
        elderly: 1,
        address: '123 Trần Hưng Đạo, Hoàn Kiếm, Hà Nội',
        conditions: ['Đói', 'Khát', 'Cần thuốc'],
        description: 'Nhà bị ngập 2m, cần cứu trợ khẩn cấp',
        reportTime: now.subtract(const Duration(hours: 2)),
      ),
      RescuePoint(
        id: 'HAN-002',
        position: const LatLng(21.0342, 105.8412),
        name: 'Trần Thị B',
        phone: '0912345002',
        isSafe: false,
        adults: 3,
        children: 2,
        address: '456 Láng Hạ, Đống Đa, Hà Nội',
        conditions: ['Bị thương', 'Thai sản'],
        reportTime: now.subtract(const Duration(hours: 1)),
      ),

      // Điểm an toàn - Hà Nội
      RescuePoint(
        id: 'HAN-003',
        position: const LatLng(21.0583, 105.8000),
        name: 'Lê Văn C',
        phone: '0912345003',
        isSafe: true,
        adults: 4,
        children: 1,
        elderly: 2,
        address: '789 Cầu Giấy, Hà Nội',
        reportTime: now.subtract(const Duration(minutes: 30)),
      ),

      // Điểm cần trợ giúp - Đà Nẵng
      RescuePoint(
        id: 'DAD-001',
        position: const LatLng(16.0544, 108.2022),
        name: 'Phạm Văn D',
        phone: '0912345004',
        isSafe: false,
        adults: 2,
        children: 3,
        elderly: 1,
        address: '12 Nguyễn Văn Linh, Hải Châu, Đà Nẵng',
        conditions: ['Đói', 'Khát', 'Người già/trẻ em'],
        description: 'Mất điện, nước ngập cao',
        reportTime: now.subtract(const Duration(hours: 3)),
      ),
      RescuePoint(
        id: 'DAD-002',
        position: const LatLng(16.0678, 108.2208),
        name: 'Hoàng Thị E',
        phone: '0912345005',
        isSafe: false,
        adults: 1,
        children: 2,
        address: '34 Trần Phú, Sơn Trà, Đà Nẵng',
        conditions: ['Bị thương', 'Cần thuốc'],
        reportTime: now.subtract(const Duration(hours: 4)),
      ),

      // Điểm an toàn - Đà Nẵng
      RescuePoint(
        id: 'DAD-003',
        position: const LatLng(16.0745, 108.1505),
        name: 'Võ Văn F',
        phone: '0912345006',
        isSafe: true,
        adults: 3,
        address: '56 Điện Biên Phủ, Thanh Khê, Đà Nẵng',
        reportTime: now.subtract(const Duration(minutes: 45)),
      ),

      // Điểm cần trợ giúp - TP.HCM
      RescuePoint(
        id: 'SGN-001',
        position: const LatLng(10.7769, 106.7009),
        name: 'Đặng Văn G',
        phone: '0912345007',
        isSafe: false,
        adults: 2,
        children: 1,
        elderly: 2,
        address: '78 Nguyễn Huệ, Quận 1, TP.HCM',
        conditions: ['Đói', 'Khát', 'Mất liên lạc'],
        description: 'Khu vực bị cô lập',
        reportTime: now.subtract(const Duration(hours: 5)),
      ),
      RescuePoint(
        id: 'SGN-002',
        position: const LatLng(10.7856, 106.6950),
        name: 'Bùi Thị H',
        phone: '0912345008',
        isSafe: false,
        adults: 4,
        children: 2,
        address: '90 Lê Lợi, Quận 1, TP.HCM',
        conditions: ['Bị thương', 'Bệnh mãn tính'],
        reportTime: now.subtract(const Duration(hours: 2)),
      ),

      // Điểm an toàn - TP.HCM
      RescuePoint(
        id: 'SGN-003',
        position: const LatLng(10.8231, 106.6297),
        name: 'Phan Văn I',
        phone: '0912345009',
        isSafe: true,
        adults: 5,
        children: 3,
        elderly: 1,
        address: '12 Trường Chinh, Tân Bình, TP.HCM',
        reportTime: now.subtract(const Duration(hours: 1)),
      ),

      // Thêm dữ liệu mẫu ngẫu nhiên
      ...List.generate(20, (index) {
        final lat = 8 + random.nextDouble() * 15;
        final lng = 102 + random.nextDouble() * 8;
        final isSafe = random.nextBool();

        return RescuePoint(
          id: 'AUTO-${index + 10}',
          position: LatLng(lat, lng),
          name: 'Người dân ${index + 10}',
          phone: '091234${(5010 + index).toString()}',
          isSafe: isSafe,
          adults: 1 + random.nextInt(4),
          children: random.nextInt(3),
          elderly: random.nextInt(2),
          address: 'Địa chỉ mẫu ${index + 10}',
          conditions: isSafe ? [] : ['Đói', 'Khát'],
          reportTime: now.subtract(Duration(hours: random.nextInt(6))),
        );
      }),
    ];
  }
}
