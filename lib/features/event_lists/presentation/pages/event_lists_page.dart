import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../core/utils/debounce.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/widgets/shared/app_gradient_background.dart';
import '../../../../core/widgets/shared/glass_panel.dart';
import '../../../../core/widgets/shared/glass_state_panel.dart';
import '../../../../core/widgets/shared/glass_skeleton.dart';
import '../../../guest_records/presentation/pages/guest_records_page.dart';
import '../../domain/entities/event_list_entity.dart';
import '../providers/event_list_providers.dart';
import '../widgets/event_form_sheet.dart';

class EventListsPage extends ConsumerStatefulWidget {
  const EventListsPage({super.key});

  static const String routeName = '/';

  @override
  ConsumerState<EventListsPage> createState() => _EventListsPageState();
}

class _EventListsPageState extends ConsumerState<EventListsPage> {
  late final TextEditingController _searchController;
  late final Debounce _searchDebounce;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController(
      text: ref.read(eventListSearchQueryProvider),
    );
    _searchDebounce = Debounce(delay: const Duration(milliseconds: 180));
  }

  @override
  void dispose() {
    _searchDebounce.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final eventsAsync = ref.watch(filteredEventListsProvider);
    final summaryAsync = ref.watch(eventListDashboardSummaryProvider);
    final actionState = ref.watch(eventListActionControllerProvider);
    final query = ref.watch(eventListSearchQueryProvider);

    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: actionState.isLoading
            ? null
            : () => _openCreateEventSheet(context),
        icon: const Icon(Icons.add_rounded),
        label: const Text('Tạo sự kiện mới'),
      ),
      body: AppGradientBackground(
        child: SafeArea(
          child: RefreshIndicator(
            onRefresh: _refresh,
            child: CustomScrollView(
              physics: const BouncingScrollPhysics(
                parent: AlwaysScrollableScrollPhysics(),
              ),
              slivers: <Widget>[
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                  sliver: SliverList.list(
                    children: <Widget>[
                      const _PageHeader(),
                      const SizedBox(height: AppSpacing.lg),
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 220),
                        child: summaryAsync.when(
                          data: (summary) => GlassPanel(
                            key: ValueKey<int>(summary.totalAmount),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                _Badge(
                                  label: 'Tổng quan hiện tại',
                                  color: AppColors.primary,
                                ),
                                const SizedBox(height: AppSpacing.md),
                                Text(
                                  CurrencyFormatter.formatVnd(
                                    summary.totalAmount,
                                  ),
                                  style: const TextStyle(
                                    fontSize: 30,
                                    fontWeight: FontWeight.w900,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                                const SizedBox(height: AppSpacing.xs),
                                const Text(
                                  'Tổng giá trị tiền mừng trong tất cả sự kiện.',
                                  style: TextStyle(
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                                const SizedBox(height: AppSpacing.lg),
                                Row(
                                  children: <Widget>[
                                    Expanded(
                                      child: _MetricTile(
                                        label: 'Sự kiện',
                                        value: '${summary.eventCount}',
                                      ),
                                    ),
                                    Expanded(
                                      child: _MetricTile(
                                        label: 'Khách mới',
                                        value: '${summary.guestCount}',
                                      ),
                                    ),
                                    Expanded(
                                      child: _MetricTile(
                                        label: 'Trạng thái',
                                        value: summary.eventCount == 0
                                            ? 'Trống'
                                            : 'Sẵn sàng',
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          loading: () => const _SummarySkeleton(),
                          error: (_, _) => const GlassStatePanel(
                            icon: Icons.bar_chart_rounded,
                            title: 'Không tải được tổng quan',
                            message:
                                'Vui lòng kéo để tải lại hoặc thử lại sau.',
                          ),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      GlassPanel(
                        padding: const EdgeInsets.all(14),
                        child: ValueListenableBuilder<TextEditingValue>(
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
                                hintText: 'Tìm theo tên, mã sự kiện, mô tả...',
                                prefixIcon: const Icon(Icons.search_rounded),
                                suffixIcon: value.text.isEmpty
                                    ? null
                                    : IconButton(
                                        onPressed: _clearSearchQuery,
                                        icon: const Icon(Icons.close_rounded),
                                      ),
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      Row(
                        children: <Widget>[
                          const Expanded(
                            child: Text(
                              'Danh sách sự kiện',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w800,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ),
                          eventsAsync.when(
                            data: (List<EventListEntity> items) => Text(
                              '${items.length} mục',
                              style: const TextStyle(
                                color: AppColors.textHint,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            loading: () => const GlassSkeleton(
                              width: 52,
                              height: 12,
                            ),
                            error: (_, _) => const SizedBox.shrink(),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.md),
                    ],
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 120),
                  sliver: eventsAsync.when(
                    data: (List<EventListEntity> items) {
                      if (items.isEmpty) {
                        return SliverToBoxAdapter(
                          child: GlassStatePanel(
                            key: ValueKey<String>(query),
                            icon: Icons.inbox_rounded,
                            title: query.trim().isNotEmpty
                                ? 'Không có kết quả phù hợp'
                                : 'Chưa có sự kiện nào',
                            message: query.trim().isNotEmpty
                                ? 'Thử lại từ khóa tìm kiếm hoặc tạo sự kiện mới.'
                                : 'Tạo sự kiện đầu tiên để bắt đầu quản lý tiền mừng.',
                            actions: query.trim().isNotEmpty
                                ? const <Widget>[]
                                : <Widget>[
                                    FilledButton.icon(
                                      onPressed: actionState.isLoading
                                          ? null
                                          : () => _openCreateEventSheet(
                                              context,
                                            ),
                                      icon: const Icon(Icons.add_rounded),
                                      label: const Text('Tạo sự kiện mới'),
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
                            return const SizedBox(height: AppSpacing.md);
                          }

                          final EventListEntity item = items[index ~/ 2];
                          return _EventCard(
                            eventList: item,
                            busy: actionState.isLoading,
                            onOpen: () => Navigator.of(context).pushNamed(
                              GuestRecordsPage.routeName,
                              arguments: item.id,
                            ),
                            onEdit: () => _openEditEventSheet(context, item),
                            onDelete: () => _confirmDelete(context, ref, item),
                          );
                        }, childCount: items.length * 2 - 1),
                      );
                    },
                    loading: () => const SliverToBoxAdapter(
                      child: _EventListLoadingState(),
                    ),
                    error: (_, _) => const SliverToBoxAdapter(
                      child: GlassStatePanel(
                        icon: Icons.cloud_off_rounded,
                        title: 'Không tải được danh sách sự kiện',
                        message:
                            'Vui lòng thử lại sau hoặc kéo để tải lại dữ liệu.',
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _refresh() async {
    ref.invalidate(allEventListsProvider);
    ref.invalidate(filteredEventListsProvider);
    ref.invalidate(eventListDashboardSummaryProvider);
    await ref.read(filteredEventListsProvider.future);
  }

  void _onSearchChanged(String value) {
    _searchDebounce(() {
      if (!mounted) {
        return;
      }
      ref.read(eventListSearchQueryProvider.notifier).state = value;
    });
  }

  void _clearSearchQuery() {
    _searchDebounce.cancel();
    _searchController.clear();
    ref.read(eventListSearchQueryProvider.notifier).state = '';
  }

  Future<void> _openCreateEventSheet(BuildContext context) async {
    final created = await showModalBottomSheet<EventListEntity>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const EventFormSheet(openDetailAfterCreate: true),
    );

    if (created != null && context.mounted) {
      Navigator.of(
        context,
      ).pushNamed(GuestRecordsPage.routeName, arguments: created.id);
    }
  }

  Future<void> _openEditEventSheet(
    BuildContext context,
    EventListEntity eventList,
  ) async {
    final updated = await showModalBottomSheet<EventListEntity>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => EventFormSheet(initialEventList: eventList),
    );

    if (updated != null && context.mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Đã cập nhật "${updated.name}".')));
    }
  }

  Future<void> _confirmDelete(
    BuildContext context,
    WidgetRef ref,
    EventListEntity eventList,
  ) async {
    final shouldDelete =
        await showDialog<bool>(
          context: context,
          builder: (BuildContext context) => AlertDialog(
            title: const Text('Xóa sự kiện?'),
            content: Text(
              'Tất cả guest record trong "${eventList.name}" cũng sẽ bị xóa.',
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
                child: const Text('Xóa'),
              ),
            ],
          ),
        ) ??
        false;

    if (!shouldDelete) {
      return;
    }

    try {
      await ref
          .read(eventListActionControllerProvider.notifier)
          .delete(eventList);
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Đã xóa "${eventList.name}".')));
      }
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Không thể xóa sự kiện. Vui lòng thử lại.'),
          ),
        );
      }
    }
  }
}

class _PageHeader extends StatelessWidget {
  const _PageHeader();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                'Nhật ký tiền mừng',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                  color: AppColors.textPrimary,
                ),
              ),
              SizedBox(height: AppSpacing.xs),
              Text(
                'Ứng dụng để quản lý sự kiện, danh sách khách và tổng tiền mừng.',
                style: TextStyle(color: AppColors.textSecondary, height: 1.45),
              ),
            ],
          ),
        ),
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white.withValues(alpha: 0.74),
            border: Border.all(color: AppColors.glassBorder),
          ),
          child: const Icon(
            Icons.auto_awesome_rounded,
            color: AppColors.primary,
          ),
        ),
      ],
    );
  }
}

class _SummarySkeleton extends StatelessWidget {
  const _SummarySkeleton();

  @override
  Widget build(BuildContext context) {
    return GlassPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const <Widget>[
          GlassSkeleton(width: 132, height: 14),
          SizedBox(height: AppSpacing.md),
          GlassSkeleton(width: 188, height: 34),
          SizedBox(height: AppSpacing.xs),
          GlassSkeleton(width: 240, height: 14),
          SizedBox(height: AppSpacing.lg),
          _OverviewSkeletonRow(),
        ],
      ),
    );
  }
}

class _EventListLoadingState extends StatelessWidget {
  const _EventListLoadingState();

  @override
  Widget build(BuildContext context) {
    return const Column(
      children: <Widget>[
        _EventCardSkeleton(),
        SizedBox(height: AppSpacing.md),
        _EventCardSkeleton(),
        SizedBox(height: AppSpacing.md),
        _EventCardSkeleton(),
      ],
    );
  }
}

class _EventCardSkeleton extends StatelessWidget {
  const _EventCardSkeleton();

  @override
  Widget build(BuildContext context) {
    return GlassPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const <Widget>[
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              GlassSkeleton(
                width: 42,
                height: 42,
                borderRadius: BorderRadius.all(Radius.circular(14)),
              ),
              SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    GlassSkeleton(width: 180, height: 16),
                    SizedBox(height: 8),
                    GlassSkeleton(width: 120, height: 12),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: AppSpacing.md),
          Row(
            children: <Widget>[
              GlassSkeleton(width: 88, height: 28),
              SizedBox(width: AppSpacing.xs),
              GlassSkeleton(width: 112, height: 28),
            ],
          ),
          SizedBox(height: AppSpacing.md),
          _OverviewSkeletonRow(),
          SizedBox(height: AppSpacing.md),
          GlassSkeleton(width: 92, height: 14),
        ],
      ),
    );
  }
}

class _OverviewSkeletonRow extends StatelessWidget {
  const _OverviewSkeletonRow();

  @override
  Widget build(BuildContext context) {
    return const Row(
      children: <Widget>[
        Expanded(child: GlassSkeleton(height: 36)),
        SizedBox(width: AppSpacing.sm),
        Expanded(child: GlassSkeleton(height: 36)),
        SizedBox(width: AppSpacing.sm),
        Expanded(child: GlassSkeleton(height: 36)),
      ],
    );
  }
}

class _EventCard extends ConsumerWidget {
  const _EventCard({
    required this.eventList,
    required this.busy,
    required this.onOpen,
    required this.onEdit,
    required this.onDelete,
  });

  final EventListEntity eventList;
  final bool busy;
  final VoidCallback onOpen;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final overviewAsync = ref.watch(eventListOverviewProvider(eventList.id));

    return GestureDetector(
      onTap: onOpen,
      child: GlassPanel(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(14),
                    gradient: const LinearGradient(
                      colors: <Color>[AppColors.primary, AppColors.secondary],
                    ),
                  ),
                  child: const Icon(
                    Icons.celebration_rounded,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        eventList.name,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        eventList.description?.trim().isNotEmpty == true
                            ? eventList.description!
                            : 'Mã ${eventList.code}',
                        style: const TextStyle(color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                ),
                PopupMenuButton<String>(
                  enabled: !busy,
                  onSelected: (String value) {
                    if (value == 'edit') {
                      onEdit();
                    }
                    if (value == 'delete') {
                      onDelete();
                    }
                  },
                  itemBuilder: (BuildContext context) =>
                      const <PopupMenuEntry<String>>[
                        PopupMenuItem<String>(
                          value: 'edit',
                          child: Text('Sửa sự kiện'),
                        ),
                        PopupMenuItem<String>(
                          value: 'delete',
                          child: Text('Xóa sự kiện'),
                        ),
                      ],
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            Wrap(
              spacing: AppSpacing.xs,
              runSpacing: AppSpacing.xs,
              children: <Widget>[
                _Badge(label: eventList.code, color: AppColors.secondary),
                _Badge(
                  label: eventList.eventDate == null
                      ? 'Chưa chọn ngày diễn ra'
                      : DateFormat('dd/MM/yyyy').format(eventList.eventDate!),
                  color: AppColors.info,
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            overviewAsync.when(
              data: (EventListOverview overview) => Row(
                children: <Widget>[
                  Expanded(
                    child: _MetricTile(
                      label: 'Khách',
                      value: '${overview.guestCount}',
                    ),
                  ),
                  Expanded(
                    child: _MetricTile(
                      label: 'Tổng tiền',
                      value: CurrencyFormatter.formatVnd(overview.totalAmount),
                    ),
                  ),
                  Expanded(
                    child: _MetricTile(
                      label: 'Nợ',
                      value: '${overview.debtCount}',
                    ),
                  ),
                ],
              ),
              loading: () => const _OverviewSkeletonRow(),
              error: (_, _) => const Text('Không tải được thống kê.'),
            ),
            const SizedBox(height: AppSpacing.md),
            const Row(
              children: <Widget>[
                Text(
                  'Xem chi tiết',
                  style: TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                SizedBox(width: 6),
                Icon(Icons.arrow_forward_rounded, color: AppColors.primary),
              ],
            ),
          ],
        ),
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
