import 'dart:convert';

class ReviewsResult {
  int id;
  int page;
  List<Review> results;
  int totalPages;
  int totalResults;

  ReviewsResult({
    required this.id,
    required this.page,
    required this.results,
    required this.totalPages,
    required this.totalResults,
  });

  factory ReviewsResult.fromRawJson(String str) => ReviewsResult.fromJson(json.decode(str));

  factory ReviewsResult.fromJson(Map<String, dynamic> json) => ReviewsResult(
        id: json["id"],
        page: json["page"],
        results: List<Review>.from(json["results"].map((x) => Review.fromJson(x))),
        totalPages: json["total_pages"],
        totalResults: json["total_results"],
      );
}

class Review {
  String author;
  AuthorDetails authorDetails;
  String content;
  DateTime createdAt;
  String id;
  DateTime updatedAt;
  String url;

  Review({
    required this.author,
    required this.authorDetails,
    required this.content,
    required this.createdAt,
    required this.id,
    required this.updatedAt,
    required this.url,
  });

  factory Review.fromJson(Map<String, dynamic> json) => Review(
        author: json["author"],
        authorDetails: AuthorDetails.fromJson(json["author_details"]),
        content: json["content"],
        createdAt: DateTime.parse(json["created_at"]),
        id: json["id"],
        updatedAt: DateTime.parse(json["updated_at"]),
        url: json["url"],
      );
}

class AuthorDetails {
  String name;
  String username;
  String? avatarPath;
  double? rating;

  AuthorDetails({
    required this.name,
    required this.username,
    this.avatarPath,
    this.rating,
  });

  factory AuthorDetails.fromJson(Map<String, dynamic> json) => AuthorDetails(
        name: json["name"] ?? '',
        username: json["username"] ?? '',
        avatarPath: json["avatar_path"],
        rating: json["rating"]?.toDouble(),
      );
}