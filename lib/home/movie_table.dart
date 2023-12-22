import 'dart:io';
import 'dart:typed_data';
import 'dart:html' as html;
import 'package:animate_do/animate_do.dart';
import 'package:csv/csv.dart';
import 'package:filmfolio/constants.dart';
import 'package:filmfolio/models/actor_model.dart';
import 'package:filmfolio/models/movie_details.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:path_provider/path_provider.dart';

// ignore: must_be_immutable
class MovieTable extends StatefulWidget {
  final List<Movie> movies;
  Actor? selectedActor;
  MovieTable({super.key, required this.movies, required this.selectedActor});

  @override
  State<MovieTable> createState() => _MovieTableState();
}

class _MovieTableState extends State<MovieTable> {
  final Set<String> allCrewRoles = {};

  List<String> getAllCrewRoles() {
    List<String> allRoles = [];
    for (var movie in widget.movies) {
      for (var crewMember in movie.crew) {
        final role = crewMember['department'];
        if (!allRoles.contains(role)) {
          allRoles.add(role);
        }
      }
    }
    return allRoles;
  }

  String getCastDetails(List<dynamic> castList) {
    return castList.map((cast) => '${cast['name']}').join(', ');
  }

  String getCrewDetails(List<Map<String, dynamic>> crewList, String role) {
    return '${crewList.where((crew) => crew['department'] == role).map((crew) => '${crew['name']}').join(', ')} ';
  }

  @override
  Widget build(BuildContext context) {
    TextStyle titleStyle = GoogleFonts.lato(fontSize: 17, color: Colors.white);
    List<String> allCrewRoles = getAllCrewRoles();

    Future<void> _exportToCsv() async {
      try {
        String csvContent = const ListToCsvConverter().convert([
          [
            'Sr No.',
            'Film Name',
            'Release Date',
            "Actor",
            "Actress",
            'Popularity',
            'Language',
            ...allCrewRoles
          ],
          ...widget.movies
              .asMap()
              .entries
              .map(
                (entry) => [
                  entry.key + 1,
                  entry.value.movieName.isEmpty ? "N/A" : entry.value.movieName,
                  entry.value.releaseDate.isEmpty
                      ? "N/A"
                      : entry.value.releaseDate,
                  getCastDetails(entry.value.cast['actor']).trim().isEmpty
                      ? "N/A"
                      : getCastDetails(entry.value.cast['actor']),
                  getCastDetails(entry.value.cast['actress']).trim().isEmpty
                      ? "N/A"
                      : getCastDetails(entry.value.cast['actress']),
                  entry.value.popularity.toString().isEmpty
                      ? "N/A"
                      : entry.value.popularity,
                  entry.value.language.isEmpty
                      ? "N/A"
                      : getLanguageName(entry.value.language),
                  ...allCrewRoles.map((role) =>
                      getCrewDetails(entry.value.crew, role).trim().isEmpty
                          ? "N/A"
                          : getCrewDetails(entry.value.crew, role)),
                ],
              )
              .toList(),
        ]);

        final blob = html.Blob([Uint8List.fromList(csvContent.codeUnits)]);
        final url = html.Url.createObjectUrlFromBlob(blob);
        final anchor = html.AnchorElement(href: url)
          ..target = 'web-download'
          ..download = '${(widget.selectedActor?.name ?? "Movies")}.csv';
        anchor.click();
        html.Url.revokeObjectUrl(url);

        toast('CSV file exported successfully!');
      } catch (e) {
        toast('Something went wrong. Please try again later');
      }
    }

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.selectedActor?.originalName ?? "N/A",
                      style: GoogleFonts.lato(
                          fontSize: 25,
                          color: Colors.white,
                          fontWeight: FontWeight.bold),
                    ),
                    15.height,
                    Row(
                      children: [
                        detailChip(
                            "Gender: ${getGender(widget.selectedActor?.gender ?? 0)}"),
                        10.width,
                        detailChip(
                            "Known for: ${widget.selectedActor?.knownForDepartment ?? "N/A"}"),
                        10.width,
                        detailChip(
                            "Language: ${(widget.selectedActor?.knownFor?.isEmpty ?? false) ? "N/A" : getLanguageName(widget.selectedActor?.knownFor?[0].originalLanguage ?? "N/A")}"),
                      ],
                    ),
                  ],
                ),
              ),
              InkWell(
                borderRadius: BorderRadius.circular(10),
                onTap: () => _exportToCsv(),
                child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 10),
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: Colors.white),
                    child: Row(
                      children: [
                        Text(
                          "Download CSV",
                          style: GoogleFonts.lato(
                            fontSize: 18,
                            color: Colors.black,
                          ),
                        ),
                        5.width,
                        Icon(
                          Icons.downloading,
                          color: Colors.black,
                        )
                      ],
                    )),
              ),
            ],
          ),
          20.height,
          Expanded(
            child: RawScrollbar(
              child: SingleChildScrollView(
                scrollDirection: Axis.vertical,
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: FadeIn(
                    child: Column(
                      children: [
                        Theme(
                          data: Theme.of(context).copyWith(
                            dividerColor: Colors.grey.withOpacity(0.4),
                            dividerTheme: DividerThemeData(
                              color: Colors.grey.withOpacity(0.4),
                            ),
                          ),
                          child: DataTable(
                            dividerThickness: 0.5,
                            columns: [
                              DataColumn(label: Text('#', style: titleStyle)),
                              DataColumn(
                                  label: Text('Movie', style: titleStyle)),
                              DataColumn(
                                  label:
                                      Text('Release Date', style: titleStyle)),
                              DataColumn(
                                  label: Text('Actor', style: titleStyle)),
                              DataColumn(
                                  label: Text('Actress', style: titleStyle)),
                              DataColumn(
                                  label: Text('Popularity', style: titleStyle)),
                              DataColumn(
                                  label: Text('Language', style: titleStyle)),
                              ...allCrewRoles.map((role) => DataColumn(
                                  label: Text(role, style: titleStyle))),
                            ],
                            rows: widget.movies
                                .asMap()
                                .entries
                                .map(
                                  (entry) => DataRow(
                                    cells: [
                                      DataCell(Text((entry.key + 1).toString(),
                                          style: titleStyle)),
                                      DataCell(Text(
                                          entry.value.movieName.isEmpty
                                              ? "N/A"
                                              : entry.value.movieName,
                                          style: titleStyle)),
                                      DataCell(Text(
                                          entry.value.releaseDate.isEmpty
                                              ? "N/A"
                                              : entry.value.releaseDate,
                                          style: titleStyle)),
                                      DataCell(Text(
                                          getCastDetails(
                                                      entry.value.cast['actor'])
                                                  .trim()
                                                  .isEmpty
                                              ? "N/A"
                                              : getCastDetails(
                                                  entry.value.cast['actor'],
                                                ),
                                          style: titleStyle)),
                                      DataCell(Text(
                                          getCastDetails(entry
                                                      .value.cast['actress'])
                                                  .trim()
                                                  .isEmpty
                                              ? "N/A"
                                              : getCastDetails(
                                                  entry.value.cast['actress']),
                                          style: titleStyle)),
                                      DataCell(Text(
                                          entry.value.popularity
                                                  .toString()
                                                  .isEmpty
                                              ? "N/A"
                                              : entry.value.popularity
                                                  .toString(),
                                          style: titleStyle)),
                                      DataCell(Text(
                                          entry.value.language.isEmpty
                                              ? "N/A"
                                              : getLanguageName(
                                                  entry.value.language),
                                          style: titleStyle)),
                                      ...allCrewRoles.map((role) => DataCell(
                                          Text(
                                              getCrewDetails(entry.value.crew,
                                                          role)
                                                      .trim()
                                                      .isEmpty
                                                  ? "N/A"
                                                  : getCrewDetails(
                                                      entry.value.crew, role),
                                              style: titleStyle))),
                                    ],
                                  ),
                                )
                                .toList(),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget detailChip(String detail) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      decoration: BoxDecoration(
          border: Border.all(color: Colors.white),
          borderRadius: BorderRadius.circular(20)),
      child: SingleChildScrollView(
        child: Text(
          detail,
          style: GoogleFonts.lato(
            fontSize: 16,
            color: Colors.grey.shade200,
          ),
        ),
      ),
    );
  }
}
