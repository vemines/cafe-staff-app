import 'package:equatable/equatable.dart';

class FeedbackEntity extends Equatable {
  final String id;
  final int rating;
  final String comment;
  final DateTime timestamp;

  const FeedbackEntity({
    required this.id,
    required this.rating,
    required this.comment,
    required this.timestamp,
  });

  @override
  List<Object?> get props => [id, rating, comment, timestamp];

  FeedbackEntity copyWith({String? id, int? rating, String? comment, DateTime? timestamp}) {
    return FeedbackEntity(
      id: id ?? this.id,
      rating: rating ?? this.rating,
      comment: comment ?? this.comment,
      timestamp: timestamp ?? this.timestamp,
    );
  }
}
