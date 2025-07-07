import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:signature/signature.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

/// A page that lets the user draw with a pen, save the result, or send
/// the image to the Gemini API to create a refined version.
class DrawingPage extends StatefulWidget {
  const DrawingPage({super.key});

  @override
  State<DrawingPage> createState() => _DrawingPageState();
}

class _DrawingPageState extends State<DrawingPage> {
  late SignatureController _controller;
  Color _penColor = Colors.black;
  double _penWidth = 3;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _controller = SignatureController(
      penStrokeWidth: _penWidth,
      penColor: _penColor,
      exportBackgroundColor: Colors.white,
    );
  }

  void _updateController() {
    final points = _controller.points;
    _controller.dispose();
    _controller = SignatureController(
      points: points,
      penStrokeWidth: _penWidth,
      penColor: _penColor,
      exportBackgroundColor: Colors.white,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final bytes = await _controller.toPngBytes();
    if (bytes == null) return;

    // Request permissions if necessary.
    final status = await Permission.storage.request();
    if (!status.isGranted) return;

    final tempDir = await getTemporaryDirectory();
    final filePath =
        '${tempDir.path}/drawing_${DateTime.now().millisecondsSinceEpoch}.png';
    final file = await File(filePath).writeAsBytes(bytes);
    await ImageGallerySaver.saveFile(file.path);

    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('保存しました')));
  }

  Future<void> _toGemini() async {
    final bytes = await _controller.toPngBytes();
    if (bytes == null) return;

    const apiKey = 'YOUR_GEMINI_API_KEY';
    final model = GenerativeModel(model: 'gemini-pro-vision', apiKey: apiKey);

    final content = [
      Content.multi([
        DataPart('image/png', bytes),
        TextPart('Refine this sketch into a colorful digital illustration.'),
      ]),
    ];

    setState(() => _loading = true);
    try {
      final response = await model.generateContent(content);
      if (!mounted || response.candidates.isEmpty) return;

      final part = response.candidates.first.content.parts.first;
      Uri? imageUri;
      if (part is FilePart) {
        imageUri = part.uri;
      }
      if (imageUri == null) return;

      if (!mounted) return;
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => GeneratedImageView(url: imageUri!)),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('AI お絵描き')),
      body: Column(
        children: [
          Expanded(
            child: Stack(
              children: [
                Signature(
                  controller: _controller,
                  backgroundColor: Colors.white,
                ),
                if (_loading)
                  const ColoredBox(
                    color: Colors.black45,
                    child: Center(child: CircularProgressIndicator()),
                  ),
              ],
            ),
          ),
          _buildToolbar(),
        ],
      ),
    );
  }

  Widget _buildToolbar() => Container(
    color: Colors.grey.shade100,
    padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
    child: Row(
      children: [
        IconButton(icon: const Icon(Icons.color_lens), onPressed: _pickColor),
        Expanded(
          child: Slider(
            value: _penWidth,
            min: 1,
            max: 10,
            onChanged: (v) => setState(() {
              _penWidth = v;
              _updateController();
            }),
          ),
        ),
        IconButton(icon: const Icon(Icons.clear), onPressed: _controller.clear),
        const Spacer(),
        IconButton(icon: const Icon(Icons.save), onPressed: _save),
        IconButton(icon: const Icon(Icons.auto_awesome), onPressed: _toGemini),
      ],
    ),
  );

  void _pickColor() => showDialog<void>(
    context: context,
    builder: (_) => AlertDialog(
      title: const Text('ペンの色'),
      content: SingleChildScrollView(
        child: BlockPicker(
          pickerColor: _penColor,
          onColorChanged: (c) => setState(() {
            _penColor = c;
            _updateController();
          }),
        ),
      ),
    ),
  );
}

/// Simple page to show the image generated by Gemini.
class GeneratedImageView extends StatelessWidget {
  final Uri url;
  const GeneratedImageView({required this.url, super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('生成イラスト')),
    body: Center(child: Image.network(url.toString())),
  );
}
