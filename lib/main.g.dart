// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'main.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Team _$TeamFromJson(Map<String, dynamic> json) => Team(
      name: json['name'] as String,
      seed: json['seed'] as int,
      region: json['region'] as String,
      imageName: json['imageName'] as String,
    );

Map<String, dynamic> _$TeamToJson(Team instance) => <String, dynamic>{
      'name': instance.name,
      'seed': instance.seed,
      'region': instance.region,
      'imageName': instance.imageName,
    };

Region _$RegionFromJson(Map<String, dynamic> json) => Region(
      teams: (json['teams'] as List<dynamic>)
          .map((e) => Team.fromJson(e as Map<String, dynamic>))
          .toList(),
      name: json['name'] as String,
      picks: (json['picks'] as List<dynamic>)
          .map((e) => (e as List<dynamic>)
              .map((e) =>
                  e == null ? null : Team.fromJson(e as Map<String, dynamic>))
              .toList())
          .toList(),
    );

Map<String, dynamic> _$RegionToJson(Region instance) => <String, dynamic>{
      'teams': instance.teams,
      'name': instance.name,
      'picks': instance.picks,
    };

FinalPicks _$FinalPicksFromJson(Map<String, dynamic> json) => FinalPicks()
  ..teamLeft = json['teamLeft'] == null
      ? null
      : Team.fromJson(json['teamLeft'] as Map<String, dynamic>)
  ..champ = json['champ'] == null
      ? null
      : Team.fromJson(json['champ'] as Map<String, dynamic>)
  ..teamRight = json['teamRight'] == null
      ? null
      : Team.fromJson(json['teamRight'] as Map<String, dynamic>);

Map<String, dynamic> _$FinalPicksToJson(FinalPicks instance) =>
    <String, dynamic>{
      'teamLeft': instance.teamLeft,
      'champ': instance.champ,
      'teamRight': instance.teamRight,
    };
