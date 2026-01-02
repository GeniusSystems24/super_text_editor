import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import 'nodes.dart';

const _uuid = Uuid();

/// Generates a unique node ID
String generateNodeId() => _uuid.v4();

/// A document composed of a list of nodes
class Document extends ChangeNotifier {
  /// The list of nodes in this document
  final List<DocumentNode> _nodes;

  /// Version number for change tracking
  int _version = 0;

  /// Creates a new document with the given nodes
  Document([List<DocumentNode>? nodes]) : _nodes = nodes ?? [ParagraphNode()];

  /// Creates an empty document with a single paragraph
  factory Document.empty() => Document([ParagraphNode()]);

  /// The version number
  int get version => _version;

  /// The nodes in this document
  List<DocumentNode> get nodes => List.unmodifiable(_nodes);

  /// The number of nodes in this document
  int get length => _nodes.length;

  /// Whether this document is empty
  bool get isEmpty => _nodes.isEmpty || (_nodes.length == 1 && _nodes.first.isEmpty);

  /// Gets a node by its ID
  DocumentNode? getNodeById(String id) {
    for (final node in _nodes) {
      if (node.id == id) return node;
    }
    return null;
  }

  /// Gets the index of a node by its ID
  int getNodeIndex(String id) {
    for (int i = 0; i < _nodes.length; i++) {
      if (_nodes[i].id == id) return i;
    }
    return -1;
  }

  /// Gets a node at the given index
  DocumentNode getNodeAt(int index) {
    if (index < 0 || index >= _nodes.length) {
      throw RangeError('Index $index is out of range [0, ${_nodes.length})');
    }
    return _nodes[index];
  }

  /// Inserts a node at the given index
  void insertNode(int index, DocumentNode node) {
    if (index < 0 || index > _nodes.length) {
      throw RangeError('Index $index is out of range [0, ${_nodes.length}]');
    }
    _nodes.insert(index, node);
    _version++;
    notifyListeners();
  }

  /// Inserts a node after the node with the given ID
  void insertNodeAfter(String nodeId, DocumentNode node) {
    final index = getNodeIndex(nodeId);
    if (index == -1) {
      throw ArgumentError('Node with ID $nodeId not found');
    }
    insertNode(index + 1, node);
  }

  /// Inserts a node before the node with the given ID
  void insertNodeBefore(String nodeId, DocumentNode node) {
    final index = getNodeIndex(nodeId);
    if (index == -1) {
      throw ArgumentError('Node with ID $nodeId not found');
    }
    insertNode(index, node);
  }

  /// Removes a node at the given index
  DocumentNode removeNodeAt(int index) {
    if (index < 0 || index >= _nodes.length) {
      throw RangeError('Index $index is out of range [0, ${_nodes.length})');
    }
    final node = _nodes.removeAt(index);

    // Ensure document always has at least one node
    if (_nodes.isEmpty) {
      _nodes.add(ParagraphNode());
    }

    _version++;
    notifyListeners();
    return node;
  }

  /// Removes a node by its ID
  DocumentNode? removeNode(String id) {
    final index = getNodeIndex(id);
    if (index == -1) return null;
    return removeNodeAt(index);
  }

  /// Replaces a node at the given index
  void replaceNode(int index, DocumentNode node) {
    if (index < 0 || index >= _nodes.length) {
      throw RangeError('Index $index is out of range [0, ${_nodes.length})');
    }
    _nodes[index] = node;
    _version++;
    notifyListeners();
  }

  /// Replaces a node by its ID
  void replaceNodeById(String id, DocumentNode node) {
    final index = getNodeIndex(id);
    if (index == -1) {
      throw ArgumentError('Node with ID $id not found');
    }
    replaceNode(index, node);
  }

  /// Moves a node from one index to another
  void moveNode(int fromIndex, int toIndex) {
    if (fromIndex < 0 || fromIndex >= _nodes.length) {
      throw RangeError('From index $fromIndex is out of range [0, ${_nodes.length})');
    }
    if (toIndex < 0 || toIndex >= _nodes.length) {
      throw RangeError('To index $toIndex is out of range [0, ${_nodes.length})');
    }

    if (fromIndex == toIndex) return;

    final node = _nodes.removeAt(fromIndex);
    _nodes.insert(toIndex, node);
    _version++;
    notifyListeners();
  }

  /// Updates a node in place
  void updateNode(String id, DocumentNode Function(DocumentNode) updater) {
    final index = getNodeIndex(id);
    if (index == -1) {
      throw ArgumentError('Node with ID $id not found');
    }
    _nodes[index] = updater(_nodes[index]);
    _version++;
    notifyListeners();
  }

  /// Clears all nodes and replaces with a single empty paragraph
  void clear() {
    _nodes.clear();
    _nodes.add(ParagraphNode());
    _version++;
    notifyListeners();
  }

  /// Gets the plain text content of the document
  String get plainText {
    final buffer = StringBuffer();
    for (int i = 0; i < _nodes.length; i++) {
      buffer.write(_nodes[i].plainText);
      if (i < _nodes.length - 1) {
        buffer.writeln();
      }
    }
    return buffer.toString();
  }

  /// Converts the document to JSON
  Map<String, dynamic> toJson() {
    return {
      'version': 1,
      'nodes': _nodes.map((n) => n.toJson()).toList(),
    };
  }

  /// Creates a document from JSON
  factory Document.fromJson(Map<String, dynamic> json) {
    final nodesJson = json['nodes'] as List<dynamic>;
    final nodes = nodesJson.map((n) => DocumentNode.fromJson(n as Map<String, dynamic>)).toList();
    return Document(nodes);
  }

  /// Creates a deep copy of this document
  Document copy() {
    return Document(_nodes.map((n) => n.copy()).toList());
  }

  @override
  String toString() => 'Document(nodes: ${_nodes.length}, version: $_version)';
}
