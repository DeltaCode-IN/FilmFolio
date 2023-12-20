class Movie {
  final String movieName;
  final String producers;
  final String director;
  final String writers;

  Movie({
    required this.movieName,
    required this.producers,
    required this.director,
    required this.writers,
  });

  factory Movie.fromJson(Map<String, dynamic> json) {
    return Movie(
      movieName: json['MovieName'] ?? '',
      producers: json['Producers'] ?? '',
      director: json['Director'] ?? '',
      writers: json['Writers'] ?? '',
    );
  }
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