import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../core/enums/import_status.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/widgets/shared/app_gradient_background.dart';
import '../../../../core/widgets/shared/glass_panel.dart';
import '../../../../core/widgets/shared/glass_state_panel.dart';
import '../../domain/entities/import_preview_row.dart';
import '../providers/excel_import_provider.dart';

class ExcelImportPage extends ConsumerWidget {
  const ExcelImportPage({super.key, required this.eventListId});

  static const String routeName = '/excel-import';

  final int eventListId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ExcelImportState state = ref.watch(excelImportProvider);
    final ExcelImportNotifier notifier = ref.read(excelImportProvider.notifier);

    final bool isBusy =
        state.status == ImportStatus.parsing ||
        state.status == ImportStatus.validating ||
        state.status == ImportStatus.importing;
    final bool hasResettableState =
        state.fileName != null ||
        state.hasPreview ||
        state.errorMessage != null ||
        state.importResult != null;

    return Scaffold(
      body: AppGradientBackground(
        child: SafeArea(
          child: Column(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                child: Row(
                  children: <Widget>[
                    IconButton.filledTonal(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.arrow_back_rounded),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          const Text(
                            'Import Excel',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w900,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Kiểm tra preview va import vào sự kiện #$eventListId.',
                            style: const TextStyle(
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
                  child: Column(
                    children: <Widget>[
                      _ImportSummaryPanel(
                        state: state,
                        isBusy: isBusy,
                        onPickFile: notifier.pickAndPreviewFile,
                        onReset: hasResettableState ? notifier.reset : null,
                      ),
                      if (state.errorMessage != null) ...<Widget>[
                        const SizedBox(height: AppSpacing.md),
                        GlassStatePanel(
                          icon: Icons.error_outline_rounded,
                          iconColor: AppColors.danger,
                          title: 'Có lỗi khi xử lý file',
                          message: state.errorMessage!,
                        ),
                      ],
                      if (state.status == ImportStatus.success &&
                          state.importResult != null) ...<Widget>[
                        const SizedBox(height: AppSpacing.md),
                        GlassStatePanel(
                          icon: Icons.check_circle_rounded,
                          iconColor: AppColors.success,
                          title: 'Import thành công',
                          message: _buildSuccessMessage(state),
                        ),
                      ],
                      const SizedBox(height: AppSpacing.lg),
                      Row(
                        children: <Widget>[
                          const Expanded(
                            child: Text(
                              'Xem trước dữ liệu',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w800,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ),
                          _StatusBadge(
                            label: _statusText(state.status),
                            color: _statusColor(state.status),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.md),
                      Expanded(
                        child: AnimatedSwitcher(
                          duration: const Duration(milliseconds: 220),
                          child: _PreviewContent(
                            key: ValueKey<String>(
                              '${state.status.name}-${state.totalCount}-${state.errorMessage}',
                            ),
                            state: state,
                            isBusy: isBusy,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                child: SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: state.status == ImportStatus.success
                        ? () => Navigator.of(context).pop()
                        : (!state.canConfirmImport || isBusy)
                        ? null
                        : () => notifier.confirmImport(eventListId),
                    icon: _buildBottomActionIcon(state, isBusy),
                    label: Text(_bottomActionLabel(state, isBusy)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ImportSummaryPanel extends StatelessWidget {
  const _ImportSummaryPanel({
    required this.state,
    required this.isBusy,
    required this.onPickFile,
    required this.onReset,
  });

  final ExcelImportState state;
  final bool isBusy;
  final VoidCallback onPickFile;
  final VoidCallback? onReset;

  @override
  Widget build(BuildContext context) {
    return GlassPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Wrap(
            spacing: AppSpacing.xs,
            runSpacing: AppSpacing.xs,
            children: <Widget>[
              _StatusBadge(
                label: _statusText(state.status),
                color: _statusColor(state.status),
              ),
            ],
          ),
          if (state.fileName != null) ...<Widget>[
            const SizedBox(height: AppSpacing.sm),
            Text(
              'File: ${state.fileName!}',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
          const SizedBox(height: AppSpacing.md),
          const Text(
            'Đọc file, kiểm tra từng dòng và chỉ import các record hợp lệ.',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          const Text(
            'Nếu file có lỗi, bạn sẽ thấy preview và danh sách cần xử lý trước khi xác nhận import.',
            style: TextStyle(color: AppColors.textSecondary, height: 1.45),
          ),
          const SizedBox(height: AppSpacing.lg),
          Row(
            children: <Widget>[
              Expanded(
                child: FilledButton.icon(
                  onPressed: isBusy ? null : onPickFile,
                  icon: const Icon(Icons.upload_file_rounded),
                  label: Text(
                    state.fileName == null ? 'Chọn file Excel' : 'Chọn file khác',
                  ),
                ),
              ),
              if (onReset != null) ...<Widget>[
                const SizedBox(width: AppSpacing.sm),
                OutlinedButton.icon(
                  onPressed: isBusy ? null : onReset,
                  icon: const Icon(Icons.restart_alt_rounded),
                  label: const Text('Làm mới'),
                ),
              ],
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          Row(
            children: <Widget>[
              Expanded(
                child: _MetricTile(
                  label: 'Tổng dòng',
                  value: '${state.totalCount}',
                ),
              ),
              Expanded(
                child: _MetricTile(
                  label: 'Hợp lệ',
                  value: '${state.validCount}',
                ),
              ),
              Expanded(
                child: _MetricTile(
                  label: 'Có lỗi',
                  value: '${state.errorCount}',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _PreviewContent extends StatelessWidget {
  const _PreviewContent({
    super.key,
    required this.state,
    required this.isBusy,
  });

  final ExcelImportState state;
  final bool isBusy;

  @override
  Widget build(BuildContext context) {
    if (state.previewRows.isEmpty) {
      if (isBusy) {
        return GlassPanel(
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                const SizedBox(
                  width: 28,
                  height: 28,
                  child: CircularProgressIndicator(strokeWidth: 3),
                ),
                const SizedBox(height: AppSpacing.md),
                Text(
                  _busyMessage(state.status),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                const Text(
                  'Vui lòng đợi trong giây lát, hệ thống đang xử lý file vừa chọn.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    height: 1.45,
                  ),
                ),
              ],
            ),
          ),
        );
      }

      return const GlassStatePanel(
        icon: Icons.table_rows_rounded,
        title: 'Chưa có dữ liệu preview',
        message:
            'Chọn file Excel để xem trước các dòng hợp lệ và các dòng cần xử lý.',
        centered: true,
      );
    }

    return GlassPanel(
      padding: EdgeInsets.zero,
      child: ListView.separated(
        padding: const EdgeInsets.all(12),
        itemCount: state.previewRows.length,
        separatorBuilder: (_, _) => const Divider(
          height: 1,
          color: AppColors.glassBorder,
        ),
        itemBuilder: (BuildContext context, int index) {
          return _PreviewRowTile(row: state.previewRows[index]);
        },
      ),
    );
  }
}

class _PreviewRowTile extends StatelessWidget {
  const _PreviewRowTile({required this.row});

  final ImportPreviewRow row;

  @override
  Widget build(BuildContext context) {
    final bool isValid = row.isValid;
    final Color accentColor = isValid ? AppColors.success : AppColors.danger;
    final String displayName =
        _firstNonEmpty(row.parsedFullName, row.fullNameRaw) ?? '(trong ten)';
    final String? displayNote = _firstNonEmpty(row.parsedNote, row.noteRaw);
    final String amountLabel = row.parsedAmount == null
        ? (_firstNonEmpty(row.amountRaw) ?? 'Số tiền không hợp lệ')
        : CurrencyFormatter.formatVnd(row.parsedAmount!);
    final String debtLabel = row.parsedIsDebtPaid == true
        ? 'Đã trả nợ'
        : row.parsedIsDebtPaid == false
        ? 'Chưa trả nợ'
        : 'Chưa rõ';

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: accentColor.withValues(alpha: 0.12),
            ),
            alignment: Alignment.center,
            child: Icon(
              isValid ? Icons.check_rounded : Icons.error_outline_rounded,
              color: accentColor,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Expanded(
                      child: Text(
                        '${row.rowNumber}. $displayName',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    _StatusBadge(
                      label: isValid ? 'Hợp lệ' : 'Cần xử lý',
                      color: accentColor,
                    ),
                  ],
                ),
                if (displayNote != null) ...<Widget>[
                  const SizedBox(height: 4),
                  Text(
                    displayNote,
                    style: const TextStyle(color: AppColors.textSecondary),
                  ),
                ],
                const SizedBox(height: AppSpacing.sm),
                Wrap(
                  spacing: AppSpacing.xs,
                  runSpacing: AppSpacing.xs,
                  children: <Widget>[
                    _StatusBadge(
                      label: amountLabel,
                      color: isValid ? AppColors.primary : AppColors.warning,
                    ),
                    _StatusBadge(label: debtLabel, color: AppColors.info),
                  ],
                ),
                if (row.hasErrors) ...<Widget>[
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    row.errors.join(' | '),
                    style: const TextStyle(
                      color: AppColors.danger,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MetricTile extends StatelessWidget {
  const _MetricTile({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: AppColors.textHint,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          value,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            fontWeight: FontWeight.w800,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

String _statusText(ImportStatus status) {
  switch (status) {
    case ImportStatus.idle:
      return 'Chờ file';
    case ImportStatus.parsing:
      return 'Đang đọc file';
    case ImportStatus.validating:
      return 'Đang kiểm tra';
    case ImportStatus.readyToImport:
      return 'Sẵn sàng import';
    case ImportStatus.importing:
      return 'Đang import';
    case ImportStatus.success:
      return 'Thành công';
    case ImportStatus.failed:
      return 'Thất bại';
  }
}

Color _statusColor(ImportStatus status) {
  switch (status) {
    case ImportStatus.idle:
      return AppColors.textHint;
    case ImportStatus.parsing:
    case ImportStatus.validating:
    case ImportStatus.importing:
      return AppColors.warning;
    case ImportStatus.readyToImport:
      return AppColors.primary;
    case ImportStatus.success:
      return AppColors.success;
    case ImportStatus.failed:
      return AppColors.danger;
  }
}

String _busyMessage(ImportStatus status) {
  switch (status) {
    case ImportStatus.parsing:
      return 'Đang đọc nội dung file Excel...';
    case ImportStatus.validating:
      return 'Đang kiểm tra từng dòng dữ liệu...';
    case ImportStatus.importing:
      return 'Đang import dữ liệu vào sự kiện...';
    case ImportStatus.idle:
    case ImportStatus.readyToImport:
    case ImportStatus.success:
    case ImportStatus.failed:
      return 'Đang xử lý...';
  }
}

Widget _buildBottomActionIcon(ExcelImportState state, bool isBusy) {
  if (isBusy) {
    return const SizedBox(
      width: 16,
      height: 16,
      child: CircularProgressIndicator(strokeWidth: 2),
    );
  }

  if (state.status == ImportStatus.success) {
    return const Icon(Icons.arrow_back_rounded);
  }

  return const Icon(Icons.cloud_upload_rounded);
}

String _bottomActionLabel(ExcelImportState state, bool isBusy) {
  if (state.status == ImportStatus.success) {
    return 'Quay lại sự kiện';
  }

  if (isBusy) {
    switch (state.status) {
      case ImportStatus.parsing:
        return 'Đang đọc file...';
      case ImportStatus.validating:
        return 'Đang kiểm tra dữ liệu...';
      case ImportStatus.importing:
        return 'Đang import...';
      case ImportStatus.idle:
      case ImportStatus.readyToImport:
      case ImportStatus.success:
      case ImportStatus.failed:
        return 'Đang xử lý...';
    }
  }

  return 'Xác nhận import';
}

String _buildSuccessMessage(ExcelImportState state) {
  final result = state.importResult!;
  if (result.skippedCount > 0) {
    return 'Đã import ${result.importedCount}/${result.totalRows} dòng và bỏ qua ${result.skippedCount} dòng không hợp lệ.';
  }
  return 'Đã import thành công ${result.importedCount}/${result.totalRows} dòng hợp lệ vào sự kiện.';
}

String? _firstNonEmpty(String? first, [String? second]) {
  final List<String?> values = <String?>[first, second];
  for (final String? value in values) {
    if (value != null && value.trim().isNotEmpty) {
      return value.trim();
    }
  }
  return null;
}
