// import 'package:eenden_app/data/game_data.dart'; // Remove old static data import
import 'package:eenden_app/models/game.dart';
// import 'package:eenden_app/pages/player_input_screen.dart'; // No longer needed here
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:eenden_app/pages/game_play_screen.dart';

class GameSelectionScreen extends StatefulWidget { // Change to StatefulWidget
  final List<String> players;

  const GameSelectionScreen({super.key, required this.players});

  @override
  State<GameSelectionScreen> createState() => _GameSelectionScreenState();
}

class _GameSelectionScreenState extends State<GameSelectionScreen> { // Create State
  late Future<List<Game>> _gamesFuture; // Hold the future

  @override
  void initState() {
    super.initState();
    // Start loading games when the screen initializes
    _gamesFuture = Game.loadGamesFromAssets();
  }

  // Helper to get localized string using a key (can be improved)
  String _getLocalizedString(BuildContext context, String key) {
    final localizations = AppLocalizations.of(context)!;
    switch (key) {
      case 'gameEendenTitle': return localizations.gameEendenTitle;
      case 'gameEendenDescription': return localizations.gameEendenDescription;
      case 'gameOtherTitle': return localizations.gameOtherTitle;
      case 'gameOtherDescription': return localizations.gameOtherDescription;
      // Add cases for challenge keys IF needed here, otherwise handle in game screen
      default:
        print("Warning: Missing localization key: $key");
        return key; // Return key as fallback
    }
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(localizations.gameSelectionTitle),
        backgroundColor: colorScheme.primaryContainer,
      ),
      body: Container(
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
        child: FutureBuilder<List<Game>>(
          future: _gamesFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              // Show loading indicator while waiting
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              // Show error message if loading failed
              print("Error loading games: ${snapshot.error}");
              return Center(child: Text('Error loading games: ${snapshot.error}'));
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              // Show message if no games were found
              return const Center(child: Text('No games found.'));
            } else {
              // Games loaded successfully, build the list
              final games = snapshot.data!;
              return Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 700), // Adjust max width
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16.0),
                    itemCount: games.length,
                    itemBuilder: (context, index) {
                      final game = games[index];
                      return GameCard(
                        game: game,
                        title: _getLocalizedString(context, game.nameKey),
                        description: _getLocalizedString(context, game.descriptionKey),
                        onTap: () {
                          print('Starting game: ${game.id} for players: ${widget.players}');
                          // Navigate to the actual game play screen
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => GamePlayScreen(
                                game: game, // Pass the whole game object
                                players: widget.players,
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
              );
            }
          },
        ),
      ),
    );
  }
}

class GameCard extends StatelessWidget {
  final Game game;
  final String title;
  final String description;
  final VoidCallback onTap;

  const GameCard({
    super.key,
    required this.game,
    required this.title,
    required this.description,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Card(
      margin: const EdgeInsets.only(bottom: 16.0),
      clipBehavior: Clip.antiAlias, // Ensures image corners match card corners
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Game Image
            Image.asset(
              game.imagePath,
              height: 150,
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                 // Simple fallback placeholder
                return Container(
                  height: 150,
                  color: Colors.grey[300],
                  child: const Center(
                    child: Icon(Icons.image_not_supported, size: 50, color: Colors.grey),
                  ),
                );
              },
            ),
            // Game Title and Description
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    description,
                    style: textTheme.bodyMedium,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
} 