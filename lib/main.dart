// Copyright 2018 The Flutter team. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:convert';
import 'dart:async';

import 'package:http/http.dart' as http;
import 'package:csv/csv.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'data.dart';
import 'views.dart';
import 'blurry.dart';
import 'standings_tab.dart';

part 'main.g.dart';

void main() async {
  runApp(const MaterialApp(home: MyApp(), debugShowCheckedModeBanner: false));
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final ValueNotifier<int> _reloadStandingsNotifier = ValueNotifier<int>(0);
  Timer? _resetAutofillTimer;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _resetAutofillTimer?.cancel();
    _tabController.dispose();
    _reloadStandingsNotifier.dispose();
    super.dispose();
  }

  loadInitialData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    // One-time migration for 2026: clear old prefs exactly once before first
    // 2026 fetch, so reloading during password setup does not clear again.
    final hasFetched2026Data = prefs.getBool("fetched2026Data") ?? false;
    final hasRun2026PrefReset = prefs.getBool("ran2026PrefReset") ?? false;
    if (!hasFetched2026Data && !hasRun2026PrefReset) {
      await prefs.clear();
      await prefs.setBool("ran2026PrefReset", true);
    }

    if (Data.clearPrefsAtStart) {
      await prefs.clear();
      Data.clearPrefsAtStart = false;
    }
    Data.submittedPicks = prefs.getBool("submittedPicks") ?? false;
    if (Data.submittedPicks) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            duration: Duration(seconds: 5),
            content: Text("You already submitted your entry! Good luck!"),
          ),
        );
      }
    }

    //prefs.setBool("stillNeedPassword", true);

    if (prefs.getBool("stillNeedPassword") ?? true) {
      // don't load any data: the user still needs to enter their initial password
      Data.notReadyYet = true;
      Data.needPassword = true;
      setState(() {});
      return;
    } else {
      Data.needPassword = false;
      var regionWestJson = prefs.getString('regionWest');
      if (regionWestJson != null) {
        Data.regionWest = Region.fromJson(
          jsonDecode(prefs.getString('regionWest')!),
        );
        Data.regionEast = Region.fromJson(
          jsonDecode(prefs.getString('regionEast')!),
        );
        Data.regionMidWest = Region.fromJson(
          jsonDecode(prefs.getString('regionMidwest')!),
        );
        Data.regionSouth = Region.fromJson(
          jsonDecode(prefs.getString('regionSouth')!),
        );
        Data.finalPicks = FinalPicks.fromJson(
          jsonDecode(prefs.getString('finalPicks')!),
        );
        Data.loadBracketLayoutFromPrefs(prefs);
        Data.notReadyYet = false;
        Data.updateWhetherWeHaveAllPicks();
        setState(() {});
        return;
      }
    }
    final response = await http.get(Uri.parse(Data.csvUrl));

    // - HAVE PRIVACY POLICY FOR DSGVO

    var initialdatacsv =
        response.body; //rootBundle.loadString('assets/initialdata.csv');
    if (Data.appstoretest) {
      initialdatacsv = await rootBundle.loadString('assets/initialdata.csv');
    }
    var list = const CsvToListConverter(eol: "\n").convert(initialdatacsv);
    if (list.isEmpty) {
      Data.notReadyYet = true;
    } else {
      Data.notReadyYet = false;
      Data.applyBracketLayoutFromCsv(list);
      Data.regionWest = region("West", list);
      Data.regionEast = region("East", list);
      Data.regionMidWest = region("MidWest", list);
      Data.regionSouth = region("South", list);
      // Mark that we've successfully fetched the 2026 data so we don't reset again.
      await prefs.setBool("fetched2026Data", true);
    }
    setState(() {});
  }

  final _textStyle = const TextStyle(fontWeight: FontWeight.bold, fontSize: 20);
  @override
  Widget build(BuildContext context) {
    if (Data.needPassword) {
      return InitialPasswordScreen(loadInitialData: loadInitialData);
    } else if (Data.notReadyYet) {
      if (Data.regionEast.teams.isEmpty) {
        loadInitialData();
      }
      return Scaffold(
        body: Center(
          child: SizedBox(
            width: 500,
            height: 500,
            child: Container(
              padding: const EdgeInsets.all(15.0),
              child: Column(
                children: [
                  Text("Not ready yet!", style: _textStyle),
                  const SizedBox(height: 10),
                  const Text(
                    "We're going to need to wait until the teams are picked.",
                  ),
                ],
              ),
            ),
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            Data.csvUrl = 'https://smoothtrack.app/tropy/initialdata.csv';
            loadInitialData();
          },
          backgroundColor: Colors.blue,
          child: const Text("Reload"),
        ),
      );
    } else {
      final leftTopRegion = Data.regionByName(Data.leftTopRegionName);
      final leftBottomRegion = Data.regionByName(Data.leftBottomRegionName);
      final rightTopRegion = Data.regionByName(Data.rightTopRegionName);
      final rightBottomRegion = Data.regionByName(Data.rightBottomRegionName);
      return Scaffold(
        appBar: AppBar(
          toolbarHeight: 0,
          bottom: TabBar(
            controller: _tabController,
            labelColor: Colors.blue,
            unselectedLabelColor: Colors.grey,
            tabs: const [Tab(text: "Picks"), Tab(text: "Standings")],
          ),
        ),
        body: TabBarView(
          controller: _tabController,
          physics: const NeverScrollableScrollPhysics(),
          children: [
            InteractiveViewer(
              constrained: false,
              boundaryMargin: const EdgeInsets.all(20.0),
              minScale: 0.01,
              maxScale: 1,
              child: SizedBox(
                width: 3768,
                height: 1600,
                child: Container(
                  margin: const EdgeInsets.all(15.0),
                  padding: const EdgeInsets.all(3.0),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.transparent),
                  ),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 250,
                        child: TeamColumn(
                          regionTop: leftTopRegion,
                          regionBottom: leftBottomRegion,
                          refresh: () => {setState(() {})},
                        ),
                      ),
                      SizedBox(
                        width: 40,
                        child: CustomPaint(
                          size: const Size(40, 1600),
                          painter: TwoToOnePainter(1),
                        ),
                      ),
                      SizedBox(
                        width: 250,
                        child: RoundColumn(
                          regionTop: leftTopRegion,
                          regionBottom: leftBottomRegion,
                          refresh: () => {setState(() {})},
                          round: 1,
                        ),
                      ),
                      SizedBox(
                        width: 40,
                        child: CustomPaint(
                          size: const Size(40, 1600),
                          painter: TwoToOnePainter(2),
                        ),
                      ),
                      SizedBox(
                        width: 250,
                        child: RoundColumn(
                          regionTop: leftTopRegion,
                          regionBottom: leftBottomRegion,
                          refresh: () => {setState(() {})},
                          round: 2,
                        ),
                      ),
                      SizedBox(
                        width: 40,
                        child: CustomPaint(
                          size: const Size(40, 1600),
                          painter: TwoToOnePainter(3),
                        ),
                      ),
                      SizedBox(
                        width: 250,
                        child: RoundColumn(
                          regionTop: leftTopRegion,
                          regionBottom: leftBottomRegion,
                          refresh: () => {setState(() {})},
                          round: 3,
                        ),
                      ),
                      SizedBox(
                        width: 40,
                        child: CustomPaint(
                          size: const Size(40, 1600),
                          painter: TwoToOnePainter(4),
                        ),
                      ),
                      SizedBox(
                        width: 250,
                        child: RoundColumn(
                          regionTop: leftTopRegion,
                          regionBottom: leftBottomRegion,
                          refresh: () => {setState(() {})},
                          round: 4,
                        ),
                      ),
                      SizedBox(
                        width: 40,
                        child: CustomPaint(
                          size: const Size(40, 1600),
                          painter: TwoToOnePainter(5),
                        ),
                      ),
                      SizedBox(
                        width: 250,
                        child: GestureDetector(
                          // When the child is tapped, show a snackbar.
                          onTap: () {
                            setState(() {
                              if (Data.submittedPicks) {
                                return;
                              }
                              Data.finalPicks.champ = Data.finalPicks.teamLeft;
                              Data.updateWhetherWeHaveAllPicks();
                            });
                          },
                          // The custom button
                          child: TeamBoxItem(
                            teamName: Data.finalPicks.teamLeft?.name ?? "",
                            teamImageName:
                                Data.finalPicks.teamLeft?.imageName ?? "",
                            seed: Data.finalPicks.teamLeft?.seed ?? -1,
                          ),
                        ),
                      ),
                      SizedBox(
                        width: 40,
                        child: CustomPaint(
                          size: const Size(40, 1600),
                          painter: TwoToOnePainter(6, backwards: false),
                        ),
                      ),
                      SizedBox(
                        width: 250,
                        child: TeamBoxItem(
                          teamName: Data.finalPicks.champ?.name ?? "",
                          teamImageName: Data.finalPicks.champ?.imageName ?? "",
                          seed: Data.finalPicks.champ?.seed ?? -1,
                        ),
                      ),
                      SizedBox(
                        width: 40,
                        child: CustomPaint(
                          size: const Size(40, 1600),
                          painter: TwoToOnePainter(6, backwards: true),
                        ),
                      ),
                      SizedBox(
                        width: 250,
                        child: GestureDetector(
                          // When the child is tapped, show a snackbar.
                          onTap: () {
                            setState(() {
                              if (Data.submittedPicks) {
                                return;
                              }
                              Data.finalPicks.champ = Data.finalPicks.teamRight;
                              Data.updateWhetherWeHaveAllPicks();
                            });
                          },
                          // The custom button
                          child: TeamBoxItem(
                            teamName: Data.finalPicks.teamRight?.name ?? "",
                            teamImageName:
                                Data.finalPicks.teamRight?.imageName ?? "",
                            seed: Data.finalPicks.teamRight?.seed ?? -1,
                          ),
                        ),
                      ),
                      SizedBox(
                        width: 40,
                        child: CustomPaint(
                          size: const Size(40, 1600),
                          painter: TwoToOnePainter(5, backwards: true),
                        ),
                      ),
                      SizedBox(
                        width: 250,
                        child: RoundColumn(
                          regionTop: rightTopRegion,
                          regionBottom: rightBottomRegion,
                          refresh: () => {setState(() {})},
                          round: 4,
                        ),
                      ),
                      SizedBox(
                        width: 40,
                        child: CustomPaint(
                          size: const Size(40, 1600),
                          painter: TwoToOnePainter(4, backwards: true),
                        ),
                      ),
                      SizedBox(
                        width: 250,
                        child: RoundColumn(
                          regionTop: rightTopRegion,
                          regionBottom: rightBottomRegion,
                          refresh: () => {setState(() {})},
                          round: 3,
                        ),
                      ),
                      SizedBox(
                        width: 40,
                        child: CustomPaint(
                          size: const Size(40, 1600),
                          painter: TwoToOnePainter(3, backwards: true),
                        ),
                      ),
                      SizedBox(
                        width: 250,
                        child: RoundColumn(
                          regionTop: rightTopRegion,
                          regionBottom: rightBottomRegion,
                          refresh: () => {setState(() {})},
                          round: 2,
                        ),
                      ),
                      SizedBox(
                        width: 40,
                        child: CustomPaint(
                          size: const Size(40, 1600),
                          painter: TwoToOnePainter(2, backwards: true),
                        ),
                      ),
                      SizedBox(
                        width: 250,
                        child: RoundColumn(
                          regionTop: rightTopRegion,
                          regionBottom: rightBottomRegion,
                          refresh: () => {setState(() {})},
                          round: 1,
                        ),
                      ),
                      SizedBox(
                        width: 40,
                        child: CustomPaint(
                          size: const Size(40, 1600),
                          painter: TwoToOnePainter(1, backwards: true),
                        ),
                      ),
                      SizedBox(
                        width: 250,
                        child: TeamColumn(
                          regionTop: rightTopRegion,
                          regionBottom: rightBottomRegion,
                          refresh: () => {setState(() {})},
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            StandingsTab(reloadNotifier: _reloadStandingsNotifier),
          ],
        ),
        floatingActionButton:
            _tabController.index == 0
                ? _getFloatingButton()
                : _getStandingsFloatingButton(),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      );
    }
  }

  Widget? _getStandingsFloatingButton() {
    return FloatingActionButton.extended(
      heroTag: "reloadStandings",
      onPressed: () {
        _reloadStandingsNotifier.value++;
      },
      backgroundColor: Colors.blue,
      label: const Text(
        "Reload Standings",
        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
      ),
      icon: const Icon(Icons.refresh, color: Colors.white),
    );
  }

  Widget? _getFloatingButton() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Listener(
          onPointerDown: (_) {
            _startResetAutofillHold();
          },
          onPointerUp: (_) {
            _cancelResetAutofillHold();
          },
          onPointerCancel: (_) {
            _cancelResetAutofillHold();
          },
          child: FloatingActionButton.extended(
            heroTag: "reset",
            onPressed: () {
              _showResetDialog(context);
            },
            backgroundColor: Colors.red,
            label: const Text("Reset"),
          ),
        ),
        if (!Data.submittedPicks) ...[
          const SizedBox(width: 12),
          FloatingActionButton(
            heroTag: "submit",
            onPressed: () {
              _showDialog(context);
            },
            backgroundColor: Data.haveAllPicks ? Colors.orange : Colors.grey,
            child: const Text("Submit"),
          ),
        ],
      ],
    );
  }

  void _startResetAutofillHold() {
    _resetAutofillTimer?.cancel();
    _resetAutofillTimer = Timer(const Duration(seconds: 5), () async {
      final filled = Data.autofillRandomPicks();
      if (!filled) {
        if (!mounted) {
          return;
        }
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            duration: Duration(seconds: 3),
            content: Text("Bracket data is not loaded yet."),
          ),
        );
        return;
      }

      if (Data.submittedPicks) {
        Data.submittedPicks = false;
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool("submittedPicks", false);
      }

      if (!mounted) {
        return;
      }
      setState(() {});
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          duration: Duration(seconds: 4),
          content: Text("Random picks generated."),
        ),
      );
    });
  }

  void _cancelResetAutofillHold() {
    _resetAutofillTimer?.cancel();
    _resetAutofillTimer = null;
  }

  _createTropyEntry(String postData) async {
    final response = await http.post(
      Uri.parse(
        'https://docs.google.com/forms/u/0/d/e/1FAIpQLSd4HNCqNPtVuCtl52nHXkOWYGJ1PsbfW9_cyEr5TMBg-_iVrA/formResponse',
      ),
      headers: <String, String>{
        'Content-Type': 'application/x-www-form-urlencoded; charset=utf-8',
      },
      body: postData,
    );
    if (response.statusCode >= 200 && response.statusCode <= 299) {
      Data.submittedPicks = true;
      SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.setBool("submittedPicks", true);

      setState(() {});
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            duration: Duration(seconds: 5),
            content: Text("Successfully submitted! Good luck!"),
          ),
        );
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            duration: Duration(seconds: 5),
            content: Text(
              "Error: uh-oh, couldn't submit! Check your internet connection and try later...",
            ),
          ),
        );
      }
    }
  }

  _voidCallback(BuildContext context, bool ready) {
    Navigator.of(context).pop();
    if (ready) {
      /*
entry.129362557: FirstName
entry.1430700886: LastName
entry.547710129: City
entry.976623211: Postal
entry.337915264: Country
entry.1737913929: Email
entry.650515796: Picks      */
      // ignore: prefer_interpolation_to_compose_strings
      var postData =
          "entry.129362557=" +
          Uri.encodeFull(Data.submission.firstName()) +
          "&entry.1430700886=" +
          Uri.encodeFull(Data.submission.lastName()) +
          "&entry.547710129=" +
          Uri.encodeFull(Data.submission.cityState) +
          "&entry.976623211=" +
          Uri.encodeFull(Data.submission.postal) +
          "&entry.337915264=" +
          Uri.encodeFull(Data.submission.country) +
          "&entry.1737913929=" +
          Uri.encodeFull(Data.submission.email) +
          "&entry.650515796=" +
          Uri.encodeFull(Data.picks());
      _createTropyEntry(postData);
    }
  }

  void _showResetDialog(BuildContext context) {
    final hasSubmitted = Data.submittedPicks;
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Reset picks?"),
          content: Text(
            hasSubmitted
                ? "You've already submitted your entry. Do you want to reset so that you can submit someone else's entry?"
                : "Are you sure? This cannot be undone.",
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              onPressed: () async {
                Navigator.of(context).pop();
                Data.resetPicks();
                if (hasSubmitted) {
                  Data.submittedPicks = false;
                  SharedPreferences prefs =
                      await SharedPreferences.getInstance();
                  await prefs.setBool("submittedPicks", false);
                }
                if (!mounted) {
                  return;
                }
                setState(() {});
              },
              child: const Text("Reset everything"),
            ),
          ],
        );
      },
    );
  }

  _showDialog(BuildContext context) {
    bool ready = Data.haveAllPicks;
    continueCallBack() => {_voidCallback(context, ready)};
    BlurryDialog alert = BlurryDialog(
      ready ? "Ready to submit?" : "Can't submit yet",
      ready
          ? "Are you all ready to make your picks?"
          : "You can't submit until you've made all your picks!",
      continueCallBack,
      !ready,
      true,
    );

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }
}

//------------- JSON structures
@JsonSerializable()
class Team {
  Team({
    required this.name,
    required this.seed,
    required this.region,
    required this.imageName,
  });

  final String name;
  final int seed;
  final String region;
  final String imageName;

  /// Connect the generated [_$TeamFromJson] function to the `fromJson`
  /// factory.
  factory Team.fromJson(Map<String, dynamic> json) => _$TeamFromJson(json);

  /// Connect the generated [_$TeamToJson] function to the `toJson` method.
  Map<String, dynamic> toJson() => _$TeamToJson(this);
}

@JsonSerializable()
class Region {
  Region({required this.teams, required this.name, required this.picks});
  final List<Team> teams;
  final String name;
  List<List<Team?>> picks;

  /// Connect the generated [_$RegionFromJson] function to the `fromJson`
  /// factory.
  factory Region.fromJson(Map<String, dynamic> json) => _$RegionFromJson(json);

  /// Connect the generated [_$RegionToJson] function to the `toJson` method.
  Map<String, dynamic> toJson() => _$RegionToJson(this);

  teamBySeed(s) {
    try {
      return teams.firstWhere((team) => team.seed == s);
    } catch (e) {
      print("Failed to find seed $s in region $name");
      print("Available seeds in $name: ${teams.map((t) => t.seed).toList()}");
      rethrow;
    }
  }

  firstRoundPick(s) {
    int index = Data.pairings.indexWhere(
      (element) => element.a == s || element.b == s,
    );
    removePicksOfTeamAfter(0, picks[0][index]);
    picks[0][index] = teamBySeed(s);
    Data.updateWhetherWeHaveAllPicks();
  }

  nullIfTeamIs(Team? teamToCheck, Team? teamToCompareWith) {
    if (teamToCheck?.name == teamToCompareWith?.name) {
      return null;
    } else {
      return teamToCheck;
    }
  }

  removePicksOfTeamAfter(round, Team? team) {
    if (team == null) {
      return;
    }
    Data.finalPicks.champ = nullIfTeamIs(Data.finalPicks.champ, team);
    Data.finalPicks.teamLeft = nullIfTeamIs(Data.finalPicks.teamLeft, team);
    Data.finalPicks.teamRight = nullIfTeamIs(Data.finalPicks.teamRight, team);
    int i = round + 1;
    while (i < 4) {
      int index = picks[i].indexWhere((element) => element?.name == team.name);
      if (index >= 0) {
        picks[i][index] = null;
      } else {
        break;
      }
      i++;
    }
  }
  // Final Four side (left/right) comes from Data's current bracket layout.

  pick(round, team) {
    if (round == 4) {
      if (Data.isLeftSideRegion(name)) {
        removePicksOfTeamAfter(round, Data.finalPicks.teamLeft);
        Data.finalPicks.teamLeft = team;
      } else {
        removePicksOfTeamAfter(round, Data.finalPicks.teamRight);
        Data.finalPicks.teamRight = team;
      }
    } else {
      int index = picks[round - 1].indexWhere((element) => element == team);
      removePicksOfTeamAfter(round, picks[round][index ~/ 2]);
      picks[round][index ~/ 2] = team!;
    }
    Data.updateWhetherWeHaveAllPicks();
  }

  bool haveAllPicks() {
    var result = picks.every(
      (element) => element.every((pick) => pick != null),
    );
    return result;
  }

  picksString(int round) {
    return picks[round]
        .map((e) => e!.region.substring(0, 1) + e.seed.toString())
        .join(",");
  }
}

@JsonSerializable()
class FinalPicks {
  Team? teamLeft;
  Team? champ;
  Team? teamRight;

  FinalPicks();

  /// Connect the generated [_$FinalPicksFromJson] function to the `fromJson`
  /// factory.
  factory FinalPicks.fromJson(Map<String, dynamic> json) =>
      _$FinalPicksFromJson(json);

  /// Connect the generated [_$FinalPicksToJson] function to the `toJson` method.
  Map<String, dynamic> toJson() => _$FinalPicksToJson(this);
}

class Pair<T1, T2> {
  final T1 a;
  final T2 b;

  Pair(this.a, this.b);
}
