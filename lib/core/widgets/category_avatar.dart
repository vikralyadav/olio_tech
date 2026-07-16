import 'package:flutter/material.dart';

import '../data/mock_data.dart';
import '../entities/category.dart';

/// Resolves category reference data (icon + colour) by id.
class CategoryVisuals {
  const CategoryVisuals._();

  static Category? byId(String? id) {
    if (id == null) return null;
    for (final c in MockData.categories) {
      if (c.id == id) return c;
    }
    return null;
  }

  static IconData iconFor(String? id) =>
      byId(id)?.icon ?? Icons.category_outlined;

  static Color colorFor(String? id) => byId(id)?.color ?? const Color(0xFF9E9E9E);
}

/// A circular category icon on a tinted background.
class CategoryAvatar extends StatelessWidget {
  final String categoryId;
  final double size;

  const CategoryAvatar({
    super.key,
    required this.categoryId,
    this.size = 44,
  });

  @override
  Widget build(BuildContext context) {
    final color = CategoryVisuals.colorFor(categoryId);
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        shape: BoxShape.circle,
      ),
      child: Icon(
        CategoryVisuals.iconFor(categoryId),
        color: color,
        size: size * 0.5,
      ),
    );
  }
}
