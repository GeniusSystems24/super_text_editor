/// Types of lists available in the editor
enum ListType {
  /// No list
  none,

  /// Bulleted/unordered list
  bullet,

  /// Numbered list with decimal numbers (1, 2, 3)
  decimal,

  /// Numbered list with leading zero (01, 02, 03)
  decimalLeadingZero,

  /// Numbered list with lowercase roman numerals (i, ii, iii)
  lowerRoman,

  /// Numbered list with uppercase roman numerals (I, II, III)
  upperRoman,

  /// Numbered list with lowercase letters (a, b, c)
  lowerAlpha,

  /// Numbered list with uppercase letters (A, B, C)
  upperAlpha,
}

/// Extension methods for ListType
extension ListTypeExtension on ListType {
  /// Returns the CSS list-style-type value
  String get cssValue {
    switch (this) {
      case ListType.none:
        return 'none';
      case ListType.bullet:
        return 'disc';
      case ListType.decimal:
        return 'decimal';
      case ListType.decimalLeadingZero:
        return 'decimal-leading-zero';
      case ListType.lowerRoman:
        return 'lower-roman';
      case ListType.upperRoman:
        return 'upper-roman';
      case ListType.lowerAlpha:
        return 'lower-alpha';
      case ListType.upperAlpha:
        return 'upper-alpha';
    }
  }

  /// Returns whether this is an ordered list type
  bool get isOrdered => this != ListType.none && this != ListType.bullet;

  /// Returns the HTML tag for this list type
  String get htmlTag => isOrdered ? 'ol' : 'ul';
}
