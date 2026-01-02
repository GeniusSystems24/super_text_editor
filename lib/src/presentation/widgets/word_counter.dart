import 'package:flutter/material.dart';
import '../editor/super_editor_controller.dart';

/// Statistics about the editor content
class EditorStats {
  /// Number of characters (including spaces)
  final int characters;

  /// Number of characters (excluding spaces)
  final int charactersNoSpaces;

  /// Number of words
  final int words;

  /// Number of sentences
  final int sentences;

  /// Number of paragraphs
  final int paragraphs;

  /// Number of lines
  final int lines;

  /// Estimated reading time in minutes
  final double readingTime;

  /// Estimated speaking time in minutes
  final double speakingTime;

  const EditorStats({
    this.characters = 0,
    this.charactersNoSpaces = 0,
    this.words = 0,
    this.sentences = 0,
    this.paragraphs = 0,
    this.lines = 0,
    this.readingTime = 0,
    this.speakingTime = 0,
  });

  /// Creates stats from text
  factory EditorStats.fromText(String text) {
    if (text.isEmpty) {
      return const EditorStats();
    }

    final characters = text.length;
    final charactersNoSpaces = text.replaceAll(RegExp(r'\s'), '').length;

    // Count words (sequences of non-whitespace)
    final wordMatches = RegExp(r'\S+').allMatches(text);
    final words = wordMatches.length;

    // Count sentences (ending with . ! ?)
    final sentenceMatches = RegExp(r'[.!?]+').allMatches(text);
    final sentences = sentenceMatches.isEmpty ? (text.trim().isEmpty ? 0 : 1) : sentenceMatches.length;

    // Count paragraphs (non-empty lines separated by blank lines)
    final paragraphMatches = text.split(RegExp(r'\n\s*\n'));
    final paragraphs = paragraphMatches.where((p) => p.trim().isNotEmpty).length;

    // Count lines
    final lines = text.split('\n').length;

    // Estimate reading time (average 200 words per minute)
    final readingTime = words / 200;

    // Estimate speaking time (average 150 words per minute)
    final speakingTime = words / 150;

    return EditorStats(
      characters: characters,
      charactersNoSpaces: charactersNoSpaces,
      words: words,
      sentences: sentences,
      paragraphs: paragraphs,
      lines: lines,
      readingTime: readingTime,
      speakingTime: speakingTime,
    );
  }

  /// Formats reading time as string
  String get readingTimeFormatted {
    if (readingTime < 1) {
      return '< 1 min read';
    }
    return '${readingTime.ceil()} min read';
  }

  /// Formats speaking time as string
  String get speakingTimeFormatted {
    if (speakingTime < 1) {
      return '< 1 min speak';
    }
    return '${speakingTime.ceil()} min speak';
  }
}

/// Display mode for word counter
enum WordCounterMode {
  /// Show only word count
  minimal,

  /// Show word and character count
  compact,

  /// Show all statistics
  detailed,
}

/// A widget that displays word/character count and other statistics
class WordCounter extends StatelessWidget {
  /// The editor controller to monitor
  final SuperEditorController controller;

  /// Display mode
  final WordCounterMode mode;

  /// Text style for the counter
  final TextStyle? textStyle;

  /// Background color
  final Color? backgroundColor;

  /// Padding
  final EdgeInsets padding;

  /// Whether to show in a card
  final bool showCard;

  const WordCounter({
    super.key,
    required this.controller,
    this.mode = WordCounterMode.compact,
    this.textStyle,
    this.backgroundColor,
    this.padding = const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
    this.showCard = false,
  });

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) {
        final stats = EditorStats.fromText(controller.plainText);
        return _buildCounter(context, stats);
      },
    );
  }

  Widget _buildCounter(BuildContext context, EditorStats stats) {
    final theme = Theme.of(context);
    final style = textStyle ?? theme.textTheme.bodySmall?.copyWith(
      color: theme.colorScheme.onSurfaceVariant,
    );

    Widget content;

    switch (mode) {
      case WordCounterMode.minimal:
        content = Text(
          '${stats.words} words',
          style: style,
        );
        break;

      case WordCounterMode.compact:
        content = Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('${stats.words} words', style: style),
            _divider(theme),
            Text('${stats.characters} chars', style: style),
          ],
        );
        break;

      case WordCounterMode.detailed:
        content = Wrap(
          spacing: 8,
          runSpacing: 4,
          children: [
            _statChip(theme, Icons.text_fields, '${stats.words} words'),
            _statChip(theme, Icons.abc, '${stats.characters} chars'),
            _statChip(theme, Icons.short_text, '${stats.sentences} sentences'),
            _statChip(theme, Icons.notes, '${stats.paragraphs} paragraphs'),
            _statChip(theme, Icons.timer, stats.readingTimeFormatted),
          ],
        );
        break;
    }

    if (showCard) {
      return Card(
        margin: EdgeInsets.zero,
        child: Padding(
          padding: padding,
          child: content,
        ),
      );
    }

    return Container(
      padding: padding,
      color: backgroundColor,
      child: content,
    );
  }

  Widget _divider(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Text(
        '|',
        style: TextStyle(color: theme.dividerColor),
      ),
    );
  }

  Widget _statChip(ThemeData theme, IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: theme.colorScheme.onSurfaceVariant),
          const SizedBox(width: 4),
          Text(
            text,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

/// A dialog showing detailed statistics
class StatsDialog extends StatelessWidget {
  /// The editor statistics
  final EditorStats stats;

  const StatsDialog({
    super.key,
    required this.stats,
  });

  /// Shows the stats dialog
  static Future<void> show(BuildContext context, EditorStats stats) {
    return showDialog(
      context: context,
      builder: (context) => StatsDialog(stats: stats),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AlertDialog(
      title: const Row(
        children: [
          Icon(Icons.analytics),
          SizedBox(width: 8),
          Text('Document Statistics'),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildStatRow(context, 'Words', stats.words.toString()),
          _buildStatRow(context, 'Characters', stats.characters.toString()),
          _buildStatRow(context, 'Characters (no spaces)', stats.charactersNoSpaces.toString()),
          _buildStatRow(context, 'Sentences', stats.sentences.toString()),
          _buildStatRow(context, 'Paragraphs', stats.paragraphs.toString()),
          _buildStatRow(context, 'Lines', stats.lines.toString()),
          const Divider(),
          _buildStatRow(context, 'Reading time', stats.readingTimeFormatted),
          _buildStatRow(context, 'Speaking time', stats.speakingTimeFormatted),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Close'),
        ),
      ],
    );
  }

  Widget _buildStatRow(BuildContext context, String label, String value) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: theme.textTheme.bodyMedium),
          Text(
            value,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
