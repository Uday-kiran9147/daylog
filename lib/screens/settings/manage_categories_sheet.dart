// lib/screens/settings/manage_categories_sheet.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/user_settings_provider.dart';
import '../../utils/constants.dart';

class ManageCategoriesSheet extends ConsumerStatefulWidget {
  const ManageCategoriesSheet({super.key});

  @override
  ConsumerState<ManageCategoriesSheet> createState() => _ManageCategoriesSheetState();
}

class _ManageCategoriesSheetState extends ConsumerState<ManageCategoriesSheet> {
  String _searchQuery = '';
  String _selectedDomain = 'All';

  void _showAddCustomCategoryDialog() {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('New Category', style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
        content: TextField(
          controller: controller,
          autofocus: true,
          textCapitalization: TextCapitalization.words,
          decoration: const InputDecoration(
            hintText: 'e.g. Mobile Apps, Guitar, Research',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              final name = controller.text.trim();
              if (name.isNotEmpty) {
                ref.read(userSettingsProvider.notifier).addCustomCategory(name);
                Navigator.pop(ctx);
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final allCategories = ref.watch(allAvailableCategoriesProvider);
    final userCategories = ref.watch(userCategoriesProvider);

    final filteredCategories = allCategories.where((cat) {
      if (_searchQuery.isNotEmpty && !cat.toLowerCase().contains(_searchQuery.toLowerCase())) {
        return false;
      }
      if (_selectedDomain != 'All') {
        final domain = kCategoryDomains.firstWhere((d) => d.title == _selectedDomain);
        if (!domain.categories.contains(cat)) return false;
      }
      return true;
    }).toList();

    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Drag Handle
          Center(
            child: Container(
              width: 38,
              height: 4,
              decoration: BoxDecoration(
                color: theme.colorScheme.outlineVariant,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 14),

          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Manage Categories',
                style: TextStyle(
                  fontSize: 19,
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              OutlinedButton.icon(
                onPressed: _showAddCustomCategoryDialog,
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
                  side: BorderSide(color: theme.colorScheme.outlineVariant),
                ),
                icon: const Icon(Icons.add_rounded, size: 16),
                label: const Text('Add New', style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600)),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            'Toggle categories to customize your quick start chips and timer selections.',
            style: TextStyle(
              fontSize: 12,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
            ),
          ),
          const SizedBox(height: 14),

          // Search Bar
          SizedBox(
            height: 40,
            child: TextField(
              onChanged: (val) => setState(() => _searchQuery = val.trim()),
              decoration: InputDecoration(
                hintText: 'Search categories...',
                prefixIcon: const Icon(Icons.search_rounded, size: 18),
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                isDense: true,
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear_rounded, size: 16),
                        onPressed: () => setState(() => _searchQuery = ''),
                      )
                    : null,
              ),
            ),
          ),
          const SizedBox(height: 10),

          // Domain Filter Tabs
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            clipBehavior: Clip.none,
            child: Row(
              children: [
                _DomainTab(
                  label: 'All Domains',
                  isSelected: _selectedDomain == 'All',
                  onTap: () => setState(() => _selectedDomain = 'All'),
                ),
                ...kCategoryDomains.map((d) => _DomainTab(
                      label: d.title,
                      icon: d.icon,
                      isSelected: _selectedDomain == d.title,
                      onTap: () => setState(() => _selectedDomain = d.title),
                    )),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Selected counter
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: isDark
                  ? Colors.black.withValues(alpha: 0.25)
                  : Colors.black.withValues(alpha: 0.03),
              borderRadius: BorderRadius.circular(999),
              border: Border.all(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.06)
                    : Colors.black.withValues(alpha: 0.04),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${userCategories.length} active categories',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.primary,
                  ),
                ),
                Text(
                  'Tap chip to toggle',
                  style: TextStyle(
                    fontSize: 11,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.55),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Chips List / Domain Sections
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                if (_searchQuery.isNotEmpty || _selectedDomain != 'All') ...[
                  if (filteredCategories.isEmpty)
                    Padding(
                      padding: const EdgeInsets.all(24),
                      child: Center(
                        child: Text(
                          'No category found matching "$_searchQuery"',
                          style: TextStyle(fontSize: 13, color: theme.colorScheme.onSurface.withValues(alpha: 0.6)),
                        ),
                      ),
                    )
                  else
                    Wrap(
                      spacing: 8,
                      runSpacing: 10,
                      children: filteredCategories.map((cat) {
                        final isSelected = userCategories.contains(cat);
                        return _ManageCategoryChip(
                          category: cat,
                          isSelected: isSelected,
                          onTap: () {
                            final current = [...userCategories];
                            if (isSelected) {
                              if (current.length > 1) {
                                current.remove(cat);
                                ref.read(userSettingsProvider.notifier).updateSelectedCategories(current);
                              }
                            } else {
                              current.add(cat);
                              ref.read(userSettingsProvider.notifier).updateSelectedCategories(current);
                            }
                          },
                        );
                      }).toList(),
                    ),
                ] else ...[
                  ...kCategoryDomains.map((domain) {
                    final domainCats = domain.categories.where((c) => allCategories.contains(c)).toList();
                    if (domainCats.isEmpty) return const SizedBox.shrink();

                    final selectedCountInDomain = domainCats.where((c) => userCategories.contains(c)).length;

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 18),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(bottom: 8, left: 2),
                            child: Row(
                              children: [
                                Icon(domain.icon, size: 15, color: theme.colorScheme.primary.withValues(alpha: 0.85)),
                                const SizedBox(width: 6),
                                Text(
                                  domain.title,
                                  style: TextStyle(
                                    fontSize: 12.5,
                                    fontWeight: FontWeight.w700,
                                    color: theme.colorScheme.onSurface.withValues(alpha: 0.85),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                if (selectedCountInDomain > 0)
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
                                    decoration: BoxDecoration(
                                      color: isDark ? DaylogColors.darkAccent100 : DaylogColors.accent100,
                                      borderRadius: BorderRadius.circular(999),
                                    ),
                                    child: Text(
                                      '$selectedCountInDomain/${domainCats.length}',
                                      style: TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                        color: isDark ? DaylogColors.darkAccent : DaylogColors.accent700,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          Wrap(
                            spacing: 8,
                            runSpacing: 10,
                            children: domainCats.map((cat) {
                              final isSelected = userCategories.contains(cat);
                              return _ManageCategoryChip(
                                category: cat,
                                isSelected: isSelected,
                                onTap: () {
                                  final current = [...userCategories];
                                  if (isSelected) {
                                    if (current.length > 1) {
                                      current.remove(cat);
                                      ref.read(userSettingsProvider.notifier).updateSelectedCategories(current);
                                    }
                                  } else {
                                    current.add(cat);
                                    ref.read(userSettingsProvider.notifier).updateSelectedCategories(current);
                                  }
                                },
                              );
                            }).toList(),
                          ),
                        ],
                      ),
                    );
                  }),

                  if (allCategories.any((c) => !kCategories.contains(c))) ...[
                    Padding(
                      padding: const EdgeInsets.only(bottom: 18),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(bottom: 8, left: 2),
                            child: Row(
                              children: [
                                Icon(Icons.label_outline_rounded, size: 15, color: theme.colorScheme.primary),
                                const SizedBox(width: 6),
                                Text(
                                  'Custom Categories',
                                  style: TextStyle(
                                    fontSize: 12.5,
                                    fontWeight: FontWeight.w700,
                                    color: theme.colorScheme.onSurface.withValues(alpha: 0.85),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Wrap(
                            spacing: 8,
                            runSpacing: 10,
                            children: allCategories.where((c) => !kCategories.contains(c)).map((cat) {
                              final isSelected = userCategories.contains(cat);
                              return _ManageCategoryChip(
                                category: cat,
                                isSelected: isSelected,
                                onTap: () {
                                  final current = [...userCategories];
                                  if (isSelected) {
                                    if (current.length > 1) {
                                      current.remove(cat);
                                      ref.read(userSettingsProvider.notifier).updateSelectedCategories(current);
                                    }
                                  } else {
                                    current.add(cat);
                                    ref.read(userSettingsProvider.notifier).updateSelectedCategories(current);
                                  }
                                },
                              );
                            }).toList(),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ManageCategoryChip extends StatelessWidget {
  final String category;
  final bool isSelected;
  final VoidCallback onTap;

  const _ManageCategoryChip({
    required this.category,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final info = getCategoryInfo(category);

    final selectedBg = isDark ? info.darkBg : info.lightBg;
    final selectedFg = isDark ? info.darkFg : info.lightFg;
    final selectedBorder = isDark
        ? Colors.white.withValues(alpha: 0.28)
        : info.tileColor.withValues(alpha: 0.45);

    final unselectedBg = theme.cardTheme.color ?? (isDark ? DaylogColors.darkCard : DaylogColors.lightCard);
    final unselectedBorder = isDark
        ? Colors.white.withValues(alpha: 0.12)
        : Colors.white.withValues(alpha: 0.85);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          HapticFeedback.selectionClick();
          onTap();
        },
        borderRadius: BorderRadius.circular(999),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          curve: Curves.easeOutCubic,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? selectedBg : unselectedBg,
            borderRadius: BorderRadius.circular(999),
            border: Border.all(
              color: isSelected ? selectedBorder : unselectedBorder,
              width: isSelected ? 1.2 : 1.0,
            ),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: info.tileColor.withValues(alpha: isDark ? 0.35 : 0.18),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.03),
                      blurRadius: 6,
                      offset: const Offset(0, 1),
                    ),
                  ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                info.icon,
                size: 15,
                color: isSelected ? selectedFg : theme.colorScheme.onSurface.withValues(alpha: 0.7),
              ),
              const SizedBox(width: 7),
              Text(
                capitalizeCategory(category),
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  color: isSelected ? selectedFg : theme.colorScheme.onSurface,
                  letterSpacing: -0.1,
                ),
              ),
              if (isSelected) ...[
                const SizedBox(width: 6),
                Icon(Icons.check_rounded, size: 14, color: selectedFg),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _DomainTab extends StatelessWidget {
  final String label;
  final IconData? icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _DomainTab({
    required this.label,
    this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.only(right: 6),
      child: InkWell(
        onTap: () {
          HapticFeedback.selectionClick();
          onTap();
        },
        borderRadius: BorderRadius.circular(999),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 6),
          decoration: BoxDecoration(
            color: isSelected
                ? (isDark ? DaylogColors.darkAccent : theme.colorScheme.primary)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(999),
            border: Border.all(
              color: isSelected
                  ? Colors.transparent
                  : (isDark
                      ? Colors.white.withValues(alpha: 0.10)
                      : Colors.black.withValues(alpha: 0.06)),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[
                Icon(
                  icon,
                  size: 13,
                  color: isSelected ? Colors.white : theme.colorScheme.onSurface.withValues(alpha: 0.65),
                ),
                const SizedBox(width: 5),
              ],
              Text(
                label,
                style: TextStyle(
                  fontSize: 11.5,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                  color: isSelected ? Colors.white : theme.colorScheme.onSurface.withValues(alpha: 0.75),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
