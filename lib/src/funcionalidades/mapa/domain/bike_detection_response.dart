class BikeDetectionResponse {
  final bool success;
  final String message;
  final String code;
  final BikeDetectionData? data;

  BikeDetectionResponse({
    required this.success,
    required this.message,
    required this.code,
    this.data,
  });

  factory BikeDetectionResponse.fromJson(Map<String, dynamic> json) {
    return BikeDetectionResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      code: json['code'] ?? '',
      data: json['data'] != null
          ? BikeDetectionData.fromJson(json['data'])
          : null,
    );
  }
}

class BikeDetectionData {
  final bool hasBike;
  final double confidence;
  final int count;
  final List<DetectedItem> items;

  BikeDetectionData({
    required this.hasBike,
    required this.confidence,
    required this.count,
    required this.items,
  });

  factory BikeDetectionData.fromJson(Map<String, dynamic> json) {
    return BikeDetectionData(
      hasBike: json['hasBike'] ?? false,
      confidence: (json['confidence'] ?? 0).toDouble(),
      count: json['count'] ?? 0,
      items: json['items'] != null
          ? (json['items'] as List)
              .map((item) => DetectedItem.fromJson(item))
              .toList()
          : [],
    );
  }
}

class DetectedItem {
  final int classValue;
  final String className;
  final double confidence;
  final List<int> bbox;

  DetectedItem({
    required this.classValue,
    required this.className,
    required this.confidence,
    required this.bbox,
  });

  factory DetectedItem.fromJson(Map<String, dynamic> json) {
    return DetectedItem(
      classValue: json['class'] ?? 0,
      className: json['class_name'] ?? '',
      confidence: (json['confidence'] ?? 0).toDouble(),
      bbox: json['bbox'] != null
          ? List<int>.from(json['bbox'])
          : [],
    );
  }
}

