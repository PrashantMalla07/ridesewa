class Review {
  final int id;
  final int rideId;
  final int userId;
  final String driverUid;
  final int driverRating;
  final int userRating;
  final String driverReview;
  final String userReview;
  final String createdAt;

  Review({
    required this.id,
    required this.rideId,
    required this.userId,
    required this.driverUid,
    required this.driverRating,
    required this.userRating,
    required this.driverReview,
    required this.userReview,
    required this.createdAt,
  });

  factory Review.fromJson(Map<String, dynamic> json) {
    return Review(
      id: json['id'],
      rideId: json['ride_id'],
      userId: json['user_id'],
      driverUid: json['driver_uid'],
      driverRating: json['driver_rating'],
      userRating: json['user_rating'],
      driverReview: json['driver_review'],
      userReview: json['user_review'],
      createdAt: json['created_at'],
    );
  }
}
