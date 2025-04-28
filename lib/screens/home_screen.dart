import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:url_launcher/url_launcher.dart';
import '../service/text_extraction_service.dart';
import '../widgets/action_button.dart';
import '../service/GeminiService.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  File? _image;
  String _extractedText = '';
  bool _isLoading = false;

  Future<void> _pickImage(ImageSource source) async {
    final pickedFile = await ImagePicker().pickImage(source: source);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
        _extractedText = '';
      });
      await _extractText(pickedFile.path);
    }
  }

  Future<void> _extractText(String imagePath) async {
    setState(() {
      _isLoading = true;
    });
    final extractedText =
        await TextExtractionService.extractTextFromImage(imagePath);
    setState(() {
      _extractedText = extractedText;
      _isLoading = false;
    });
  }

  void _copyToClipboard() {
    if (_extractedText.isEmpty) return;
    Clipboard.setData(ClipboardData(text: _extractedText));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Copied to Clipboard')),
    );
  }

  Future<void> _searchOnGoogle() async {
    if (_extractedText.isEmpty) return;
    final query = Uri.encodeComponent(_extractedText);
    final url = 'https://www.google.com/search?q=$query';
    // final url = 'https://www.google.com/search?q=utkarshBhatt';
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url));
    }
  }

  Future<void> _translateText() async {
    if (_extractedText.isEmpty) return;
    final text = Uri.encodeComponent(_extractedText);
    final url = 'https://translate.google.com/?text=$text';
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url));
    }
  }

  Future<void> _askGeminiAboutExtractedText() async {
    showDialog(
      context: context,
      builder: (context) => const Center(child: CircularProgressIndicator()),
      barrierDismissible: false,
    );

    final geminiResponse =
        await GeminiService.askGemini("Explain more about: $_extractedText");

    Navigator.pop(context);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Gemini Response'),
        content: SingleChildScrollView(
          child: Text(geminiResponse),
        ),
        actions: [
          TextButton(
            child: const Text('Close'),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Text Extractor App'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton.icon(
                    icon: const Icon(Icons.camera_alt),
                    label: const Text('Camera'),
                    onPressed: () => _pickImage(ImageSource.camera),
                  ),
                  const SizedBox(width: 16),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.photo_library),
                    label: const Text('Gallery'),
                    onPressed: () => _pickImage(ImageSource.gallery),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  // Display picked image
                  if (_image != null)
                    Card(
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Image.file(
                        _image!,
                        height: 200,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
                    ),
                  const SizedBox(height: 16),
                  if (_isLoading)
                    const Center(child: CircularProgressIndicator())
                  else
                    Card(
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Text(
                          _extractedText.isEmpty
                              ? 'No text extracted yet.'
                              : _extractedText,
                          style: const TextStyle(fontSize: 16),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (_extractedText.isNotEmpty)
              ElevatedButton(
                onPressed: _askGeminiAboutExtractedText,
                child: const Text('Ask Gemini for More Info'),
              ),
            const SizedBox(height: 8),
            ActionButtons(
              onCopy: _extractedText.isEmpty ? null : _copyToClipboard,
              onSearch: _extractedText.isEmpty ? null : _searchOnGoogle,
              onTranslate: _extractedText.isEmpty ? null : _translateText,
            ),
          ],
        ),
      ),
    );
  }
}
