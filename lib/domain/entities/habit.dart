import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

import 'habit_frequency.dart';

class Habit extends Equatable {
  const Habit({
    required this.id,
    required this.name,
    required this.description,
    required this.color,
    required this.icon,
    required this.frequency,
    required this.position,
    required this.archived,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String name;
  final String? description;
  final Color color;
  final IconData icon;
  final HabitFrequency frequency;
  final int position;
  final bool archived;
  final DateTime createdAt;
  final DateTime updatedAt;

  Habit copyWith({
    String? name,
    String? description,
    Color? color,
    IconData? icon,
    HabitFrequency? frequency,
    int? position,
    bool? archived,
    DateTime? updatedAt,
  }) {
    return Habit(
      id: id,
      name: name ?? this.name,
      description: description ?? this.description,
      color: color ?? this.color,
      icon: icon ?? this.icon,
      frequency: frequency ?? this.frequency,
      position: position ?? this.position,
      archived: archived ?? this.archived,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        name,
        description,
        color,
        icon,
        frequency,
        position,
        archived,
        createdAt,
        updatedAt,
      ];
}
