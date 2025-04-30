import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:eenden_app/pages/game_selection_screen.dart';

// Keep the String capitalize extension for use in this file
extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${substring(1).toLowerCase()}";
  }
}

class PlayerInputScreen extends StatefulWidget {
  const PlayerInputScreen({super.key});

  @override
  State<PlayerInputScreen> createState() => _PlayerInputScreenState();
}

class _PlayerInputScreenState extends State<PlayerInputScreen> {
  final List<String> _players = [];
  final TextEditingController _nameController = TextEditingController();
  final FocusNode _nameFieldFocus = FocusNode();

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.redAccent,
      ),
    );
  }

  void _addPlayer() {
    final localizations = AppLocalizations.of(context)!;
    String name = _nameController.text.trim();

    if (name.isEmpty) {
      _showErrorSnackBar(localizations.errorNameEmpty);
      return;
    }

    if (!RegExp(r'^[a-zA-Z]').hasMatch(name)) {
      _showErrorSnackBar(localizations.errorNameNotLetter);
      return;
    }

    name = name.capitalize();

    if (_players.contains(name)) {
      _showErrorSnackBar(localizations.errorNameDuplicate(name));
    } else {
      setState(() {
        _players.add(name);
        _nameController.clear();
        _nameFieldFocus.requestFocus();
      });
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _nameFieldFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final bool isSmallScreen = screenSize.width < 600;
    final localizations = AppLocalizations.of(context)!;
    
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Theme.of(context).colorScheme.primaryContainer.withOpacity(0.3),
              Theme.of(context).colorScheme.surface,
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 600),
              child: Padding(
                padding: EdgeInsets.all(isSmallScreen ? 16.0 : 24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    _buildHeader(context, localizations),
                    
                    SizedBox(height: isSmallScreen ? 20.0 : 30.0),
                    
                    _buildInputSection(isSmallScreen, localizations),
                    
                    SizedBox(height: isSmallScreen ? 16.0 : 24.0),
                    
                    Expanded(
                      child: _buildPlayersList(context, localizations),
                    ),
                    
                    SizedBox(height: isSmallScreen ? 16.0 : 20.0),
                    
                    _buildStartButton(context, localizations),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, AppLocalizations localizations) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                'images/Duck-512.png',
                height: 60,
                errorBuilder: (context, error, stackTrace) {
                  return const Icon(Icons.pets, size: 60, color: Colors.amber);
                },
              ),
              const SizedBox(width: 16),
              Text(
                localizations.addPlayersTitle,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildInputSection(bool isSmallScreen, AppLocalizations localizations) {
    if (isSmallScreen) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextField(
            controller: _nameController,
            focusNode: _nameFieldFocus,
            decoration: InputDecoration(
              labelText: localizations.playerNameHint,
              hintText: localizations.playerNameHint,
              prefixIcon: const Icon(Icons.person_add_outlined),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              filled: true,
              fillColor: Colors.white,
            ),
            onSubmitted: (_) => _addPlayer(),
          ),
          const SizedBox(height: 12),
          ElevatedButton.icon(
            onPressed: _addPlayer,
            icon: const Icon(Icons.add),
            label: Text(localizations.addPlayerButton),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      );
    } else {
      return Row(
        children: <Widget>[
          Expanded(
            child: TextField(
              controller: _nameController,
              focusNode: _nameFieldFocus,
              decoration: InputDecoration(
                labelText: localizations.playerNameHint,
                hintText: localizations.playerNameHint,
                prefixIcon: const Icon(Icons.person_add_outlined),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Colors.white,
              ),
              onSubmitted: (_) => _addPlayer(),
            ),
          ),
          const SizedBox(width: 12),
          ElevatedButton.icon(
            onPressed: _addPlayer,
            icon: const Icon(Icons.add),
            label: Text(localizations.addPlayerButton),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      );
    }
  }

  Widget _buildPlayersList(BuildContext context, AppLocalizations localizations) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Icon(
                  Icons.group,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  localizations.playersListTitle,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                const Spacer(),
                Text(
                  localizations.playerCount(_players.length),
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: _players.isEmpty
                ? _buildEmptyPlayersList(context, localizations)
                : ListView.builder(
                    itemCount: _players.length,
                    itemBuilder: (context, index) {
                      return _buildPlayerTile(context, index);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyPlayersList(BuildContext context, AppLocalizations localizations) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.person_search,
            size: 48,
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.3),
          ),
          const SizedBox(height: 16),
          Text(
            localizations.noPlayersYet,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            localizations.addPlayersPrompt,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.4),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlayerTile(BuildContext context, int index) {
    return ListTile(
		leading: CircleAvatar(
			backgroundColor: Colors.transparent,
			child: SvgPicture.asset(
				'assets/images/Player-icon.svg',
				colorFilter: ColorFilter.mode(getPlayerColor(index), BlendMode.srcIn),
				width: 30,
				height: 30,
			),
		),
      title: Text(
        _players[index],
        style: const TextStyle(fontWeight: FontWeight.w500),
      ),
      trailing: IconButton(
        icon: const Icon(Icons.delete_outline),
        color: Colors.redAccent,
        onPressed: () {
          setState(() {
            _players.removeAt(index);
          });
        },
      ),
    );
  }

  Color getPlayerColor(int index) {
    final List<Color> colors = [
      Colors.blue,
      Colors.red,
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.teal,
      Colors.pink,
      Colors.indigo,
    ];
    return colors[index % colors.length];
  }

  Widget _buildStartButton(BuildContext context, AppLocalizations localizations) {
    final bool canStart = _players.length >= 2;
    
    return ElevatedButton.icon(
      onPressed: canStart
          ? () {
              print('Proceeding to game selection with players: $_players');
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => GameSelectionScreen(players: _players),
                ),
              );
            }
          : null,
      icon: const Icon(Icons.play_arrow),
      label: Text(localizations.startGame),
      style: ElevatedButton.styleFrom(
        backgroundColor: canStart 
            ? Theme.of(context).colorScheme.primary 
            : null,
        foregroundColor: canStart 
            ? Colors.white 
            : null,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        disabledBackgroundColor: 
            Theme.of(context).colorScheme.onSurface.withOpacity(0.12),
      ),
    );
  }
}