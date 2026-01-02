## 1.0.0

### Major Release - Native Flutter Document Editor

Complete architectural rewrite following a Document/Node-based approach. This release introduces a professional-grade document editor without WebView dependency.

#### Architecture

- **Document Model**: New `Document` class as a list of `DocumentNode` objects
- **Node Types**:
  - `ParagraphNode` - Text paragraphs with headings support
  - `ListItemNode` - Bullet and numbered list items
  - `TableNode` - Full table support with rows/columns
  - `ImageNode` - Image blocks
  - `CodeBlockNode` - Code blocks with language support
  - `HorizontalRuleNode` - Horizontal dividers
- **AttributedText**: Rich text model with formatting spans
- **Selection System**: `EditorSelection` with `NodePosition` for precise cursor control
- **Command Pattern**: All editing operations as undoable commands
- **History Management**: Full Undo/Redo support via `EditorHistory`

#### Core Features

- **Rich Text Formatting**
  - Bold, Italic, Underline, Strikethrough
  - Subscript, Superscript
  - Text color and background color
  - Font size and font family

- **Block Styles**
  - Paragraph
  - Headings (H1-H6)
  - Blockquote
  - Preformatted/Code

- **Text Alignment**
  - Left, Center, Right, Justify

- **Lists**
  - Bullet lists
  - Numbered lists
  - Nested indentation

- **Tables**
  - Insert via CKEditor-style grid picker
  - Add/Remove rows and columns
  - Edit cell content
  - Header row support
  - Horizontal scroll for wide tables

- **Links & Media**
  - Insert/Edit links with URL
  - Insert images
  - Horizontal rules

- **Code Blocks**
  - Syntax highlighting ready
  - Language selection

#### UI Components

- `DocumentEditor` - Main editor widget
- `DocumentEditorController` - Full programmatic control
- `EditorToolbar` - Configurable formatting toolbar
- `TableSizePicker` - Grid-based table size selector
- `ParagraphComponent` - Paragraph renderer
- `ListItemComponent` - List item renderer
- `TableComponent` - Table renderer with controls
- `ImageComponent` - Image renderer
- `CodeBlockComponent` - Code block renderer

#### Import/Export

- `HtmlExporter` - Export document to HTML
- `HtmlImporter` - Import HTML to document
- `DocumentSerializer` - JSON serialization

#### Breaking Changes

- Complete API redesign - see migration guide below
- Replaced `SuperEditor` with `DocumentEditor`
- Replaced `SuperEditorController` with `DocumentEditorController`
- New document model replaces simple text-based approach

#### Migration from 0.x

```dart
// Old (0.x)
final controller = SuperEditorController();
SuperEditor(controller: controller)
final html = controller.html;

// New (1.0.0)
final controller = DocumentEditorController();
DocumentEditor(controller: controller)
final html = HtmlExporter().export(controller.document);
```

---

## 0.3.0

### Professional Editor Features

- Keyboard shortcuts system
- Find & Replace dialog
- Word/character counter widget
- Context menu (right-click)
- Text patterns (@mentions, #hashtags)
- Document export functionality
- Editor theming system

---

## 0.2.0

### New Features

#### Code Block Support
- **Code Block Dialog** (`CodeBlockDialog`)
  - Insert code blocks with syntax highlighting support
  - Language selector with 25+ programming languages
  - Syntax highlighting ready (Dart, JavaScript, Python, Java, etc.)

#### Emoji Picker
- **Emoji Picker Dialog** (`EmojiPickerDialog`)
  - 8 emoji categories (Smileys, People, Animals, Food, Travel, Activities, Objects, Symbols)
  - Search functionality
  - Category tabs for easy navigation
  - 80+ emojis per category

#### Special Characters
- **Special Characters Dialog** (`SpecialCharactersDialog`)
  - 7 character categories (Common, Currency, Math, Arrows, Latin, Greek, Punctuation)
  - Hover preview
  - Tab navigation
  - 20+ characters per category

#### Font Size Control
- **Font Size Selector** (`FontSizeSelector`)
  - Predefined sizes (8-72px)
  - Default size option
  - Dropdown selector in toolbar

#### HTML Parser
- **HTML Parser Utility** (`HtmlParser`)
  - Parse HTML to EditorNodes
  - Convert EditorNodes to HTML
  - Extract text formatting from HTML
  - Support for inline styles (colors, fonts)

### Improvements

- Enhanced toolbar with new buttons for all new features
- Updated `EditorToolbarConfig` with new options
- New controller methods for code blocks, text insertion, font size

---

## 0.1.0

### Initial Release

#### Features
- **Rich Text Editor Widget** (`SuperEditor`)
- **Text Formatting**: Bold, italic, underline, strikethrough, subscript, superscript
- **Colors**: Text color and background/highlight color
- **Paragraph Styles**: Headings (H1-H6), preformatted, blockquote
- **Lists**: Bulleted and numbered lists with multiple styles
- **Alignment**: Left, center, right, justify
- **Insert Elements**: Links, images, tables, horizontal rules
- **Editor Controller** with HTML and plain text output
- **Form Integration** with `SuperEditorFormField`
- **Toolbar Configurations**: Full, basic, minimal, custom
