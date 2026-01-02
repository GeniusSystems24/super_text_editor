import 'package:flutter/material.dart';

/// Represents a detected pattern in text
class TextPattern {
  /// The type of pattern
  final TextPatternType type;

  /// Start index in the text
  final int start;

  /// End index in the text
  final int end;

  /// The matched text
  final String text;

  /// The value (e.g., URL, username, hashtag)
  final String value;

  const TextPattern({
    required this.type,
    required this.start,
    required this.end,
    required this.text,
    required this.value,
  });
}

/// Types of text patterns
enum TextPatternType {
  /// URL link (http, https, www)
  url,

  /// Email address
  email,

  /// Phone number
  phone,

  /// Mention (@username)
  mention,

  /// Hashtag (#tag)
  hashtag,
}

/// Pattern matching configuration
class PatternConfig {
  /// Whether to detect URLs
  final bool detectUrls;

  /// Whether to detect emails
  final bool detectEmails;

  /// Whether to detect phone numbers
  final bool detectPhones;

  /// Whether to detect mentions
  final bool detectMentions;

  /// Whether to detect hashtags
  final bool detectHashtags;

  /// Style for URLs
  final TextStyle? urlStyle;

  /// Style for emails
  final TextStyle? emailStyle;

  /// Style for phone numbers
  final TextStyle? phoneStyle;

  /// Style for mentions
  final TextStyle? mentionStyle;

  /// Style for hashtags
  final TextStyle? hashtagStyle;

  const PatternConfig({
    this.detectUrls = true,
    this.detectEmails = true,
    this.detectPhones = false,
    this.detectMentions = true,
    this.detectHashtags = true,
    this.urlStyle,
    this.emailStyle,
    this.phoneStyle,
    this.mentionStyle,
    this.hashtagStyle,
  });

  /// Default styles
  static PatternConfig withDefaults({
    Color linkColor = Colors.blue,
    Color mentionColor = Colors.purple,
    Color hashtagColor = Colors.teal,
  }) {
    return PatternConfig(
      urlStyle: TextStyle(
        color: linkColor,
        decoration: TextDecoration.underline,
      ),
      emailStyle: TextStyle(
        color: linkColor,
        decoration: TextDecoration.underline,
      ),
      phoneStyle: TextStyle(
        color: linkColor,
        decoration: TextDecoration.underline,
      ),
      mentionStyle: TextStyle(
        color: mentionColor,
        fontWeight: FontWeight.w500,
      ),
      hashtagStyle: TextStyle(
        color: hashtagColor,
        fontWeight: FontWeight.w500,
      ),
    );
  }
}

/// Detects and matches text patterns
class TextPatternMatcher {
  TextPatternMatcher._();

  /// URL pattern
  static final RegExp urlPattern = RegExp(
    r'(?:https?:\/\/|www\.)[^\s<>\[\]{}|\\^]+',
    caseSensitive: false,
  );

  /// Email pattern
  static final RegExp emailPattern = RegExp(
    r'[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}',
    caseSensitive: false,
  );

  /// Phone pattern (various formats)
  static final RegExp phonePattern = RegExp(
    r'(?:\+?[1-9]\d{0,2}[-.\s]?)?\(?\d{2,4}\)?[-.\s]?\d{2,4}[-.\s]?\d{2,9}',
  );

  /// Mention pattern (@username)
  static final RegExp mentionPattern = RegExp(
    r'@[a-zA-Z0-9_]+',
  );

  /// Hashtag pattern (#tag)
  static final RegExp hashtagPattern = RegExp(
    r'#[a-zA-Z0-9_\u0600-\u06FF]+', // Includes Arabic characters
  );

  /// Finds all patterns in text
  static List<TextPattern> findPatterns(String text, PatternConfig config) {
    final patterns = <TextPattern>[];

    if (config.detectUrls) {
      patterns.addAll(_findMatches(text, urlPattern, TextPatternType.url));
    }

    if (config.detectEmails) {
      patterns.addAll(_findMatches(text, emailPattern, TextPatternType.email));
    }

    if (config.detectPhones) {
      patterns.addAll(_findMatches(text, phonePattern, TextPatternType.phone));
    }

    if (config.detectMentions) {
      patterns.addAll(_findMatches(text, mentionPattern, TextPatternType.mention));
    }

    if (config.detectHashtags) {
      patterns.addAll(_findMatches(text, hashtagPattern, TextPatternType.hashtag));
    }

    // Sort by start position
    patterns.sort((a, b) => a.start.compareTo(b.start));

    // Remove overlapping patterns (keep first)
    final result = <TextPattern>[];
    int lastEnd = -1;
    for (final pattern in patterns) {
      if (pattern.start >= lastEnd) {
        result.add(pattern);
        lastEnd = pattern.end;
      }
    }

    return result;
  }

  static List<TextPattern> _findMatches(
    String text,
    RegExp pattern,
    TextPatternType type,
  ) {
    return pattern.allMatches(text).map((match) {
      String value = match.group(0)!;

      // Extract value based on type
      if (type == TextPatternType.mention) {
        value = value.substring(1); // Remove @
      } else if (type == TextPatternType.hashtag) {
        value = value.substring(1); // Remove #
      }

      return TextPattern(
        type: type,
        start: match.start,
        end: match.end,
        text: match.group(0)!,
        value: value,
      );
    }).toList();
  }

  /// Builds TextSpan with pattern highlighting
  static TextSpan buildTextSpan({
    required String text,
    required PatternConfig config,
    TextStyle? baseStyle,
    void Function(TextPattern pattern)? onPatternTap,
  }) {
    final patterns = findPatterns(text, config);

    if (patterns.isEmpty) {
      return TextSpan(text: text, style: baseStyle);
    }

    final spans = <InlineSpan>[];
    int currentIndex = 0;

    for (final pattern in patterns) {
      // Add text before pattern
      if (pattern.start > currentIndex) {
        spans.add(TextSpan(
          text: text.substring(currentIndex, pattern.start),
          style: baseStyle,
        ));
      }

      // Add pattern with style
      TextStyle? patternStyle;
      switch (pattern.type) {
        case TextPatternType.url:
          patternStyle = config.urlStyle;
          break;
        case TextPatternType.email:
          patternStyle = config.emailStyle;
          break;
        case TextPatternType.phone:
          patternStyle = config.phoneStyle;
          break;
        case TextPatternType.mention:
          patternStyle = config.mentionStyle;
          break;
        case TextPatternType.hashtag:
          patternStyle = config.hashtagStyle;
          break;
      }

      spans.add(TextSpan(
        text: pattern.text,
        style: baseStyle?.merge(patternStyle) ?? patternStyle,
        // recognizer: onPatternTap != null
        //     ? (TapGestureRecognizer()..onTap = () => onPatternTap(pattern))
        //     : null,
      ));

      currentIndex = pattern.end;
    }

    // Add remaining text
    if (currentIndex < text.length) {
      spans.add(TextSpan(
        text: text.substring(currentIndex),
        style: baseStyle,
      ));
    }

    return TextSpan(children: spans);
  }
}

// TapGestureRecognizer placeholder
class TapGestureRecognizer {
  VoidCallback? onTap;
}

/// Widget for displaying suggestion popup (mentions/hashtags)
class SuggestionPopup<T> extends StatelessWidget {
  /// The suggestions to display
  final List<T> suggestions;

  /// Builder for each suggestion item
  final Widget Function(BuildContext context, T item, bool isSelected) itemBuilder;

  /// Currently selected index
  final int selectedIndex;

  /// Callback when item is selected
  final ValueChanged<T> onSelect;

  /// Maximum height of the popup
  final double maxHeight;

  const SuggestionPopup({
    super.key,
    required this.suggestions,
    required this.itemBuilder,
    this.selectedIndex = 0,
    required this.onSelect,
    this.maxHeight = 200,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (suggestions.isEmpty) {
      return const SizedBox.shrink();
    }

    return Material(
      elevation: 8,
      borderRadius: BorderRadius.circular(8),
      child: ConstrainedBox(
        constraints: BoxConstraints(maxHeight: maxHeight),
        child: ListView.builder(
          shrinkWrap: true,
          padding: const EdgeInsets.symmetric(vertical: 4),
          itemCount: suggestions.length,
          itemBuilder: (context, index) {
            final item = suggestions[index];
            final isSelected = index == selectedIndex;

            return InkWell(
              onTap: () => onSelect(item),
              child: Container(
                color: isSelected
                    ? theme.colorScheme.primaryContainer.withValues(alpha: 0.3)
                    : null,
                child: itemBuilder(context, item, isSelected),
              ),
            );
          },
        ),
      ),
    );
  }
}

/// A suggestion item for mentions
class MentionSuggestion {
  /// Unique identifier
  final String id;

  /// Display name
  final String name;

  /// Username (without @)
  final String username;

  /// Avatar URL
  final String? avatarUrl;

  const MentionSuggestion({
    required this.id,
    required this.name,
    required this.username,
    this.avatarUrl,
  });
}

/// Default mention suggestion item builder
Widget buildMentionSuggestionItem(
  BuildContext context,
  MentionSuggestion item,
  bool isSelected,
) {
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    child: Row(
      children: [
        CircleAvatar(
          radius: 16,
          backgroundImage: item.avatarUrl != null
              ? NetworkImage(item.avatarUrl!)
              : null,
          child: item.avatarUrl == null
              ? Text(item.name[0].toUpperCase())
              : null,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                item.name,
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
              Text(
                '@${item.username}',
                style: TextStyle(
                  fontSize: 12,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

/// A suggestion item for hashtags
class HashtagSuggestion {
  /// The hashtag (without #)
  final String tag;

  /// Usage count
  final int? usageCount;

  const HashtagSuggestion({
    required this.tag,
    this.usageCount,
  });
}

/// Default hashtag suggestion item builder
Widget buildHashtagSuggestionItem(
  BuildContext context,
  HashtagSuggestion item,
  bool isSelected,
) {
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    child: Row(
      children: [
        const Icon(Icons.tag, size: 20),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            item.tag,
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
        ),
        if (item.usageCount != null)
          Text(
            '${item.usageCount} posts',
            style: TextStyle(
              fontSize: 12,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
      ],
    ),
  );
}
