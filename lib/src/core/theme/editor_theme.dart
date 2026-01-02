import 'package:flutter/material.dart';

/// Theme configuration for the editor
class EditorTheme {
  /// Background color of the editor
  final Color? backgroundColor;

  /// Text color
  final Color? textColor;

  /// Cursor color
  final Color? cursorColor;

  /// Selection color
  final Color? selectionColor;

  /// Selection handle color
  final Color? selectionHandleColor;

  /// Placeholder text color
  final Color? placeholderColor;

  /// Link color
  final Color? linkColor;

  /// Toolbar background color
  final Color? toolbarBackgroundColor;

  /// Toolbar icon color
  final Color? toolbarIconColor;

  /// Toolbar active icon color
  final Color? toolbarActiveColor;

  /// Toolbar divider color
  final Color? toolbarDividerColor;

  /// Border color
  final Color? borderColor;

  /// Border radius
  final BorderRadius? borderRadius;

  /// Content padding
  final EdgeInsets? contentPadding;

  /// Base text style
  final TextStyle? textStyle;

  /// Heading 1 style
  final TextStyle? heading1Style;

  /// Heading 2 style
  final TextStyle? heading2Style;

  /// Heading 3 style
  final TextStyle? heading3Style;

  /// Heading 4 style
  final TextStyle? heading4Style;

  /// Heading 5 style
  final TextStyle? heading5Style;

  /// Heading 6 style
  final TextStyle? heading6Style;

  /// Code block style
  final TextStyle? codeStyle;

  /// Code block background color
  final Color? codeBackgroundColor;

  /// Blockquote style
  final TextStyle? blockquoteStyle;

  /// Blockquote border color
  final Color? blockquoteBorderColor;

  /// Line height
  final double? lineHeight;

  /// Paragraph spacing
  final double? paragraphSpacing;

  const EditorTheme({
    this.backgroundColor,
    this.textColor,
    this.cursorColor,
    this.selectionColor,
    this.selectionHandleColor,
    this.placeholderColor,
    this.linkColor,
    this.toolbarBackgroundColor,
    this.toolbarIconColor,
    this.toolbarActiveColor,
    this.toolbarDividerColor,
    this.borderColor,
    this.borderRadius,
    this.contentPadding,
    this.textStyle,
    this.heading1Style,
    this.heading2Style,
    this.heading3Style,
    this.heading4Style,
    this.heading5Style,
    this.heading6Style,
    this.codeStyle,
    this.codeBackgroundColor,
    this.blockquoteStyle,
    this.blockquoteBorderColor,
    this.lineHeight,
    this.paragraphSpacing,
  });

  /// Light theme
  static EditorTheme light({Color? primaryColor}) {
    final primary = primaryColor ?? Colors.blue;
    return EditorTheme(
      backgroundColor: Colors.white,
      textColor: Colors.black87,
      cursorColor: primary,
      selectionColor: primary.withValues(alpha: 0.3),
      selectionHandleColor: primary,
      placeholderColor: Colors.black38,
      linkColor: primary,
      toolbarBackgroundColor: Colors.grey.shade50,
      toolbarIconColor: Colors.black87,
      toolbarActiveColor: primary,
      toolbarDividerColor: Colors.grey.shade300,
      borderColor: Colors.grey.shade300,
      borderRadius: BorderRadius.circular(8),
      contentPadding: const EdgeInsets.all(16),
      textStyle: const TextStyle(
        fontSize: 16,
        height: 1.5,
        color: Colors.black87,
      ),
      heading1Style: const TextStyle(
        fontSize: 32,
        fontWeight: FontWeight.bold,
        height: 1.2,
      ),
      heading2Style: const TextStyle(
        fontSize: 28,
        fontWeight: FontWeight.bold,
        height: 1.2,
      ),
      heading3Style: const TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.bold,
        height: 1.3,
      ),
      heading4Style: const TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        height: 1.3,
      ),
      heading5Style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        height: 1.4,
      ),
      heading6Style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        height: 1.4,
      ),
      codeStyle: TextStyle(
        fontFamily: 'monospace',
        fontSize: 14,
        backgroundColor: Colors.grey.shade100,
      ),
      codeBackgroundColor: Colors.grey.shade100,
      blockquoteStyle: TextStyle(
        fontStyle: FontStyle.italic,
        color: Colors.grey.shade700,
      ),
      blockquoteBorderColor: Colors.grey.shade400,
      lineHeight: 1.5,
      paragraphSpacing: 16,
    );
  }

  /// Dark theme
  static EditorTheme dark({Color? primaryColor}) {
    final primary = primaryColor ?? Colors.blue.shade300;
    return EditorTheme(
      backgroundColor: const Color(0xFF1E1E1E),
      textColor: Colors.white.withValues(alpha: 0.87),
      cursorColor: primary,
      selectionColor: primary.withValues(alpha: 0.3),
      selectionHandleColor: primary,
      placeholderColor: Colors.white38,
      linkColor: primary,
      toolbarBackgroundColor: const Color(0xFF2D2D2D),
      toolbarIconColor: Colors.white.withValues(alpha: 0.87),
      toolbarActiveColor: primary,
      toolbarDividerColor: Colors.white24,
      borderColor: Colors.white24,
      borderRadius: BorderRadius.circular(8),
      contentPadding: const EdgeInsets.all(16),
      textStyle: TextStyle(
        fontSize: 16,
        height: 1.5,
        color: Colors.white.withValues(alpha: 0.87),
      ),
      heading1Style: TextStyle(
        fontSize: 32,
        fontWeight: FontWeight.bold,
        height: 1.2,
        color: Colors.white.withValues(alpha: 0.87),
      ),
      heading2Style: TextStyle(
        fontSize: 28,
        fontWeight: FontWeight.bold,
        height: 1.2,
        color: Colors.white.withValues(alpha: 0.87),
      ),
      heading3Style: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.bold,
        height: 1.3,
        color: Colors.white.withValues(alpha: 0.87),
      ),
      heading4Style: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        height: 1.3,
        color: Colors.white.withValues(alpha: 0.87),
      ),
      heading5Style: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        height: 1.4,
        color: Colors.white.withValues(alpha: 0.87),
      ),
      heading6Style: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        height: 1.4,
        color: Colors.white.withValues(alpha: 0.87),
      ),
      codeStyle: const TextStyle(
        fontFamily: 'monospace',
        fontSize: 14,
        backgroundColor: Color(0xFF2D2D2D),
      ),
      codeBackgroundColor: const Color(0xFF2D2D2D),
      blockquoteStyle: TextStyle(
        fontStyle: FontStyle.italic,
        color: Colors.white.withValues(alpha: 0.6),
      ),
      blockquoteBorderColor: Colors.white38,
      lineHeight: 1.5,
      paragraphSpacing: 16,
    );
  }

  /// Sepia theme (for reading)
  static EditorTheme sepia({Color? primaryColor}) {
    final primary = primaryColor ?? const Color(0xFF8B4513);
    return EditorTheme(
      backgroundColor: const Color(0xFFF5E6D3),
      textColor: const Color(0xFF5D4E37),
      cursorColor: primary,
      selectionColor: primary.withValues(alpha: 0.3),
      selectionHandleColor: primary,
      placeholderColor: const Color(0xFF8B7355),
      linkColor: primary,
      toolbarBackgroundColor: const Color(0xFFEDE0D0),
      toolbarIconColor: const Color(0xFF5D4E37),
      toolbarActiveColor: primary,
      toolbarDividerColor: const Color(0xFFD4C4B0),
      borderColor: const Color(0xFFD4C4B0),
      borderRadius: BorderRadius.circular(8),
      contentPadding: const EdgeInsets.all(16),
      textStyle: const TextStyle(
        fontSize: 16,
        height: 1.6,
        color: Color(0xFF5D4E37),
      ),
      codeStyle: const TextStyle(
        fontFamily: 'monospace',
        fontSize: 14,
        backgroundColor: Color(0xFFEDE0D0),
      ),
      codeBackgroundColor: const Color(0xFFEDE0D0),
      blockquoteStyle: const TextStyle(
        fontStyle: FontStyle.italic,
        color: Color(0xFF8B7355),
      ),
      blockquoteBorderColor: const Color(0xFFBBA98A),
      lineHeight: 1.6,
      paragraphSpacing: 18,
    );
  }

  /// High contrast theme
  static EditorTheme highContrast() {
    return const EditorTheme(
      backgroundColor: Colors.black,
      textColor: Colors.white,
      cursorColor: Colors.yellow,
      selectionColor: Colors.yellow,
      selectionHandleColor: Colors.yellow,
      placeholderColor: Colors.grey,
      linkColor: Colors.cyan,
      toolbarBackgroundColor: Colors.black,
      toolbarIconColor: Colors.white,
      toolbarActiveColor: Colors.yellow,
      toolbarDividerColor: Colors.white,
      borderColor: Colors.white,
      borderRadius: BorderRadius.zero,
      contentPadding: EdgeInsets.all(16),
      textStyle: TextStyle(
        fontSize: 18,
        height: 1.5,
        color: Colors.white,
      ),
      codeStyle: TextStyle(
        fontFamily: 'monospace',
        fontSize: 16,
        color: Colors.lime,
        backgroundColor: Color(0xFF1A1A1A),
      ),
      codeBackgroundColor: Color(0xFF1A1A1A),
      blockquoteStyle: TextStyle(
        fontStyle: FontStyle.italic,
        color: Colors.grey,
      ),
      blockquoteBorderColor: Colors.white,
      lineHeight: 1.5,
      paragraphSpacing: 20,
    );
  }

  /// Creates a copy with modified properties
  EditorTheme copyWith({
    Color? backgroundColor,
    Color? textColor,
    Color? cursorColor,
    Color? selectionColor,
    Color? selectionHandleColor,
    Color? placeholderColor,
    Color? linkColor,
    Color? toolbarBackgroundColor,
    Color? toolbarIconColor,
    Color? toolbarActiveColor,
    Color? toolbarDividerColor,
    Color? borderColor,
    BorderRadius? borderRadius,
    EdgeInsets? contentPadding,
    TextStyle? textStyle,
    TextStyle? heading1Style,
    TextStyle? heading2Style,
    TextStyle? heading3Style,
    TextStyle? heading4Style,
    TextStyle? heading5Style,
    TextStyle? heading6Style,
    TextStyle? codeStyle,
    Color? codeBackgroundColor,
    TextStyle? blockquoteStyle,
    Color? blockquoteBorderColor,
    double? lineHeight,
    double? paragraphSpacing,
  }) {
    return EditorTheme(
      backgroundColor: backgroundColor ?? this.backgroundColor,
      textColor: textColor ?? this.textColor,
      cursorColor: cursorColor ?? this.cursorColor,
      selectionColor: selectionColor ?? this.selectionColor,
      selectionHandleColor: selectionHandleColor ?? this.selectionHandleColor,
      placeholderColor: placeholderColor ?? this.placeholderColor,
      linkColor: linkColor ?? this.linkColor,
      toolbarBackgroundColor: toolbarBackgroundColor ?? this.toolbarBackgroundColor,
      toolbarIconColor: toolbarIconColor ?? this.toolbarIconColor,
      toolbarActiveColor: toolbarActiveColor ?? this.toolbarActiveColor,
      toolbarDividerColor: toolbarDividerColor ?? this.toolbarDividerColor,
      borderColor: borderColor ?? this.borderColor,
      borderRadius: borderRadius ?? this.borderRadius,
      contentPadding: contentPadding ?? this.contentPadding,
      textStyle: textStyle ?? this.textStyle,
      heading1Style: heading1Style ?? this.heading1Style,
      heading2Style: heading2Style ?? this.heading2Style,
      heading3Style: heading3Style ?? this.heading3Style,
      heading4Style: heading4Style ?? this.heading4Style,
      heading5Style: heading5Style ?? this.heading5Style,
      heading6Style: heading6Style ?? this.heading6Style,
      codeStyle: codeStyle ?? this.codeStyle,
      codeBackgroundColor: codeBackgroundColor ?? this.codeBackgroundColor,
      blockquoteStyle: blockquoteStyle ?? this.blockquoteStyle,
      blockquoteBorderColor: blockquoteBorderColor ?? this.blockquoteBorderColor,
      lineHeight: lineHeight ?? this.lineHeight,
      paragraphSpacing: paragraphSpacing ?? this.paragraphSpacing,
    );
  }

  /// Resolves theme from context, falling back to defaults
  static EditorTheme of(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    return brightness == Brightness.dark ? dark() : light();
  }
}

/// InheritedWidget for editor theme
class EditorThemeProvider extends InheritedWidget {
  final EditorTheme theme;

  const EditorThemeProvider({
    super.key,
    required this.theme,
    required super.child,
  });

  static EditorTheme of(BuildContext context) {
    final provider = context.dependOnInheritedWidgetOfExactType<EditorThemeProvider>();
    return provider?.theme ?? EditorTheme.of(context);
  }

  @override
  bool updateShouldNotify(EditorThemeProvider oldWidget) {
    return theme != oldWidget.theme;
  }
}
