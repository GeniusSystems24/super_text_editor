import 'package:flutter/material.dart';
import '../../core/document/nodes.dart';

/// Component for rendering an image node
class ImageComponent extends StatelessWidget {
  /// The image node to render
  final ImageNode node;

  /// Callback when the image is tapped
  final VoidCallback? onTap;

  /// Whether the image is selected
  final bool isSelected;

  const ImageComponent({
    super.key,
    required this.node,
    this.onTap,
    this.isSelected = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    Widget image;
    if (node.src.startsWith('http://') || node.src.startsWith('https://')) {
      image = Image.network(
        node.src,
        width: node.width,
        height: node.height,
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) {
          return _buildErrorPlaceholder(theme);
        },
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return _buildLoadingPlaceholder(theme, loadingProgress);
        },
      );
    } else {
      // Local file or asset
      image = Image.asset(
        node.src,
        width: node.width,
        height: node.height,
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) {
          return _buildErrorPlaceholder(theme);
        },
      );
    }

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          border: isSelected
              ? Border.all(color: theme.colorScheme.primary, width: 2)
              : null,
          borderRadius: BorderRadius.circular(4),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: _buildAlignedImage(image),
        ),
      ),
    );
  }

  Widget _buildAlignedImage(Widget image) {
    switch (node.alignment) {
      case TextAlign.center:
        return Center(child: image);
      case TextAlign.right:
        return Align(alignment: Alignment.centerRight, child: image);
      case TextAlign.left:
      case TextAlign.justify:
      default:
        return Align(alignment: Alignment.centerLeft, child: image);
    }
  }

  Widget _buildErrorPlaceholder(ThemeData theme) {
    return Container(
      width: node.width ?? 200,
      height: node.height ?? 150,
      color: theme.colorScheme.errorContainer,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.broken_image,
            size: 48,
            color: theme.colorScheme.error,
          ),
          const SizedBox(height: 8),
          Text(
            'Failed to load image',
            style: TextStyle(color: theme.colorScheme.error),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingPlaceholder(ThemeData theme, ImageChunkEvent loadingProgress) {
    final progress = loadingProgress.expectedTotalBytes != null
        ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
        : null;

    return Container(
      width: node.width ?? 200,
      height: node.height ?? 150,
      color: theme.colorScheme.surfaceContainerHighest,
      child: Center(
        child: CircularProgressIndicator(value: progress),
      ),
    );
  }
}
