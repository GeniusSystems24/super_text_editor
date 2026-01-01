# Super Text Editor

A powerful, customizable rich text editor for Flutter with comprehensive formatting options, tables, lists, and HTML support. Similar to CKEditor 5.

[![pub package](https://img.shields.io/pub/v/super_text_editor.svg)](https://pub.dev/packages/super_text_editor)
[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](https://opensource.org/licenses/MIT)

## Features

- **Text Formatting**: Bold, italic, underline, strikethrough, subscript, superscript
- **Colors**: Text color and background/highlight color
- **Paragraphs**: Multiple heading levels (H1-H6), preformatted, blockquote
- **Lists**: Bulleted lists and numbered lists with multiple styles (decimal, roman, alpha)
- **Alignment**: Left, center, right, justify
- **Insert Elements**: Links, images, tables, horizontal rules
- **Undo/Redo**: Full history support
- **HTML Output**: Get content as HTML or plain text
- **Customizable Toolbar**: Configure which features to show
- **Form Integration**: Works with Flutter's Form system
- **Dark Mode**: Full support for light and dark themes

## Screenshots

| Full Editor | List Styles | Table Insert |
|-------------|-------------|--------------|
| ![Editor](screenshots/editor.png) | ![Lists](screenshots/lists.png) | ![Table](screenshots/table.png) |

## Installation

Add this to your package's `pubspec.yaml` file:

```yaml
dependencies:
  super_text_editor: ^0.1.0
```

## Usage

### Basic Usage

```dart
import 'package:super_text_editor/super_text_editor.dart';

// Simple editor
SuperEditor(
  placeholder: 'Start typing...',
  onChanged: (text) => print(text),
  onHtmlChanged: (html) => print(html),
)
```

### With Controller

```dart
final controller = SuperEditorController(
  initialHtml: '<p>Hello <strong>World</strong>!</p>',
);

SuperEditor(
  controller: controller,
  autofocus: true,
)

// Get HTML content
final html = controller.html;

// Get plain text
final text = controller.plainText;

// Set content
controller.setHtml('<p>New content</p>');
controller.setText('Plain text');

// Format text
controller.toggleFormat(TextFormat.bold);
controller.setTextColor(Colors.red);
controller.setParagraphType(ParagraphType.heading1);
```

### Toolbar Configuration

```dart
// Full toolbar (default)
SuperEditor(
  toolbarConfig: EditorToolbarConfig.full,
)

// Basic toolbar (text formatting only)
SuperEditor(
  toolbarConfig: EditorToolbarConfig.basic,
)

// Minimal toolbar
SuperEditor(
  toolbarConfig: EditorToolbarConfig.minimal,
)

// Custom configuration
SuperEditor(
  toolbarConfig: EditorToolbarConfig(
    showUndoRedo: true,
    showTextFormatting: true,
    showTextColor: true,
    showAlignment: false,
    showLists: false,
    showTable: false,
  ),
)
```

### Form Integration

```dart
Form(
  child: Column(
    children: [
      SuperEditorFormField(
        labelText: 'Content',
        minHeight: 200,
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please enter content';
          }
          return null;
        },
        onSaved: (value) => _content = value ?? '',
      ),
    ],
  ),
)
```

### Full Screen Editor Page

```dart
// Show editor page
final html = await SuperEditorPage.show(
  context,
  initialHtml: existingContent,
  title: 'Edit Content',
);

if (html != null) {
  // User saved content
  print(html);
}
```

## API Reference

### SuperEditorController

| Property | Type | Description |
|----------|------|-------------|
| `html` | `String` | Get content as HTML |
| `plainText` | `String` | Get content as plain text |
| `hasContent` | `bool` | Check if editor has content |
| `canUndo` | `bool` | Check if undo is available |
| `canRedo` | `bool` | Check if redo is available |
| `currentStyle` | `TextStyleModel` | Current text style |

| Method | Description |
|--------|-------------|
| `toggleFormat(TextFormat)` | Toggle text format |
| `setTextColor(Color?)` | Set text color |
| `setBackgroundColor(Color?)` | Set highlight color |
| `setParagraphType(ParagraphType)` | Set paragraph type |
| `setAlignment(TextAlignment)` | Set text alignment |
| `setListType(ListType)` | Set list type |
| `undo()` | Undo last action |
| `redo()` | Redo last action |
| `insertLink(url, text)` | Insert a link |
| `insertImage(url)` | Insert an image |
| `insertTable(rows, cols)` | Insert a table |
| `setHtml(html)` | Set content from HTML |
| `setText(text)` | Set content from text |
| `clear()` | Clear all content |

### TextFormat

- `bold`
- `italic`
- `underline`
- `strikethrough`
- `subscript`
- `superscript`
- `code`

### ParagraphType

- `paragraph`
- `heading1` - `heading6`
- `preformatted`
- `blockquote`

### ListType

- `none`
- `bullet`
- `decimal` (1, 2, 3)
- `decimalLeadingZero` (01, 02, 03)
- `lowerRoman` (i, ii, iii)
- `upperRoman` (I, II, III)
- `lowerAlpha` (a, b, c)
- `upperAlpha` (A, B, C)

## Example

See the [example](example/) folder for a complete example application.

```bash
cd example
flutter run
```

## Contributing

Contributions are welcome! Please read our [contributing guidelines](CONTRIBUTING.md) first.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
