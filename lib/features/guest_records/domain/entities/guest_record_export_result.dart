import 'package:equatable/equatable.dart';

class GuestRecordExportResult extends Equatable {
  const GuestRecordExportResult({
    required this.fileName,
    required this.filePath,
    required this.recordCount,
    required this.exportedAt,
  });

  final String fileName;
  final String filePath;
  final int recordCount;
  final DateTime exportedAt;

  @override
  List<Object?> get props => <Object?>[
    fileName,
    filePath,
    recordCount,
    exportedAt,
  ];
}
