import 'package:flutter/material.dart';
import 'main.dart';
import 'data.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TwoToOnePainter extends CustomPainter {
  TwoToOnePainter(this.round, {this.backwards = false});

  final int round;
  final bool backwards;

  @override
  void paint(Canvas canvas, Size size) {
    // Create a Paint object.
    Paint paint = Paint()
      ..color = Colors.black
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke
      ..strokeJoin = StrokeJoin.round;

    // Set the color of the paint to blue.
    paint.color = Colors.blue;

    // super embarrassingly duplicated code since i'm running out of time...
    if (round == 1) {
      drawTwoToOne(canvas, paint, 0, 0, 40, backwards);
      drawTwoToOne(canvas, paint, 0, 94, 40, backwards);
      drawTwoToOne(canvas, paint, 0, 94 * 2, 40, backwards);
      drawTwoToOne(canvas, paint, 0, 94 * 3, 40, backwards);
      drawTwoToOne(canvas, paint, 0, 94 * 4, 40, backwards);
      drawTwoToOne(canvas, paint, 0, 94 * 5, 40, backwards);
      drawTwoToOne(canvas, paint, 0, 94 * 6, 40, backwards);
      drawTwoToOne(canvas, paint, 0, 94 * 7, 40, backwards);
      drawTwoToOne(canvas, paint, 0, 94 * 8 + 26, 40, backwards);
      drawTwoToOne(canvas, paint, 0, 94 * 9 + 26, 40, backwards);
      drawTwoToOne(canvas, paint, 0, 94 * 10 + 26, 40, backwards);
      drawTwoToOne(canvas, paint, 0, 94 * 11 + 26, 40, backwards);
      drawTwoToOne(canvas, paint, 0, 94 * 12 + 26, 40, backwards);
      drawTwoToOne(canvas, paint, 0, 94 * 13 + 26, 40, backwards);
      drawTwoToOne(canvas, paint, 0, 94 * 14 + 26, 40, backwards);
      drawTwoToOne(canvas, paint, 0, 94 * 15 + 26, 40, backwards);
    } else if (round == 2) {
      drawTwoToOne(canvas, paint, 0, 18, 94, backwards);
      drawTwoToOne(canvas, paint, 0, 18 + 94 * 2, 94, backwards);
      drawTwoToOne(canvas, paint, 0, 18 + 94 * 4, 94, backwards);
      drawTwoToOne(canvas, paint, 0, 18 + 94 * 6, 94, backwards);
      drawTwoToOne(canvas, paint, 0, 18 + 94 * 8 + 26, 94, backwards);
      drawTwoToOne(canvas, paint, 0, 18 + 94 * 10 + 26, 94, backwards);
      drawTwoToOne(canvas, paint, 0, 18 + 94 * 12 + 26, 94, backwards);
      drawTwoToOne(canvas, paint, 0, 18 + 94 * 14 + 26, 94, backwards);
    } else if (round == 3) {
      drawTwoToOne(canvas, paint, 0, 65, 188, backwards);
      drawTwoToOne(canvas, paint, 0, 65 + 94 * 4, 188, backwards);
      drawTwoToOne(canvas, paint, 0, 65 + 94 * 8 + 26, 188, backwards);
      drawTwoToOne(canvas, paint, 0, 65 + 94 * 12 + 26, 188, backwards);
    } else if (round == 4) {
      drawTwoToOne(canvas, paint, 0, 160, 188 * 2, backwards);
      drawTwoToOne(canvas, paint, 0, 160 + 94 * 8 + 26, 188 * 2, backwards);
    } else if (round == 5) {
      drawTwoToOne(canvas, paint, 0, 345, 188 * 4 + 26, backwards);
    } else if (round == 6) {
      var path = Path();
      path.moveTo(0, 188 * 4 + 26);
      path.lineTo(40, 188 * 4 + 26);
      canvas.drawPath(path, paint);
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
    if (Data.regionEast.teams.isEmpty) {
      return const Text("");
    }
    var picks = widget.regionTop.picks[widget.round - 1];
    var topList = picks.map((e) {
      return GestureDetector(
          // When the child is tapped, show a snackbar.
          onTap: () {
            if (Data.submittedPicks) {
              return;
            }
            widget.regionTop.pick(widget.round, e);
            widget.refresh();
            setState(() {});
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
            if (Data.submittedPicks) {
              return;
            }
            widget.regionBottom.pick(widget.round, e);
            widget.refresh();
            setState(() {});
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
    for (var element in topList) {
      totalList.add(element);
      totalList.add(SizedBox(
        width: 0,
        height: spaceInBetween,
      ));
    }
    totalList.add(Container(
        margin: const EdgeInsets.fromLTRB(0, 0, 0, 3),
        child: Text("", style: _textStyle)));
//    totalList.addAll(topList);
    for (var element in bottomList) {
      totalList.add(element);
      totalList.add(SizedBox(
        width: 0,
        height: spaceInBetween,
      ));
    }
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
  @override
  Widget build(BuildContext context) {
    if (Data.regionEast.teams.isEmpty) {
      return const Text("");
    }
    List<Widget> topList = Data.pairings.map(
      (e) {
        return PairingItem(
          t1: widget.regionTop.teamBySeed(e.a),
          t2: widget.regionTop.teamBySeed(e.b),
          tapped: () => {
            setState(() {
              if (Data.submittedPicks) {
                return;
              }
              widget.regionTop.firstRoundPick(e.a);
              widget.refresh();
            })
          },
          tapped2: () => {
            setState(() {
              if (Data.submittedPicks) {
                return;
              }
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
              if (Data.submittedPicks) {
                return;
              }
              widget.regionBottom.firstRoundPick(e.a);
              widget.refresh();
            })
          },
          tapped2: () => {
            setState(() {
              if (Data.submittedPicks) {
                return;
              }
              widget.regionBottom.firstRoundPick(e.b);
              widget.refresh();
            })
          },
        );
      },
    ).toList();
    List<Widget> totalList = [];
    totalList.add(RegionNameBar(region: widget.regionTop));
    totalList.addAll(topList);
    totalList.add(RegionNameBar(region: widget.regionBottom));
    totalList.addAll(bottomList);

    return Column(
      children: totalList,
    );
  }
}

class RegionNameBar extends StatelessWidget {
  final _textStyle = const TextStyle(fontWeight: FontWeight.bold, fontSize: 20);
  final Region region;
  const RegionNameBar({super.key, required this.region});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
        width: 250.0,
        child: DecoratedBox(
          decoration: const BoxDecoration(color: Colors.orange),
          child: Text(
            region.name,
            style: _textStyle,
            textAlign: TextAlign.center,
          ),
        ));
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
        ? const SizedBox(width: 30, height: 30)
        : Image(
            image: CachedNetworkImageProvider(
                'https://smoothtrack.app/tropy/assets/$teamImageName'),
            errorBuilder: (BuildContext context, Object exception,
                StackTrace? stackTrace) {
              return const SizedBox(width: 30, height: 30);
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

class InitialPasswordScreen extends StatefulWidget {
  final Function() loadInitialData;
  const InitialPasswordScreen({super.key, required this.loadInitialData});

  @override
  State<InitialPasswordScreen> createState() => InitialPasswordScreenState();
}

class InitialPasswordScreenState extends State<InitialPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _textStyle = const TextStyle(fontWeight: FontWeight.bold, fontSize: 20);

  setPasswordSet() async {
    Data.needPassword = false;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool("stillNeedPassword", false);
    widget.loadInitialData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SizedBox(
          width: 500,
          height: 500,
          child: Container(
            padding: const EdgeInsets.all(15.0),
            child: Column(
              children: [
                Text(
                  "Welcome to the Traveling Tropy!",
                  style: _textStyle,
                ),
                Padding(
                  padding: EdgeInsets.all(20),
                  child: Image(
                    image: AssetImage("assets/icon/icon.png"),
                    width: 150,
                  ),
                ),
                const Text("Please enter your entry passphrase."),
                const SizedBox(height: 100),
                Form(
                  key: _formKey,
                  child: TextFormField(
                    onFieldSubmitted: (value) => {
                      if (_formKey.currentState!.validate()) {setPasswordSet()}
                    },
                    obscureText: true,
                    decoration: const InputDecoration(
                      labelText: 'Password',
                    ),
                    validator: (String? value) {
                      if (value != "rockchalk") {
                        return "Wrong password!";
                      }
                      return null;
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          if (_formKey.currentState!.validate()) {
            setPasswordSet();
          }
        },
        backgroundColor: Colors.blue,
        child: const Text("Enter"),
      ),
    );
  }
}
