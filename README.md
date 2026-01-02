# Super Text Editor

A powerful native Flutter document editor with support for rich text, tables, lists, and more. Built on a Document/Node architecture without WebView.

[![pub package](https://img.shields.io/pub/v/super_text_editor.svg)](https://pub.dev/packages/super_text_editor)
[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](https://opensource.org/licenses/MIT)

## Features

- **Document-Based Architecture**: Document = List of Nodes (Blocks)
- **Rich Text Formatting**: Bold, italic, underline, strikethrough, subscript, superscript
- **Block Styles**: Headings (H1-H6), blockquote, preformatted
- **Text Alignment**: Left, center, right, justify
- **Lists**: Bullet and numbered lists with nesting
- **Tables**: CKEditor-style grid picker, add/remove rows and columns
- **Links & Images**: Insert and edit links, embed images
- **Code Blocks**: With language support
- **Undo/Redo**: Full history support with command pattern
- **Import/Export**: HTML and JSON serialization
- **RTL Support**: Right-to-left text direction
- **Customizable Toolbar**: Configure which features to show
- **Dark Mode**: Full support for light and dark themes

## Architecture

```
Document
├── ParagraphNode (text, headings, blockquote)
├── ListItemNode (bullet, numbered)
├── TableNode (rows × columns of cells)
├── ImageNode
├── CodeBlockNode
└── HorizontalRuleNode
```

## Installation

Add this to your package's `pubspec.yaml` file:

```yaml
dependencies:
  super_text_editor: ^1.0.0
```

## Usage

### Basic Usage

```dart
import 'package:super_text_editor/super_text_editor.dart';

// Create a controller
final controller = DocumentEditorController();

// Use the editor
DocumentEditor(
  controller: controller,
  placeholder: 'Start typing...',
)
```

### With Initial Content

```dart
final document = Document([
  ParagraphNode(
    text: AttributedText.fromText('Welcome to Super Text Editor'),
    blockType: BlockType.heading1,
  ),
  ParagraphNode(
    text: AttributedText.fromText('This is a paragraph with rich text support.'),
  ),
  ListItemNode.fromText('First item'),
  ListItemNode.fromText('Second item'),
  ListItemNode.fromText('Third item'),
]);

final controller = DocumentEditorController(document: document);

DocumentEditor(
  controller: controller,
)
```

### With Toolbar

```dart
Column(
  children: [
    EditorToolbar(
      controller: controller,
      config: EditorToolbarConfig(
        showTextFormatting: true,
        showHeadings: true,
        showAlignment: true,
        showLists: true,
        showTable: true,
        showUndoRedo: true,
      ),
      onInsertLink: () => _showLinkDialog(),
      onInsertImage: () => _showImageDialog(),
    ),
    Expanded(
      child: DocumentEditor(
        controller: controller,
      ),
    ),
  ],
)
```

### Insert a Table

```dart
// Using the controller
controller.insertTable(3, 4); // 3 rows, 4 columns

// Or show the table size picker
final result = await TableSizePicker.show(context);
if (result != null) {
  controller.insertTable(result.rows, result.columns);
}
```

### Text Formatting

```dart
// Toggle formatting
controller.toggleBold();
controller.toggleItalic();
controller.toggleUnderline();
controller.toggleStrikethrough();

// Set alignment
controller.setAlignment(TextAlign.center);

// Set block type
controller.setBlockType(BlockType.heading1);

// Toggle lists
controller.toggleBulletList();
controller.toggleNumberedList();
```

### Table Operations

```dart
// Add rows/columns
controller.addTableRow(above: false); // Add below
controller.addTableRow(above: true);  // Add above
controller.addTableColumn(left: false); // Add right
controller.addTableColumn(left: true);  // Add left

// Delete rows/columns
controller.deleteTableRow();
controller.deleteTableColumn();
```

### Undo/Redo

```dart
// Undo last action
controller.undo();

// Redo last undone action
controller.redo();

// Check availability
if (controller.canUndo) { ... }
if (controller.canRedo) { ... }
```

### Export to HTML

```dart
final exporter = HtmlExporter();
final html = exporter.export(controller.document);
print(html);
// Output: <h1>Welcome</h1><p>Paragraph text...</p>
```

### Import from HTML

```dart
final importer = HtmlImporter();
final document = importer.import('<h1>Hello</h1><p>World</p>');
controller.loadFromJson(document.toJson());
```

### Export to JSON

```dart
final serializer = DocumentSerializer();
final json = serializer.serialize(controller.document, pretty: true);
print(json);
```

### Import from JSON

```dart
final serializer = DocumentSerializer();
final document = serializer.deserialize(jsonString);
```

## API Reference

### DocumentEditorController

| Property | Type | Description |
|----------|------|-------------|
| `document` | `Document` | The document being edited |
| `selection` | `EditorSelection?` | Current selection |
| `canUndo` | `bool` | Whether undo is available |
| `canRedo` | `bool` | Whether redo is available |

| Method | Description |
|--------|-------------|
| `insertText(text)` | Insert text at cursor |
| `deleteBackward()` | Delete character before cursor |
| `deleteForward()` | Delete character after cursor |
| `insertParagraph()` | Insert new paragraph (Enter) |
| `toggleBold()` | Toggle bold formatting |
| `toggleItalic()` | Toggle italic formatting |
| `toggleUnderline()` | Toggle underline formatting |
| `toggleStrikethrough()` | Toggle strikethrough |
| `setAlignment(align)` | Set text alignment |
| `toggleBulletList()` | Toggle bullet list |
| `toggleNumberedList()` | Toggle numbered list |
| `setBlockType(type)` | Set block type (heading, etc.) |
| `insertTable(rows, cols)` | Insert a table |
| `addTableRow(above)` | Add table row |
| `addTableColumn(left)` | Add table column |
| `deleteTableRow()` | Delete current table row |
| `deleteTableColumn()` | Delete current table column |
| `insertLink(url, text)` | Insert a link |
| `insertImage(src, alt)` | Insert an image |
| `undo()` | Undo last action |
| `redo()` | Redo last undone action |

### Node Types

#### ParagraphNode
```dart
ParagraphNode(
  text: AttributedText.fromText('Hello World'),
  blockType: BlockType.heading1, // paragraph, heading1-6, blockquote, preformatted
  alignment: TextAlign.center,
  indentLevel: 0,
)
```

#### ListItemNode
```dart
ListItemNode(
  text: AttributedText.fromText('List item'),
  listType: ListType.bullet, // bullet, numbered
  indentLevel: 0,
)
```

#### TableNode
```dart
TableNode.withSize(3, 4, hasHeader: true) // 3 rows, 4 columns
```

#### ImageNode
```dart
ImageNode(
  src: 'https://example.com/image.png',
  alt: 'Description',
  width: 300,
  height: 200,
)
```

#### CodeBlockNode
```dart
CodeBlockNode(
  code: 'print("Hello World")',
  language: 'dart',
)
```

### BlockType

- `paragraph`
- `heading1` - `heading6`
- `blockquote`
- `preformatted`

### ListType

- `bullet`
- `numbered`

### TextAlign

- `left`
- `center`
- `right`
- `justify`

## Example

See the [example](example/) folder for a complete example application with:
- Document editor demo
- Table editing demo
- Export demo (HTML/JSON)

```bash
cd example
flutter run
```

## Package Structure

```
lib/
├── super_text_editor.dart          # Main library exports
└── src/
    ├── core/
    │   ├── document/               # Document, Nodes, AttributedText
    │   ├── selection/              # Selection management
    │   ├── commands/               # Editing commands
    │   └── history/                # Undo/Redo
    ├── ui/
    │   ├── editor/                 # DocumentEditor widget
    │   ├── toolbar/                # EditorToolbar
    │   ├── components/             # Node renderers
    │   └── pickers/                # TableSizePicker
    └── io/
        ├── html/                   # HTML import/export
        └── json/                   # JSON serialization
```

## Contributing

Contributions are welcome! Please read our [contributing guidelines](CONTRIBUTING.md) first.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
