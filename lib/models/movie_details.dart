class Movie {
  final String movieName, releaseDate, language;
  final double popularity;
  final Map<String, dynamic> cast;
  final List<Map<String, dynamic>> crew;

  Movie({
    required this.movieName,
    required this.releaseDate,
    required this.popularity,
    required this.language,
    required this.cast,
    required this.crew,
  });
}

class MovieCredits {
  final List<Map<String, dynamic>> cast;
  final List<Map<String, dynamic>> crew;

  MovieCredits({required this.cast, required this.crew});

  factory MovieCredits.fromJson(Map<String, dynamic> json) {
    return MovieCredits(
      cast: List<Map<String, dynamic>>.from(json['cast'] ?? []),
      crew: List<Map<String, dynamic>>.from(json['crew'] ?? []),
    );
  }
}