import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../core/enums/sort_field.dart';
import '../../../../core/enums/sort_order.dart';
import '../../../../core/utils/debounce.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/utils/excel_mapper.dart';
import '../../../../core/widgets/shared/app_gradient_background.dart';
import '../../../../core/widgets/shared/glass_panel.dart';
import '../../../../core/widgets/shared/glass_state_panel.dart';
import '../../../../core/widgets/shared/glass_skeleton.dart';
import '../../../event_lists/domain/entities/event_list_entity.dart';
import '../../../event_lists/presentation/providers/event_list_providers.dart';
import '../../../event_lists/presentation/widgets/event_form_sheet.dart';
import '../../../excel_import/presentation/pages/excel_import_page.dart';
import '../../../search_sort/presentation/providers/search_sort_provider.dart';
import '../../domain/entities/guest_record_entity.dart';
import '../../domain/entities/guest_record_export_result.dart';
import '../providers/guest_record_providers.dart';

class GuestRecordsPage extends ConsumerStatefulWidget {
  const GuestRecordsPage({super.key, required this.eventListId});

  static const String routeName = '/guest-records';

  final int eventListId;

  @override
  ConsumerState<GuestRecordsPage> createState() => _GuestRecordsPageState();
}

class _GuestRecordsPageState extends ConsumerState<GuestRecordsPage> {
  late final TextEditingController _searchController;
  late final Debounce _searchDebounce;
  bool _isSelectionMode = false;
  final Set<int> _selectedRecordIds = <int>{};

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _searchDebounce = Debounce(delay: const Duration(milliseconds: 180));
    ref.read(searchSortProvider.notifier).reset();
  }

  @override
  void dispose() {
    _searchDebounce.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final eventAsync = ref.watch(eventListDetailsProvider(widget.eventListId));
    final overviewAsync = ref.watch(
      eventListOverviewProvider(widget.eventListId),
    );
    final recordsAsync = ref.watch(
      filteredGuestRecordsProvider(widget.eventListId),
    );
    final searchState = ref.watch(searchSortProvider);
    final guestActionState = ref.watch(guestRecordActionControllerProvider);
    final exportState = ref.watch(guestRecordExportControllerProvider);
    final eventActionState = ref.watch(eventListActionControllerProvider);
    final bool isBusy =
        guestActionState.isLoading ||
        eventActionState.isLoading ||
        exportState.isLoading;

    return Scaffold(
      floatingActionButton: _isSelectionMode
          ? null
          : FloatingActionButton.extended(
              onPressed: isBusy ? null : _openCreateGuestSheet,
              icon: const Icon(Icons.person_add_alt_1_rounded),
              label: const Text('Thêm khách'),
            ),
      body: AppGradientBackground(
        child: SafeArea(
          child: eventAsync.when(
            data: (event) {
              if (event == null) {
                return const GlassStateView(
                  icon: Icons.event_busy_rounded,
                  title: 'Không tìm thấy sự kiện',
                  message:
                      'Sự kiện này có thể đã bị xóa hoặc dữ liệu chưa kịp đồng bộ.',
                );
              }

              return RefreshIndicator(
                onRefresh: _refresh,
                child: CustomScrollView(
                  physics: const BouncingScrollPhysics(
                    parent: AlwaysScrollableScrollPhysics(),
                  ),
                  slivers: <Widget>[
                    SliverPadding(
                      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                      sliver: SliverList.list(
                        children: _buildStaticSections(
                          context: context,
                          event: event,
                          overviewAsync: overviewAsync,
                          recordsAsync: recordsAsync,
                          searchState: searchState,
                          isBusy: isBusy,
                        ),
                      ),
                    ),
                    SliverPadding(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 120),
                      sliver: _buildRecordsSliver(
                        recordsAsync: recordsAsync,
                        searchState: searchState,
                        isBusy: isBusy,
                      ),
                    ),
                  ],
                ),
              );
            },
            loading: () => const _GuestRecordsPageSkeleton(),
            error: (_, _) => const GlassStateView(
              icon: Icons.cloud_off_rounded,
              title: 'Không tải được sự kiện',
              message: 'Vui lòng thử lại sau hoặc kéo để tải lại dữ liệu.',
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> _buildStaticSections({
    required BuildContext context,
    required EventListEntity event,
    required AsyncValue<EventListOverview> overviewAsync,
    required AsyncValue<List<GuestRecordEntity>> recordsAsync,
    required SearchSortState searchState,
    required bool isBusy,
  }) {
    final List<GuestRecordEntity> visibleRecords =
        recordsAsync.valueOrNull ?? const <GuestRecordEntity>[];

    return <Widget>[
      Row(
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
                Text(
                  event.name,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  event.eventDate == null
                      ? 'Chưa xác định ngày diễn ra'
                      : 'Ngày ${DateFormat('dd/MM/yyyy').format(event.eventDate!)}',
                  style: const TextStyle(color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.xs),
          IconButton.filledTonal(
            onPressed: isBusy || _isSelectionMode
                ? null
                : () => _openEditEventSheet(event),
            icon: const Icon(Icons.edit_rounded),
            tooltip: 'Sửa sự kiện',
          ),
        ],
      ),
      const SizedBox(height: AppSpacing.lg),
      AnimatedSwitcher(
        duration: const Duration(milliseconds: 220),
        child: overviewAsync.when(
          data: (overview) => GlassPanel(
            key: ValueKey<int>(overview.totalAmount),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Wrap(
                  spacing: AppSpacing.xs,
                  runSpacing: AppSpacing.xs,
                  children: <Widget>[
                    _Badge(label: event.code, color: AppColors.secondary),
                    if (event.isArchived)
                      const _Badge(
                        label: 'Đã lưu trữ',
                        color: AppColors.warning,
                      ),
                    if (event.description?.trim().isNotEmpty == true)
                      _Badge(
                        label: event.description!,
                        color: AppColors.info,
                      ),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),
                Text(
                  CurrencyFormatter.formatVnd(overview.totalAmount),
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w900,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                const Text(
                  'Tổng tiền mừng đã ghi nhận trong sự kiện này',
                  style: TextStyle(color: AppColors.textSecondary),
                ),
                const SizedBox(height: AppSpacing.lg),
                Row(
                  children: <Widget>[
                    Expanded(
                      child: _MetricTile(
                        label: 'Khách mời',
                        value: '${overview.guestCount}',
                      ),
                    ),
                    Expanded(
                      child: _MetricTile(
                        label: 'Chưa trả nợ',
                        value: '${overview.debtCount}',
                      ),
                    ),
                    Expanded(
                      child: _MetricTile(
                        label: 'Sắp xếp theo',
                        value: _sortLabel(searchState),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          loading: () => const _GuestOverviewSkeleton(),
          error: (_, _) => const GlassStatePanel(
            icon: Icons.bar_chart_rounded,
            title: 'Không tải được thống kê sự kiện',
            message: 'Vui lòng thử lại sau hoặc kéo để tải lại de cập nhật.',
          ),
        ),
      ),
      const SizedBox(height: AppSpacing.lg),
      GlassPanel(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            ValueListenableBuilder<TextEditingValue>(
              valueListenable: _searchController,
              builder: (
                BuildContext context,
                TextEditingValue value,
                _,
              ) {
                return TextField(
                  controller: _searchController,
                  onChanged: _onSearchChanged,
                  decoration: InputDecoration(
                    hintText: 'Tìm theo tên khách hoặc ghi chú...',
                    prefixIcon: const Icon(Icons.search_rounded),
                    suffixIcon: value.text.isEmpty
                        ? null
                        : IconButton(
                            onPressed: _clearSearchKeyword,
                            icon: const Icon(Icons.close_rounded),
                          ),
                  ),
                );
              },
            ),
            const SizedBox(height: AppSpacing.md),
            Wrap(
              spacing: AppSpacing.xs,
              runSpacing: AppSpacing.xs,
              children: <Widget>[
                ChoiceChip(
                  label: const Text('Tất cả'),
                  selected: searchState.filterDebtPaid == null,
                  onSelected: (_) => ref
                      .read(searchSortProvider.notifier)
                      .setFilterDebtPaid(null),
                ),
                ChoiceChip(
                  label: const Text('Chưa trả'),
                  selected: searchState.filterDebtPaid == false,
                  onSelected: (_) => ref
                      .read(searchSortProvider.notifier)
                      .setFilterDebtPaid(false),
                ),
                ChoiceChip(
                  label: const Text('Đã trả'),
                  selected: searchState.filterDebtPaid == true,
                  onSelected: (_) => ref
                      .read(searchSortProvider.notifier)
                      .setFilterDebtPaid(true),
                ),
                _buildSortChip(searchState),
              ],
            ),
          ],
        ),
      ),
      const SizedBox(height: AppSpacing.lg),
      Row(
        children: <Widget>[
          const Expanded(
            child: Text(
              'Danh sách khách mời',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          Flexible(
            child: Align(
              alignment: Alignment.centerRight,
              child: Wrap(
                spacing: AppSpacing.xs,
                runSpacing: AppSpacing.xs,
                alignment: WrapAlignment.end,
                children: <Widget>[
                  if (_isSelectionMode)
                    OutlinedButton.icon(
                      onPressed: isBusy ? null : _exitSelectionMode,
                      icon: const Icon(Icons.close_rounded),
                      label: const Text('Xong'),
                    )
                  else ...<Widget>[
                    OutlinedButton.icon(
                      onPressed: isBusy ? null : _openImportPage,
                      icon: const Icon(Icons.upload_file_rounded),
                      label: const Text('Import Excel'),
                    ),
                    OutlinedButton.icon(
                      onPressed: isBusy ? null : () => _exportRecords(event),
                      icon: const Icon(Icons.download_rounded),
                      label: const Text('Export CSV'),
                    ),
                    OutlinedButton.icon(
                      onPressed: isBusy || visibleRecords.isEmpty
                          ? null
                          : _enterSelectionMode,
                      icon: const Icon(Icons.checklist_rounded),
                      label: const Text('Chọn nhiều'),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
      if (_isSelectionMode) ...<Widget>[
        const SizedBox(height: AppSpacing.md),
        GlassPanel(
          fillColor: Colors.white.withValues(alpha: 0.9),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                'Đã chọn ${_selectedRecordIds.length}/${visibleRecords.length} khách trong danh sách hiện tại.',
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Wrap(
                spacing: AppSpacing.xs,
                runSpacing: AppSpacing.xs,
                children: <Widget>[
                  OutlinedButton.icon(
                    onPressed: isBusy || visibleRecords.isEmpty
                        ? null
                        : () => _selectAllVisibleRecords(visibleRecords),
                    icon: const Icon(Icons.select_all_rounded),
                    label: const Text('Chọn tất cả'),
                  ),
                  OutlinedButton.icon(
                    onPressed: isBusy || _selectedRecordIds.isEmpty
                        ? null
                        : _clearSelectedRecords,
                    icon: const Icon(Icons.deselect_rounded),
                    label: const Text('Bỏ chọn'),
                  ),
                  FilledButton.icon(
                    onPressed: isBusy || _selectedRecordIds.isEmpty
                        ? null
                        : _confirmDeleteSelectedRecords,
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.danger,
                    ),
                    icon: const Icon(Icons.delete_sweep_rounded),
                    label: const Text('Xóa đã chọn'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
      const SizedBox(height: AppSpacing.md),
    ];
  }

  Widget _buildRecordsSliver({
    required AsyncValue<List<GuestRecordEntity>> recordsAsync,
    required SearchSortState searchState,
    required bool isBusy,
  }) {
    return recordsAsync.when(
      data: (List<GuestRecordEntity> records) {
        _syncSelectionWithVisibleRecords(records);

        if (records.isEmpty) {
          return SliverToBoxAdapter(
            child: GlassStatePanel(
              key: ValueKey<String>(
                '${searchState.keyword}-${searchState.filterDebtPaid}',
              ),
              icon: Icons.people_outline_rounded,
              title:
                  searchState.keyword.trim().isNotEmpty ||
                      searchState.filterDebtPaid != null
                  ? 'Không có khách mời phù hợp'
                  : 'Chưa có khách mời nào được thêm vào',
              message:
                  searchState.keyword.trim().isNotEmpty ||
                      searchState.filterDebtPaid != null
                  ? 'Thử đổi từ khóa, bỏ lọc hoặc thay đổi sắp xếp để kiểm tra lại.'
                  : 'Bạn có thể nhập tay từng khách hoặc import Excel để đổ dữ liệu vào sự kiện này.',
              actions:
                  searchState.keyword.trim().isNotEmpty ||
                      searchState.filterDebtPaid != null
                  ? const <Widget>[]
                  : <Widget>[
                      FilledButton.icon(
                        onPressed: isBusy ? null : _openCreateGuestSheet,
                        icon: const Icon(Icons.person_add_alt_1_rounded),
                        label: const Text('Thêm khách đầu tiên'),
                      ),
                      OutlinedButton.icon(
                        onPressed: isBusy ? null : _openImportPage,
                        icon: const Icon(Icons.upload_file_rounded),
                        label: const Text('Import Excel'),
                      ),
                    ],
            ),
          );
        }

        return SliverList(
          delegate: SliverChildBuilderDelegate((
            BuildContext context,
            int index,
          ) {
            if (index.isOdd) {
              return const SizedBox(height: AppSpacing.sm);
            }

            final GuestRecordEntity record = records[index ~/ 2];
            return _GuestRecordCard(
              record: record,
              selectionMode: _isSelectionMode,
              selected: _selectedRecordIds.contains(record.id),
              busy: isBusy,
              onTap: () => _handleRecordTap(record),
              onLongPress: () => _handleRecordLongPress(record),
              onToggleSelected: () => _toggleRecordSelection(record),
              onEdit: () => _openEditGuestSheet(record),
              onDelete: () => _confirmDeleteRecord(record),
            );
          }, childCount: records.length * 2 - 1),
        );
      },
      loading: () => const SliverToBoxAdapter(
        child: _GuestRecordListLoadingState(),
      ),
      error: (_, _) => const SliverToBoxAdapter(
        child: GlassStatePanel(
          icon: Icons.cloud_off_rounded,
          title: 'Không tải được danh sách khách mời',
          message: 'Vui lòng thử lại sau hoặc kéo để tải lại danh sách.',
        ),
      ),
    );
  }

  Widget _buildSortChip(SearchSortState searchState) {
    return PopupMenuButton<_SortAction>(
      tooltip: 'Sắp xếp',
      onSelected: (_SortAction action) {
        final notifier = ref.read(searchSortProvider.notifier);
        switch (action) {
          case _SortAction.newest:
            notifier.setSortField(SortField.createdAt);
          case _SortAction.name:
            notifier.setSortField(SortField.fullName);
          case _SortAction.amount:
            notifier.setSortField(SortField.amount);
          case _SortAction.debt:
            notifier.setSortField(SortField.isDebtPaid);
          case _SortAction.toggleOrder:
            notifier.setSortOrder(
              searchState.sortOrder == SortOrder.ascending
                  ? SortOrder.descending
                  : SortOrder.ascending,
            );
        }
      },
      itemBuilder: (BuildContext context) =>
          const <PopupMenuEntry<_SortAction>>[
            PopupMenuItem<_SortAction>(
              value: _SortAction.newest,
              child: Text('Sắp xếp theo mới nhất'),
            ),
            PopupMenuItem<_SortAction>(
              value: _SortAction.name,
              child: Text('Sắp xếp theo tên'),
            ),
            PopupMenuItem<_SortAction>(
              value: _SortAction.amount,
              child: Text('Sắp xếp theo số tiền'),
            ),
            PopupMenuItem<_SortAction>(
              value: _SortAction.debt,
              child: Text('Sắp xếp theo trạng thái nợ'),
            ),
            PopupMenuDivider(),
            PopupMenuItem<_SortAction>(
              value: _SortAction.toggleOrder,
              child: Text('Đảo chiều thứ tự'),
            ),
          ],
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
        decoration: BoxDecoration(
          color: AppColors.accentTint,
          borderRadius: BorderRadius.circular(999),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            const Icon(
              Icons.swap_vert_rounded,
              size: 18,
              color: AppColors.primary,
            ),
            const SizedBox(width: 6),
            Text(
              _sortLabel(searchState),
              style: const TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _onSearchChanged(String value) {
    _searchDebounce(() {
      if (!mounted) {
        return;
      }
      ref.read(searchSortProvider.notifier).setKeyword(value);
    });
  }

  void _clearSearchKeyword() {
    _searchDebounce.cancel();
    _searchController.clear();
    ref.read(searchSortProvider.notifier).clearKeyword();
  }

  void _enterSelectionMode() {
    if (_isSelectionMode) {
      return;
    }
    setState(() {
      _isSelectionMode = true;
    });
  }

  void _exitSelectionMode() {
    if (!_isSelectionMode && _selectedRecordIds.isEmpty) {
      return;
    }
    setState(() {
      _isSelectionMode = false;
      _selectedRecordIds.clear();
    });
  }

  void _handleRecordTap(GuestRecordEntity record) {
    if (!_isSelectionMode) {
      return;
    }
    _toggleRecordSelection(record);
  }

  void _handleRecordLongPress(GuestRecordEntity record) {
    if (_isSelectionMode) {
      _toggleRecordSelection(record);
      return;
    }

    setState(() {
      _isSelectionMode = true;
      _selectedRecordIds.add(record.id);
    });
  }

  void _toggleRecordSelection(GuestRecordEntity record) {
    setState(() {
      if (_selectedRecordIds.contains(record.id)) {
        _selectedRecordIds.remove(record.id);
      } else {
        _selectedRecordIds.add(record.id);
      }

      if (_selectedRecordIds.isEmpty) {
        _isSelectionMode = false;
      }
    });
  }

  void _selectAllVisibleRecords(List<GuestRecordEntity> records) {
    setState(() {
      _isSelectionMode = true;
      _selectedRecordIds
        ..clear()
        ..addAll(records.map((GuestRecordEntity record) => record.id));
    });
  }

  void _clearSelectedRecords() {
    setState(() {
      _selectedRecordIds.clear();
      _isSelectionMode = false;
    });
  }

  void _syncSelectionWithVisibleRecords(List<GuestRecordEntity> records) {
    if (_selectedRecordIds.isEmpty) {
      return;
    }

    final Set<int> visibleIds = records
        .map((GuestRecordEntity record) => record.id)
        .toSet();
    if (_selectedRecordIds.every(visibleIds.contains)) {
      return;
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      setState(() {
        _selectedRecordIds.removeWhere((int id) => !visibleIds.contains(id));
        if (_selectedRecordIds.isEmpty) {
          _isSelectionMode = false;
        }
      });
    });
  }

  Future<void> _refresh() async {
    ref.invalidate(eventListDetailsProvider(widget.eventListId));
    await _refreshGuestData(awaitReload: true);
  }

  Future<void> _openCreateGuestSheet() async {
    final GuestRecordEntity? created =
        await showModalBottomSheet<GuestRecordEntity>(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          builder: (_) => _GuestRecordFormSheet(eventListId: widget.eventListId),
        );

    if (created == null || !mounted) {
      return;
    }

    await _refreshGuestData(awaitReload: true);
    _showSnackBar('Đã thêm "${created.fullName}" vào sự kiện.');
  }

  Future<void> _openEditEventSheet(EventListEntity event) async {
    final EventListEntity? updated =
        await showModalBottomSheet<EventListEntity>(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          builder: (_) => EventFormSheet(initialEventList: event),
        );

    if (updated == null || !mounted) {
      return;
    }

    ref.invalidate(eventListDetailsProvider(widget.eventListId));
    _showSnackBar('Đã cập nhật sự kiện "${updated.name}".');
  }

  Future<void> _openEditGuestSheet(GuestRecordEntity record) async {
    final GuestRecordEntity? updated =
        await showModalBottomSheet<GuestRecordEntity>(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          builder: (_) => _GuestRecordFormSheet(
            eventListId: widget.eventListId,
            initialRecord: record,
          ),
        );

    if (updated == null || !mounted) {
      return;
    }

    await _refreshGuestData(awaitReload: true);
    _showSnackBar('Đã cập nhật "${updated.fullName}".');
  }

  Future<void> _confirmDeleteRecord(GuestRecordEntity record) async {
    final bool? shouldDelete = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: const Text('Xóa khách mời?'),
        content: Text(
          'Bạn có chắc muốn xóa "${record.fullName}" khỏi sự kiện này?',
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Hủy'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: FilledButton.styleFrom(backgroundColor: AppColors.danger),
            child: const Text('Xóa'),
          ),
        ],
      ),
    );

    if (shouldDelete != true || !mounted) {
      return;
    }

    try {
      await ref.read(guestRecordActionControllerProvider.notifier).delete(
        record,
      );
      await _refreshGuestData(awaitReload: true);
      if (mounted) {
        _showSnackBar('Đã xóa "${record.fullName}".');
      }
    } catch (_) {
      if (mounted) {
        _showSnackBar('Không thể xóa khách mời. Vui lòng thử lại.');
      }
    }
  }

  Future<void> _openImportPage() async {
    await Navigator.of(
      context,
    ).pushNamed(ExcelImportPage.routeName, arguments: widget.eventListId);
    await _refreshGuestData(awaitReload: true);
  }

  Future<void> _confirmDeleteSelectedRecords() async {
    final List<int> selectedIds = _selectedRecordIds.toList(growable: false);
    if (selectedIds.isEmpty) {
      return;
    }

    final bool shouldDelete =
        await showDialog<bool>(
          context: context,
          builder: (BuildContext context) => AlertDialog(
            title: const Text('Xóa khách đã chọn?'),
            content: Text(
              'Bạn có chắc muốn xóa ${selectedIds.length} khách đang được tích chọn?',
            ),
            actions: <Widget>[
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Hủy'),
              ),
              FilledButton(
                onPressed: () => Navigator.of(context).pop(true),
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.danger,
                ),
                child: const Text('Xóa tất cả'),
              ),
            ],
          ),
        ) ??
        false;

    if (!shouldDelete || !mounted) {
      return;
    }

    try {
      await ref
          .read(guestRecordActionControllerProvider.notifier)
          .deleteMany(eventListId: widget.eventListId, ids: selectedIds);
      await _refreshGuestData(awaitReload: true);
      _exitSelectionMode();
      _showSnackBar('Đã xóa ${selectedIds.length} khách đã chọn.');
    } catch (_) {
      if (mounted) {
        _showSnackBar('Không thể xóa nhiều khách. Vui lòng thử lại.');
      }
    }
  }

  Future<void> _exportRecords(EventListEntity event) async {
    try {
      final List<GuestRecordEntity> records = await ref.read(
        filteredGuestRecordsProvider(widget.eventListId).future,
      );

      if (records.isEmpty) {
        _showSnackBar('Không có dữ liệu để export theo bộ lọc hiện tại.');
        return;
      }

      final GuestRecordExportResult result = await ref
          .read(guestRecordExportControllerProvider.notifier)
          .export(eventList: event, records: records);

      if (!mounted) {
        return;
      }

      await showDialog<void>(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Đã xuất file CSV'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'Đã xuất ${result.recordCount} dòng từ sự kiện "${event.name}".',
                ),
                const SizedBox(height: AppSpacing.sm),
                const Text(
                  'File đã lưu tại:',
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 6),
                SelectableText(result.filePath),
              ],
            ),
            actions: <Widget>[
              FilledButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Đóng'),
              ),
            ],
          );
        },
      );
    } catch (_) {
      if (!mounted) {
        return;
      }
      _showSnackBar('Không thể export CSV. Vui lòng thử lại.');
    }
  }

  Future<void> _refreshGuestData({required bool awaitReload}) async {
    ref.invalidate(eventListOverviewProvider(widget.eventListId));
    ref.invalidate(guestRecordsProvider(widget.eventListId));
    ref.invalidate(filteredGuestRecordsProvider(widget.eventListId));
    ref.invalidate(eventListDashboardSummaryProvider);
    if (awaitReload) {
      await ref.read(filteredGuestRecordsProvider(widget.eventListId).future);
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  String _sortLabel(SearchSortState state) {
    final String base = switch (state.sortField) {
      SortField.fullName => 'Tên',
      SortField.note => 'Ghi chú',
      SortField.amount => 'Số tiền',
      SortField.createdAt => 'Mới nhất',
      SortField.isDebtPaid => 'Trạng thái nợ',
    };
    final String order = state.sortOrder == SortOrder.ascending ? 'A-Z' : 'Z-A';
    if (state.sortField == SortField.amount ||
        state.sortField == SortField.createdAt) {
      return base;
    }
    return '$base $order';
  }
}

class _GuestRecordsPageSkeleton extends StatelessWidget {
  const _GuestRecordsPageSkeleton();

  @override
  Widget build(BuildContext context) {
    return const AppGradientBackground(
      child: SafeArea(
        child: Padding(
          padding: EdgeInsets.fromLTRB(20, 16, 20, 120),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                children: <Widget>[
                  GlassSkeleton(
                    width: 44,
                    height: 44,
                    borderRadius: BorderRadius.all(Radius.circular(14)),
                  ),
                  SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        GlassSkeleton(width: 200, height: 22),
                        SizedBox(height: 8),
                        GlassSkeleton(width: 132, height: 12),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: AppSpacing.lg),
              _GuestOverviewSkeleton(),
              SizedBox(height: AppSpacing.lg),
              GlassPanel(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    GlassSkeleton(height: 48, borderRadius: BorderRadius.all(Radius.circular(16))),
                    SizedBox(height: AppSpacing.md),
                    GlassSkeleton(height: 34),
                  ],
                ),
              ),
              SizedBox(height: AppSpacing.lg),
              _GuestRecordListLoadingState(),
            ],
          ),
        ),
      ),
    );
  }
}

class _GuestOverviewSkeleton extends StatelessWidget {
  const _GuestOverviewSkeleton();

  @override
  Widget build(BuildContext context) {
    return GlassPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const <Widget>[
          Row(
            children: <Widget>[
              GlassSkeleton(width: 96, height: 28),
              SizedBox(width: AppSpacing.xs),
              GlassSkeleton(width: 128, height: 28),
            ],
          ),
          SizedBox(height: AppSpacing.md),
          GlassSkeleton(width: 180, height: 32),
          SizedBox(height: AppSpacing.xs),
          GlassSkeleton(width: 250, height: 14),
          SizedBox(height: AppSpacing.lg),
          Row(
            children: <Widget>[
              Expanded(child: GlassSkeleton(height: 36)),
              SizedBox(width: AppSpacing.sm),
              Expanded(child: GlassSkeleton(height: 36)),
              SizedBox(width: AppSpacing.sm),
              Expanded(child: GlassSkeleton(height: 36)),
            ],
          ),
        ],
      ),
    );
  }
}

class _GuestRecordListLoadingState extends StatelessWidget {
  const _GuestRecordListLoadingState();

  @override
  Widget build(BuildContext context) {
    return const Column(
      children: <Widget>[
        _GuestRecordCardSkeleton(),
        SizedBox(height: AppSpacing.sm),
        _GuestRecordCardSkeleton(),
        SizedBox(height: AppSpacing.sm),
        _GuestRecordCardSkeleton(),
      ],
    );
  }
}

class _GuestRecordCardSkeleton extends StatelessWidget {
  const _GuestRecordCardSkeleton();

  @override
  Widget build(BuildContext context) {
    return GlassPanel(
      child: Row(
        children: const <Widget>[
          GlassSkeleton(
            width: 42,
            height: 42,
            borderRadius: BorderRadius.all(Radius.circular(999)),
          ),
          SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                GlassSkeleton(width: 150, height: 16),
                SizedBox(height: 8),
                GlassSkeleton(width: 110, height: 12),
                SizedBox(height: 10),
                GlassSkeleton(width: 82, height: 28),
              ],
            ),
          ),
          SizedBox(width: AppSpacing.md),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: <Widget>[
              GlassSkeleton(width: 72, height: 16),
              SizedBox(height: 8),
              GlassSkeleton(width: 36, height: 12),
            ],
          ),
        ],
      ),
    );
  }
}

class _GuestRecordCard extends StatelessWidget {
  const _GuestRecordCard({
    required this.record,
    required this.selectionMode,
    required this.selected,
    required this.onTap,
    required this.onLongPress,
    required this.onToggleSelected,
    required this.onEdit,
    required this.onDelete,
    required this.busy,
  });

  final GuestRecordEntity record;
  final bool selectionMode;
  final bool selected;
  final VoidCallback onTap;
  final VoidCallback onLongPress;
  final VoidCallback onToggleSelected;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final bool busy;

  @override
  Widget build(BuildContext context) {
    final bool debtPaid = record.isDebtPaid;
    final Color badgeColor = debtPaid ? AppColors.success : AppColors.danger;

    return GestureDetector(
      onTap: selectionMode ? onTap : null,
      onLongPress: busy ? null : onLongPress,
      child: GlassPanel(
        padding: const EdgeInsets.all(14),
        fillColor: selected
            ? AppColors.primary.withValues(alpha: 0.18)
            : AppColors.glassFill,
        child: Row(
          children: <Widget>[
            if (selectionMode) ...<Widget>[
              Checkbox(
                value: selected,
                onChanged: busy ? null : (_) => onToggleSelected(),
              ),
              const SizedBox(width: AppSpacing.xs),
            ],
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primary.withValues(alpha: 0.14),
              ),
              alignment: Alignment.center,
              child: Text(
                record.fullName.isEmpty ? '?' : record.fullName[0].toUpperCase(),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: AppColors.primary,
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    record.fullName,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    record.note.isEmpty ? '' : record.note,
                    style: const TextStyle(color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: badgeColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      debtPaid ? 'Đã trả nợ' : 'Chưa trả nợ',
                      style: TextStyle(
                        color: badgeColor,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: <Widget>[
                Text(
                  CurrencyFormatter.formatVnd(record.amount),
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                    color: debtPaid ? AppColors.success : AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  DateFormat('dd/MM').format(record.createdAt),
                  style: const TextStyle(color: AppColors.textHint),
                ),
              ],
            ),
            if (!selectionMode)
              PopupMenuButton<_GuestRecordAction>(
                enabled: !busy,
                tooltip: 'Hành động',
                onSelected: (_GuestRecordAction action) {
                  switch (action) {
                    case _GuestRecordAction.edit:
                      onEdit();
                    case _GuestRecordAction.delete:
                      onDelete();
                  }
                },
                itemBuilder: (BuildContext context) =>
                    const <PopupMenuEntry<_GuestRecordAction>>[
                      PopupMenuItem<_GuestRecordAction>(
                        value: _GuestRecordAction.edit,
                        child: Text('Sửa'),
                      ),
                      PopupMenuItem<_GuestRecordAction>(
                        value: _GuestRecordAction.delete,
                        child: Text('Xóa'),
                      ),
                    ],
                icon: const Icon(
                  Icons.more_horiz_rounded,
                  color: AppColors.textSecondary,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _GuestRecordFormSheet extends ConsumerStatefulWidget {
  const _GuestRecordFormSheet({
    required this.eventListId,
    this.initialRecord,
  });

  final int eventListId;
  final GuestRecordEntity? initialRecord;

  @override
  ConsumerState<_GuestRecordFormSheet> createState() =>
      _GuestRecordFormSheetState();
}

class _GuestRecordFormSheetState extends ConsumerState<_GuestRecordFormSheet> {
  late final TextEditingController _fullNameController;
  late final TextEditingController _amountController;
  late final TextEditingController _noteController;
  late bool _isDebtPaid;
  String? _errorMessage;

  bool get _isEditing => widget.initialRecord != null;

  @override
  void initState() {
    super.initState();
    final GuestRecordEntity? record = widget.initialRecord;
    _fullNameController = TextEditingController(text: record?.fullName ?? '');
    _amountController = TextEditingController(
      text: record == null
          ? ''
          : NumberFormat.decimalPattern('vi_VN').format(record.amount),
    );
    _noteController = TextEditingController(text: record?.note ?? '');
    _isDebtPaid = record?.isDebtPaid ?? false;
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final actionState = ref.watch(guestRecordActionControllerProvider);
    final bool isBusy = actionState.isLoading;
    final int? parsedAmount = ExcelMapper.parseAmount(_amountController.text);

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
                _isEditing ? 'Cập nhật khách mời' : 'Thêm khách mời mới',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                _isEditing
                    ? 'Sửa nhanh số tiền, ghi chú hoặc trạng thái trả nợ.'
                    : 'Nhập tay từng khách để sự kiện có thể sử dụng ngay cả khi không có file Excel.',
                style: const TextStyle(color: AppColors.textSecondary),
              ),
              const SizedBox(height: AppSpacing.lg),
              TextField(
                controller: _fullNameController,
                enabled: !isBusy,
                textCapitalization: TextCapitalization.words,
                onChanged: (_) => _clearError(),
                decoration: const InputDecoration(
                  labelText: 'Tên khách',
                  hintText: 'Ví dụ: Nguyễn Minh',
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              TextField(
                controller: _amountController,
                enabled: !isBusy,
                keyboardType: TextInputType.text,
                onChanged: (_) {
                  setState(() {
                    _errorMessage = null;
                  });
                },
                decoration: const InputDecoration(
                  labelText: 'Số tiền mừng',
                  hintText: 'Ví dụ: 500000, 500k, 1tr',
                ),
              ),
              if (_amountController.text.trim().isNotEmpty) ...<Widget>[
                const SizedBox(height: AppSpacing.xs),
                Text(
                  parsedAmount == null || parsedAmount <= 0
                      ? 'Không nhận được số tiền. Thử lại theo dạng 500000, 500k, 1tr.'
                      : 'Sẽ lưu: ${CurrencyFormatter.formatVnd(parsedAmount)}',
                  style: TextStyle(
                    color: parsedAmount == null || parsedAmount <= 0
                        ? AppColors.danger
                        : AppColors.textSecondary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
              const SizedBox(height: AppSpacing.md),
              SwitchListTile.adaptive(
                value: _isDebtPaid,
                onChanged: isBusy
                    ? null
                    : (bool value) {
                        setState(() {
                          _isDebtPaid = value;
                        });
                      },
                contentPadding: EdgeInsets.zero,
                title: const Text('Đã trả nợ'),
                subtitle: Text(
                  _isDebtPaid
                      ? 'Khoản mừng này đã hoàn tất.'
                      : 'Đánh dấu để theo dõi sau.',
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              TextField(
                controller: _noteController,
                enabled: !isBusy,
                onChanged: (_) => _clearError(),
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Ghi chú',
                  hintText: 'Bạn thân, đồng nghiệp, địa chỉ...',
                ),
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
                                  : Icons.check_rounded,
                            ),
                      label: Text(
                        isBusy
                            ? (_isEditing ? 'Đang lưu...' : 'Đang thêm...')
                            : (_isEditing ? 'Lưu thay đổi' : 'Thêm khách'),
                      ),
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

  Future<void> _submit() async {
    final String fullName = _fullNameController.text.trim();
    final int? amount = ExcelMapper.parseAmount(_amountController.text);

    if (fullName.isEmpty) {
      setState(() {
        _errorMessage = 'Tên khách không được để trống.';
      });
      return;
    }

    if (amount == null || amount <= 0) {
      setState(() {
        _errorMessage = 'Số tiền không hợp lệ. Vui lòng nhập lại.';
      });
      return;
    }

    final DateTime now = DateTime.now();
    final GuestRecordEntity? initialRecord = widget.initialRecord;
    final GuestRecordEntity payload = GuestRecordEntity(
      id: initialRecord?.id ?? 0,
      eventListId: widget.eventListId,
      fullName: fullName,
      note: _noteController.text.trim(),
      amount: amount,
      isDebtPaid: _isDebtPaid,
      createdAt: initialRecord?.createdAt ?? now,
      updatedAt: now,
    );

    try {
      final GuestRecordEntity result = _isEditing
          ? await ref
                .read(guestRecordActionControllerProvider.notifier)
                .update(payload)
          : await ref
                .read(guestRecordActionControllerProvider.notifier)
                .create(payload);

      if (mounted) {
        Navigator.of(context).pop(result);
      }
    } catch (_) {
      setState(() {
        _errorMessage = _isEditing
            ? 'Không thể cập nhật khách mời. Vui lòng thử lại.'
            : 'Không thể tạo khách mời. Vui lòng thử lại.';
      });
    }
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
            color: AppColors.textHint,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          value,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }
}

class _Badge extends StatelessWidget {
  const _Badge({required this.label, required this.color});

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

enum _SortAction { newest, name, amount, debt, toggleOrder }

enum _GuestRecordAction { edit, delete }
