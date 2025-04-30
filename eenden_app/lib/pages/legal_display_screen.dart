import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle; // Needed for asset loading
import 'package:flutter_markdown/flutter_markdown.dart';

// Convert to StatefulWidget
class LegalDisplayScreen extends StatefulWidget {
  final String title;
  final String contentAssetPath; // Changed from content

  const LegalDisplayScreen({
    super.key, 
    required this.title, 
    required this.contentAssetPath
  });

  @override
  State<LegalDisplayScreen> createState() => _LegalDisplayScreenState();
}

class _LegalDisplayScreenState extends State<LegalDisplayScreen> {
  late Future<String> _contentFuture; // Future to hold loaded content

  @override
  void initState() {
    super.initState();
    _contentFuture = _loadContent(); // Start loading on init
  }

  Future<String> _loadContent() async {
    try {
      return await rootBundle.loadString(widget.contentAssetPath);
    } catch (e) {
      print("Error loading legal content from ${widget.contentAssetPath}: $e");
      return "Error loading content."; // Fallback error message
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title), // Access title via widget
        backgroundColor: colorScheme.primaryContainer,
      ),
      body: Container(
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
        // Use FutureBuilder to display content once loaded
        child: FutureBuilder<String>(
          future: _contentFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError || !snapshot.hasData) {
              return const Center(child: Text("Error loading content.")); // Show error
            } else {
              // Content loaded, display using Markdown
              return SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: MarkdownBody(
                  data: snapshot.data!, // Use loaded data
                  selectable: true,
                ),
              );
            }
          },
        ),
      ),
    );
  }
} 