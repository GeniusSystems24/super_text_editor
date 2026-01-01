import 'package:flutter/material.dart';

/// Categories of emojis
enum EmojiCategory {
  /// Smileys & Emotion
  smileys('😀', 'Smileys'),

  /// People & Body
  people('👋', 'People'),

  /// Animals & Nature
  animals('🐱', 'Animals'),

  /// Food & Drink
  food('🍕', 'Food'),

  /// Travel & Places
  travel('✈️', 'Travel'),

  /// Activities
  activities('⚽', 'Activities'),

  /// Objects
  objects('💡', 'Objects'),

  /// Symbols
  symbols('❤️', 'Symbols');

  final String icon;
  final String label;
  const EmojiCategory(this.icon, this.label);
}

/// Emoji data organized by category
const Map<EmojiCategory, List<String>> emojis = {
  EmojiCategory.smileys: [
    '😀', '😃', '😄', '😁', '😆', '😅', '🤣', '😂', '🙂', '😊',
    '😇', '🥰', '😍', '🤩', '😘', '😗', '😚', '😙', '🥲', '😋',
    '😛', '😜', '🤪', '😝', '🤑', '🤗', '🤭', '🤫', '🤔', '🤐',
    '🤨', '😐', '😑', '😶', '😏', '😒', '🙄', '😬', '😮', '🥱',
    '😴', '🤤', '😪', '😵', '🤯', '🤠', '🥳', '🥸', '😎', '🤓',
    '🧐', '😕', '😟', '🙁', '☹️', '😮', '😯', '😲', '😳', '🥺',
    '😦', '😧', '😨', '😰', '😥', '😢', '😭', '😱', '😖', '😣',
    '😞', '😓', '😩', '😫', '🥱', '😤', '😡', '😠', '🤬', '😈',
  ],
  EmojiCategory.people: [
    '👋', '🤚', '🖐️', '✋', '🖖', '👌', '🤌', '🤏', '✌️', '🤞',
    '🤟', '🤘', '🤙', '👈', '👉', '👆', '🖕', '👇', '☝️', '👍',
    '👎', '✊', '👊', '🤛', '🤜', '👏', '🙌', '👐', '🤲', '🤝',
    '🙏', '✍️', '💅', '🤳', '💪', '🦾', '🦿', '🦵', '🦶', '👂',
    '🦻', '👃', '🧠', '🫀', '🫁', '🦷', '🦴', '👀', '👁️', '👅',
    '👄', '👶', '🧒', '👦', '👧', '🧑', '👱', '👨', '🧔', '👩',
  ],
  EmojiCategory.animals: [
    '🐶', '🐱', '🐭', '🐹', '🐰', '🦊', '🐻', '🐼', '🐻‍❄️', '🐨',
    '🐯', '🦁', '🐮', '🐷', '🐸', '🐵', '🙈', '🙉', '🙊', '🐒',
    '🐔', '🐧', '🐦', '🐤', '🐣', '🐥', '🦆', '🦅', '🦉', '🦇',
    '🐺', '🐗', '🐴', '🦄', '🐝', '🪱', '🐛', '🦋', '🐌', '🐞',
    '🐜', '🪰', '🪲', '🪳', '🦟', '🦗', '🕷️', '🦂', '🐢', '🐍',
    '🦎', '🦖', '🦕', '🐙', '🦑', '🦐', '🦞', '🦀', '🐡', '🐠',
  ],
  EmojiCategory.food: [
    '🍏', '🍎', '🍐', '🍊', '🍋', '🍌', '🍉', '🍇', '🍓', '🫐',
    '🍈', '🍒', '🍑', '🥭', '🍍', '🥥', '🥝', '🍅', '🍆', '🥑',
    '🥦', '🥬', '🥒', '🌶️', '🫑', '🌽', '🥕', '🫒', '🧄', '🧅',
    '🥔', '🍠', '🥐', '🥯', '🍞', '🥖', '🥨', '🧀', '🥚', '🍳',
    '🧈', '🥞', '🧇', '🥓', '🥩', '🍗', '🍖', '🦴', '🌭', '🍔',
    '🍟', '🍕', '🫓', '🥪', '🥙', '🧆', '🌮', '🌯', '🫔', '🥗',
  ],
  EmojiCategory.travel: [
    '🚗', '🚕', '🚙', '🚌', '🚎', '🏎️', '🚓', '🚑', '🚒', '🚐',
    '🛻', '🚚', '🚛', '🚜', '🏍️', '🛵', '🚲', '🛴', '🛹', '🛼',
    '🚁', '🛸', '✈️', '🛩️', '🛫', '🛬', '🚀', '🛰️', '🚢', '⛵',
    '🏠', '🏡', '🏢', '🏣', '🏤', '🏥', '🏦', '🏨', '🏩', '🏪',
    '🏫', '🏬', '🏭', '🏯', '🏰', '💒', '🗼', '🗽', '⛪', '🕌',
    '🛕', '🕍', '⛩️', '🕋', '⛲', '⛺', '🌁', '🌃', '🏙️', '🌄',
  ],
  EmojiCategory.activities: [
    '⚽', '🏀', '🏈', '⚾', '🥎', '🎾', '🏐', '🏉', '🥏', '🎱',
    '🪀', '🏓', '🏸', '🏒', '🏑', '🥍', '🏏', '🪃', '🥅', '⛳',
    '🪁', '🏹', '🎣', '🤿', '🥊', '🥋', '🎽', '🛹', '🛼', '🛷',
    '⛸️', '🥌', '🎿', '⛷️', '🏂', '🪂', '🏋️', '🤼', '🤸', '🤺',
    '🏆', '🥇', '🥈', '🥉', '🏅', '🎖️', '🎗️', '🎫', '🎟️', '🎪',
    '🎭', '🎨', '🎬', '🎤', '🎧', '🎼', '🎹', '🥁', '🪘', '🎷',
  ],
  EmojiCategory.objects: [
    '💡', '🔦', '🏮', '🪔', '📱', '📲', '💻', '🖥️', '🖨️', '🖱️',
    '🖲️', '💽', '💾', '💿', '📀', '🧮', '🎥', '📹', '📼', '📷',
    '📸', '📺', '📻', '🎙️', '⏰', '⏱️', '⏲️', '🕰️', '📡', '🔋',
    '🔌', '💎', '🔮', '💰', '💴', '💵', '💶', '💷', '💸', '💳',
    '🧾', '📦', '📫', '📪', '📬', '📭', '📮', '📯', '📜', '📃',
    '📄', '📑', '📊', '📈', '📉', '📆', '📅', '🗓️', '📇', '🗃️',
  ],
  EmojiCategory.symbols: [
    '❤️', '🧡', '💛', '💚', '💙', '💜', '🖤', '🤍', '🤎', '💔',
    '❣️', '💕', '💞', '💓', '💗', '💖', '💘', '💝', '💟', '☮️',
    '✝️', '☪️', '🕉️', '☸️', '✡️', '🔯', '🕎', '☯️', '☦️', '🛐',
    '⛎', '♈', '♉', '♊', '♋', '♌', '♍', '♎', '♏', '♐',
    '♑', '♒', '♓', '🆔', '⚛️', '🉑', '☢️', '☣️', '📴', '📳',
    '🈶', '🈚', '🈸', '🈺', '🈷️', '✴️', '🆚', '💮', '🉐', '㊙️',
  ],
};

/// Dialog for inserting emojis
class EmojiPickerDialog extends StatefulWidget {
  /// Creates a new EmojiPickerDialog
  const EmojiPickerDialog({super.key});

  /// Shows the dialog and returns the selected emoji
  static Future<String?> show(BuildContext context) {
    return showDialog<String>(
      context: context,
      builder: (context) => const EmojiPickerDialog(),
    );
  }

  @override
  State<EmojiPickerDialog> createState() => _EmojiPickerDialogState();
}

class _EmojiPickerDialogState extends State<EmojiPickerDialog> {
  EmojiCategory _selectedCategory = EmojiCategory.smileys;
  final TextEditingController _searchController = TextEditingController();
  List<String> _filteredEmojis = [];
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    _filteredEmojis = emojis[_selectedCategory]!;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    setState(() {
      if (query.isEmpty) {
        _isSearching = false;
        _filteredEmojis = emojis[_selectedCategory]!;
      } else {
        _isSearching = true;
        _filteredEmojis = [];
        for (final category in emojis.values) {
          _filteredEmojis.addAll(category);
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AlertDialog(
      title: const Text('Insert Emoji'),
      content: SizedBox(
        width: 350,
        height: 400,
        child: Column(
          children: [
            // Search bar
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search emojis...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                isDense: true,
              ),
              onChanged: _onSearchChanged,
            ),
            const SizedBox(height: 12),
            // Category tabs
            if (!_isSearching)
              SizedBox(
                height: 40,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: EmojiCategory.values.length,
                  itemBuilder: (context, index) {
                    final category = EmojiCategory.values[index];
                    final isSelected = category == _selectedCategory;
                    return Padding(
                      padding: const EdgeInsets.only(right: 4),
                      child: FilterChip(
                        label: Text(category.icon),
                        selected: isSelected,
                        onSelected: (_) {
                          setState(() {
                            _selectedCategory = category;
                            _filteredEmojis = emojis[category]!;
                          });
                        },
                        tooltip: category.label,
                      ),
                    );
                  },
                ),
              ),
            const SizedBox(height: 8),
            // Emoji grid
            Expanded(
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 8,
                  childAspectRatio: 1,
                ),
                itemCount: _filteredEmojis.length,
                itemBuilder: (context, index) {
                  final emoji = _filteredEmojis[index];
                  return InkWell(
                    onTap: () => Navigator.of(context).pop(emoji),
                    borderRadius: BorderRadius.circular(4),
                    child: Container(
                      alignment: Alignment.center,
                      child: Text(
                        emoji,
                        style: const TextStyle(fontSize: 24),
                      ),
                    ),
                  );
                },
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
}
