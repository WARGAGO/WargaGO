import 'package:wargago/core/models/BlobStorage/storage_response.dart';

class UserImagesResponse {
  final String userId;
  final int count;
  final List<StorageResponse> images;

  UserImagesResponse({
    required this.userId,
    required this.count,
    required this.images,
  });

  factory UserImagesResponse.fromJson(Map<String, dynamic> json) {
    return UserImagesResponse(
      userId: json['user_id'] as String,
      count: json['count'] as int,
      images: (json['images'] as List)
          .map((imageJson) => StorageResponse.fromJson(imageJson))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'count': count,
      'images': images.map((image) => image.toJson()).toList(),
    };
  }
}
