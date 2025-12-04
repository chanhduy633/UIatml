// ============================================
// FILE: lib/constants/province_map.dart
// ============================================
class ProvinceMap {
  static const Map<String, String> provinces = {
    "HÀ NỘI": "HAN",
    "HẢI PHÒNG": "HPH",
    "LÀO CAI": "LCA",
    "YÊN BÁI": "YBA",
    "ĐIỆN BIÊN": "DBI",
    "HÒA BÌNH": "HBI",
    "LAI CHÂU": "LCH",
    "SƠN LA": "SLA",
    "HÀ GIANG": "HGI",
    "CAO BẰNG": "CBA",
    "BẮC KẠN": "BKA",
    "LẠNG SƠN": "LSO",
    "TUYÊN QUANG": "TQU",
    "THÁI NGUYÊN": "TNG",
    "PHÚ THỌ": "PTO",
    "BẮC GIANG": "BGG",
    "QUẢNG NINH": "QNI",
    "BẮC NINH": "BNI",
    "HÀ NAM": "HNA",
    "HẢI DƯƠNG": "HDU",
    "HƯNG YÊN": "HYE",
    "NAM ĐỊNH": "NDH",
    "NINH BÌNH": "NBH",
    "THÁI BÌNH": "TBH",
    "VĨNH PHÚC": "VPH",
    "THANH HÓA": "THO",
    "NGHỆ AN": "NAN",
    "HÀ TĨNH": "HTI",
    "QUẢNG BÌNH": "QBI",
    "QUẢNG TRỊ": "QTR",
    "THỪA THIÊN HUẾ": "HUI",
    "ĐÀ NẴNG": "DAD",
    "QUẢNG NAM": "QNM",
    "QUẢNG NGÃI": "QNG",
    "BÌNH ĐỊNH": "BDI",
    "PHÚ YÊN": "PYN",
    "KHÁNH HÒA": "KHO",
    "NINH THUẬN": "NTH",
    "BÌNH THUẬN": "BTH",
    "KON TUM": "KTU",
    "GIA LAI": "GLA",
    "ĐẮK LẮK": "DLK",
    "ĐẮK NÔNG": "DNO",
    "LÂM ĐỒNG": "LDG",
    "HỒ CHÍ MINH": "SGN",
    "BÌNH PHƯỚC": "BPC",
    "BÌNH DƯƠNG": "BDG",
    "ĐỒNG NAI": "DNI",
    "TÂY NINH": "TNI",
    "BÀ RỊA VŨNG TÀU": "VTU",
    "CẦN THƠ": "VCA",
    "LONG AN": "LAN",
    "TIỀN GIANG": "TGG",
    "BẾN TRE": "BTR",
    "TRÀ VINH": "TVH",
    "VĨNH LONG": "VLG",
    "ĐỒNG THÁP": "DTP",
    "AN GIANG": "AGI",
    "KIÊN GIANG": "KGI",
    "HẬU GIANG": "HGU",
    "SÓC TRĂNG": "STR",
    "BẠC LIÊU": "BLI",
    "CÀ MAU": "CMU",
  };

  static String? getProvinceCode(String address) {
    final upperAddress = address.toUpperCase();
    for (var entry in provinces.entries) {
      if (upperAddress.contains(entry.key)) {
        return entry.value;
      }
    }
    return null;
  }

  static String generateCode(String? provinceCode) {
    final timestamp = DateTime.now().millisecondsSinceEpoch
        .toString()
        .substring(7);
    return '${provinceCode ?? 'UNK'}-$timestamp';
  }
}
