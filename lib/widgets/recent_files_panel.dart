import 'package:flutter/material.dart';

class RecentFilesPanel extends StatelessWidget {
  final List<String> files;
  final Function(String filePath) onTap;

  const RecentFilesPanel({
    super.key,
    required this.files,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.all(8.0),
          child: Text(
            "Recent Files",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
        ...files.map((file) => ListTile(
              leading: const Icon(Icons.picture_as_pdf),
              title: Text(file.split('/').last),
              onTap: () => onTap(file),
            )),
      ],
    );
  }
}
