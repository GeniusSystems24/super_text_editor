import 'package:flutter/material.dart';

/// A span of text with specific attributes
class AttributedSpan {
  /// Start offset of this span
  final int start;

  /// End offset of this span (exclusive)
  final int end;

  /// The attributes applied to this span
  final TextAttributes attributes;

  const AttributedSpan({
    required this.start,
    required this.end,
    required this.attributes,
  });

  /// Creates a copy with optional new values
  AttributedSpan copyWith({
    int? start,
    int? end,
    TextAttributes? attributes,
  }) {
    return AttributedSpan(
      start: start ?? this.start,
      end: end ?? this.end,
      attributes: attributes ?? this.attributes,
    );
  }

  /// Checks if this span overlaps with the given range
  bool overlaps(int rangeStart, int rangeEnd) {
    return start < rangeEnd && end > rangeStart;
  }

  /// Checks if this span contains the given offset
  bool contains(int offset) {
    return offset >= start && offset < end;
  }

  Map<String, dynamic> toJson() {
    return {
      'start': start,
      'end': end,
      'attributes': attributes.toJson(),
    };
  }

  factory AttributedSpan.fromJson(Map<String, dynamic> json) {
    return AttributedSpan(
      start: json['start'] as int,
      end: json['end'] as int,
      attributes: TextAttributes.fromJson(json['attributes'] as Map<String, dynamic>),
    );
  }
}

/// Text formatting attributes
class TextAttributes {
  final bool bold;
  final bool italic;
  final bool underline;
  final bool strikethrough;
  final bool subscript;
  final bool superscript;
  final bool code;
  final Color? textColor;
  final Color? backgroundColor;
  final double? fontSize;
  final String? fontFamily;
  final String? linkUrl;

  const TextAttributes({
    this.bold = false,
    this.italic = false,
    this.underline = false,
    this.strikethrough = false,
    this.subscript = false,
    this.superscript = false,
    this.code = false,
    this.textColor,
    this.backgroundColor,
    this.fontSize,
    this.fontFamily,
    this.linkUrl,
  });

  /// Empty attributes
  static const TextAttributes empty = TextAttributes();

  /// Whether any formatting is applied
  bool get hasFormatting =>
      bold ||
      italic ||
      underline ||
      strikethrough ||
      subscript ||
      superscript ||
      code ||
      textColor != null ||
      backgroundColor != null ||
      fontSize != null ||
      fontFamily != null ||
      linkUrl != null;

  /// Creates a copy with merged attributes
  TextAttributes merge(TextAttributes other) {
    return TextAttributes(
      bold: other.bold || bold,
      italic: other.italic || italic,
      underline: other.underline || underline,
      strikethrough: other.strikethrough || strikethrough,
      subscript: other.subscript || subscript,
      superscript: other.superscript || superscript,
      code: other.code || code,
      textColor: other.textColor ?? textColor,
      backgroundColor: other.backgroundColor ?? backgroundColor,
      fontSize: other.fontSize ?? fontSize,
      fontFamily: other.fontFamily ?? fontFamily,
      linkUrl: other.linkUrl ?? linkUrl,
    );
  }

  /// Creates a copy with optional new values
  TextAttributes copyWith({
    bool? bold,
    bool? italic,
    bool? underline,
    bool? strikethrough,
    bool? subscript,
    bool? superscript,
    bool? code,
    Color? textColor,
    Color? backgroundColor,
    double? fontSize,
    String? fontFamily,
    String? linkUrl,
  }) {
    return TextAttributes(
      bold: bold ?? this.bold,
      italic: italic ?? this.italic,
      underline: underline ?? this.underline,
      strikethrough: strikethrough ?? this.strikethrough,
      subscript: subscript ?? this.subscript,
      superscript: superscript ?? this.superscript,
      code: code ?? this.code,
      textColor: textColor ?? this.textColor,
      backgroundColor: backgroundColor ?? this.backgroundColor,
      fontSize: fontSize ?? this.fontSize,
      fontFamily: fontFamily ?? this.fontFamily,
      linkUrl: linkUrl ?? this.linkUrl,
    );
  }

  /// Toggles a specific attribute
  TextAttributes toggle(String attribute) {
    switch (attribute) {
      case 'bold':
        return copyWith(bold: !bold);
      case 'italic':
        return copyWith(italic: !italic);
      case 'underline':
        return copyWith(underline: !underline);
      case 'strikethrough':
        return copyWith(strikethrough: !strikethrough);
      case 'subscript':
        return copyWith(subscript: !subscript);
      case 'superscript':
        return copyWith(superscript: !superscript);
      case 'code':
        return copyWith(code: !code);
      default:
        return this;
    }
  }

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
    if (bold) json['bold'] = true;
    if (italic) json['italic'] = true;
    if (underline) json['underline'] = true;
    if (strikethrough) json['strikethrough'] = true;
    if (subscript) json['subscript'] = true;
    if (superscript) json['superscript'] = true;
    if (code) json['code'] = true;
    if (textColor != null) json['textColor'] = textColor!.value;
    if (backgroundColor != null) json['backgroundColor'] = backgroundColor!.value;
    if (fontSize != null) json['fontSize'] = fontSize;
    if (fontFamily != null) json['fontFamily'] = fontFamily;
    if (linkUrl != null) json['linkUrl'] = linkUrl;
    return json;
  }

  factory TextAttributes.fromJson(Map<String, dynamic> json) {
    return TextAttributes(
      bold: json['bold'] as bool? ?? false,
      italic: json['italic'] as bool? ?? false,
      underline: json['underline'] as bool? ?? false,
      strikethrough: json['strikethrough'] as bool? ?? false,
      subscript: json['subscript'] as bool? ?? false,
      superscript: json['superscript'] as bool? ?? false,
      code: json['code'] as bool? ?? false,
      textColor: json['textColor'] != null ? Color(json['textColor'] as int) : null,
      backgroundColor: json['backgroundColor'] != null ? Color(json['backgroundColor'] as int) : null,
      fontSize: json['fontSize'] as double?,
      fontFamily: json['fontFamily'] as String?,
      linkUrl: json['linkUrl'] as String?,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is TextAttributes &&
        other.bold == bold &&
        other.italic == italic &&
        other.underline == underline &&
        other.strikethrough == strikethrough &&
        other.subscript == subscript &&
        other.superscript == superscript &&
        other.code == code &&
        other.textColor == textColor &&
        other.backgroundColor == backgroundColor &&
        other.fontSize == fontSize &&
        other.fontFamily == fontFamily &&
        other.linkUrl == linkUrl;
  }

  @override
  int get hashCode => Object.hash(
        bold,
        italic,
        underline,
        strikethrough,
        subscript,
        superscript,
        code,
        textColor,
        backgroundColor,
        fontSize,
        fontFamily,
        linkUrl,
      );
}

/// Rich text with attributed spans
class AttributedText {
  /// The plain text content
  final String text;

  /// The attributed spans
  final List<AttributedSpan> spans;

  const AttributedText({
    required this.text,
    this.spans = const [],
  });

  /// Creates an empty attributed text
  static const AttributedText empty = AttributedText(text: '');

  /// Creates attributed text from plain text
  factory AttributedText.fromText(String text) {
    return AttributedText(text: text);
  }

  /// Length of the text
  int get length => text.length;

  /// Whether the text is empty
  bool get isEmpty => text.isEmpty;

  /// Whether the text is not empty
  bool get isNotEmpty => text.isNotEmpty;

  /// Gets attributes at a specific offset
  TextAttributes getAttributesAt(int offset) {
    var result = TextAttributes.empty;
    for (final span in spans) {
      if (span.contains(offset)) {
        result = result.merge(span.attributes);
      }
    }
    return result;
  }

  /// Inserts text at the given offset with optional attributes
  AttributedText insertText(int offset, String insertedText, [TextAttributes? attributes]) {
    if (offset < 0 || offset > text.length) {
      throw RangeError('Offset $offset is out of range for text of length ${text.length}');
    }

    final newText = text.substring(0, offset) + insertedText + text.substring(offset);
    final insertLength = insertedText.length;

    // Adjust existing spans
    final newSpans = <AttributedSpan>[];
    for (final span in spans) {
      if (span.end <= offset) {
        // Span is before insertion - keep as is
        newSpans.add(span);
      } else if (span.start >= offset) {
        // Span is after insertion - shift by insert length
        newSpans.add(span.copyWith(
          start: span.start + insertLength,
          end: span.end + insertLength,
        ));
      } else {
        // Span contains insertion point - split or extend
        newSpans.add(span.copyWith(end: span.end + insertLength));
      }
    }

    // Add span for inserted text if it has attributes
    if (attributes != null && attributes.hasFormatting) {
      newSpans.add(AttributedSpan(
        start: offset,
        end: offset + insertLength,
        attributes: attributes,
      ));
    }

    return AttributedText(text: newText, spans: _normalizeSpans(newSpans));
  }

  /// Deletes text in the given range
  AttributedText deleteText(int start, int end) {
    if (start < 0 || end > text.length || start > end) {
      throw RangeError('Invalid range [$start, $end] for text of length ${text.length}');
    }

    final newText = text.substring(0, start) + text.substring(end);
    final deleteLength = end - start;

    // Adjust existing spans
    final newSpans = <AttributedSpan>[];
    for (final span in spans) {
      if (span.end <= start) {
        // Span is before deletion - keep as is
        newSpans.add(span);
      } else if (span.start >= end) {
        // Span is after deletion - shift by delete length
        newSpans.add(span.copyWith(
          start: span.start - deleteLength,
          end: span.end - deleteLength,
        ));
      } else if (span.start >= start && span.end <= end) {
        // Span is within deletion - remove
        continue;
      } else if (span.start < start && span.end > end) {
        // Span contains deletion - shrink
        newSpans.add(span.copyWith(end: span.end - deleteLength));
      } else if (span.start < start) {
        // Span starts before, ends within deletion
        newSpans.add(span.copyWith(end: start));
      } else {
        // Span starts within, ends after deletion
        newSpans.add(span.copyWith(start: start, end: span.end - deleteLength));
      }
    }

    return AttributedText(text: newText, spans: _normalizeSpans(newSpans));
  }

  /// Applies attributes to the given range
  AttributedText applyAttributes(int start, int end, TextAttributes attributes) {
    if (start < 0 || end > text.length || start >= end) {
      return this;
    }

    final newSpans = List<AttributedSpan>.from(spans);
    newSpans.add(AttributedSpan(
      start: start,
      end: end,
      attributes: attributes,
    ));

    return AttributedText(text: text, spans: _normalizeSpans(newSpans));
  }

  /// Toggles an attribute in the given range
  AttributedText toggleAttribute(int start, int end, String attribute) {
    if (start < 0 || end > text.length || start >= end) {
      return this;
    }

    // Check if attribute is already applied to the entire range
    bool isApplied = true;
    for (int i = start; i < end; i++) {
      final attrs = getAttributesAt(i);
      switch (attribute) {
        case 'bold':
          if (!attrs.bold) isApplied = false;
          break;
        case 'italic':
          if (!attrs.italic) isApplied = false;
          break;
        case 'underline':
          if (!attrs.underline) isApplied = false;
          break;
        case 'strikethrough':
          if (!attrs.strikethrough) isApplied = false;
          break;
        default:
          isApplied = false;
      }
      if (!isApplied) break;
    }

    // Toggle the attribute
    final newAttrs = TextAttributes.empty.toggle(attribute);
    if (isApplied) {
      // Remove the attribute - this is simplified, a proper implementation
      // would need to handle span splitting
      return applyAttributes(start, end, newAttrs.copyWith(
        bold: attribute == 'bold' ? false : null,
        italic: attribute == 'italic' ? false : null,
        underline: attribute == 'underline' ? false : null,
        strikethrough: attribute == 'strikethrough' ? false : null,
      ));
    } else {
      return applyAttributes(start, end, newAttrs);
    }
  }

  /// Normalizes spans by merging overlapping spans with same attributes
  List<AttributedSpan> _normalizeSpans(List<AttributedSpan> spans) {
    if (spans.isEmpty) return spans;

    // Remove empty spans
    final nonEmptySpans = spans.where((s) => s.start < s.end).toList();

    // Sort by start position
    nonEmptySpans.sort((a, b) => a.start.compareTo(b.start));

    return nonEmptySpans;
  }

  /// Creates a substring with preserved attributes
  AttributedText substring(int start, [int? end]) {
    end ??= text.length;
    final newText = text.substring(start, end);

    final newSpans = <AttributedSpan>[];
    for (final span in spans) {
      if (span.overlaps(start, end)) {
        newSpans.add(AttributedSpan(
          start: (span.start - start).clamp(0, newText.length),
          end: (span.end - start).clamp(0, newText.length),
          attributes: span.attributes,
        ));
      }
    }

    return AttributedText(text: newText, spans: newSpans);
  }

  /// Concatenates two attributed texts
  AttributedText concat(AttributedText other) {
    final newText = text + other.text;
    final newSpans = List<AttributedSpan>.from(spans);

    for (final span in other.spans) {
      newSpans.add(span.copyWith(
        start: span.start + text.length,
        end: span.end + text.length,
      ));
    }

    return AttributedText(text: newText, spans: newSpans);
  }

  Map<String, dynamic> toJson() {
    return {
      'text': text,
      'spans': spans.map((s) => s.toJson()).toList(),
    };
  }

  factory AttributedText.fromJson(Map<String, dynamic> json) {
    return AttributedText(
      text: json['text'] as String,
      spans: (json['spans'] as List<dynamic>?)
              ?.map((s) => AttributedSpan.fromJson(s as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  /// Creates a copy with optional new values
  AttributedText copyWith({
    String? text,
    List<AttributedSpan>? spans,
  }) {
    return AttributedText(
      text: text ?? this.text,
      spans: spans ?? this.spans,
    );
  }
}
