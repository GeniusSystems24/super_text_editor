/// A powerful, customizable rich text editor for Flutter.
///
/// Super Text Editor provides a comprehensive rich text editing experience
/// similar to CKEditor 5, with support for text formatting, lists, tables,
/// images, links, and more.
///
/// ## Getting Started
///
/// ```dart
/// import 'package:super_text_editor/super_text_editor.dart';
///
/// // Basic usage
/// SuperEditor(
///   placeholder: 'Start typing...',
///   onChanged: (text) => print(text),
///   onHtmlChanged: (html) => print(html),
/// )
///
/// // With controller
/// final controller = SuperEditorController();
/// SuperEditor(controller: controller)
///
/// // Get HTML output
/// final html = controller.html;
/// ```
library super_text_editor;

// Domain - Enums
export 'src/domain/enums/list_type.dart';
export 'src/domain/enums/paragraph_type.dart';
export 'src/domain/enums/text_alignment.dart';
export 'src/domain/enums/text_format.dart';

// Domain - Models
export 'src/domain/models/editor_node.dart';
export 'src/domain/models/editor_state.dart';
export 'src/domain/models/text_style_model.dart';

// Presentation - Editor
export 'src/presentation/editor/super_editor.dart';
export 'src/presentation/editor/super_editor_controller.dart';

// Presentation - Toolbar
export 'src/presentation/toolbar/editor_toolbar.dart';
export 'src/presentation/toolbar/toolbar_button.dart';

// Presentation - Dialogs
export 'src/presentation/dialogs/image_dialog.dart';
export 'src/presentation/dialogs/link_dialog.dart';
export 'src/presentation/dialogs/table_dialog.dart';
