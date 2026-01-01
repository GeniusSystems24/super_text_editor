import 'package:flutter/material.dart';

/// Categories of special characters
enum SpecialCharacterCategory {
  /// Common symbols
  common('Common'),

  /// Currency symbols
  currency('Currency'),

  /// Mathematical symbols
  math('Math'),

  /// Arrows
  arrows('Arrows'),

  /// Latin characters
  latin('Latin'),

  /// Greek letters
  greek('Greek'),

  /// Punctuation
  punctuation('Punctuation');

  final String label;
  const SpecialCharacterCategory(this.label);
}

/// Special characters data
const Map<SpecialCharacterCategory, List<String>> specialCharacters = {
  SpecialCharacterCategory.common: [
    '©', '®', '™', '°', '±', '×', '÷', '•', '…', '—',
    '–', '†', '‡', '§', '¶', '№', '‰', '′', '″', '‴',
  ],
  SpecialCharacterCategory.currency: [
    '\$', '€', '£', '¥', '¢', '₹', '₽', '₩', '₿', '฿',
    '₫', '₴', '₦', '₱', '₪', '₡', '₲', '₵', '₸', '₺',
  ],
  SpecialCharacterCategory.math: [
    '∞', '∑', '∏', '√', '∛', '∜', '∫', '∬', '∂', '∇',
    '≈', '≠', '≤', '≥', '≡', '∝', '∈', '∉', '∩', '∪',
    '⊂', '⊃', '⊆', '⊇', '∅', '∴', '∵', '∀', '∃', '¬',
  ],
  SpecialCharacterCategory.arrows: [
    '←', '→', '↑', '↓', '↔', '↕', '⇐', '⇒', '⇑', '⇓',
    '⇔', '⇕', '↖', '↗', '↘', '↙', '↩', '↪', '↰', '↱',
    '➔', '➜', '➡', '⬅', '⬆', '⬇', '⬈', '⬉', '⬊', '⬋',
  ],
  SpecialCharacterCategory.latin: [
    'À', 'Á', 'Â', 'Ã', 'Ä', 'Å', 'Æ', 'Ç', 'È', 'É',
    'Ê', 'Ë', 'Ì', 'Í', 'Î', 'Ï', 'Ñ', 'Ò', 'Ó', 'Ô',
    'Õ', 'Ö', 'Ø', 'Ù', 'Ú', 'Û', 'Ü', 'Ý', 'ß', 'à',
    'á', 'â', 'ã', 'ä', 'å', 'æ', 'ç', 'è', 'é', 'ê',
  ],
  SpecialCharacterCategory.greek: [
    'Α', 'Β', 'Γ', 'Δ', 'Ε', 'Ζ', 'Η', 'Θ', 'Ι', 'Κ',
    'Λ', 'Μ', 'Ν', 'Ξ', 'Ο', 'Π', 'Ρ', 'Σ', 'Τ', 'Υ',
    'Φ', 'Χ', 'Ψ', 'Ω', 'α', 'β', 'γ', 'δ', 'ε', 'ζ',
    'η', 'θ', 'ι', 'κ', 'λ', 'μ', 'ν', 'ξ', 'ο', 'π',
  ],
  SpecialCharacterCategory.punctuation: [
    '¡', '¿', '«', '»', '‹', '›', '"', '"', ''', ''',
    '„', '‚', '·', '¦', '¨', '¯', '´', '¸', 'ˆ', '˜',
  ],
};

/// Dialog for inserting special characters
class SpecialCharactersDialog extends StatefulWidget {
  /// Creates a new SpecialCharactersDialog
  const SpecialCharactersDialog({super.key});

  /// Shows the dialog and returns the selected character
  static Future<String?> show(BuildContext context) {
    return showDialog<String>(
      context: context,
      builder: (context) => const SpecialCharactersDialog(),
    );
  }

  @override
  State<SpecialCharactersDialog> createState() =>
      _SpecialCharactersDialogState();
}

class _SpecialCharactersDialogState extends State<SpecialCharactersDialog>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String? _hoveredChar;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: SpecialCharacterCategory.values.length,
      vsync: this,
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AlertDialog(
      title: Row(
        children: [
          const Text('Special Characters'),
          const Spacer(),
          if (_hoveredChar != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                _hoveredChar!,
                style: TextStyle(
                  fontSize: 24,
                  color: theme.colorScheme.onPrimaryContainer,
                ),
              ),
            ),
        ],
      ),
      content: SizedBox(
        width: 400,
        height: 350,
        child: Column(
          children: [
            TabBar(
              controller: _tabController,
              isScrollable: true,
              tabs: SpecialCharacterCategory.values.map((cat) {
                return Tab(text: cat.label);
              }).toList(),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: SpecialCharacterCategory.values.map((cat) {
                  return _buildCharacterGrid(specialCharacters[cat]!);
                }).toList(),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Close'),
        ),
      ],
    );
  }

  Widget _buildCharacterGrid(List<String> chars) {
    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 10,
        childAspectRatio: 1,
        crossAxisSpacing: 4,
        mainAxisSpacing: 4,
      ),
      itemCount: chars.length,
      itemBuilder: (context, index) {
        final char = chars[index];
        return _CharacterButton(
          character: char,
          onTap: () => Navigator.of(context).pop(char),
          onHover: (isHovered) {
            setState(() {
              _hoveredChar = isHovered ? char : null;
            });
          },
        );
      },
    );
  }
}

class _CharacterButton extends StatefulWidget {
  final String character;
  final VoidCallback onTap;
  final ValueChanged<bool> onHover;

  const _CharacterButton({
    required this.character,
    required this.onTap,
    required this.onHover,
  });

  @override
  State<_CharacterButton> createState() => _CharacterButtonState();
}

class _CharacterButtonState extends State<_CharacterButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return MouseRegion(
      onEnter: (_) {
        setState(() => _isHovered = true);
        widget.onHover(true);
      },
      onExit: (_) {
        setState(() => _isHovered = false);
        widget.onHover(false);
      },
      child: GestureDetector(
        onTap: widget.onTap,
        child: Container(
          decoration: BoxDecoration(
            color: _isHovered
                ? theme.colorScheme.primary.withValues(alpha: 0.2)
                : theme.colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(4),
            border: Border.all(
              color: _isHovered
                  ? theme.colorScheme.primary
                  : theme.dividerColor,
            ),
          ),
          alignment: Alignment.center,
          child: Text(
            widget.character,
            style: TextStyle(
              fontSize: 18,
              color: theme.colorScheme.onSurface,
            ),
          ),
        ),
      ),
    );
  }
}
