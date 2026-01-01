import 'package:flutter/material.dart';
import '../enums/text_format.dart';

/// Model representing text styling attributes
class TextStyleModel {
  /// Set of active text formats
  final Set<TextFormat> formats;

  /// Text color (null means default)
  final Color? textColor;

  /// Background/highlight color (null means none)
  final Color? backgroundColor;

  /// Font size in logical pixels (null means default)
  final double? fontSize;

  /// Font family name (null means default)
  final String? fontFamily;

  /// Creates a new TextStyleModel
  const TextStyleModel({
    this.formats = const {},
    this.textColor,
    this.backgroundColor,
    this.fontSize,
    this.fontFamily,
  });

  /// Creates an empty/default TextStyleModel
  factory TextStyleModel.empty() => const TextStyleModel();

  /// Returns true if bold format is active
  bool get isBold => formats.contains(TextFormat.bold);

  /// Returns true if italic format is active
  bool get isItalic => formats.contains(TextFormat.italic);

  /// Returns true if underline format is active
  bool get isUnderline => formats.contains(TextFormat.underline);

  /// Returns true if strikethrough format is active
  bool get isStrikethrough => formats.contains(TextFormat.strikethrough);

  /// Returns true if subscript format is active
  bool get isSubscript => formats.contains(TextFormat.subscript);

  /// Returns true if superscript format is active
  bool get isSuperscript => formats.contains(TextFormat.superscript);

  /// Returns true if code format is active
  bool get isCode => formats.contains(TextFormat.code);

  /// Creates a copy with the specified format toggled
  TextStyleModel toggleFormat(TextFormat format) {
    final newFormats = Set<TextFormat>.from(formats);
    if (newFormats.contains(format)) {
      newFormats.remove(format);
    } else {
      // Handle mutually exclusive formats
      if (format == TextFormat.subscript) {
        newFormats.remove(TextFormat.superscript);
      } else if (format == TextFormat.superscript) {
        newFormats.remove(TextFormat.subscript);
      }
      newFormats.add(format);
    }
    return copyWith(formats: newFormats);
  }

  /// Creates a copy with the specified text color
  TextStyleModel withTextColor(Color? color) => copyWith(textColor: color);

  /// Creates a copy with the specified background color
  TextStyleModel withBackgroundColor(Color? color) =>
      copyWith(backgroundColor: color);

  /// Creates a copy with the specified font size
  TextStyleModel withFontSize(double? size) => copyWith(fontSize: size);

  /// Converts to Flutter TextStyle
  TextStyle toTextStyle() {
    return TextStyle(
      fontWeight: isBold ? FontWeight.bold : null,
      fontStyle: isItalic ? FontStyle.italic : null,
      decoration: _getDecoration(),
      color: textColor,
      backgroundColor: backgroundColor,
      fontSize: fontSize,
      fontFamily: fontFamily,
      fontFeatures: isSubscript
          ? [const FontFeature.subscripts()]
          : isSuperscript
              ? [const FontFeature.superscripts()]
              : null,
    );
  }

  TextDecoration? _getDecoration() {
    final decorations = <TextDecoration>[];
    if (isUnderline) decorations.add(TextDecoration.underline);
    if (isStrikethrough) decorations.add(TextDecoration.lineThrough);
    if (decorations.isEmpty) return null;
    return TextDecoration.combine(decorations);
  }

  /// Creates a copy with the specified properties
  TextStyleModel copyWith({
    Set<TextFormat>? formats,
    Color? textColor,
    Color? backgroundColor,
    double? fontSize,
    String? fontFamily,
  }) {
    return TextStyleModel(
      formats: formats ?? this.formats,
      textColor: textColor ?? this.textColor,
      backgroundColor: backgroundColor ?? this.backgroundColor,
      fontSize: fontSize ?? this.fontSize,
      fontFamily: fontFamily ?? this.fontFamily,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is TextStyleModel &&
        _setEquals(other.formats, formats) &&
        other.textColor == textColor &&
        other.backgroundColor == backgroundColor &&
        other.fontSize == fontSize &&
        other.fontFamily == fontFamily;
  }

  bool _setEquals<T>(Set<T> a, Set<T> b) {
    if (a.length != b.length) return false;
    return a.every(b.contains);
  }

  @override
  int get hashCode => Object.hash(
        Object.hashAll(formats),
        textColor,
        backgroundColor,
        fontSize,
        fontFamily,
      );
}
