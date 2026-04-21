import 'package:equatable/equatable.dart';

class EventListEntity extends Equatable {
  const EventListEntity({
    required this.id,
    required this.code,
    required this.name,
    this.eventDate,
    this.description,
    this.isArchived = false,
    required this.createdAt,
    required this.updatedAt,
  });

  final int id;
  final String code;
  final String name;
  final DateTime? eventDate;
  final String? description;
  final bool isArchived;
  final DateTime createdAt;
  final DateTime updatedAt;

  EventListEntity copyWith({
    int? id,
    String? code,
    String? name,
    DateTime? eventDate,
    String? description,
    bool? isArchived,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return EventListEntity(
      id: id ?? this.id,
      code: code ?? this.code,
      name: name ?? this.name,
      eventDate: eventDate ?? this.eventDate,
      description: description ?? this.description,
      isArchived: isArchived ?? this.isArchived,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
    id,
    code,
    name,
    eventDate,
    description,
    isArchived,
    createdAt,
    updatedAt,
  ];
}
