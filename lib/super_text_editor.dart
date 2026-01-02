/// A powerful native Flutter document editor with support for rich text,
/// tables, lists, and more. Built on super_editor with additional features.
///
/// ## Features
///
/// - Built on super_editor for robust document editing
/// - Rich text formatting: Bold, Italic, Underline, Strikethrough
/// - Paragraph styles: Headings (H1-H6), Blockquote, Preformatted
/// - Text alignment: Left, Center, Right, Justify
/// - Lists: Bullet and Numbered lists
/// - Tables: Insert via picker, add/remove rows/columns
/// - Images and Horizontal rules
/// - Links with URL support
/// - Code blocks with language highlighting
/// - Undo/Redo support
/// - HTML import/export
/// - JSON serialization
/// - RTL support
///
/// ## Getting Started
///
/// ```dart
/// import 'package:super_text_editor/super_text_editor.dart';
///
/// // Use SuperEditor from super_editor package
/// SuperEditor(
///   editor: editor,
///   document: document,
///   composer: composer,
/// )
///
/// // Use additional utilities
/// final picker = TableSizePicker(onSizeSelected: (size) => print(size));
/// ```
library super_text_editor;

// Re-export super_editor for full functionality
export 'package:super_editor/super_editor.dart';

// UI - Pickers (additional utilities)
export 'src/ui/pickers/table_size_picker.dart';

// IO - HTML (additional utilities)
export 'src/io/html/html_exporter.dart';
export 'src/io/html/html_importer.dart';

// IO - JSON (additional utilities)
export 'src/io/json/document_serializer.dart';
