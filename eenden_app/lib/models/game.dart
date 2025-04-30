import 'dart:convert';
import 'dart:math';
import 'package:eenden_app/models/challenge.dart';
import 'package:flutter/services.dart' show rootBundle;

class Game {
  final String id;
  final String nameKey;
  final String descriptionKey;
  final String imagePath;
  final List<Challenge> challenges;

  // State for random challenge logic
  final List<String> _recentChallengeIds = [];
  final int _maxRecent = 1; // Only prevent immediate repetition
  final Random _random = Random();

  Game({
    required this.id,
    required this.nameKey,
    required this.descriptionKey,
    required this.imagePath,
    required this.challenges,
  });

  factory Game.fromJson(Map<String, dynamic> json) {
    var challengeList = json['challenges'] as List;
    List<Challenge> challenges = challengeList.map((i) => Challenge.fromJson(i)).toList();

    return Game(
      id: json['id'] as String,
      nameKey: json['nameKey'] as String,
      descriptionKey: json['descriptionKey'] as String,
      imagePath: json['imagePath'] as String,
      challenges: challenges,
    );
  }

  Challenge getRandomChallenge() {
    if (challenges.isEmpty) {
      // Handle case with no challenges (though JSON should have them)
      throw Exception("Game '$id' has no challenges!");
    }

    List<Challenge> availableChallenges = challenges
        .where((challenge) => !_recentChallengeIds.contains(challenge.id))
        .toList();

    // If all challenges have been recently used (only happens if _maxRecent >= challenges.length)
    // or if only one challenge exists, just pick randomly from all.
    if (availableChallenges.isEmpty) {
        availableChallenges = challenges;
    }

    // Select a random challenge from the available ones
    final selectedChallenge = availableChallenges[_random.nextInt(availableChallenges.length)];

    // Update recent challenges list
    _recentChallengeIds.add(selectedChallenge.id);
    if (_recentChallengeIds.length > _maxRecent) {
      _recentChallengeIds.removeAt(0); // Remove the oldest ID
    }

    print("Selected challenge: ${selectedChallenge.id}, Recent: $_recentChallengeIds"); // For debugging
    return selectedChallenge;
  }

  // Static method to load all games from JSON assets
  static Future<List<Game>> loadGamesFromAssets() async {
    // 1. Load the AssetManifest
    final manifestContent = await rootBundle.loadString('AssetManifest.json');
    final Map<String, dynamic> manifestMap = json.decode(manifestContent);

    // 2. Filter keys for game JSON files
    final gameJsonPaths = manifestMap.keys
        .where((String key) => key.startsWith('assets/games/') && key.endsWith('.json'))
        .toList();

    // 3. Load and parse each game file
    List<Game> games = [];
    for (String path in gameJsonPaths) {
      try {
        String jsonString = await rootBundle.loadString(path);
        Map<String, dynamic> jsonMap = json.decode(jsonString);
        games.add(Game.fromJson(jsonMap));
      } catch (e) {
        print("Error loading or parsing game from $path: $e");
        // Decide how to handle errors: skip file, throw exception, etc.
      }
    }
    print("Loaded ${games.length} games from assets.");
    return games;
  }
} 