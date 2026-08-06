import 'package:flutter/material.dart';
import '../../../models/field_catalog.dart';
import '../../../models/narrow_topic.dart';
import '../../../theme/app_colors.dart';
import '../../common/markdown_text.dart';

class IntersectionTab extends StatelessWidget {
  final NarrowTopic topic;
  final List<String> fields;
  final String language;

  const IntersectionTab({
    super.key,
    required this.topic,
    required this.fields,
    required this.language,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: fields.map((fieldId) {
              return Chip(
                label: Text(
                  fieldLabel(fieldId, language),
                  style: const TextStyle(fontSize: 12),
                ),
                backgroundColor: colors.teal.withValues(alpha: 0.10),
                side: BorderSide(color: colors.teal.withValues(alpha: 0.3)),
                visualDensity: VisualDensity.compact,
              );
            }).toList(),
          ),
          const SizedBox(height: 16),
          MarkdownText(topic.fieldsIntersectionExplanation),
        ],
      ),
    );
  }
}
