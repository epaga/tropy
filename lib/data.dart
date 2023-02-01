import 'main.dart';

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

  static Region regionWest = Region(teams: [], name: "", picks: []);
  static Region regionEast = Region(teams: [], name: "", picks: []);
  static Region regionSouth = Region(teams: [], name: "", picks: []);
  static Region regionMidWest = Region(teams: [], name: "", picks: []);

  static FinalPicks finalPicks = FinalPicks();
}
