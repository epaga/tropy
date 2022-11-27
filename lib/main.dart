// Copyright 2018 The Flutter team. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'data.dart';

void main() {
  runApp(MyApp());
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
}

class FinalPicks {
  Team? teamLeft = Team(
      name: "Colgate",
      seed: 14,
      region: "MidWest",
      imageName: "Colgate_Raiders_(2020)_logo.svg.png");
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
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Traveling Tropy',
      home: Scaffold(
        body: InteractiveViewer(
          constrained: false,
          boundaryMargin: const EdgeInsets.all(20.0),
          minScale: 0.01,
          maxScale: 1,
          child: SizedBox(
            width: 3300,
            height: 1600,
            child: Container(
              margin: const EdgeInsets.all(15.0),
              padding: const EdgeInsets.all(3.0),
              decoration:
                  BoxDecoration(border: Border.all(color: Colors.black)),
              child: Row(
                children: [
                  SizedBox(
                      width: 250,
                      child: TeamColumn(
                        regionTop: Data.regionWest,
                        regionBottom: Data.regionEast,
                      )),
                  SizedBox(
                      width: 250,
                      child: RoundColumn(
                          regionTop: Data.regionMidWest,
                          regionBottom: Data.regionEast,
                          round: 1)),
                  SizedBox(
                      width: 250,
                      child: RoundColumn(
                          regionTop: Data.regionMidWest,
                          regionBottom: Data.regionEast,
                          round: 2)),
                  SizedBox(
                      width: 250,
                      child: RoundColumn(
                          regionTop: Data.regionMidWest,
                          regionBottom: Data.regionEast,
                          round: 3)),
                  SizedBox(
                      width: 250,
                      child: RoundColumn(
                          regionTop: Data.regionMidWest,
                          regionBottom: Data.regionEast,
                          round: 4)),
                  SizedBox(
                      width: 250,
                      child: GestureDetector(
                          // When the child is tapped, show a snackbar.
                          onTap: () {
                            setState(() {
                              Data.finalPicks.champ = Data.finalPicks.teamLeft;
                            });
                          },
                          // The custom button
                          child: TeamBoxItem(
                              teamName: Data.finalPicks.teamLeft?.name ?? "",
                              teamImageName:
                                  Data.finalPicks.teamLeft?.imageName ?? "",
                              seed: Data.finalPicks.teamLeft?.seed ?? -1))),
                  SizedBox(
                      width: 250,
                      child: TeamBoxItem(
                          teamName: Data.finalPicks.champ?.name ?? "",
                          teamImageName: Data.finalPicks.champ?.imageName ?? "",
                          seed: Data.finalPicks.champ?.seed ?? -1)),
                  SizedBox(
                      width: 250,
                      child: TeamBoxItem(
                          teamName: "", teamImageName: "", seed: -1)),
                  SizedBox(
                      width: 250,
                      child: RoundColumn(
                          regionTop: Data.regionMidWest,
                          regionBottom: Data.regionEast,
                          round: 4)),
                  SizedBox(
                      width: 250,
                      child: RoundColumn(
                          regionTop: Data.regionMidWest,
                          regionBottom: Data.regionEast,
                          round: 3)),
                  SizedBox(
                      width: 250,
                      child: RoundColumn(
                          regionTop: Data.regionMidWest,
                          regionBottom: Data.regionEast,
                          round: 2)),
                  SizedBox(
                      width: 250,
                      child: RoundColumn(
                          regionTop: Data.regionMidWest,
                          regionBottom: Data.regionEast,
                          round: 1)),
                  SizedBox(
                      width: 250,
                      child: TeamColumn(
                        regionTop: Data.regionSouth,
                        regionBottom: Data.regionMidWest,
                      )),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class RoundColumn extends StatefulWidget {
  const RoundColumn(
      {required this.regionTop,
      required this.regionBottom,
      required this.round,
      super.key});

  final Region regionTop;
  final Region regionBottom;
  final int round;

  @override
  State<RoundColumn> createState() => _RoundColumnState();
}

class _RoundColumnState extends State<RoundColumn> {
  final _textStyle = const TextStyle(fontWeight: FontWeight.bold, fontSize: 20);
  @override
  Widget build(BuildContext context) {
    var picks = widget.regionTop.picks[widget.round - 1];
    var topList = picks.map((e) {
      return TeamBoxItem(
          teamName: e?.name ?? "", teamImageName: e?.imageName ?? "", seed: -1);
    }).toList();
    var bottomPicks = widget.regionBottom.picks[widget.round - 1];
    var bottomList = bottomPicks.map((e) {
      return TeamBoxItem(
          teamName: e?.name ?? "", teamImageName: e?.imageName ?? "", seed: -1);
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
      {required this.regionTop, required this.regionBottom, super.key});

  final Region regionTop;
  final Region regionBottom;

  @override
  State<TeamColumn> createState() => _TeamColumnState();
}

class _TeamColumnState extends State<TeamColumn> {
  final _textStyle = const TextStyle(fontWeight: FontWeight.bold, fontSize: 20);

  @override
  Widget build(BuildContext context) {
    List<Widget> topList = Data.pairings.map(
      (e) {
        return PairingItem(
            t1: widget.regionTop.teamBySeed(e.a),
            t2: widget.regionTop.teamBySeed(e.b));
      },
    ).toList();
    List<Widget> bottomList = Data.pairings.map(
      (e) {
        return PairingItem(
            t1: widget.regionBottom.teamBySeed(e.a),
            t2: widget.regionBottom.teamBySeed(e.b));
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
  const PairingItem({required this.t1, required this.t2, super.key});

  final Team t1;
  final Team t2;

  @override
  Widget build(BuildContext context) {
    return Container(
        margin: const EdgeInsets.all(3.0),
        child: Column(
          children: [TeamBoxItem.fromTeam(t1), TeamBoxItem.fromTeam(t2)],
        ));
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
            width: 30,
            height: 30,
          );

    return Container(
        margin: const EdgeInsets.all(3.0),
        padding: const EdgeInsets.all(3.0),
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
