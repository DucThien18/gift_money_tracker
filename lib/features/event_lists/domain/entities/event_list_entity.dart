import 'package:equatable/equatable.dart';

class EventListEntity extends Equatable {
  const EventListEntity({
    required this.id,
    required this.code,
    required this.name,
    this.eventDate,
    this.description,
    required this.createdAt,
    required this.updatedAt,
  });

  final int id;
  final String code;
  final String name;
  final DateTime? eventDate;
  final String? description;
  final DateTime createdAt;
  final DateTime updatedAt;

  EventListEntity copyWith({
    int? id,
    String? code,
    String? name,
    DateTime? eventDate,
    String? description,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return EventListEntity(
      id: id ?? this.id,
      code: code ?? this.code,
      name: name ?? this.name,
      eventDate: eventDate ?? this.eventDate,
      description: description ?? this.description,
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
    createdAt,
    updatedAt,
  ];
}
