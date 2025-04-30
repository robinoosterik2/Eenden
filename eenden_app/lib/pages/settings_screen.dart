import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:eenden_app/pages/legal_display_screen.dart';

// Key for storing the custom points label
const String kCustomPointsLabelKey = 'custom_points_label';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final TextEditingController _pointsLabelController = TextEditingController();
  bool _isLoading = true;
  bool _isEditingLabel = false;
  String _initialLabelValue = "";

  @override
  void initState() {
    super.initState();
    _loadCurrentLabel();
  }

  @override
  void dispose() {
    _pointsLabelController.dispose();
    super.dispose();
  }

  Future<void> _loadCurrentLabel() async {
    setState(() => _isLoading = true);
    try {
      final prefs = await SharedPreferences.getInstance();
      final currentLabel = prefs.getString(kCustomPointsLabelKey) ?? '';
      _pointsLabelController.text = currentLabel;
      _initialLabelValue = currentLabel;
    } catch (e) {
      print("Error loading points label: $e");
    } finally {
       if (mounted) {
         setState(() => _isLoading = false);
       }
    }
  }

  Future<void> _saveLabel() async {
    if (_isLoading) return;

    final newLabel = _pointsLabelController.text.trim();
    setState(() => _isLoading = true);
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(kCustomPointsLabelKey, newLabel);
      _initialLabelValue = newLabel;
      if (mounted) {
           ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Label saved.'), duration: Duration(seconds: 1)),
          );
           setState(() {
             _isEditingLabel = false; 
             _isLoading = false;
           }); 
      }
    } catch (e) {
       print("Error saving points label: $e");
       if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Error saving label.')),
            );
            setState(() => _isLoading = false); 
       }
    }
  }

  void _cancelEdit() {
    setState(() {
      _pointsLabelController.text = _initialLabelValue;
      _isEditingLabel = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    // Determine the display label (or default if empty)
    String displayLabel = _pointsLabelController.text.trim();
    if (displayLabel.isEmpty) {
      displayLabel = localizations.pointsPlural; // Use default plural
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(localizations.settingsTitle),
        backgroundColor: colorScheme.primaryContainer,
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
        child: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 600),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator()) // Center loader
                    : ListView(
                        children: [
                          ListTile(
                            contentPadding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 0),
                            title: Text(
                              localizations.customPointsLabelSetting,
                              style: textTheme.titleLarge,
                            ),
                            subtitle: _isEditingLabel
                              ? _buildEditingView(localizations, colorScheme, textTheme)
                              : _buildDisplayView(displayLabel, localizations, colorScheme, textTheme),
                            trailing: !_isEditingLabel
                              ? null // No edit icon needed here anymore
                              : null,
                          ),
                           const Divider(height: 32, thickness: 1),
                           // Legal Links Section
                           ListTile(
                              leading: const Icon(Icons.gavel_outlined), // Icon for terms
                              title: Text(localizations.termsAndConditions),
                              trailing: const Icon(Icons.chevron_right), // Indicate navigation
                              onTap: () {
                                // Navigate to display screen with T&C content
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) => LegalDisplayScreen(
                                      title: localizations.termsAndConditions,
                                      contentAssetPath: localizations.termsContentPath,
                                  )),
                                );
                              },
                           ),
                           ListTile(
                              leading: const Icon(Icons.privacy_tip_outlined), // Icon for privacy
                              title: Text(localizations.privacyPolicy),
                              trailing: const Icon(Icons.chevron_right), // Indicate navigation
                              onTap: () {
                                // Navigate to display screen with Privacy Policy content
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) => LegalDisplayScreen(
                                      title: localizations.privacyPolicy,
                                      contentAssetPath: localizations.privacyPolicyPath,
                                  )),
                                );
                              },
                           ),
                           // Add more settings/links below if needed
                        ],
                      ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Helper Widget for Display View
  Widget _buildDisplayView(String displayLabel, AppLocalizations localizations, ColorScheme colorScheme, TextTheme textTheme) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        setState(() => _isEditingLabel = true);
      },
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0), 
          margin: const EdgeInsets.only(top: 8.0),
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainerLowest,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: colorScheme.outlineVariant),
            boxShadow: [
              BoxShadow(
                color: colorScheme.shadow.withOpacity(0.05),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center, 
                    children: [
                        Text(
                            displayLabel,
                            style: textTheme.bodyLarge?.copyWith(
                              color: colorScheme.onSurface,
                              fontWeight: FontWeight.w500,
                            ),
                             maxLines: 1, 
                            overflow: TextOverflow.ellipsis, 
                        ),
                    ],
                ),
              ),
              const SizedBox(width: 8),
              Icon(
                Icons.edit_outlined,
                color: colorScheme.onSurfaceVariant,
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Helper Widget for Editing View
  Widget _buildEditingView(AppLocalizations localizations, ColorScheme colorScheme, TextTheme textTheme) {
    final hintText = localizations.tapToEditLabelHint;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 8),
        TextField(
          controller: _pointsLabelController,
          decoration: InputDecoration(
            hintText: hintText,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: colorScheme.outline),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: colorScheme.outlineVariant),
            ),
            filled: true,
            fillColor: colorScheme.surfaceContainerLowest,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
          autofocus: true,
          onSubmitted: (_) => _saveLabel(),
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            OutlinedButton(
              onPressed: _cancelEdit,
              style: OutlinedButton.styleFrom(
                foregroundColor: colorScheme.onSurface,
              ),
              child: Text(localizations.cancel),
            ),
            const SizedBox(width: 8),
            ElevatedButton(
              onPressed: _saveLabel,
              child: Text(localizations.save),
            ),
          ],
        )
      ],
    );
  }
} 