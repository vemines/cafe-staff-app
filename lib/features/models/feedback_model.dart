import '/core/constants/api_map.dart';
import '/core/utils/parse_utils.dart';
import '../entities/feedback_entity.dart';

class FeedbackModel extends FeedbackEntity {
  const FeedbackModel({
    required super.id,
    required super.rating,
    required super.comment,
    required super.timestamp,
  });

  factory FeedbackModel.fromJson(Map<String, dynamic> json) {
    return FeedbackModel(
      id: json[FeedbackApiMap.id] as String,
      rating: intParse(json[FeedbackApiMap.rating]),
      comment: json[FeedbackApiMap.comment] as String,
      timestamp: dateParse(json[FeedbackApiMap.timestamp]),
    );
  }
  factory FeedbackModel.fromEntity(FeedbackEntity entity) {
    return FeedbackModel(
      id: entity.id,
      rating: entity.rating,
      comment: entity.comment,
      timestamp: entity.timestamp,
    );
  }

  @override
  FeedbackModel copyWith({String? id, int? rating, String? comment, DateTime? timestamp}) {
    return FeedbackModel(
      id: id ?? this.id,
      rating: rating ?? this.rating,
      comment: comment ?? this.comment,
      timestamp: timestamp ?? this.timestamp,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      FeedbackApiMap.id: id,
      FeedbackApiMap.rating: rating,
      FeedbackApiMap.comment: comment,
      FeedbackApiMap.timestamp: timestamp.toIso8601String(),
    };
  }
}
