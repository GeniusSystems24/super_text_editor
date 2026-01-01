/// Paragraph/block types available in the editor
enum ParagraphType {
  /// Normal paragraph
  paragraph,

  /// Heading level 1
  heading1,

  /// Heading level 2
  heading2,

  /// Heading level 3
  heading3,

  /// Heading level 4
  heading4,

  /// Heading level 5
  heading5,

  /// Heading level 6
  heading6,

  /// Preformatted/code block
  preformatted,

  /// Block quote
  blockquote,
}

/// Extension methods for ParagraphType
extension ParagraphTypeExtension on ParagraphType {
  /// Returns the HTML tag for this paragraph type
  String get htmlTag {
    switch (this) {
      case ParagraphType.paragraph:
        return 'p';
      case ParagraphType.heading1:
        return 'h1';
      case ParagraphType.heading2:
        return 'h2';
      case ParagraphType.heading3:
        return 'h3';
      case ParagraphType.heading4:
        return 'h4';
      case ParagraphType.heading5:
        return 'h5';
      case ParagraphType.heading6:
        return 'h6';
      case ParagraphType.preformatted:
        return 'pre';
      case ParagraphType.blockquote:
        return 'blockquote';
    }
  }

  /// Returns the display name for this paragraph type
  String get displayName {
    switch (this) {
      case ParagraphType.paragraph:
        return 'Paragraph';
      case ParagraphType.heading1:
        return 'Heading 1';
      case ParagraphType.heading2:
        return 'Heading 2';
      case ParagraphType.heading3:
        return 'Heading 3';
      case ParagraphType.heading4:
        return 'Heading 4';
      case ParagraphType.heading5:
        return 'Heading 5';
      case ParagraphType.heading6:
        return 'Heading 6';
      case ParagraphType.preformatted:
        return 'Preformatted';
      case ParagraphType.blockquote:
        return 'Block Quote';
    }
  }
}
