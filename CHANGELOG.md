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
- Updated `EditorToolbarConfig` with new options:
  - `showFontSize` - Font size selector
  - `showCodeBlock` - Code block button
  - `showEmoji` - Emoji picker button
  - `showSpecialChars` - Special characters button
- New controller methods:
  - `insertCodeBlock(code, language)` - Insert code block
  - `insertText(text)` - Insert text/emoji/special char at cursor
  - `setFontSize(size)` - Set font size
  - `currentFontSize` getter

### Documentation
- Updated README with new features
- Added examples for new dialogs

---

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
