class CategoryItem {
  final String id;
  final String displayName;
  bool isSelected;

  CategoryItem({
    required this.id,
    required this.displayName,
    this.isSelected = false,
  });

  CategoryItem copyWith({
    String? id,
    String? displayName,
    bool? isSelected,
  }) {
    return CategoryItem(
      id: id ?? this.id,
      displayName: displayName ?? this.displayName,
      isSelected: isSelected ?? this.isSelected,
    );
  }

  @override
  bool operator ==(Object other) {
    return other is CategoryItem &&
        other.id == id &&
        other.displayName == displayName &&
        other.isSelected == isSelected;
  }

  @override
  int get hashCode => id.hashCode ^ displayName.hashCode ^ isSelected.hashCode;
}

class FilterCategory {
  final String id;
  final String displayName;
  final List<CategoryItem> items;

  FilterCategory({
    required this.id,
    required this.displayName,
    required this.items,
  });

  FilterCategory copyWith({
    String? id,
    String? displayName,
    List<CategoryItem>? items,
  }) {
    return FilterCategory(
      id: id ?? this.id,
      displayName: displayName ?? this.displayName,
      items: items ?? this.items,
    );
  }

  @override
  bool operator ==(Object other) {
    return other is FilterCategory &&
        other.id == id &&
        other.displayName == displayName &&
        other.items == items;
  }

  @override
  int get hashCode => id.hashCode ^ displayName.hashCode ^ items.hashCode;
}

class FilterMenuModel {
  final List<FilterCategory> categories;

  const FilterMenuModel({
    required this.categories,
  });

  // Add method to get selected items
  Set<String> get selectedItemIds => categories
      .expand((category) => category.items)
      .where((item) => item.isSelected)
      .map((item) => item.id)
      .toSet();

  FilterMenuModel copyWith({
    List<FilterCategory>? categories,
  }) {
    return FilterMenuModel(categories: categories ?? this.categories);
  }

  FilterMenuModel toggleItem({
    required String categoryId,
    required String itemId,
    bool? isSelected,
  }) {
    try {
      final categoryIndex =
          categories.indexWhere((category) => category.id == categoryId);
      if (categoryIndex == -1) {
        throw Exception('Category not found: $categoryId');
      }

      final category = categories[categoryIndex];
      final itemIndex = category.items.indexWhere((item) => item.id == itemId);
      if (itemIndex == -1) {
        throw Exception('Item not found: $itemId');
      }

      final newItems = List<CategoryItem>.from(category.items);
      newItems[itemIndex] = newItems[itemIndex].copyWith(
        isSelected: isSelected ?? !newItems[itemIndex].isSelected,
      );

      final newCategories = List<FilterCategory>.from(categories);
      newCategories[categoryIndex] = category.copyWith(items: newItems);

      return copyWith(categories: newCategories);
    } catch (e) {
      return this;
    }
  }

  @override
  bool operator ==(Object other) {
    return other is FilterMenuModel && other.categories == categories;
  }

  @override
  int get hashCode => categories.hashCode;

  static FilterMenuModel dummy() {
    return FilterMenuModel(
      categories: [
        FilterCategory(
          id: 'type',
          displayName: 'Type',
          items: List.generate(
            5,
            (index) => CategoryItem(
              id: 'type_$index',
              displayName: 'Type $index',
              isSelected: false,
            ),
          ),
        ),
        FilterCategory(
          id: 'category',
          displayName: 'Category',
          items: List.generate(
            50,
            (index) => CategoryItem(
              id: 'category_$index',
              displayName: 'Category $index',
              isSelected: false,
            ),
          ),
        ),
        FilterCategory(
          id: 'area',
          displayName: 'Area',
          items: [
            CategoryItem(
              id: 'venetian_macao',
              displayName: 'Venetian Macao',
              isSelected: false,
            ),
            CategoryItem(
              id: 'conrad_macao',
              displayName: 'Conrad Macao',
              isSelected: false,
            ),
            CategoryItem(
              id: 'londoner_macao',
              displayName: 'Londoner Macao',
              isSelected: false,
            ),
          ],
        ),
      ],
    );
  }
}
