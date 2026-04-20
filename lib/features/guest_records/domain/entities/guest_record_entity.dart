import 'package:equatable/equatable.dart';

class GuestRecordEntity extends Equatable {
  const GuestRecordEntity({
    required this.id,
    required this.eventListId,
    required this.fullName,
    required this.note,
    required this.amount,
    required this.isDebtPaid,
    required this.createdAt,
    required this.updatedAt,
  });

  final int id;
  final int eventListId;
  final String fullName;
  final String note;
  final int amount;
  final bool isDebtPaid;
  final DateTime createdAt;
  final DateTime updatedAt;

  GuestRecordEntity copyWith({
    int? id,
    int? eventListId,
    String? fullName,
    String? note,
    int? amount,
    bool? isDebtPaid,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return GuestRecordEntity(
      id: id ?? this.id,
      eventListId: eventListId ?? this.eventListId,
      fullName: fullName ?? this.fullName,
      note: note ?? this.note,
      amount: amount ?? this.amount,
      isDebtPaid: isDebtPaid ?? this.isDebtPaid,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
    id,
    eventListId,
    fullName,
    note,
    amount,
    isDebtPaid,
    createdAt,
    updatedAt,
  ];
}
