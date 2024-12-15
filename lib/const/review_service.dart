// import 'dart:convert';
// import 'package:http/http.dart' as http;
// import 'package:provider/provider.dart';
// import 'package:ridesewa/provider/driverprovider.dart';
// import 'package:your_app/providers/driver_provider.dart';

// class ReviewService {
//   final String baseUrl = 'http://yourserver.com'; // Replace with your API base URL

//   Future<List<Review>> getDriverReviews(BuildContext context) async {
//     final driverUid = Provider.of<DriverProvider>(context).driverUid;

//     final response = await http.get(Uri.parse('$baseUrl/driver/reviews/$driverUid'));

//     if (response.statusCode == 200) {
//       List<dynamic> data = json.decode(response.body);
//       return data.map((json) => Review.fromJson(json)).toList();
//     } else {
//       throw Exception('Failed to load reviews');
//     }
//   }

//   Future<void> addReview(BuildContext context, int driverRating, int userRating, String driverReview, String userReview) async {
//     final driverUid = Provider.of<DriverProvider>(context).driverUid;

//     final response = await http.post(
//       Uri.parse('$baseUrl/driver/review'),
//       headers: {'Content-Type': 'application/json'},
//       body: json.encode({
//         'driver_uid': driverUid,
//         'driver_rating': driverRating,
//         'user_rating': userRating,
//         'driver_review': driverReview,
//         'user_review': userReview,
//       }),
//     );

//     if (response.statusCode != 201) {
//       throw Exception('Failed to add review');
//     }
//   }

//   Future<void> updateReview(BuildContext context, int reviewId, int driverRating, int userRating, String driverReview, String userReview) async {
//     final driverUid = Provider.of<DriverProvider>(context).driverUid;

//     final response = await http.put(
//       Uri.parse('$baseUrl/driver/review/$reviewId'),
//       headers: {'Content-Type': 'application/json'},
//       body: json.encode({
//         'driver_uid': driverUid,
//         'driver_rating': driverRating,
//         'user_rating': userRating,
//         'driver_review': driverReview,
//         'user_review': userReview,
//       }),
//     );

//     if (response.statusCode != 200) {
//       throw Exception('Failed to update review');
//     }
//   }

//   Future<void> deleteReview() async {
//     final driverProvider = Provider.of<DriverProvider>(context, listen: false);
//     final String? driveruid = driverProvider.driver?.uid?.toString();

//     final response = await http.delete(
//       Uri.parse('$baseUrl/driver/review/$reviewId'),
//     );

//     if (response.statusCode != 200) {
//       throw Exception('Failed to delete review');
//     }
//   }
// }
