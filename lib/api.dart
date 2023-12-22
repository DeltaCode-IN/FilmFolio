import 'dart:convert';

import 'package:filmfolio/constants.dart';
import 'package:filmfolio/models/actor_model.dart';
import 'package:filmfolio/models/movie_details.dart';
import 'package:http/http.dart' as http;
import 'package:nb_utils/nb_utils.dart';

Future<ActorModel?> searchActor(String name) async {
  try {
    final response = await http.get(
        Uri.parse('https://api.themoviedb.org/3/search/person?query=$name'),
        headers: {
          // 'x-access-token': apiKey,
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        });

    if (response.statusCode == 200) {
      var body = json.decode(response.body);
      ActorModel actorRes = ActorModel.fromJson(body);
      return actorRes;
    } else {
      return null;
    }
  } catch (e) {
    toast("Something went wrong. Please try again later");
    print(e);
    return null;
  }
}

Future<MovieCredits> getMovieCredits(int movieId) async {
  final creditsUrl = 'https://api.themoviedb.org/3/movie/$movieId/credits';
  final response = await http.get(Uri.parse(creditsUrl), headers: {
    // 'x-access-token': apiKey,
    'Authorization': 'Bearer $token',
    'Content-Type': 'application/json',
  });

  if (response.statusCode == 200) {
    return MovieCredits.fromJson(json.decode(response.body));
  } else {
    throw Exception('Failed to load movie credits');
  }
}

Future<List<Movie>> getMoviesWithCast(int actorId) async {
  const baseUrl = 'https://api.themoviedb.org/3/discover/movie';
  final List<Movie> allMovies = [];
  int page = 1;
  try {
    while (true) {
      final response = await http
          .get(Uri.parse('$baseUrl?with_cast=$actorId&page=$page'), headers: {
        // 'x-access-token': apiKey,
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      });

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data['results'] != null && data['results'].isNotEmpty) {
          for (var movie in data['results']) {
            final movieId = movie['id'] ?? '';
            final creditsData = await getMovieCredits(movieId);

            final cast = extractCastDetails(creditsData.cast);
            final crew = extractCrewDetails(creditsData.crew);


            final Map<String, String> crewDetails = {};

            for (var crewMember in creditsData.crew) {
              final department = crewMember['known_for_department'];
              final name = crewMember['name'];
              crewDetails[department] = name;
            }

             allMovies.add(Movie(
              movieName: movie['title'] ?? '',
              releaseDate: movie['release_date'] ?? '',
              popularity: movie['popularity'].toDouble(),
              language: movie['original_language'] ?? '',
              cast: cast,
              crew: crew,
            ));
          }
          page++;
        } else {
          break;
        }
      } else {
        throw Exception('Failed to load movies');
      }
    }
  } catch (e) {
    print(e);
  }

  return allMovies;
}

Map<String, dynamic> extractCastDetails(List<Map<String, dynamic>> castList) {
  Map<String, dynamic> castDetails = {'actor': [], 'actress': []};

  for (var member in castList) {
    final gender = member['gender'];
    final department = member['known_for_department'];
    final name = member['name'];

    if (gender == 2) {
      castDetails['actor'].add({'name': name, 'department': department});
    } else {
      castDetails['actress'].add({'name': name, 'department': department});
    }
  }

  return castDetails;
}

List<Map<String, dynamic>> extractCrewDetails(List<Map<String, dynamic>> crewList) {
  return crewList.map((member) => {'name': member['name'], 'department': member['department']}).toList();
}