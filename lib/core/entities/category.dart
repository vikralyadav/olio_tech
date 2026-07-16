import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

enum CategoryType { income, expense }

class Category extends Equatable {
  final String id;
  final String name;
  final IconData icon;
  final Color color;
  final CategoryType type;

  const Category({
    required this.id,
    required this.name,
    required this.icon,
    required this.color,
    required this.type,
  });

  @override
  List<Object?> get props => [id, name, icon, color, type];
}
