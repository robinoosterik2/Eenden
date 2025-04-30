import 'dart:math'; // Import dart:math for Random
import 'package:eenden_app/models/challenge.dart';
import 'package:eenden_app/models/game.dart';
import 'package:eenden_app/pages/leaderboard_screen.dart'; // Import LeaderboardScreen
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart'; // Import
import 'package:eenden_app/pages/settings_screen.dart'; // Import for key

class GamePlayScreen extends StatefulWidget {
  final Game game;
  final List<String> players;

  const GamePlayScreen({super.key, required this.game, required this.players});

  @override
  State<GamePlayScreen> createState() => _GamePlayScreenState();
}

class _GamePlayScreenState extends State<GamePlayScreen> {
  Challenge? _currentChallenge;
  List<int> _currentPlayerIndices = [];
  final Random _playerRandom = Random();
  late Map<String, int> _scores; // Add score map
  String _pointsLabel = ""; // State for the label
  bool _labelIsLoading = true;

  @override
  void initState() {
    super.initState();
    // Initialize scores for all players to 0
    _scores = { for (var player in widget.players) player : 0 };
    _loadPointsLabel(); // Load label on init
  }

  Future<void> _loadPointsLabel() async {
     if (!mounted) return;
     setState(() => _labelIsLoading = true);
     try {
        final prefs = await SharedPreferences.getInstance();
        final customLabel = prefs.getString(kCustomPointsLabelKey);
        final localizations = AppLocalizations.of(context)!;

        if (customLabel != null && customLabel.isNotEmpty) {
            _pointsLabel = customLabel;
        } else {
             // Use default based on locale (assuming 1 point needs singular)
             // This logic needs refinement if point values change drastically
            _pointsLabel = localizations.pointsPlural; // Default to plural for label
        }
     } catch (e) {
        print("Error loading points label: $e");
         final localizations = AppLocalizations.of(context)!;
        _pointsLabel = localizations.pointsPlural; // Fallback to default plural
     } finally {
        if (mounted) {
            setState(() => _labelIsLoading = false);
        }
     }
  }

  void _getNextChallengeAndPlayers() {
    if (widget.players.isEmpty) return;

    final challenge = widget.game.getRandomChallenge();
    final requiredPlayers = challenge.playerCount;
    List<int> selectedIndices = [];

    if (widget.players.length < requiredPlayers) {
       // Not enough players for this challenge - ideally, filter challenges 
       // before calling getRandomChallenge, but for now, just show an error/skip
       print("Error: Not enough players for challenge requiring $requiredPlayers players.");
       // Maybe pick a different challenge or show a message?
       // For now, we'll just clear the state and let the UI show the default.
       setState(() {
           _currentChallenge = null;
           _currentPlayerIndices = [];
       });
       return;
    }

    // Select required number of unique random players
    selectedIndices.addAll(widget.players.asMap().keys.toList()); // Get all possible indices
    selectedIndices.shuffle(_playerRandom);
    selectedIndices = selectedIndices.take(requiredPlayers).toList();

    // Simple check to avoid exact same group if possible (for 2+ players)
    // This isn't perfect for preventing *any* overlap, just the identical set.
    if (requiredPlayers > 1 && 
        widget.players.length > requiredPlayers &&
        _listsEqual(selectedIndices..sort(), _currentPlayerIndices..sort())) 
    {
      // Try one more time to shuffle and pick a different group
      selectedIndices.shuffle(_playerRandom);
      selectedIndices = selectedIndices.take(requiredPlayers).toList();
    }

    setState(() {
      _currentChallenge = challenge;
      _currentPlayerIndices = selectedIndices;

      // --- Simulate awarding points --- 
      // In a real game, you might have buttons for success/failure
      // For now, let's just add points to the selected players when the challenge appears
      if (_currentChallenge != null) {
        for (int index in _currentPlayerIndices) {
          String playerName = widget.players[index];
          _scores[playerName] = (_scores[playerName] ?? 0) + _currentChallenge!.points;
          print("Awarded ${_currentChallenge!.points} points to $playerName. New score: ${_scores[playerName]}");
        }
      }
      // --- End simulated point awarding ---
    });
  }

  // Helper to check if two lists contain the same elements (order doesn't matter after sorting)
  bool _listsEqual(List<int> a, List<int> b) {
    if (a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }

  // Helper to get localized string (specific to this screen's needs)
  String _getLocalizedChallengeText(BuildContext context, String key) {
    final localizations = AppLocalizations.of(context)!;
    // Basic lookup - consider a Map or reflection for many keys
    switch (key) {
      case 'challengeEenden1': return localizations.challengeEenden1;
      case 'challengeEenden2': return localizations.challengeEenden2;
      case 'challengeEenden3': return localizations.challengeEenden3;
      case 'challengeEenden4': return localizations.challengeEenden4;
      case 'challengeEenden5_2p': return localizations.challengeEenden5_2p;
      case 'challengeEenden6_2p': return localizations.challengeEenden6_2p;
      case 'challengeOther1': return localizations.challengeOther1;
      case 'challengeOther2': return localizations.challengeOther2;
      // Add more challenge keys here
      default:
        print("Warning: Missing localization for challenge key: $key");
        return key; // Fallback
    }
  }
   String _getLocalizedGameTitle(BuildContext context, String key) {
    final localizations = AppLocalizations.of(context)!;
    switch (key) {
      case 'gameEendenTitle': return localizations.gameEendenTitle;
      case 'gameOtherTitle': return localizations.gameOtherTitle;
      default:
         print("Warning: Missing localization for game title key: $key");
        return key; 
    }
  }

  void _endGame() {
      print("Ending game with scores: $_scores");
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => LeaderboardScreen(
            scores: _scores,
            players: widget.players, // Pass players for the 'New Quiz' button
          ),
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    
    // Get player names based on selected indices
    String? player1Name;
    String? player2Name;
    if (_currentPlayerIndices.isNotEmpty) {
        player1Name = widget.players[_currentPlayerIndices[0]];
    }
    if (_currentPlayerIndices.length > 1) {
        player2Name = widget.players[_currentPlayerIndices[1]];
    }

    // Determine if the UI should show the start message
    bool showStartMessage = _currentChallenge == null || 
                            (_currentChallenge!.playerCount == 1 && player1Name == null) || 
                            (_currentChallenge!.playerCount == 2 && (player1Name == null || player2Name == null));

    String challengeText = "";
    if (!showStartMessage) {
        challengeText = _getLocalizedChallengeText(context, _currentChallenge!.textKey);
        if (player1Name != null) {
            challengeText = challengeText.replaceAll('<player1>', player1Name);
        }
        if (player2Name != null) {
            challengeText = challengeText.replaceAll('<player2>', player2Name);
        }
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: colorScheme.primaryContainer,
        automaticallyImplyLeading: false, // Prevent back navigation during game
        title: Center(
          child: TextButton.icon(
            icon: const Icon(Icons.stop_circle_outlined),
            label: Text(localizations.endGameButton),
            onPressed: _endGame,
            style: TextButton.styleFrom(
              foregroundColor: colorScheme.onPrimaryContainer,
              padding: const EdgeInsets.symmetric(horizontal: 16.0)
            ),
          ),
        ),
        actions: [ 
          // Keep actions empty or add other icons here if needed later
        ],
      ),
      body: GestureDetector(
        onTap: _getNextChallengeAndPlayers,
        behavior: HitTestBehavior.opaque,
        child: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                colorScheme.primaryContainer.withOpacity(0.3),
                colorScheme.background,
              ],
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Center(
                    child: showStartMessage
                        ? Text(
                            "Tap anywhere to start!",
                            style: textTheme.headlineSmall,
                            textAlign: TextAlign.center,
                          )
                        : Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                challengeText,
                                style: textTheme.headlineMedium,
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 16),
                              _labelIsLoading 
                                ? const SizedBox(height: 24, width: 24, child: CircularProgressIndicator(strokeWidth: 2)) // Show loading for label
                                : Chip(
                                  label: Text(
                                    // Use state variable for label, handle potential pluralization simply
                                    '${_currentChallenge!.points} $_pointsLabel', 
                                    style: textTheme.titleMedium?.copyWith(color: colorScheme.onSecondaryContainer)
                                  ),
                                  avatar: Icon(Icons.star, color: Colors.amber, size: 20),
                                  backgroundColor: colorScheme.secondaryContainer,
                                ),
                            ],
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
} 