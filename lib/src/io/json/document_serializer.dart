import 'dart:convert';
import '../../core/document/document.dart';

/// Serializes and deserializes documents to/from JSON
class DocumentSerializer {
  /// Creates a new document serializer
  const DocumentSerializer();

  /// Serializes a document to a JSON string
  String serialize(Document document, {bool pretty = false}) {
    final json = document.toJson();

    if (pretty) {
      return const JsonEncoder.withIndent('  ').convert(json);
    }

    return jsonEncode(json);
  }

  /// Deserializes a document from a JSON string
  Document deserialize(String jsonString) {
    final json = jsonDecode(jsonString) as Map<String, dynamic>;
    return Document.fromJson(json);
  }

  /// Serializes a document to a JSON map
  Map<String, dynamic> toMap(Document document) {
    return document.toJson();
  }

  /// Deserializes a document from a JSON map
  Document fromMap(Map<String, dynamic> json) {
    return Document.fromJson(json);
  }
}
