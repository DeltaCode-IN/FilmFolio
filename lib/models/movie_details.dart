class Movie {
  final String movieName, releaseDate, language;
  final double popularity;
  final Map<String, String> crewDetails;

  Movie({
    required this.movieName,
    required this.releaseDate,
    required this.popularity,
    required this.language,
    required this.crewDetails,
  });
}

class MovieCredits {
  final List<Map<String, dynamic>> crew;

  MovieCredits({required this.crew});

  factory MovieCredits.fromJson(Map<String, dynamic> json) {
    return MovieCredits(
      crew: List<Map<String, dynamic>>.from(json['crew'] ?? []),
    );
  }
}
