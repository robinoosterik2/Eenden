import 'package:eenden_app/models/game.dart';

// Sample list of games
// TODO: Replace with actual game data source if needed
final List<Game> availableGames = [
  const Game(
    id: 'eenden',
    titleKey: 'gameEendenTitle', // Use keys from .arb files
    descriptionKey: 'gameEendenDescription',
    imagePath: 'assets/images/Duck-512.png', // Assuming this image exists
  ),
  // Add more games here later if needed
  // const Game(
  //   id: 'another_game',
  //   titleKey: 'gameAnotherTitle',
  //   descriptionKey: 'gameAnotherDescription',
  //   imagePath: 'assets/images/another_game_icon.png',
  // ),
]; 