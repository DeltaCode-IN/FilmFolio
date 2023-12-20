import 'package:filmfolio/api.dart';
import 'package:filmfolio/constants.dart';
import 'package:filmfolio/home/movie_table.dart';
import 'package:filmfolio/models/actor_model.dart';
import 'package:filmfolio/models/movie_details.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import 'package:nb_utils/nb_utils.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  ActorModel? actorList;
  Actor? selectedActor;
  TextEditingController actorSearchCont = TextEditingController();
  bool isSearching = false;

  bool isDetailsLoading = false;

  setDetailsLoader(bool val) {
    setState(() {
      isDetailsLoading = val;
    });
  }

  setSearchLoader(bool val) {
    setState(() {
      isSearching = val;
    });
  }

  void getActorList(String name) async {
    if (!isSearching) {
      setSearchLoader(true);
    }
    actorList = await searchActor(name);
    setSearchLoader(false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: selectedActor == null
          ? searchComponent()
          : Row(
              children: [
                Expanded(child: searchComponent()),
                Expanded(
                    child: Container(
                  height: height(context),
                  margin: EdgeInsets.only(top: 30, bottom: 30, right: 30),
                  decoration: BoxDecoration(
                      color: Colors.grey.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20)),
                  child: FutureBuilder(
                    future: getMoviesWithCast(selectedActor?.id ?? 0),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Center(
                          child: SpinKitChasingDots(color: Colors.white),
                        );
                      } else if (snapshot.hasError) {
                        return Text(
                          'Error: ${snapshot.error}',
                          style: TextStyle(color: Colors.white),
                        );
                      } else {
                        final List<Movie> movies = snapshot.data as List<Movie>;
                        return movies.isEmpty
                            ? Center(
                                child: Text(
                                  "No Movies found for ${selectedActor?.name ?? "N/A"}\nMaybe they're starring in the sequel 'The Invisible Actor'? 🎬🤔",
                                  textAlign: TextAlign.center,
                                  style: GoogleFonts.lato(
                                      fontSize: 17, color: Colors.white),
                                ),
                              )
                            : MovieTable(
                                movies: movies,
                                selectedActor: selectedActor,
                              );
                      }
                    },
                  ),
                ))
              ],
            ),
    );
  }

  Widget searchComponent() {
    return SizedBox(
      height: height(context),
      width: width(context),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Lottie.asset(
            'assets/lottie/search.json',
            height: height(context) * 0.45,
            width: height(context) * 0.45,
            fit: BoxFit.cover,
          ),
          20.height,
          Padding(
            padding: selectedActor != null
                ? EdgeInsets.symmetric(horizontal: width(context) * 0.1)
                : EdgeInsets.symmetric(horizontal: width(context) * 0.35),
            child: TextFormField(
              cursorColor: Colors.black,
              style: GoogleFonts.lato(
                  fontSize: 18, fontWeight: FontWeight.bold, letterSpacing: 1),
              controller: actorSearchCont,
              onChanged: (val) {
                getActorList(val);
              },
              decoration: InputDecoration(
                  suffixIcon: actorSearchCont.text.isEmpty
                      ? null
                      : Padding(
                          padding: const EdgeInsets.only(right: 15.0),
                          child: InkWell(
                            onTap: () => setState(() {
                              selectedActor = null;
                              actorSearchCont.clear();
                              actorList = null;
                            }),
                            child: Icon(
                              Icons.close,
                              color: Colors.black,
                            ),
                          ),
                        ),
                  fillColor: Colors.white,
                  filled: true,
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 15, vertical: 20),
                  hintText: 'Search for actor...',
                  hintStyle: GoogleFonts.lato(
                      color: Colors.grey, fontWeight: FontWeight.normal),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30))),
              onFieldSubmitted: (_) {
                hideKeyboard(context);
              },
            ),
          ),
          20.height,
          isSearching
              ? SpinKitChasingDots(
                  color: Colors.white,
                )
              : Container(),
          actorList != null && actorSearchCont.text.isNotEmpty && !isSearching
              ? Container(
                  height: (actorList?.results?.isEmpty ?? false)
                      ? height(context) * 0.2
                      : height(context) * 0.4,
                  width: width(context) * 0.4,
                  padding: EdgeInsets.only(left: 15, top: 15),
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      color: Colors.white),
                  child: (actorList != null &&
                          (actorList?.results?.isEmpty ?? false))
                      ? Center(
                          child: Text(
                            "No Actor found in the name of ${actorSearchCont.text}",
                            style: GoogleFonts.lato(
                                fontSize: 17, color: Colors.black),
                          ),
                        )
                      : ListView.builder(
                          shrinkWrap: true,
                          itemCount: actorList?.results?.length ?? 0,
                          itemBuilder: (_, index) {
                            return InkWell(
                              splashColor: Colors.transparent,
                              highlightColor: Colors.transparent,
                              onTap: () {
                                selectedActor = actorList?.results?[index];
                                setState(() {});
                              },
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    actorList?.results?[index].name ?? "N/A",
                                    style: GoogleFonts.lato(fontSize: 18),
                                  ),
                                  Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Text(
                                        "Gender: ${getGender(actorList?.results?[index].gender ?? 0)}",
                                        style: GoogleFonts.lato(
                                            fontSize: 17, color: Colors.grey),
                                      ),
                                      Container(
                                        margin:
                                            EdgeInsets.symmetric(horizontal: 5),
                                        height: height(context) * 0.016,
                                        width: 2,
                                        color: Colors.grey.shade300,
                                      ),
                                      Text(
                                        "Language: ${(actorList?.results?[index].knownFor?.isEmpty ?? false) ? "N/A" : getLanguageName(actorList?.results?[index].knownFor?[0].originalLanguage ?? "N/A")}",
                                        style: GoogleFonts.lato(
                                            fontSize: 17, color: Colors.grey),
                                      ),
                                    ],
                                  ),
                                  Divider(),
                                ],
                              ),
                            );
                          }),
                )
              : Container()
        ],
      ),
    );
  }
}
