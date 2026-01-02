/// A powerful native Flutter document editor with support for rich text,
/// tables, lists, and more. Built on a Document/Node architecture without WebView.
///
/// ## Features
///
/// - Document-based architecture (Document = List of Blocks/Nodes)
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
/// // Basic usage
/// DocumentEditor(
///   placeholder: 'Start typing...',
///   onChanged: () => print('Document changed'),
/// )
///
/// // With controller
/// final controller = DocumentEditorController();
/// DocumentEditor(controller: controller)
///
/// // Export to HTML
/// final htmlExporter = HtmlExporter();
/// final html = htmlExporter.export(controller.document);
///
/// // Export to JSON
/// final json = controller.document.toJson();
/// ```
library super_text_editor;

// Re-export super_editor for convenience
export 'package:super_editor/super_editor.dart';

// Core - Document
export 'src/core/document/document.dart';
export 'src/core/document/nodes.dart';
export 'src/core/document/attributed_text.dart';

// Core - Selection
export 'src/core/selection/editor_selection.dart';

// Core - Commands
export 'src/core/commands/editor_command.dart';

// Core - History
export 'src/core/history/undo_redo.dart';

// UI - Editor
export 'src/ui/editor/document_editor.dart';

// UI - Toolbar
export 'src/ui/toolbar/editor_toolbar.dart';

// UI - Components
export 'src/ui/components/paragraph_component.dart';
export 'src/ui/components/list_item_component.dart';
export 'src/ui/components/table_component.dart';
export 'src/ui/components/image_component.dart';
export 'src/ui/components/horizontal_rule_component.dart';
export 'src/ui/components/code_block_component.dart';

// UI - Pickers
export 'src/ui/pickers/table_size_picker.dart';

// IO - HTML
export 'src/io/html/html_exporter.dart';
export 'src/io/html/html_importer.dart';

// IO - JSON
export 'src/io/json/document_serializer.dart';
