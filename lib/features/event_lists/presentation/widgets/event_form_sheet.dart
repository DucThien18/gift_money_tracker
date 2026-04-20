import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../core/widgets/shared/glass_panel.dart';
import '../../domain/entities/event_list_entity.dart';
import '../providers/event_list_providers.dart';

class EventFormSheet extends ConsumerStatefulWidget {
  const EventFormSheet({
    super.key,
    this.initialEventList,
    this.openDetailAfterCreate = false,
  });

  final EventListEntity? initialEventList;
  final bool openDetailAfterCreate;

  @override
  ConsumerState<EventFormSheet> createState() => _EventFormSheetState();
}

class _EventFormSheetState extends ConsumerState<EventFormSheet> {
  late final TextEditingController _nameController;
  late final TextEditingController _descriptionController;
  DateTime? _selectedDate;
  String? _errorMessage;

  bool get _isEditing => widget.initialEventList != null;

  @override
  void initState() {
    super.initState();
    final EventListEntity? eventList = widget.initialEventList;
    _nameController = TextEditingController(text: eventList?.name ?? '');
    _descriptionController = TextEditingController(
      text: eventList?.description ?? '',
    );
    _selectedDate = eventList?.eventDate;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final AsyncValue<void> actionState = ref.watch(
      eventListActionControllerProvider,
    );
    final bool isBusy = actionState.isLoading;

    return Padding(
      padding: EdgeInsets.only(
        left: AppSpacing.md,
        right: AppSpacing.md,
        top: 40,
        bottom: MediaQuery.of(context).viewInsets.bottom + AppSpacing.md,
      ),
      child: SingleChildScrollView(
        child: GlassPanel(
          fillColor: AppColors.glassFillStrong,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                _isEditing ? 'Chỉnh sửa sự kiện' : 'Tạo sự kiện mới',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                _isEditing
                    ? 'Cập nhật tên, mô tả và ngày để danh sách sự kiện luôn dễ đọc và dễ tìm.'
                    : 'Đặt tên rõ ràng để dễ tìm, dễ import và theo dõi tổng tiền.',
                style: const TextStyle(color: AppColors.textSecondary),
              ),
              const SizedBox(height: AppSpacing.lg),
              TextField(
                controller: _nameController,
                enabled: !isBusy,
                onChanged: (_) => _clearError(),
                decoration: const InputDecoration(
                  labelText: 'Tên sự kiện',
                  hintText: 'Ví dụ: Đám cưới Lan Anh',
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              TextField(
                controller: _descriptionController,
                enabled: !isBusy,
                onChanged: (_) => _clearError(),
                maxLines: 2,
                decoration: const InputDecoration(
                  labelText: 'Mô tả ngắn',
                  hintText: 'Họ tên, đồng nghiệp, khu vực...',
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              Wrap(
                spacing: AppSpacing.sm,
                runSpacing: AppSpacing.sm,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: <Widget>[
                  OutlinedButton.icon(
                    onPressed: isBusy ? null : _pickDate,
                    icon: const Icon(Icons.event_rounded),
                    label: Text(
                      _selectedDate == null
                          ? 'Chọn ngày sự kiện'
                          : 'Ngày ${DateFormat('dd/MM/yyyy').format(_selectedDate!)}',
                    ),
                  ),
                  if (_selectedDate != null)
                    TextButton.icon(
                      onPressed: isBusy
                          ? null
                          : () {
                              setState(() {
                                _selectedDate = null;
                              });
                            },
                      icon: const Icon(Icons.close_rounded),
                      label: const Text('Bỏ ngày'),
                    ),
                ],
              ),
              if (_errorMessage != null) ...<Widget>[
                const SizedBox(height: AppSpacing.md),
                Text(
                  _errorMessage!,
                  style: const TextStyle(
                    color: AppColors.danger,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
              const SizedBox(height: AppSpacing.lg),
              Row(
                children: <Widget>[
                  Expanded(
                    child: TextButton(
                      onPressed: isBusy
                          ? null
                          : () => Navigator.of(context).pop(),
                      child: const Text('Đóng'),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: isBusy ? null : _submit,
                      icon: isBusy
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : Icon(
                              _isEditing
                                  ? Icons.save_rounded
                                  : Icons.arrow_forward_rounded,
                            ),
                      label: Text(_submitLabel(isBusy)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _pickDate() async {
    final DateTime now = DateTime.now();
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? now,
      firstDate: DateTime(now.year - 3),
      lastDate: DateTime(now.year + 5),
    );

    if (picked == null || !mounted) {
      return;
    }

    setState(() {
      _selectedDate = picked;
    });
  }

  Future<void> _submit() async {
    setState(() {
      _errorMessage = null;
    });

    try {
      final EventListEntity result = _isEditing
          ? await ref
                .read(eventListActionControllerProvider.notifier)
                .update(
                  eventList: widget.initialEventList!,
                  name: _nameController.text,
                  description: _descriptionController.text,
                  eventDate: _selectedDate,
                )
          : await ref
                .read(eventListActionControllerProvider.notifier)
                .create(
                  name: _nameController.text,
                  description: _descriptionController.text,
                  eventDate: _selectedDate,
                );
      if (mounted) {
        Navigator.of(context).pop(result);
      }
    } catch (error) {
      setState(() {
        _errorMessage = error is ArgumentError
            ? error.message?.toString()
            : _isEditing
            ? 'Không thể cập nhật sự kiện. Vui lòng thử lại.'
            : 'Không thể tạo sự kiện. Vui lòng thử lại.';
      });
    }
  }

  String _submitLabel(bool isBusy) {
    if (isBusy) {
      return _isEditing ? 'Đang lưu...' : 'Đang tạo...';
    }
    if (_isEditing) {
      return 'Lưu thay đổi';
    }
    return widget.openDetailAfterCreate ? 'Tạo và mở' : 'Tạo sự kiện';
  }

  void _clearError() {
    if (_errorMessage == null) {
      return;
    }
    setState(() {
      _errorMessage = null;
    });
  }
}
