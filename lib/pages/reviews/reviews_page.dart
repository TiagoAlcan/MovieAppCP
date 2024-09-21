import 'package:flutter/material.dart';
import 'package:movie_app/models/reviews_model.dart';
import 'package:movie_app/services/api_services.dart';

class ReviewsPage extends StatefulWidget {
  final int movieId;

  const ReviewsPage({
    Key? key, 
    required this.movieId
  }) : super(key: key);

  @override
  State<ReviewsPage> createState() => _ReviewsPageState();
}

class _ReviewsPageState extends State<ReviewsPage> {
  ApiServices apiServices = ApiServices();
  late Future<ReviewsResult> _movieReviews;

  @override
  void initState() {
    super.initState();
    _fetchInitialData();
  }

  Future<void> _fetchInitialData() async {
    _movieReviews = apiServices.getReviews(widget.movieId);
  }

  String _getAvatarUrl(String? path) {
    if (path == null) return 'https://via.placeholder.com/150';
    if (path.startsWith('/')) {
      return 'https://image.tmdb.org/t/p/w185$path';
    }
    return path;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Reviews'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: FutureBuilder<ReviewsResult>(
          future: _movieReviews,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            } else if (!snapshot.hasData || snapshot.data!.results.isEmpty) {
              return Center(child: Text('No reviews found.'));
            } else {
              var reviews = snapshot.data!.results;
              return ListView.builder(
                itemCount: reviews.length,
                itemBuilder: (context, index) {
                  var review = reviews[index];
                  return Card(
                    margin: EdgeInsets.only(bottom: 16),
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              CircleAvatar(
                                backgroundImage: NetworkImage(
                                  _getAvatarUrl(review.authorDetails.avatarPath),
                                ),
                              ),
                              SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      review.author,
                                      style: TextStyle(fontWeight: FontWeight.bold),
                                    ),
                                    if (review.authorDetails.rating != null)
                                      Row(
                                        children: [
                                          Icon(Icons.star, color: Colors.amber, size: 18),
                                          Text(' ${review.authorDetails.rating!.toStringAsFixed(1)}'),
                                        ],
                                      ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 16),
                          Text(
                            review.content.length > 500
                                ? '${review.content.substring(0, 500)}...'
                                : review.content,
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            }
          },
        ),
      ),
    );
  }
}