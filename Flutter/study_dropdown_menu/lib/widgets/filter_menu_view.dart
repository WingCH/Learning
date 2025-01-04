import 'package:flutter/material.dart';

import 'filter_menu_model.dart';

class FilterMenuView extends StatefulWidget {
  final FilterMenuModel initialValue;
  final VoidCallback? onReset;
  final Function(Set<String>)? onConfirm;

  const FilterMenuView({
    super.key,
    required this.initialValue,
    this.onReset,
    this.onConfirm,
  });

  @override
  State<FilterMenuView> createState() => _FilterMenuViewState();
}

class _FilterMenuViewState extends State<FilterMenuView> {
  late FilterMenuModel _value;
  late List<GlobalKey> _categoryKeys;
  late ScrollController _scrollController;
  static const double separatorHeight = 19.0;
  int _selectedCategoryIndex = 0;

  @override
  void initState() {
    super.initState();
    _value = widget.initialValue;
    _categoryKeys = List.generate(
      _value.categories.length,
      (index) => GlobalKey(),
    );
    _scrollController = ScrollController();
    _scrollController.addListener(_updateSelectedCategory);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_updateSelectedCategory);
    _scrollController.dispose();
    super.dispose();
  }

  void _updateSelectedCategory() {
    if (!_scrollController.hasClients) return;

    final scrollOffset = _scrollController.offset;
    var totalHeight = 0.0;

    for (int i = 0; i < _categoryKeys.length; i++) {
      final key = _categoryKeys[i];
      final renderObject = key.currentContext?.findRenderObject() as RenderBox?;

      if (renderObject != null) {
        final height = renderObject.size.height + separatorHeight;

        // Check if this section is the most visible one
        if (scrollOffset >= totalHeight &&
            scrollOffset < (totalHeight + height)) {
          if (_selectedCategoryIndex != i) {
            setState(() {
              _selectedCategoryIndex = i;
            });
          }
          break;
        }

        totalHeight += height;
      }
    }
  }

  void _onSelectedItem({
    required String categoryId,
    required String itemId,
    required bool selected,
  }) {
    setState(() {
      _value = _value.toggleItem(
        categoryId: categoryId,
        itemId: itemId,
        isSelected: selected,
      );
    });
  }

  void _handleReset() {
    setState(() {
      _value = widget.initialValue;
    });
  }

  void _handleConfirm() {
    widget.onConfirm?.call(_value.selectedItemIds);
  }

  Future<void> _scrollToCategory(int index) async {
    final categoryKey = _categoryKeys[index];
    final context = categoryKey.currentContext;
    if (context != null) {
      await Scrollable.ensureVisible(
        context,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        alignment: 0.0,
      );
      setState(() {
        _selectedCategoryIndex = index;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 367,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(20),
          bottomRight: Radius.circular(20),
        ),
      ),
      child: Column(
        children: [
          Expanded(
            child: _FilterContent(
              value: _value,
              categoryKeys: _categoryKeys,
              selectedCategoryIndex: _selectedCategoryIndex,
              scrollController: _scrollController,
              onCategoryTap: _scrollToCategory,
              onSelectedItem: _onSelectedItem,
            ),
          ),
          _ActionButtons(
            onReset: _handleReset,
            onConfirm: _handleConfirm,
          ),
        ],
      ),
    );
  }
}

// New widget for filter content
class _FilterContent extends StatelessWidget {
  final FilterMenuModel value;
  final List<GlobalKey> categoryKeys;
  final int selectedCategoryIndex;
  final ScrollController scrollController;
  final Future<void> Function(int) onCategoryTap;
  final Function({
    required String categoryId,
    required String itemId,
    required bool selected,
  }) onSelectedItem;

  const _FilterContent({
    required this.value,
    required this.categoryKeys,
    required this.selectedCategoryIndex,
    required this.scrollController,
    required this.onCategoryTap,
    required this.onSelectedItem,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _CategoryList(
          categories: value.categories,
          selectedIndex: selectedCategoryIndex,
          onCategoryTap: onCategoryTap,
        ),
        _FilterSectionList(
          value: value,
          categoryKeys: categoryKeys,
          scrollController: scrollController,
          onSelectedItem: onSelectedItem,
        ),
      ],
    );
  }
}

class _CategoryList extends StatelessWidget {
  final List<FilterCategory> categories;
  final int selectedIndex;
  final Future<void> Function(int) onCategoryTap;

  const _CategoryList({
    required this.categories,
    required this.selectedIndex,
    required this.onCategoryTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.sizeOf(context).width * (100 / 375),
      color: const Color(0xFFFAFAFC),
      child: ListView.builder(
        itemCount: categories.length,
        itemBuilder: (context, index) => GestureDetector(
          onTap: () => onCategoryTap(index),
          child: _CategoryListItem(
            category: categories[index],
            isSelected: index == selectedIndex,
          ),
        ),
      ),
    );
  }
}

// New widget for filter section list
class _FilterSectionList extends StatelessWidget {
  final FilterMenuModel value;
  final List<GlobalKey> categoryKeys;
  final ScrollController scrollController;
  final Function({
    required String categoryId,
    required String itemId,
    required bool selected,
  }) onSelectedItem;

  const _FilterSectionList({
    required this.value,
    required this.categoryKeys,
    required this.scrollController,
    required this.onSelectedItem,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: SingleChildScrollView(
        controller: scrollController,
        child: Padding(
          padding: const EdgeInsets.only(
            left: 25,
            right: 18,
            top: 14,
            bottom: 14,
          ),
          child: Column(
            children: List.generate(
              value.categories.length,
              (index) => Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _FilterSection(
                    key: categoryKeys[index],
                    category: value.categories[index],
                    onSelect: (itemId, selected) {
                      onSelectedItem(
                        categoryId: value.categories[index].id,
                        itemId: itemId,
                        selected: selected,
                      );
                    },
                  ),
                  if (index < value.categories.length - 1)
                    const SizedBox(
                      height: _FilterMenuViewState.separatorHeight,
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// New widget for action buttons
class _ActionButtons extends StatelessWidget {
  final VoidCallback onReset;
  final VoidCallback onConfirm;

  const _ActionButtons({
    required this.onReset,
    required this.onConfirm,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: onReset,
              child: const Text('Reset'),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: FilledButton(
              onPressed: onConfirm,
              child: const Text('Confirm'),
            ),
          ),
        ],
      ),
    );
  }
}

class _CategoryListItem extends StatelessWidget {
  final FilterCategory category;
  final bool isSelected;

  const _CategoryListItem({
    required this.category,
    required this.isSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: isSelected ? Colors.white : Colors.grey[50],
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          bottomLeft: Radius.circular(20),
        ),
      ),
      padding: const EdgeInsets.symmetric(
        vertical: 16,
        horizontal: 12,
      ),
      child: Text(
        category.displayName,
        style: TextStyle(
          color: Colors.grey[600],
          fontSize: 16,
        ),
      ),
    );
  }
}

class _FilterSection extends StatelessWidget {
  final FilterCategory category;
  final Function(String, bool) onSelect;

  const _FilterSection({
    required super.key,
    required this.category,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          category.displayName,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: category.items
              .map(
                (item) => _FilterChip(
                  item: item,
                  onSelected: (selected) {
                    onSelect(item.id, selected);
                  },
                ),
              )
              .toList(),
        ),
      ],
    );
  }
}

class _FilterChip extends StatelessWidget {
  final CategoryItem item;
  final Function(bool) onSelected;

  const _FilterChip({
    required this.item,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return FilterChip(
      label: Text(item.displayName),
      selected: item.isSelected,
      onSelected: (bool selected) {
        onSelected(selected);
      },
      backgroundColor: Colors.grey[100],
      selectedColor: Colors.black,
      labelStyle: TextStyle(
        color: item.isSelected ? Colors.white : Colors.black,
      ),
    );
  }
}
