import 'package:flutter/material.dart';

class FloatingToolbox extends StatelessWidget {
  final void Function()? onEditText;
  final void Function()? onAddText;
  final void Function()? onAddImage;
  final void Function()? onOCR;

  const FloatingToolbox({
    super.key,
    this.onEditText,
    this.onAddText,
    this.onAddImage,
    this.onOCR,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 6,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Wrap(
          spacing: 12,
          children: [
            IconButton(icon: const Icon(Icons.edit), onPressed: onEditText),
            IconButton(
                icon: const Icon(Icons.text_fields), onPressed: onAddText),
            IconButton(icon: const Icon(Icons.image), onPressed: onAddImage),
            IconButton(
                icon: const Icon(Icons.document_scanner), onPressed: onOCR),
          ],
        ),
      ),
    );
  }
}
