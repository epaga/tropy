// Copyright 2018 The Flutter team. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:http/http.dart' as http;
import 'package:csv/csv.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'data.dart';
import 'blurry.dart';

void main() async {
  runApp(const MaterialApp(home: MyApp()));
}

Region region(String regionName, List<List<dynamic>> list) {
  return Region(
      name: regionName,
      picks: [
        [null, null, null, null, null, null, null, null],
        [null, null, null, null],
        [null, null],
        [null]
      ],
      teams: list
          .where((element) => element[2] == regionName)
          .map((e) =>
              Team(name: e[0], seed: e[1], region: e[2], imageName: e[3]))
          .toList());
}

class Team {
  Team(
      {required this.name,
      required this.seed,
      required this.region,
      required this.imageName});

  final String name;
  final int seed;
  final String region;
  final String imageName;
}

class Region {
  Region({required this.teams, required this.name, required this.picks});
  final List<Team> teams;
  final String name;
  List<List<Team?>> picks;

  teamBySeed(s) {
    return teams.firstWhere((team) => team.seed == s);
  }

  firstRoundPick(s) {
    int index =
        Data.pairings.indexWhere((element) => element.a == s || element.b == s);
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

  pick(round, team) {
    if (round == 4) {
      if (name == Data.regionWest.name || name == Data.regionEast.name) {
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
    var result =
        picks.every((element) => element.every((pick) => pick != null));
    return result;
  }

  picksString(int round) {
    return picks[round]
        .map((e) => e!.region.substring(0, 1) + e!.seed.toString())
        .join(",");
  }
}

class FinalPicks {
  Team? teamLeft;
  Team? champ;
  Team? teamRight;
}

class Pair<T1, T2> {
  final T1 a;
  final T2 b;

  Pair(this.a, this.b);
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  loadInitialData() async {
    var initialdatacsv = await rootBundle.loadString('assets/initialdata.csv');
    var list = CsvToListConverter(eol: "\n").convert(initialdatacsv);
    Data.regionWest = region("West", list);
    Data.regionEast = region("East", list);
    Data.regionMidWest = region("MidWest", list);
    Data.regionSouth = region("South", list);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    if (Data.regionEast.teams.length == 0) {
      loadInitialData();
    }
    return Scaffold(
      body: InteractiveViewer(
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
            decoration: BoxDecoration(border: Border.all(color: Colors.black)),
            child: Row(
              children: [
                SizedBox(
                    width: 250,
                    child: TeamColumn(
                      regionTop: Data.regionWest,
                      regionBottom: Data.regionEast,
                      refresh: () => {setState(() {})},
                    )),
                SizedBox(
                  width: 40,
                  child: CustomPaint(
                    size: Size(40, 1600),
                    painter: TwoToOnePainter(1),
                  ),
                ),
                SizedBox(
                    width: 250,
                    child: RoundColumn(
                        regionTop: Data.regionWest,
                        regionBottom: Data.regionEast,
                        refresh: () => {setState(() {})},
                        round: 1)),
                SizedBox(
                  width: 40,
                  child: CustomPaint(
                    size: Size(40, 1600),
                    painter: TwoToOnePainter(2),
                  ),
                ),
                SizedBox(
                    width: 250,
                    child: RoundColumn(
                        regionTop: Data.regionWest,
                        regionBottom: Data.regionEast,
                        refresh: () => {setState(() {})},
                        round: 2)),
                SizedBox(
                  width: 40,
                  child: CustomPaint(
                    size: Size(40, 1600),
                    painter: TwoToOnePainter(3),
                  ),
                ),
                SizedBox(
                    width: 250,
                    child: RoundColumn(
                        regionTop: Data.regionWest,
                        regionBottom: Data.regionEast,
                        refresh: () => {setState(() {})},
                        round: 3)),
                SizedBox(
                  width: 40,
                  child: CustomPaint(
                    size: Size(40, 1600),
                    painter: TwoToOnePainter(4),
                  ),
                ),
                SizedBox(
                    width: 250,
                    child: RoundColumn(
                        regionTop: Data.regionWest,
                        regionBottom: Data.regionEast,
                        refresh: () => {setState(() {})},
                        round: 4)),
                SizedBox(
                  width: 40,
                  child: CustomPaint(
                    size: Size(40, 1600),
                    painter: TwoToOnePainter(5),
                  ),
                ),
                SizedBox(
                    width: 250,
                    child: GestureDetector(
                        // When the child is tapped, show a snackbar.
                        onTap: () {
                          setState(() {
                            Data.finalPicks.champ = Data.finalPicks.teamLeft;
                            Data.updateWhetherWeHaveAllPicks();
                          });
                        },
                        // The custom button
                        child: TeamBoxItem(
                            teamName: Data.finalPicks.teamLeft?.name ?? "",
                            teamImageName:
                                Data.finalPicks.teamLeft?.imageName ?? "",
                            seed: Data.finalPicks.teamLeft?.seed ?? -1))),
                SizedBox(
                  width: 40,
                  child: CustomPaint(
                    size: Size(40, 1600),
                    painter: TwoToOnePainter(6, backwards: false),
                  ),
                ),
                SizedBox(
                    width: 250,
                    child: TeamBoxItem(
                        teamName: Data.finalPicks.champ?.name ?? "",
                        teamImageName: Data.finalPicks.champ?.imageName ?? "",
                        seed: Data.finalPicks.champ?.seed ?? -1)),
                SizedBox(
                  width: 40,
                  child: CustomPaint(
                    size: Size(40, 1600),
                    painter: TwoToOnePainter(6, backwards: true),
                  ),
                ),
                SizedBox(
                    width: 250,
                    child: GestureDetector(
                        // When the child is tapped, show a snackbar.
                        onTap: () {
                          setState(() {
                            Data.finalPicks.champ = Data.finalPicks.teamRight;
                          });
                        },
                        // The custom button
                        child: TeamBoxItem(
                            teamName: Data.finalPicks.teamRight?.name ?? "",
                            teamImageName:
                                Data.finalPicks.teamRight?.imageName ?? "",
                            seed: Data.finalPicks.teamRight?.seed ?? -1))),
                SizedBox(
                  width: 40,
                  child: CustomPaint(
                    size: Size(40, 1600),
                    painter: TwoToOnePainter(5, backwards: true),
                  ),
                ),
                SizedBox(
                    width: 250,
                    child: RoundColumn(
                        regionTop: Data.regionSouth,
                        regionBottom: Data.regionMidWest,
                        refresh: () => {setState(() {})},
                        round: 4)),
                SizedBox(
                  width: 40,
                  child: CustomPaint(
                    size: Size(40, 1600),
                    painter: TwoToOnePainter(4, backwards: true),
                  ),
                ),
                SizedBox(
                    width: 250,
                    child: RoundColumn(
                        regionTop: Data.regionSouth,
                        regionBottom: Data.regionMidWest,
                        refresh: () => {setState(() {})},
                        round: 3)),
                SizedBox(
                  width: 40,
                  child: CustomPaint(
                    size: Size(40, 1600),
                    painter: TwoToOnePainter(3, backwards: true),
                  ),
                ),
                SizedBox(
                    width: 250,
                    child: RoundColumn(
                        regionTop: Data.regionSouth,
                        regionBottom: Data.regionMidWest,
                        refresh: () => {setState(() {})},
                        round: 2)),
                SizedBox(
                  width: 40,
                  child: CustomPaint(
                    size: Size(40, 1600),
                    painter: TwoToOnePainter(2, backwards: true),
                  ),
                ),
                SizedBox(
                    width: 250,
                    child: RoundColumn(
                        regionTop: Data.regionSouth,
                        regionBottom: Data.regionMidWest,
                        refresh: () => {setState(() {})},
                        round: 1)),
                SizedBox(
                  width: 40,
                  child: CustomPaint(
                    size: Size(40, 1600),
                    painter: TwoToOnePainter(1, backwards: true),
                  ),
                ),
                SizedBox(
                    width: 250,
                    child: TeamColumn(
                      regionTop: Data.regionSouth,
                      regionBottom: Data.regionMidWest,
                      refresh: () => {setState(() {})},
                    )),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showDialog(context);
        },
        backgroundColor: Data.haveAllPicks ? Colors.blue : Colors.grey,
        child: const Text("Submit"),
      ),
    );
  }

  _voidCallback(BuildContext context, bool ready) {
    Navigator.of(context).pop();
    if (ready) {
      /*
      entry.1605530316 // first name
      entry.1938482540 // last name
      entry.580760508 // city/state
      entry.1605013589 // postal
      entry.470103823 // country
      entry.2137142274 // email
      entry.795823503 // picks
      */
      var postData = "entry.1605530316=" +
          Uri.encodeFull(Data.submission.firstName()) +
          "&entry.1938482540=" +
          Uri.encodeFull(Data.submission.lastName()) +
          "&entry.580760508=" +
          Uri.encodeFull(Data.submission.cityState) +
          "&entry.1605013589=" +
          Uri.encodeFull(Data.submission.postal) +
          "&entry.470103823=" +
          Uri.encodeFull(Data.submission.country) +
          "&entry.2137142274=" +
          Uri.encodeFull(Data.submission.email) +
          "&entry.795823503=" +
          Uri.encodeFull(Data.picks());
      Future<http.Response> createAlbum(String title) {
        return http.post(
          Uri.parse(
              'https://docs.google.com/forms/u/0/d/e/googleformid/formResponse'),
          headers: <String, String>{
            'Content-Type': 'application/x-www-form-urlencoded; charset=utf-8',
          },
          body: postData,
        );
      }

      createAlbum("title");
    }
  }

  _showDialog(BuildContext context) {
    bool ready = Data.haveAllPicks;
    VoidCallback continueCallBack = () => {
          _voidCallback(context, ready),
        };
    BlurryDialog alert = BlurryDialog(
        ready ? "Ready to submit?" : "Can't submit yet",
        ready
            ? "Are you all ready to make your picks?"
            : "You can't submit until you've made all your picks!",
        continueCallBack,
        !ready,
        true);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }
}

class TwoToOnePainter extends CustomPainter {
  TwoToOnePainter(this.round, {this.backwards = false});

  final int round;
  final bool backwards;

  @override
  void paint(Canvas canvas, Size size) {
    // Create a Paint object.
    Paint _paint = Paint()
      ..color = Colors.black
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke
      ..strokeJoin = StrokeJoin.round;

    // Set the color of the paint to blue.
    _paint.color = Colors.blue;

    // super embarrassingly duplicated code since i'm running out of time...
    if (round == 1) {
      drawTwoToOne(canvas, _paint, 0, 0, 40, backwards);
      drawTwoToOne(canvas, _paint, 0, 94, 40, backwards);
      drawTwoToOne(canvas, _paint, 0, 94 * 2, 40, backwards);
      drawTwoToOne(canvas, _paint, 0, 94 * 3, 40, backwards);
      drawTwoToOne(canvas, _paint, 0, 94 * 4, 40, backwards);
      drawTwoToOne(canvas, _paint, 0, 94 * 5, 40, backwards);
      drawTwoToOne(canvas, _paint, 0, 94 * 6, 40, backwards);
      drawTwoToOne(canvas, _paint, 0, 94 * 7, 40, backwards);
      drawTwoToOne(canvas, _paint, 0, 94 * 8 + 26, 40, backwards);
      drawTwoToOne(canvas, _paint, 0, 94 * 9 + 26, 40, backwards);
      drawTwoToOne(canvas, _paint, 0, 94 * 10 + 26, 40, backwards);
      drawTwoToOne(canvas, _paint, 0, 94 * 11 + 26, 40, backwards);
      drawTwoToOne(canvas, _paint, 0, 94 * 12 + 26, 40, backwards);
      drawTwoToOne(canvas, _paint, 0, 94 * 13 + 26, 40, backwards);
      drawTwoToOne(canvas, _paint, 0, 94 * 14 + 26, 40, backwards);
      drawTwoToOne(canvas, _paint, 0, 94 * 15 + 26, 40, backwards);
    } else if (round == 2) {
      drawTwoToOne(canvas, _paint, 0, 18, 94, backwards);
      drawTwoToOne(canvas, _paint, 0, 18 + 94 * 2, 94, backwards);
      drawTwoToOne(canvas, _paint, 0, 18 + 94 * 4, 94, backwards);
      drawTwoToOne(canvas, _paint, 0, 18 + 94 * 6, 94, backwards);
      drawTwoToOne(canvas, _paint, 0, 18 + 94 * 8 + 26, 94, backwards);
      drawTwoToOne(canvas, _paint, 0, 18 + 94 * 10 + 26, 94, backwards);
      drawTwoToOne(canvas, _paint, 0, 18 + 94 * 12 + 26, 94, backwards);
      drawTwoToOne(canvas, _paint, 0, 18 + 94 * 14 + 26, 94, backwards);
    } else if (round == 3) {
      drawTwoToOne(canvas, _paint, 0, 65, 188, backwards);
      drawTwoToOne(canvas, _paint, 0, 65 + 94 * 4, 188, backwards);
      drawTwoToOne(canvas, _paint, 0, 65 + 94 * 8 + 26, 188, backwards);
      drawTwoToOne(canvas, _paint, 0, 65 + 94 * 12 + 26, 188, backwards);
    } else if (round == 4) {
      drawTwoToOne(canvas, _paint, 0, 160, 188 * 2, backwards);
      drawTwoToOne(canvas, _paint, 0, 160 + 94 * 8 + 26, 188 * 2, backwards);
    } else if (round == 5) {
      drawTwoToOne(canvas, _paint, 0, 345, 188 * 4 + 26, backwards);
    } else if (round == 6) {
      var path = Path();
      path.moveTo(0, 188 * 4 + 26);
      path.lineTo(40, 188 * 4 + 26);
      canvas.drawPath(path, _paint);
    }
  }

  void drawTwoToOne(Canvas canvas, Paint paint, double x, double y,
      double height, bool backwards) {
    if (backwards) {
      var path = Path();
      path.moveTo(x + 40, y + 50);
      path.lineTo(x + 40 - 25, y + 50);
      path.lineTo(x + 40 - 25, y + 50 + height);
      path.lineTo(x + 40, y + 50 + height);
      path.moveTo(x + 40 - 25, y + 50 + height / 2);
      path.lineTo(x, y + 50 + height / 2);
      canvas.drawPath(path, paint);
    } else {
      var path = Path();
      path.moveTo(x, y + 50);
      path.lineTo(x + 25, y + 50);
      path.lineTo(x + 25, y + 50 + height);
      path.lineTo(x, y + 50 + height);
      path.moveTo(x + 25, y + 50 + height / 2);
      path.lineTo(x + 40, y + 50 + height / 2);
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false;
  }
}

class RoundColumn extends StatefulWidget {
  const RoundColumn(
      {required this.regionTop,
      required this.regionBottom,
      required this.round,
      required this.refresh,
      super.key});

  final Region regionTop;
  final Region regionBottom;
  final int round;
  final Function() refresh;

  @override
  State<RoundColumn> createState() => _RoundColumnState();
}

class _RoundColumnState extends State<RoundColumn> {
  final _textStyle = const TextStyle(fontWeight: FontWeight.bold, fontSize: 20);

  @override
  Widget build(BuildContext context) {
    if (Data.regionEast.teams.length == 0) {
      return Text("");
    }
    var picks = widget.regionTop.picks[widget.round - 1];
    var topList = picks.map((e) {
      return GestureDetector(
          // When the child is tapped, show a snackbar.
          onTap: () {
            widget.regionTop.pick(widget.round, e);
            widget.refresh();
          },
          // The custom button
          child: TeamBoxItem(
              teamName: e?.name ?? "",
              teamImageName: e?.imageName ?? "",
              seed: -1));
    }).toList();
    var bottomPicks = widget.regionBottom.picks[widget.round - 1];
    var bottomList = bottomPicks.map((e) {
      return GestureDetector(
          // When the child is tapped, show a snackbar.
          onTap: () {
            widget.regionBottom.pick(widget.round, e);
            widget.refresh();
          },
          // The custom button
          child: TeamBoxItem(
              teamName: e?.name ?? "",
              teamImageName: e?.imageName ?? "",
              seed: -1));
    }).toList();
    final double spaceTop = widget.round == 1
        ? 20
        : widget.round == 2
            ? 68
            : widget.round == 3
                ? 163
                : 350;
    final double spaceInBetween = widget.round == 1
        ? 50
        : widget.round == 2
            ? 144
            : widget.round == 3
                ? 330
                : 700;
    List<Widget> totalList = [];
    totalList.add(Container(
        margin: const EdgeInsets.fromLTRB(0, 0, 0, 3),
        child: Text("", style: _textStyle)));
    totalList.add(SizedBox(
      width: 0,
      height: spaceTop,
    ));
    topList.forEach((element) {
      totalList.add(element);
      totalList.add(SizedBox(
        width: 0,
        height: spaceInBetween,
      ));
    });
    totalList.add(Container(
        margin: const EdgeInsets.fromLTRB(0, 0, 0, 3),
        child: Text("", style: _textStyle)));
//    totalList.addAll(topList);
    bottomList.forEach((element) {
      totalList.add(element);
      totalList.add(SizedBox(
        width: 0,
        height: spaceInBetween,
      ));
    });
    totalList.removeLast();
    return Column(
      children: totalList,
    );
  }
}

class TeamColumn extends StatefulWidget {
  const TeamColumn(
      {required this.regionTop,
      required this.regionBottom,
      required this.refresh,
      super.key});

  final Region regionTop;
  final Region regionBottom;
  final Function() refresh;

  @override
  State<TeamColumn> createState() => _TeamColumnState();
}

class _TeamColumnState extends State<TeamColumn> {
  final _textStyle = const TextStyle(fontWeight: FontWeight.bold, fontSize: 20);

  @override
  Widget build(BuildContext context) {
    if (Data.regionEast.teams.length == 0) {
      return Text("");
    }
    List<Widget> topList = Data.pairings.map(
      (e) {
        return PairingItem(
          t1: widget.regionTop.teamBySeed(e.a),
          t2: widget.regionTop.teamBySeed(e.b),
          tapped: () => {
            setState(() {
              widget.regionTop.firstRoundPick(e.a);
              widget.refresh();
            })
          },
          tapped2: () => {
            setState(() {
              widget.regionTop.firstRoundPick(e.b);
              widget.refresh();
            })
          },
        );
      },
    ).toList();
    List<Widget> bottomList = Data.pairings.map(
      (e) {
        return PairingItem(
          t1: widget.regionBottom.teamBySeed(e.a),
          t2: widget.regionBottom.teamBySeed(e.b),
          tapped: () => {
            setState(() {
              widget.regionBottom.firstRoundPick(e.a);
              widget.refresh();
            })
          },
          tapped2: () => {
            setState(() {
              widget.regionBottom.firstRoundPick(e.b);
              widget.refresh();
            })
          },
        );
      },
    ).toList();
    List<Widget> totalList = [];
    totalList.add(Text(
      widget.regionTop.name,
      style: _textStyle,
    ));
    totalList.addAll(topList);
    totalList.add(Text(
      widget.regionBottom.name,
      style: _textStyle,
    ));
    totalList.addAll(bottomList);

    return Column(
      children: totalList,
    );
  }
}

class PairingItem extends StatelessWidget {
  const PairingItem(
      {required this.t1,
      required this.t2,
      required this.tapped,
      required this.tapped2,
      super.key});

  final Team t1;
  final Team t2;
  final Function() tapped;
  final Function() tapped2;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(0, 3, 0, 3),
      child: Column(
        children: [
          GestureDetector(
              // When the child is tapped, show a snackbar.
              onTap: () {
                tapped();
              },
              // The custom button
              child: TeamBoxItem.fromTeam(t1)),
          GestureDetector(
              // When the child is tapped, show a snackbar.
              onTap: () {
                tapped2();
              },
              // The custom button
              child: TeamBoxItem.fromTeam(t2)),
        ],
      ),
    );
  }
}

class TeamBoxItem extends StatelessWidget {
  const TeamBoxItem(
      {super.key,
      required this.teamName,
      required this.teamImageName,
      required this.seed});
  factory TeamBoxItem.fromTeam(Team team) {
    return TeamBoxItem(
        teamName: team.name, teamImageName: team.imageName, seed: team.seed);
  }
  final String teamImageName;
  final String teamName;
  final int seed;
  final _textStyle = const TextStyle(fontWeight: FontWeight.bold);

  @override
  Widget build(BuildContext context) {
    Widget i = teamImageName == ""
        ? SizedBox(width: 30, height: 30)
        : Image(
            image: AssetImage('assets/${teamImageName}'),
            errorBuilder: (BuildContext context, Object exception,
                StackTrace? stackTrace) {
              return SizedBox(width: 30, height: 30);
            },
            width: 30,
            height: 30,
          );

    return Container(
        margin: const EdgeInsets.fromLTRB(0, 3, 0, 3),
        padding: const EdgeInsets.all(3),
        decoration: BoxDecoration(border: Border.all(color: Colors.blueAccent)),
        child: Row(
          children: [
            Text(
              "${seed < 0 ? "" : seed}",
              style: _textStyle,
            ),
            const Spacer(),
            Text(
              teamName,
              style: _textStyle,
            ),
            const SizedBox(width: 10),
            i
          ],
        ));
  }
}
