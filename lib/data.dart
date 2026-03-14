import 'dart:convert';
import 'dart:math';

import 'main.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Data {
  static final Random _random = Random();
  static const String westRegionName = "West";
  static const String eastRegionName = "East";
  static const String southRegionName = "South";
  static const String midWestRegionName = "MidWest";
  static const Set<String> validRegionNames = {
    westRegionName,
    eastRegionName,
    southRegionName,
    midWestRegionName,
  };
  static List<Pair> pairings = [
    Pair(1, 16),
    Pair(8, 9),
    Pair(5, 12),
    Pair(4, 13),
    Pair(6, 11),
    Pair(3, 14),
    Pair(7, 10),
    Pair(2, 15),
  ];

  static bool haveAllPicks = false;
  static bool submittedPicks = true;
  // south <-> midwest
  // east <-> west
  static Region regionWest = Region(teams: [], name: "", picks: []);
  static Region regionEast = Region(teams: [], name: "", picks: []);
  static Region regionSouth = Region(teams: [], name: "", picks: []);
  static Region regionMidWest = Region(teams: [], name: "", picks: []);
  static String leftTopRegionName = southRegionName;
  static String leftBottomRegionName = westRegionName;
  static String rightTopRegionName = eastRegionName;
  static String rightBottomRegionName = midWestRegionName;
  static bool notReadyYet = true;
  static String csvUrl = 'https://smoothtrack.app/tropy/initialdata.csv';
  static bool needPassword = false;

  static FinalPicks finalPicks = FinalPicks();

  static bool clearPrefsAtStart = false;
  static bool appstoretest = false;
  static bool migrationDone = false;

  static void storeToDisk() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('regionWest', jsonEncode(regionWest.toJson()));
    prefs.setString('regionEast', jsonEncode(regionEast.toJson()));
    prefs.setString('regionMidwest', jsonEncode(regionMidWest.toJson()));
    prefs.setString('regionSouth', jsonEncode(regionSouth.toJson()));
    prefs.setString('finalPicks', jsonEncode(finalPicks.toJson()));
    prefs.setString('leftTopRegionName', leftTopRegionName);
    prefs.setString('leftBottomRegionName', leftBottomRegionName);
    prefs.setString('rightTopRegionName', rightTopRegionName);
    prefs.setString('rightBottomRegionName', rightBottomRegionName);
  }

  static void resetBracketLayoutToDefault() {
    setBracketLayout(
      leftTop: southRegionName,
      leftBottom: westRegionName,
      rightTop: eastRegionName,
      rightBottom: midWestRegionName,
    );
  }

  static void loadBracketLayoutFromPrefs(SharedPreferences prefs) {
    setBracketLayout(
      leftTop: prefs.getString('leftTopRegionName') ?? southRegionName,
      leftBottom: prefs.getString('leftBottomRegionName') ?? westRegionName,
      rightTop: prefs.getString('rightTopRegionName') ?? eastRegionName,
      rightBottom:
          prefs.getString('rightBottomRegionName') ?? midWestRegionName,
    );
  }

  static void setBracketLayout({
    required String leftTop,
    required String leftBottom,
    required String rightTop,
    required String rightBottom,
  }) {
    final normalized = [
      _canonicalRegionName(leftTop),
      _canonicalRegionName(leftBottom),
      _canonicalRegionName(rightTop),
      _canonicalRegionName(rightBottom),
    ];
    final containsInvalid = normalized.any((name) => name == null);
    if (containsInvalid || normalized.toSet().length != 4) {
      leftTopRegionName = southRegionName;
      leftBottomRegionName = westRegionName;
      rightTopRegionName = eastRegionName;
      rightBottomRegionName = midWestRegionName;
      return;
    }

    leftTopRegionName = normalized[0]!;
    leftBottomRegionName = normalized[1]!;
    rightTopRegionName = normalized[2]!;
    rightBottomRegionName = normalized[3]!;
  }

  static void applyBracketLayoutFromCsv(List<List<dynamic>> list) {
    final layoutRow = list.cast<List<dynamic>?>().firstWhere(
      (row) =>
          row != null &&
          row.length >= 5 &&
          row[0].toString().trim().toUpperCase() == "BRACKET_LAYOUT",
      orElse: () => null,
    );

    if (layoutRow == null) {
      resetBracketLayoutToDefault();
      return;
    }

    setBracketLayout(
      leftTop: layoutRow[1].toString(),
      leftBottom: layoutRow[2].toString(),
      rightTop: layoutRow[3].toString(),
      rightBottom: layoutRow[4].toString(),
    );
  }

  static String? _canonicalRegionName(String input) {
    final normalized = input.trim().toLowerCase();
    for (final regionName in validRegionNames) {
      if (regionName.toLowerCase() == normalized) {
        return regionName;
      }
    }
    return null;
  }

  static Region regionByName(String regionName) {
    switch (regionName) {
      case westRegionName:
        return regionWest;
      case eastRegionName:
        return regionEast;
      case southRegionName:
        return regionSouth;
      case midWestRegionName:
        return regionMidWest;
      default:
        return regionSouth;
    }
  }

  static bool isLeftSideRegion(String regionName) {
    return regionName == leftTopRegionName ||
        regionName == leftBottomRegionName;
  }

  static void updateWhetherWeHaveAllPicks() {
    storeToDisk();

    haveAllPicks =
        regionWest.haveAllPicks() &&
        regionEast.haveAllPicks() &&
        regionSouth.haveAllPicks() &&
        regionMidWest.haveAllPicks() &&
        finalPicks.champ != null &&
        finalPicks.teamLeft != null &&
        finalPicks.teamRight != null;
  }

  static void resetPicks() {
    regionWest = _resetRegion(regionWest);
    regionEast = _resetRegion(regionEast);
    regionSouth = _resetRegion(regionSouth);
    regionMidWest = _resetRegion(regionMidWest);
    finalPicks = FinalPicks();
    updateWhetherWeHaveAllPicks();
  }

  static bool autofillRandomPicks() {
    if (regionWest.teams.isEmpty ||
        regionEast.teams.isEmpty ||
        regionSouth.teams.isEmpty ||
        regionMidWest.teams.isEmpty) {
      return false;
    }

    resetPicks();

    _autofillRegion(regionWest);
    _autofillRegion(regionEast);
    _autofillRegion(regionSouth);
    _autofillRegion(regionMidWest);

    final leftSideWinners = <Team>[
      if (regionByName(leftTopRegionName).picks[3][0] != null)
        regionByName(leftTopRegionName).picks[3][0]!,
      if (regionByName(leftBottomRegionName).picks[3][0] != null)
        regionByName(leftBottomRegionName).picks[3][0]!,
    ];
    final rightSideWinners = <Team>[
      if (regionByName(rightTopRegionName).picks[3][0] != null)
        regionByName(rightTopRegionName).picks[3][0]!,
      if (regionByName(rightBottomRegionName).picks[3][0] != null)
        regionByName(rightBottomRegionName).picks[3][0]!,
    ];

    if (leftSideWinners.isEmpty || rightSideWinners.isEmpty) {
      return false;
    }

    finalPicks.teamLeft =
        leftSideWinners[_random.nextInt(leftSideWinners.length)];
    finalPicks.teamRight =
        rightSideWinners[_random.nextInt(rightSideWinners.length)];
    finalPicks.champ =
        _random.nextBool() ? finalPicks.teamLeft : finalPicks.teamRight;

    updateWhetherWeHaveAllPicks();
    return true;
  }

  static void _autofillRegion(Region region) {
    for (var i = 0; i < pairings.length; i++) {
      final pair = pairings[i];
      final teamA = region.teamBySeed(pair.a) as Team;
      final teamB = region.teamBySeed(pair.b) as Team;
      region.picks[0][i] = _random.nextBool() ? teamA : teamB;
    }

    for (var round = 1; round < 4; round++) {
      for (var i = 0; i < region.picks[round].length; i++) {
        final previousA = region.picks[round - 1][i * 2]!;
        final previousB = region.picks[round - 1][i * 2 + 1]!;
        region.picks[round][i] = _random.nextBool() ? previousA : previousB;
      }
    }
  }

  static Region _resetRegion(Region region) {
    return Region(
      name: region.name,
      teams: region.teams,
      picks: [
        List<Team?>.filled(8, null, growable: false),
        List<Team?>.filled(4, null, growable: false),
        List<Team?>.filled(2, null, growable: false),
        List<Team?>.filled(1, null, growable: false),
      ],
    );
  }

  static Submission submission = Submission();

  static String picks() {
    var westR1Picks = regionWest.picksString(0);
    var eastR1Picks = regionEast.picksString(0);
    var southR1Picks = regionSouth.picksString(0);
    var midwestR1Picks = regionMidWest.picksString(0);
    var westR2Picks = regionWest.picksString(1);
    var eastR2Picks = regionEast.picksString(1);
    var southR2Picks = regionSouth.picksString(1);
    var midwestR2Picks = regionMidWest.picksString(1);
    var westR3Picks = regionWest.picksString(2);
    var eastR3Picks = regionEast.picksString(2);
    var southR3Picks = regionSouth.picksString(2);
    var midwestR3Picks = regionMidWest.picksString(2);
    var westR4Picks = regionWest.picksString(3);
    var eastR4Picks = regionEast.picksString(3);
    var southR4Picks = regionSouth.picksString(3);
    var midwestR4Picks = regionMidWest.picksString(3);
    var leftPick = finalPicks.teamLeft!;
    var leftPickString =
        leftPick.region.substring(0, 1) + leftPick.seed.toString();
    var rightPick = finalPicks.teamRight!;
    var rightPickString =
        rightPick.region.substring(0, 1) + rightPick.seed.toString();
    var champPick = finalPicks.champ!;
    var champPickString =
        champPick.region.substring(0, 1) + champPick.seed.toString();
    return westR1Picks +
        "," +
        eastR1Picks +
        "," +
        southR1Picks +
        "," +
        midwestR1Picks +
        "," +
        westR2Picks +
        "," +
        eastR2Picks +
        "," +
        southR2Picks +
        "," +
        midwestR2Picks +
        "," +
        westR3Picks +
        "," +
        eastR3Picks +
        "," +
        southR3Picks +
        "," +
        midwestR3Picks +
        "," +
        westR4Picks +
        "," +
        eastR4Picks +
        "," +
        southR4Picks +
        "," +
        midwestR4Picks +
        "," +
        leftPickString +
        "," +
        rightPickString +
        "," +
        champPickString;
  }
}

class Submission {
  var name = "";
  var cityState = "";
  var postal = "";
  var country = "";
  var email = "";
  var picks = "";

  String firstName() {
    return name.substring(0, name.lastIndexOf(' ') + 1);
  }

  String lastName() {
    return name.substring(name.lastIndexOf(' ') + 1);
  }
}

Region region(String regionName, List<List<dynamic>> list) {
  return Region(
    name: regionName,
    picks: [
      [null, null, null, null, null, null, null, null],
      [null, null, null, null],
      [null, null],
      [null],
    ],
    teams:
        list
            .where(
              (element) =>
                  element.length >= 4 &&
                  element[1] is num &&
                  element[2].toString().trim() == regionName,
            )
            .map(
              (e) =>
                  Team(name: e[0], seed: e[1], region: e[2], imageName: e[3]),
            )
            .toList(),
  );
}
