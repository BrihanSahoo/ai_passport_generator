import 'dart:typed_data';
import 'dart:html' as html;
import 'dart:ui';
import 'package:flutter/material.dart';

import '../services/api_service.dart';
import '../utils/file_utils.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Uint8List? imageBytes;
  String? fileName;

  int copies = 6;
  String size = "passport";
  String bgColor = "white";
  bool bw = false;

  bool isLoading = false;

  Future<void> pickImage() async {
    final uploadInput = html.FileUploadInputElement();
    uploadInput.accept = 'image/*';
    uploadInput.click();

    uploadInput.onChange.listen((event) {
      final file = uploadInput.files?.first;
      if (file == null) return;

      final reader = html.FileReader();
      reader.readAsArrayBuffer(file);

      reader.onLoadEnd.listen((event) {
        setState(() {
          imageBytes = reader.result as Uint8List;
          fileName = file.name;
        });
      });
    });
  }

  Future<void> generate() async {
    if (imageBytes == null) return;

    setState(() => isLoading = true);

    final result = await ApiService.generateA4(
      imageBytes: imageBytes!,
      fileName: fileName ?? "image.jpg",
      copies: copies,
      size: size,
      bgColor: bgColor,
      bw: bw,
    );

    if (result != null) {
      FileUtils.downloadPdf(result);
    }

    setState(() => isLoading = false);
  }

  Widget glassCard(Widget child) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white12),
          ),
          child: child,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 700;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF0F172A), Color(0xFF020617)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1100),
              child: Column(
                children: [
                  const SizedBox(height: 20),

                  // Title
                  const Text(
                    "AI Passport Generator",
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                    ),
                  ),

                  const SizedBox(height: 30),

                  // Responsive Layout
                  isMobile
                      ? Column(
                          children: [
                            previewSection(),
                            const SizedBox(height: 20),
                            controlSection(),
                          ],
                        )
                      : Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(child: previewSection()),
                            const SizedBox(width: 20),
                            Expanded(child: controlSection()),
                          ],
                        ),

                  const SizedBox(height: 30),

                  // Generate Button
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    child: GestureDetector(
                      onTap: isLoading ? null : generate,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 50, vertical: 18),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF6366F1), Color(0xFF22D3EE)],
                          ),
                          borderRadius: BorderRadius.circular(40),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.blueAccent.withOpacity(0.5),
                              blurRadius: 25,
                            ),
                          ],
                        ),
                        child: isLoading
                            ? const CircularProgressIndicator(
                                color: Colors.white)
                            : const Text(
                                "Generate PDF",
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget previewSection() {
    return glassCard(
      Column(
        children: [
          ElevatedButton(
            onPressed: pickImage,
            child: const Text("Upload Image"),
          ),
          const SizedBox(height: 20),
          if (imageBytes != null)
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.memory(imageBytes!, height: 250),
            )
          else
            const Text("No image selected"),
        ],
      ),
    );
  }

  Widget controlSection() {
    return glassCard(
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Copies"),
          Slider(
            value: copies.toDouble(),
            min: 1,
            max: 20,
            divisions: 19,
            label: copies.toString(),
            onChanged: (val) {
              setState(() => copies = val.toInt());
            },
          ),

          const SizedBox(height: 10),

          const Text("Size"),
          DropdownButton<String>(
            value: size,
            isExpanded: true,
            items: const [
              DropdownMenuItem(value: "passport", child: Text("Passport")),
              DropdownMenuItem(value: "visa", child: Text("Visa")),
              DropdownMenuItem(value: "square", child: Text("Square")),
            ],
            onChanged: (val) {
              setState(() => size = val!);
            },
          ),

          const SizedBox(height: 10),

          const Text("Background"),
          DropdownButton<String>(
            value: bgColor,
            isExpanded: true,
            items: const [
              DropdownMenuItem(value: "white", child: Text("White")),
              DropdownMenuItem(value: "blue", child: Text("Blue")),
            ],
            onChanged: (val) {
              setState(() => bgColor = val!);
            },
          ),

          const SizedBox(height: 10),

          SwitchListTile(
            title: const Text("Black & White"),
            value: bw,
            onChanged: (val) {
              setState(() => bw = val);
            },
          ),
        ],
      ),
    );
  }
}