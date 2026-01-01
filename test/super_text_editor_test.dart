import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:super_text_editor/super_text_editor.dart';

void main() {
  group('SuperEditorController', () {
    late SuperEditorController controller;

    setUp(() {
      controller = SuperEditorController();
    });

    tearDown(() {
      controller.dispose();
    });

    test('should initialize with empty content', () {
      expect(controller.plainText, isEmpty);
      expect(controller.hasContent, isFalse);
    });

    test('should initialize with initial text', () {
      final controllerWithText = SuperEditorController(initialText: 'Hello World');
      expect(controllerWithText.plainText, 'Hello World');
      expect(controllerWithText.hasContent, isTrue);
      controllerWithText.dispose();
    });

    test('should set and get text', () {
      controller.setText('Test content');
      expect(controller.plainText, 'Test content');
    });

    test('should clear content', () {
      controller.setText('Test content');
      controller.clear();
      expect(controller.plainText, isEmpty);
    });

    test('should toggle bold format', () {
      expect(controller.isFormatActive(TextFormat.bold), isFalse);
      controller.toggleFormat(TextFormat.bold);
      expect(controller.isFormatActive(TextFormat.bold), isTrue);
      controller.toggleFormat(TextFormat.bold);
      expect(controller.isFormatActive(TextFormat.bold), isFalse);
    });

    test('should toggle italic format', () {
      expect(controller.isFormatActive(TextFormat.italic), isFalse);
      controller.toggleFormat(TextFormat.italic);
      expect(controller.isFormatActive(TextFormat.italic), isTrue);
    });

    test('should set text color', () {
      expect(controller.currentStyle.textColor, isNull);
      controller.setTextColor(Colors.red);
      expect(controller.currentStyle.textColor, Colors.red);
    });

    test('should set background color', () {
      expect(controller.currentStyle.backgroundColor, isNull);
      controller.setBackgroundColor(Colors.yellow);
      expect(controller.currentStyle.backgroundColor, Colors.yellow);
    });

    test('should set paragraph type', () {
      expect(controller.currentParagraphType, ParagraphType.paragraph);
      controller.setParagraphType(ParagraphType.heading1);
      expect(controller.currentParagraphType, ParagraphType.heading1);
    });

    test('should set alignment', () {
      expect(controller.currentAlignment, TextAlignment.left);
      controller.setAlignment(TextAlignment.center);
      expect(controller.currentAlignment, TextAlignment.center);
    });

    test('should set list type', () {
      expect(controller.currentListType, ListType.none);
      controller.setListType(ListType.bullet);
      expect(controller.currentListType, ListType.bullet);
    });

    test('should support undo/redo', () {
      expect(controller.canUndo, isFalse);
      expect(controller.canRedo, isFalse);

      controller.setText('First');
      controller.setText('Second');

      expect(controller.canUndo, isTrue);
      controller.undo();
      expect(controller.canRedo, isTrue);
    });

    test('should clear formatting', () {
      controller.toggleFormat(TextFormat.bold);
      controller.toggleFormat(TextFormat.italic);
      controller.setTextColor(Colors.red);
      controller.setParagraphType(ParagraphType.heading1);

      controller.clearFormatting();

      expect(controller.isFormatActive(TextFormat.bold), isFalse);
      expect(controller.isFormatActive(TextFormat.italic), isFalse);
      expect(controller.currentStyle.textColor, isNull);
      expect(controller.currentParagraphType, ParagraphType.paragraph);
    });
  });

  group('TextStyleModel', () {
    test('should create empty model', () {
      final style = TextStyleModel.empty();
      expect(style.isBold, isFalse);
      expect(style.isItalic, isFalse);
      expect(style.textColor, isNull);
    });

    test('should toggle format', () {
      var style = TextStyleModel.empty();
      style = style.toggleFormat(TextFormat.bold);
      expect(style.isBold, isTrue);
      style = style.toggleFormat(TextFormat.bold);
      expect(style.isBold, isFalse);
    });

    test('should handle mutually exclusive formats', () {
      var style = TextStyleModel.empty();
      style = style.toggleFormat(TextFormat.subscript);
      expect(style.isSubscript, isTrue);
      expect(style.isSuperscript, isFalse);

      style = style.toggleFormat(TextFormat.superscript);
      expect(style.isSubscript, isFalse);
      expect(style.isSuperscript, isTrue);
    });

    test('should convert to TextStyle', () {
      var style = const TextStyleModel(
        formats: {TextFormat.bold, TextFormat.italic},
        textColor: Colors.red,
      );

      final textStyle = style.toTextStyle();
      expect(textStyle.fontWeight, FontWeight.bold);
      expect(textStyle.fontStyle, FontStyle.italic);
      expect(textStyle.color, Colors.red);
    });
  });

  group('EditorNode', () {
    test('ParagraphNode should generate HTML', () {
      final node = ParagraphNode(
        children: [TextSpanNode(text: 'Hello World')],
      );
      expect(node.toHtml(), '<p>Hello World</p>');
    });

    test('TextSpanNode should escape HTML', () {
      final node = TextSpanNode(text: '<script>alert("xss")</script>');
      expect(node.toHtml(), contains('&lt;script&gt;'));
    });

    test('TextSpanNode should apply formatting tags', () {
      final node = TextSpanNode(
        text: 'Bold text',
        style: const TextStyleModel(formats: {TextFormat.bold}),
      );
      expect(node.toHtml(), '<strong>Bold text</strong>');
    });

    test('ListNode should generate HTML', () {
      final node = ListNode(
        listType: ListType.bullet,
        items: [
          ListItemNode(children: [TextSpanNode(text: 'Item 1')]),
          ListItemNode(children: [TextSpanNode(text: 'Item 2')]),
        ],
      );
      final html = node.toHtml();
      expect(html, contains('<ul>'));
      expect(html, contains('<li>Item 1</li>'));
      expect(html, contains('<li>Item 2</li>'));
    });

    test('TableNode should generate HTML', () {
      final node = TableNode(
        hasHeader: true,
        rows: [
          TableRowNode(cells: [
            TableCellNode(
              isHeader: true,
              children: [TextSpanNode(text: 'Header')],
            ),
          ]),
          TableRowNode(cells: [
            TableCellNode(children: [TextSpanNode(text: 'Data')]),
          ]),
        ],
      );
      final html = node.toHtml();
      expect(html, contains('<table>'));
      expect(html, contains('<thead>'));
      expect(html, contains('<th>Header</th>'));
      expect(html, contains('<td>Data</td>'));
    });
  });

  group('ListType', () {
    test('should return correct CSS values', () {
      expect(ListType.bullet.cssValue, 'disc');
      expect(ListType.decimal.cssValue, 'decimal');
      expect(ListType.lowerRoman.cssValue, 'lower-roman');
      expect(ListType.upperAlpha.cssValue, 'upper-alpha');
    });

    test('should identify ordered lists', () {
      expect(ListType.bullet.isOrdered, isFalse);
      expect(ListType.decimal.isOrdered, isTrue);
      expect(ListType.lowerRoman.isOrdered, isTrue);
    });
  });

  group('ParagraphType', () {
    test('should return correct HTML tags', () {
      expect(ParagraphType.paragraph.htmlTag, 'p');
      expect(ParagraphType.heading1.htmlTag, 'h1');
      expect(ParagraphType.blockquote.htmlTag, 'blockquote');
      expect(ParagraphType.preformatted.htmlTag, 'pre');
    });

    test('should return display names', () {
      expect(ParagraphType.paragraph.displayName, 'Paragraph');
      expect(ParagraphType.heading1.displayName, 'Heading 1');
    });
  });

  group('SuperEditor Widget', () {
    testWidgets('should render with placeholder', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SuperEditor(
              placeholder: 'Enter text here...',
            ),
          ),
        ),
      );

      expect(find.text('Enter text here...'), findsOneWidget);
    });

    testWidgets('should render toolbar', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SuperEditor(
              showToolbar: true,
            ),
          ),
        ),
      );

      // Check for toolbar icons
      expect(find.byIcon(Icons.format_bold), findsOneWidget);
      expect(find.byIcon(Icons.format_italic), findsOneWidget);
      expect(find.byIcon(Icons.undo), findsOneWidget);
    });

    testWidgets('should hide toolbar when disabled', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SuperEditor(
              showToolbar: false,
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.format_bold), findsNothing);
    });

    testWidgets('should render in read-only mode', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SuperEditor(
              readOnly: true,
              showToolbar: true,
            ),
          ),
        ),
      );

      // Toolbar should be hidden in read-only mode
      expect(find.byIcon(Icons.format_bold), findsNothing);
    });
  });
}
