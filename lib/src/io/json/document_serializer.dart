import 'dart:convert';
import 'package:super_editor/super_editor.dart';

/// Serializes and deserializes super_editor documents to/from JSON
class DocumentSerializer {
  /// Creates a new document serializer
  const DocumentSerializer();

  /// Serializes a document to a JSON string
  String serialize(Document document, {bool pretty = false}) {
    final json = _documentToJson(document);

    if (pretty) {
      return const JsonEncoder.withIndent('  ').convert(json);
    }

    return jsonEncode(json);
  }

  /// Deserializes a document from a JSON string
  MutableDocument deserialize(String jsonString) {
    final json = jsonDecode(jsonString) as Map<String, dynamic>;
    return _documentFromJson(json);
  }

  /// Serializes a document to a JSON map
  Map<String, dynamic> toMap(Document document) {
    return _documentToJson(document);
  }

  /// Deserializes a document from a JSON map
  MutableDocument fromMap(Map<String, dynamic> json) {
    return _documentFromJson(json);
  }

  Map<String, dynamic> _documentToJson(Document document) {
    final nodes = <Map<String, dynamic>>[];

    for (int i = 0; i < document.nodeCount; i++) {
      final node = document.getNodeAt(i);
      nodes.add(_nodeToJson(node));
    }

    return {
      'version': 1,
      'nodes': nodes,
    };
  }

  Map<String, dynamic> _nodeToJson(DocumentNode node) {
    if (node is ParagraphNode) {
      return {
        'type': 'paragraph',
        'id': node.id,
        'text': node.text.text,
        'metadata': _metadataToJson(node.metadata),
      };
    } else if (node is ListItemNode) {
      return {
        'type': 'listItem',
        'id': node.id,
        'text': node.text.text,
        'itemType': node.type.name,
      };
    } else if (node is TaskNode) {
      return {
        'type': 'task',
        'id': node.id,
        'text': node.text.text,
        'isComplete': node.isComplete,
      };
    } else if (node is ImageNode) {
      return {
        'type': 'image',
        'id': node.id,
        'imageUrl': node.imageUrl,
        'altText': node.altText,
      };
    } else if (node is HorizontalRuleNode) {
      return {
        'type': 'horizontalRule',
        'id': node.id,
      };
    }

    return {
      'type': 'unknown',
      'id': node.id,
    };
  }

  Map<String, dynamic> _metadataToJson(Map<String, dynamic> metadata) {
    final result = <String, dynamic>{};

    for (final entry in metadata.entries) {
      if (entry.value is Attribution) {
        result[entry.key] = _attributionToString(entry.value as Attribution);
      } else {
        result[entry.key] = entry.value;
      }
    }

    return result;
  }

  String _attributionToString(Attribution attribution) {
    if (attribution == header1Attribution) return 'header1';
    if (attribution == header2Attribution) return 'header2';
    if (attribution == header3Attribution) return 'header3';
    if (attribution == header4Attribution) return 'header4';
    if (attribution == header5Attribution) return 'header5';
    if (attribution == header6Attribution) return 'header6';
    if (attribution == blockquoteAttribution) return 'blockquote';
    if (attribution == codeAttribution) return 'code';
    return 'paragraph';
  }

  MutableDocument _documentFromJson(Map<String, dynamic> json) {
    final nodesJson = json['nodes'] as List<dynamic>? ?? [];
    final nodes = <DocumentNode>[];

    for (final nodeJson in nodesJson) {
      final node = _nodeFromJson(nodeJson as Map<String, dynamic>);
      if (node != null) {
        nodes.add(node);
      }
    }

    if (nodes.isEmpty) {
      nodes.add(ParagraphNode(
        id: Editor.createNodeId(),
        text: AttributedText(''),
      ));
    }

    return MutableDocument(nodes: nodes);
  }

  DocumentNode? _nodeFromJson(Map<String, dynamic> json) {
    final type = json['type'] as String?;
    final id = json['id'] as String? ?? Editor.createNodeId();

    switch (type) {
      case 'paragraph':
        return ParagraphNode(
          id: id,
          text: AttributedText(json['text'] as String? ?? ''),
          metadata: _metadataFromJson(json['metadata'] as Map<String, dynamic>?),
        );
      case 'listItem':
        return ListItemNode(
          id: id,
          itemType: _parseListItemType(json['itemType'] as String?),
          text: AttributedText(json['text'] as String? ?? ''),
        );
      case 'task':
        return TaskNode(
          id: id,
          text: AttributedText(json['text'] as String? ?? ''),
          isComplete: json['isComplete'] as bool? ?? false,
        );
      case 'image':
        return ImageNode(
          id: id,
          imageUrl: json['imageUrl'] as String? ?? '',
          altText: json['altText'] as String? ?? '',
        );
      case 'horizontalRule':
        return HorizontalRuleNode(id: id);
      default:
        return null;
    }
  }

  Map<String, dynamic> _metadataFromJson(Map<String, dynamic>? metadata) {
    if (metadata == null) return {};

    final result = <String, dynamic>{};

    for (final entry in metadata.entries) {
      if (entry.key == 'blockType' && entry.value is String) {
        result[entry.key] = _stringToAttribution(entry.value as String);
      } else {
        result[entry.key] = entry.value;
      }
    }

    return result;
  }

  Attribution? _stringToAttribution(String value) {
    switch (value) {
      case 'header1':
        return header1Attribution;
      case 'header2':
        return header2Attribution;
      case 'header3':
        return header3Attribution;
      case 'header4':
        return header4Attribution;
      case 'header5':
        return header5Attribution;
      case 'header6':
        return header6Attribution;
      case 'blockquote':
        return blockquoteAttribution;
      case 'code':
        return codeAttribution;
      default:
        return null;
    }
  }

  ListItemType _parseListItemType(String? type) {
    if (type == 'ordered') return ListItemType.ordered;
    return ListItemType.unordered;
  }
}
