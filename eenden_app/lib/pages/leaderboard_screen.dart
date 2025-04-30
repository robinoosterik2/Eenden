import 'package:eenden_app/pages/game_selection_screen.dart';
import 'package:eenden_app/pages/player_input_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:eenden_app/pages/settings_screen.dart';

class LeaderboardScreen extends StatefulWidget {
  final Map<String, int> scores;
  final List<String> players; // Need players to pass back to game selection

  const LeaderboardScreen({super.key, required this.scores, required this.players});

  @override
  State<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends State<LeaderboardScreen> {
  String _pointsLabel = "";
  bool _labelIsLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPointsLabel(); // Load label on init
  }

  Future<void> _loadPointsLabel() async {
    if (!mounted) return;
    setState(() => _labelIsLoading = true);
    try {
      final prefs = await SharedPreferences.getInstance();
      final customLabel = prefs.getString(kCustomPointsLabelKey);
      // Get localizations after checking mount status if possible
      final localizations = AppLocalizations.of(context)!;

      if (customLabel != null && customLabel.isNotEmpty) {
        _pointsLabel = customLabel;
      } else {
        // Use default from locale
        _pointsLabel = localizations.pointsPlural; // Default to plural for label
      }
    } catch (e) {
      print("Error loading points label: $e");
      final localizations = AppLocalizations.of(context)!;
      _pointsLabel = localizations.pointsPlural; // Fallback
    } finally {
      if (mounted) {
        setState(() => _labelIsLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    // Sort scores descending
    final sortedScores = widget.scores.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Scaffold(
      appBar: AppBar(
        title: Text(localizations.leaderboardTitle),
        backgroundColor: colorScheme.primaryContainer,
        automaticallyImplyLeading: false, // Remove back button
      ),
      body: Container(
        width: double.infinity,
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
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600), // Adjust max width
            child: Column(
              children: [
                Expanded(
                  // Show loading indicator for label
                  child: _labelIsLoading 
                      ? const Center(child: CircularProgressIndicator()) 
                      : ListView.builder(
                      padding: const EdgeInsets.all(16.0),
                      itemCount: sortedScores.length,
                      itemBuilder: (context, index) {
                        final entry = sortedScores[index];
                        return Card(
                          margin: const EdgeInsets.symmetric(vertical: 4.0),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: colorScheme.primary,
                              child: Text(
                                '${index + 1}', // Rank
                                style: TextStyle(color: colorScheme.onPrimary, fontWeight: FontWeight.bold),
                              ),
                            ),
                            title: Text(entry.key, style: textTheme.titleMedium),
                            trailing: Text(
                              // Use state variable for label
                              '${entry.value} $_pointsLabel', 
                              style: textTheme.titleMedium?.copyWith(color: colorScheme.secondary, fontWeight: FontWeight.bold),
                            ),
                          ),
                        );
                      },
                    ),
                ),
                // Action Buttons
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0), // Increased vertical padding
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0), // Add space between buttons
                          child: ElevatedButton(
                            onPressed: () {
                              // Pop Leaderboard to return to Game Selection
                              Navigator.pop(context);
                            },
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16), // Increase padding
                              textStyle: textTheme.titleMedium, // Slightly larger text
                            ),
                            child: Text(localizations.newQuizButton),
                          ),
                        ),
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: ElevatedButton(
                            onPressed: () {
                               // Pop Leaderboard and Game Selection to return to Player Input
                               Navigator.of(context)
                                 ..pop() // Pop LeaderboardScreen
                                 ..pop(); // Pop GameSelectionScreen
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: colorScheme.secondaryContainer,
                              foregroundColor: colorScheme.onSecondaryContainer,
                              padding: const EdgeInsets.symmetric(vertical: 16), // Increase padding
                              textStyle: textTheme.titleMedium, // Slightly larger text
                            ),
                            child: Text(localizations.differentPlayersButton),
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
} 