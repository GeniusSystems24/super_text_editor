## 0.1.0

### Initial Release

#### Features
- **Rich Text Editor Widget** (`SuperEditor`)
  - Full-featured WYSIWYG editor similar to CKEditor 5
  - Customizable toolbar with configurable options
  - Support for light and dark themes

- **Text Formatting**
  - Bold, italic, underline, strikethrough
  - Subscript and superscript
  - Inline code formatting

- **Colors**
  - Text color picker with preset colors
  - Background/highlight color picker

- **Paragraph Styles**
  - Normal paragraph
  - Headings (H1-H6)
  - Preformatted/code block
  - Block quote

- **Lists**
  - Bulleted (unordered) lists
  - Numbered (ordered) lists with multiple styles:
    - Decimal (1, 2, 3)
    - Decimal with leading zero (01, 02, 03)
    - Lower Roman (i, ii, iii)
    - Upper Roman (I, II, III)
    - Lower Alpha (a, b, c)
    - Upper Alpha (A, B, C)

- **Text Alignment**
  - Left, center, right, justify

- **Insert Elements**
  - Links with dialog
  - Images with preview
  - Tables with size picker
  - Horizontal rules

- **Editor Controller** (`SuperEditorController`)
  - Full programmatic control
  - HTML and plain text output
  - Undo/redo support
  - Format toggling

- **Form Integration**
  - `SuperEditorFormField` for Flutter Form integration
  - Validation support

- **Full-Screen Editor**
  - `SuperEditorPage` for full-screen editing experience

- **Toolbar Configurations**
  - `EditorToolbarConfig.full` - All features
  - `EditorToolbarConfig.basic` - Text formatting only
  - `EditorToolbarConfig.minimal` - B/I/U/S only
  - Custom configuration support

#### Documentation
- Comprehensive README with usage examples
- Full API reference
- Example application with multiple demos
