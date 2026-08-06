import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:markdown/markdown.dart' as md;
import 'package:url_launcher/url_launcher.dart';
import 'package:html_unescape/html_unescape.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';

final _unescape = HtmlUnescape();

/// Shared renderer for every AI-generated prose field (pitch,
/// whyFitsAllFields, levelNotes, fieldsIntersectionExplanation, relevance,
/// outline descriptions, refinementSummary, clarifyingQuestion). GFM
/// extensions enabled, custom styling pulled from the app theme, with an
/// entity-decoding safety net in case a raw entity ever slips through.
class MarkdownText extends StatelessWidget {
  final String data;
  final TextAlign textAlign;

  const MarkdownText(this.data, {super.key, this.textAlign = TextAlign.start});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final safeData = _unescape.convert(data);

    return MarkdownBody(
      data: safeData,
      selectable: true,
      extensionSet: md.ExtensionSet.gitHubFlavored,
      onTapLink: (text, href, title) {
        if (href == null) return;
        launchUrl(Uri.parse(href), mode: LaunchMode.externalApplication);
      },
      styleSheet: MarkdownStyleSheet(
        p: AppTypography.sans(
          fontSize: 15,
          color: colors.ink,
        ).copyWith(height: 1.55),
        strong: AppTypography.sans(
          weight: FontWeight.w700,
          fontSize: 15,
          color: colors.ink,
        ),
        em: AppTypography.sans(
          fontSize: 15,
          color: colors.ink,
        ).copyWith(fontStyle: FontStyle.italic),
        listBullet: AppTypography.sans(fontSize: 15, color: colors.inkMuted),
        a: AppTypography.sans(
          weight: FontWeight.w600,
          fontSize: 15,
          color: colors.teal,
        ).copyWith(decoration: TextDecoration.underline),
        blockquote: AppTypography.serif(
          style: FontStyle.italic,
          fontSize: 16,
          color: colors.inkMuted,
        ),
        blockquoteDecoration: BoxDecoration(
          color: colors.parchment,
          border: Border(left: BorderSide(color: colors.amber, width: 3)),
        ),
        code: AppTypography.mono(
          fontSize: 13,
          color: colors.ink,
        ).copyWith(backgroundColor: colors.parchment),
        codeblockDecoration: BoxDecoration(
          color: colors.parchment,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: colors.border),
        ),
        h1: AppTypography.serif(fontSize: 22, color: colors.ink),
        h2: AppTypography.serif(fontSize: 19, color: colors.ink),
        h3: AppTypography.serif(fontSize: 17, color: colors.ink),
      ),
    );
  }
}
