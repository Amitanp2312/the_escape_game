import 'package:flutter/material.dart';

import '../utils/constants.dart';
import '../widgets/neon_scaffold.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return NeonScaffold(
      title: 'About',
      child: ListView(
        padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
        children: const [
          _AboutRow(label: 'Game', value: AppInfo.gameTitle),
          _AboutRow(label: 'Project Type', value: AppInfo.projectType),
          _AboutRow(label: 'Technology', value: AppInfo.technology),
          _AboutRow(label: 'Developer', value: AppInfo.developerName),
          SizedBox(height: 16),
          Text(
            'Description',
            style: TextStyle(
              color: NeonColors.cyan,
              fontWeight: FontWeight.w800,
            ),
          ),
          SizedBox(height: 8),
          Text(
            AppInfo.description,
            style: TextStyle(
              color: NeonColors.text,
              height: 1.45,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }
}

class _AboutRow extends StatelessWidget {
  const _AboutRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: NeonColors.mutedText,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              color: NeonColors.text,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
