import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:eenden_app/main.dart'; // To access MyApp.setLocale
import 'package:eenden_app/pages/player_input_screen.dart'; // Import PlayerInputScreen again
import 'package:eenden_app/pages/settings_screen.dart'; // Import SettingsScreen

// Convert to StatefulWidget
class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  // Although locale is global, dropdown needs to know current selection
  // We get this from the context on build

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    final currentLocale = Localizations.localeOf(context); // Get current locale

    return Scaffold(
      body: Container(
        width: double.infinity, // Ensure Container fills width
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
        child: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 500),
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    // Welcome / Title text
                    Text(
                      localizations.mainTitle, // Use existing main title
                      style: textTheme.displaySmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: colorScheme.primary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 60),
                    
                    // Add Start Button
                    ElevatedButton(
                      onPressed: () {
                         // Navigate to Player Input Screen
                         Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (context) => const PlayerInputScreen()),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        textStyle: textTheme.titleLarge
                      ),
                      child: Text(localizations.startGame), // Use existing Start Game key
                    ),
                    const SizedBox(height: 40), // Spacing

                    // Add Row for Language and Settings
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Language Dropdown - Wrapped in a Container for styling
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 4.0),
                          decoration: BoxDecoration(
                            color: colorScheme.surfaceVariant.withOpacity(0.5), // Subtle background
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          child: DropdownButtonHideUnderline( // Remove underline this way
                            child: DropdownButton<Locale>(
                              value: currentLocale,
                              icon: Icon(Icons.language, color: colorScheme.onSurfaceVariant), // Match variant color
                              dropdownColor: colorScheme.surfaceVariant, // Match dropdown menu bg
                              items: const [
                                DropdownMenuItem(
                                  value: Locale('en'),
                                  child: Text('English'),
                                ),
                                DropdownMenuItem(
                                  value: Locale('nl'),
                                  child: Text('Nederlands'),
                                ),
                              ],
                              onChanged: (Locale? newLocale) {
                                if (newLocale != null) {
                                  MyApp.setLocale(context, newLocale);
                                }
                              },
                            ),
                          ),
                        ),
                        const SizedBox(width: 20), // Spacing between dropdown and button
                        // Settings Button
                        IconButton(
                          icon: const Icon(Icons.settings),
                          tooltip: 'Settings', // Localize
                          onPressed: () {
                            // Navigate to Settings page
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => const SettingsScreen()),
                            );
                          },
                        ),
                      ],
                    )
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
} 