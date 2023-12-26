import 'dart:io';
import 'dart:typed_data';
import 'dart:html' as html;
import 'package:animate_do/animate_do.dart';
import 'package:csv/csv.dart';
import 'package:filmfolio/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_fonts/google_fonts.dart';
// import 'package:html/dom.dart';
import 'package:html/dom.dart' as dom;
import 'package:html/parser.dart';
import 'package:http/http.dart' as http;
import 'package:nb_utils/nb_utils.dart';

class WikiTable extends StatefulWidget {
  String url;
  WikiTable({Key? key, required this.url}) : super(key: key);

  @override
  _WikiTableState createState() => _WikiTableState();
}

class _WikiTableState extends State<WikiTable> {
  bool isLoading = true;
  List<FilmDetails> filmDetailsList = [];
  List<String> allKeys = [];
  String? actorName;
  String? filmCount;
  bool isError = false;
  final ScrollController _scrollController = ScrollController();

  setLoader(bool val) {
    if (mounted) {
      setState(() {
        isLoading = val;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    init();
  }

  reset() {
    actorName = null;
    filmCount = null;
    filmDetailsList = [];
    allKeys = [];
    if (mounted) {
      setState(() {});
    }
  }

  init() async {
    reset();

    try {
      final resp = await http.Client().get(Uri.parse(widget.url), headers: {
        "Access-Control-Allow-Origin": "*",
        "Access-Control-Allow-Headers":
            "Origin,Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token,locale",
        "Access-Control-Allow-Methods": "GET,PUT,PATCH,POST,DELETE"
      });
      const baseUrl = "https://en.wikipedia.org";

      if (resp.statusCode == 200) {
        var document = parse(resp.body);
        var titleElement = document.querySelector('title');
        var pageTitle = titleElement?.text ?? '';
        actorName = pageTitle.split(' filmography')[0];
        if (mounted) {
          setState(() {});
        }
        var s = document.getElementById('Filmography');
        s ??= document.getElementById('Film');

        dom.Element? rows;

        if (s != null) {
          var t = s.parent!;
          while (true) {
            t = t.nextElementSibling!;
            if (t.className.contains('wikitable') &&
                t.className.contains('sortable') &&
                t.className.contains('plainrowheaders')) {
              break;
            }
          }

          rows = t.getElementsByTagName('tbody')[0];
        } else {
          var ts = document.getElementsByTagName('table');
          for (var t in ts) {
            if (t.className.contains('wikitable') &&
                t.className.contains('sortable') &&
                t.className.contains('plainrowheaders')) {
              rows = t.getElementsByTagName('tbody')[0];
              break;
            }
          }
        }

        // Film Count
        filmCount = (rows!.children.length - 1).toString();
        if (mounted) {
          setState(() {});
        }

        // print('Film Count: $filmCount');

        for (var film in rows.children) {
          if (rows.children[0] == film) continue;

          var filmContents = film.getElementsByTagName('i');
          if (filmContents.isEmpty) continue;
          var filmContent = filmContents[0];

          // Film Link
          var filmLinkContent = filmContent.getElementsByTagName('a');
          var filmLink = "";
          if (filmLinkContent.isNotEmpty) {
            filmLink =
                "$baseUrl${filmLinkContent[0].attributes['href'] ?? ''}".trim();
          }

          var filmName = "";
          if (filmLink.isNotEmpty) {
            filmName = filmContent.children[0].text.trim();
          } else {
            filmName = filmContent.text;
          }
          print('$filmName - $filmLink');

          if (filmLink.isNotEmpty) {
            try {
              await getFilmDetails(filmName, filmLink);
            } catch (e) {
              filmDetailsList.add(FilmDetails(title: filmName, details: {}));
            }
          } else {
            filmDetailsList.add(FilmDetails(title: filmName, details: {}));
          }
        }
      } else {
        isError = true;
        if (mounted) {
          setState(() {});
        }
      }
    } catch (e) {
      isError = true;
      if (mounted) {
        setState(() {});
      }
    }
  }

  void scrollDown() {
    if (_scrollController.hasClients &&
        _scrollController.position.pixels <
            _scrollController.position.maxScrollExtent) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    }
  }

  void exportToCsv() {
    if (filmDetailsList.isEmpty) {
      toast("Data not available");
    } else {
      try {
        List<List<dynamic>> rows = [];

        rows.add(['Sr No.', 'Movie', ...allKeys]);

        for (int i = 0; i < filmDetailsList.length; i++) {
          FilmDetails film = filmDetailsList[i];
          List<dynamic> row = [i + 1, film.title];

          for (var key in allKeys) {
            row.add(film.details[key] ?? 'N/A');
          }

          rows.add(row);
        }

        String csv = const ListToCsvConverter().convert(rows);

        final blob = html.Blob([Uint8List.fromList(csv.codeUnits)]);
        final url = html.Url.createObjectUrlFromBlob(blob);
        final anchor = html.AnchorElement(href: url)
          ..target = 'web-download'
          ..download = '${(actorName ?? "Movies")}.csv';
        anchor.click();
        html.Url.revokeObjectUrl(url);
      } catch (e) {
        toast("Please wait for the data to load");
      }
    }
  }

  String getText(dom.Node? e, {String delimeter = " "}) {
    if (e == null) return '';
    if (e is dom.Element &&
        (e.localName?.contains(RegExp(r'(style|sup|sub)')) ?? false)) return '';
    if (e.nodes.isEmpty) return e.text?.trim() ?? '';

    var val = "";
    for (var child in e.nodes) {
      var x = getText(child, delimeter: delimeter);
      val += x;
      if (x.isNotEmpty && e.nodes[e.nodes.length - 1] != child) {
        val += delimeter;
      }
    }

    return val;
  }

  Future<void> getFilmDetails(String name, String url) async {
    if (url == 'https://en.wikipedia.org/wiki/Ente_Katha') {
      print('test');
    }
    final resp = await http.Client().get(Uri.parse(url));
    Map<String, String> filmDetails = {};

    if (resp.statusCode == 200) {
      var document = parse(resp.body);
      var table = document.getElementsByClassName('infobox')[0];
      var rows = table.children[0];

      for (var row in rows.children) {
        if (row.children.length != 2) continue;

        // This is the column name
        var col = row.children[0].text.trim();

        var delimeter = " ";

        if (col
            .toLowerCase()
            .contains(RegExp(r'(by|company|companies|starring)'))) {
          delimeter = ", ";
        }

        // Value of it
        var val = getText(row.children[1], delimeter: delimeter);
        // print("$col: $val");
        filmDetails.addAll({col: val});
      }
      filmDetailsList.add(FilmDetails(title: name, details: filmDetails));

      for (var film in filmDetailsList) {
        for (var key in film.details.keys) {
          if (!allKeys.contains(key)) {
            allKeys.add(key);
          }
        }
      }
      scrollDown();
      if (mounted) {
        setState(() {});
      }
    } else {}
  }

  @override
  void dispose() {
    super.dispose();
    _scrollController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    TextStyle titleStyle = GoogleFonts.lato(fontSize: 17, color: Colors.white);

    return Scaffold(
      backgroundColor: Colors.black,
      body:
          // actorName == null
          //     ? SpinKitChasingDots(
          //         color: Colors.white,
          //       )
          //     :
          Container(
        height: height(context),
        margin: EdgeInsets.only(top: 30, bottom: 30, right: 30),
        decoration: BoxDecoration(
            color: Colors.grey.withOpacity(0.2),
            borderRadius: BorderRadius.circular(20)),
        child: Padding(
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
                          actorName ?? "N/A",
                          style: GoogleFonts.lato(
                              fontSize: 25,
                              color: Colors.white,
                              fontWeight: FontWeight.bold),
                        ),
                        5.height,
                        Text(
                          "Total films: ${filmCount ?? "N/A"}",
                          style: GoogleFonts.lato(
                              fontSize: 18,
                              color: Colors.grey,
                              fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                  filmDetailsList.isNotEmpty && !isError
                      ? InkWell(
                          borderRadius: BorderRadius.circular(10),
                          onTap: () => exportToCsv(),
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
                        )
                      : Container(),
                ],
              ),
              20.height,
              Expanded(
                child: isError
                    ? FadeIn(
                        child: Center(
                          child: Text(
                            "No Movies found for ${actorName ?? "N/A"}\nTry Movie DB 🎬",
                            textAlign: TextAlign.center,
                            style: GoogleFonts.lato(
                                fontSize: 17, color: Colors.white),
                          ),
                        ),
                      )
                    : RawScrollbar(
                        controller: _scrollController,
                        radius: Radius.circular(20),
                        child: SingleChildScrollView(
                          controller: _scrollController,
                          scrollDirection: Axis.vertical,
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: FadeIn(
                              child: Column(
                                children: [
                                  Theme(
                                    data: Theme.of(context).copyWith(
                                      dividerColor:
                                          Colors.grey.withOpacity(0.4),
                                      dividerTheme: DividerThemeData(
                                        color: Colors.grey.withOpacity(0.4),
                                      ),
                                    ),
                                    child: DataTable(
                                      dividerThickness: 0.5,
                                      columns: [
                                        DataColumn(
                                            label: Text(
                                          'Sr No.',
                                          style: titleStyle,
                                        )),
                                        DataColumn(
                                            label: Text(
                                          'Movie',
                                          style: titleStyle,
                                        )),
                                        for (var key in allKeys)
                                          DataColumn(
                                              label: Text(
                                            key,
                                            style: titleStyle,
                                          )),
                                      ],
                                      rows: filmDetailsList
                                          .asMap()
                                          .entries
                                          .map((entry) {
                                        int index = entry.key;
                                        FilmDetails film = entry.value;

                                        List<DataCell> cells = [
                                          DataCell(Text(
                                            '${index + 1}',
                                            style: titleStyle,
                                          )),
                                          DataCell(Text(
                                            film.title,
                                            style: titleStyle,
                                          )),
                                        ];

                                        for (var key in allKeys) {
                                          String value =
                                              film.details[key] ?? '';
                                          cells.add(DataCell(Text(
                                            value.isEmpty ? "N/A" : value,
                                            style: titleStyle,
                                          )));
                                        }

                                        return DataRow(cells: cells);
                                      }).toList(),
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
        ),
      ),
    );
  }
}

class FilmDetails {
  String title;
  Map<String, String> details;

  FilmDetails({
    required this.title,
    required this.details,
  });
}
