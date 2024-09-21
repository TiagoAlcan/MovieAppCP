import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:movie_app/common/utils.dart';
import 'package:movie_app/models/movie_detail_model.dart';
import 'package:movie_app/pages/add_rating/add_rating.dart';
import 'package:movie_app/pages/reviews/reviews_page.dart';
import 'package:movie_app/services/api_services.dart';

class MovieDetailPage extends StatefulWidget {
  final int movieId;
  const MovieDetailPage({super.key, required this.movieId});

  @override
  State<MovieDetailPage> createState() => _MovieDetailPageState();
}

class _MovieDetailPageState extends State<MovieDetailPage> {
  ApiServices apiServices = ApiServices();
  late Future<MovieDetailModel> _movieDetail;

  @override
  void initState() {
    super.initState();
    _fetchInitialData();
  }

  Future<void> _fetchInitialData() async {
    _movieDetail = apiServices.getMovieDetail(widget.movieId);
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    print(widget.movieId);
    return Scaffold(
      body: SingleChildScrollView(
        child: FutureBuilder(
          future: _movieDetail,
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              final movie = snapshot.data;
              final genresText =
                  movie!.genres.map((genre) => genre.name).join(', ');

              return _MovieDetailSection(
                movie: movie,
                genresText: genresText,
                size: size,
              );
            }
            return const SizedBox();
          },
        ),
      ),
    );
  }
}

class _MovieDetailSection extends StatelessWidget {
  final MovieDetailModel movie;
  final String genresText;
  final Size size;

  const _MovieDetailSection({
    required this.movie,
    required this.genresText,
    required this.size,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _MovieHeader(
          movie: movie,
          size: size,
        ),
        _MovieInfoSection(
          movie: movie,
          genresText: genresText,
        ),
        _MovieRecommendationsSection(
          movieId: movie.id,
        ),
      ],
    );
  }
}

class _MovieHeader extends StatelessWidget {
  final MovieDetailModel movie;
  final Size size;

  const _MovieHeader({
    required this.movie,
    required this.size,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          height: size.height * 0.4,
          decoration: BoxDecoration(
            image: DecorationImage(
              image: NetworkImage("$imageUrl${movie.posterPath}"),
              fit: BoxFit.cover,
            ),
          ),
          child: SafeArea(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                )
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _MovieInfoSection extends StatelessWidget {
  final MovieDetailModel movie;
  final String genresText;

  const _MovieInfoSection({
    required this.movie,
    required this.genresText,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            movie.title,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 15),
          Row(
            children: [
              Text(
                movie.releaseDate.year.toString(),
                style: const TextStyle(
                  color: Colors.grey,
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Text(
                  genresText,
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 14,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildRatingWidget(context),
              _buildReviewButton(context),
            ],
          ),
          const SizedBox(height: 20),
          Text(
            movie.overview,
            maxLines: 6,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRatingWidget(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => AddRatingPage(movie: movie),
          ),
        );
      },
      child: Row(
        children: [
          const Icon(Icons.star, color: Colors.yellow, size: 20),
          const SizedBox(width: 5),
          Text(
            '${movie.voteAverage.toStringAsFixed(1)}/10',
            style: const TextStyle(fontSize: 16),
          ),
        ],
      ),
    );
  }

  Widget _buildReviewButton(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ReviewsPage(movieId: movie.id),
          ),
        );
      },
      icon: const Icon(Icons.rate_review, size: 20),
      label: const Text('Review'),
      style: ElevatedButton.styleFrom(
        foregroundColor: Colors.white,
        backgroundColor: Colors.blue,
      ),
    );
  }
}

class _MovieRecommendationsSection extends StatelessWidget {
  final int movieId;

  const _MovieRecommendationsSection({
    required this.movieId,
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: ApiServices().getMovieRecommendations(movieId),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          final movie = snapshot.data;
          return movie!.movies.isEmpty
              ? const SizedBox()
              : Padding(
                  padding: const EdgeInsets.all(10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Títulos parecidos",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                      const SizedBox(height: 10),
                      GridView.builder(
                        physics: const NeverScrollableScrollPhysics(),
                        shrinkWrap: true,
                        padding: EdgeInsets.zero,
                        scrollDirection: Axis.vertical,
                        itemCount: movie.movies.length,
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          mainAxisSpacing: 10,
                          crossAxisSpacing: 10,
                          childAspectRatio: 1.5 / 2,
                        ),
                      itemBuilder: (context, index) {
                        return InkWell(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => MovieDetailPage(
                                  movieId: movie.movies[index].id,
                                ),
                              ),
                            );
                          },
                          child: CachedNetworkImage(
                            imageUrl:
                                "$imageUrl${movie.movies[index].posterPath}",
                          ),
                        );
                       },
                      ),
                    ],
                  ),
                );
        }
        return const Text("Something Went wrong");
      },
    );
  }
}
