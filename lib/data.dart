import 'dart:convert';

import 'package:flutter/src/widgets/form.dart';

import 'main.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Data {
  static List<Pair> pairings = [
    Pair(1, 16),
    Pair(8, 9),
    Pair(5, 12),
    Pair(4, 13),
    Pair(6, 11),
    Pair(3, 14),
    Pair(7, 10),
    Pair(2, 15)
  ];

  static bool haveAllPicks = false;
  static bool submittedPicks = true;

  static Region regionWest = Region(teams: [], name: "", picks: []);
  static Region regionEast = Region(teams: [], name: "", picks: []);
  static Region regionSouth = Region(teams: [], name: "", picks: []);
  static Region regionMidWest = Region(teams: [], name: "", picks: []);
  static bool notReadyYet = true;
  static String csvUrl = 'https://smoothtrack.app/tropy/initialdata2.csv';
  static bool needPassword = false;

  static FinalPicks finalPicks = FinalPicks();

  static bool clearPrefsAtStart = true;

  static void storeToDisk() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('regionWest', jsonEncode(regionWest.toJson()));
    prefs.setString('regionEast', jsonEncode(regionEast.toJson()));
    prefs.setString('regionMidwest', jsonEncode(regionMidWest.toJson()));
    prefs.setString('regionSouth', jsonEncode(regionSouth.toJson()));
    prefs.setString('finalPicks', jsonEncode(finalPicks.toJson()));
  }

  static void updateWhetherWeHaveAllPicks() {
    storeToDisk();

    haveAllPicks = regionWest.haveAllPicks() &&
        regionEast.haveAllPicks() &&
        regionSouth.haveAllPicks() &&
        regionMidWest.haveAllPicks() &&
        finalPicks.champ != null &&
        finalPicks.teamLeft != null &&
        finalPicks.teamRight != null;
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
