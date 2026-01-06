import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hrd_app/core/theme/app_colors.dart';
import 'package:hrd_app/features/fitur/data/fitur_data.dart';
import 'package:hrd_app/features/fitur/models/fitur_item_model.dart';
import 'package:hrd_app/features/fitur/widgets/fitur_search_bar.dart';
import 'package:hrd_app/features/fitur/widgets/fitur_section_header.dart';
import 'package:hrd_app/features/fitur/widgets/fitur_category_header.dart';
import 'package:hrd_app/features/fitur/widgets/fitur_item_grid.dart';
import 'package:hrd_app/features/fitur/widgets/fitur_item_list.dart';

class FiturScreen extends StatefulWidget {
  const FiturScreen({super.key});

  @override
  State<FiturScreen> createState() => _FiturScreenState();
}

class _FiturScreenState extends State<FiturScreen> {
  // Default: Grid View (true)
  bool _isGridView = true;
  final _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    setState(() {
      _searchQuery = query;
    });
  }

  void _onItemTap(FiturItemModel item) {
    // TODO: Navigate to feature detail
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Fitur "${item.title}" belum tersedia'),
        duration: const Duration(seconds: 1),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final filteredSections = FiturData.search(_searchQuery);

    return Scaffold(
      backgroundColor: colors.surface,
      body: SafeArea(
        child: Column(
          children: [
            FiturSearchBar(
              controller: _searchController,
              onChanged: _onSearchChanged,
            ),
            // Header dengan title dan toggle buttons
            _buildHeader(colors),

            // Search bar

            // Content
            Expanded(
              child: filteredSections.isEmpty
                  ? _buildEmptyState(colors)
                  : _buildContent(filteredSections, colors),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(dynamic colors) {
    return Container(
      color: colors.background,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 8, 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Fitur',
              style: GoogleFonts.inter(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: colors.textPrimary,
              ),
            ),
            Row(
              children: [
                // List view button
                IconButton(
                  onPressed: () {
                    setState(() {
                      _isGridView = false;
                    });
                  },
                  icon: Icon(
                    Icons.format_list_bulleted,
                    color: !_isGridView
                        ? colors.primaryBlue
                        : colors.inactiveGray,
                    size: 24,
                  ),
                ),
                // Grid view button
                IconButton(
                  onPressed: () {
                    setState(() {
                      _isGridView = true;
                    });
                  },
                  icon: Icon(
                    Icons.grid_view_rounded,
                    color: _isGridView
                        ? colors.primaryBlue
                        : colors.inactiveGray,
                    size: 24,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(dynamic colors) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off, size: 64, color: colors.inactiveGray),
          const SizedBox(height: 16),
          Text(
            'Fitur tidak ditemukan',
            style: GoogleFonts.inter(fontSize: 16, color: colors.textSecondary),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(List<FiturSectionModel> sections, dynamic colors) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (final section in sections) ...[
            // Section header
            FiturSectionHeader(title: section.name),
            // Categories
            for (final category in section.categories) ...[
              Container(
                margin: const EdgeInsets.symmetric(vertical: 2),
                padding: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: colors.background,
                  // borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    FiturCategoryHeader(title: category.name),
                    const SizedBox(height: 16),
                    if (_isGridView)
                      _buildGridItems(
                        category.items,
                        category.backgroundColor,
                        category.iconColor,
                      )
                    else
                      _buildListItems(
                        category.items,
                        category.backgroundColor,
                        category.iconColor,
                      ),
                  ],
                ),
              ),
            ],
          ],
          // Bottom padding
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildGridItems(
    List<FiturItemModel> items,
    Color? categoryBackgroundColor,
    Color? categoryIconColor,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 4,
          childAspectRatio: 0.85,
          crossAxisSpacing: 8,
          mainAxisSpacing: 8,
        ),
        itemCount: items.length,
        itemBuilder: (context, index) {
          return FiturItemGrid(
            item: items[index],
            categoryBackgroundColor: categoryBackgroundColor,
            categoryIconColor: categoryIconColor,
            onTap: () => _onItemTap(items[index]),
          );
        },
      ),
    );
  }

  Widget _buildListItems(
    List<FiturItemModel> items,
    Color? categoryBackgroundColor,
    Color? categoryIconColor,
  ) {
    return Column(
      children: items.map((item) {
        return FiturItemList(
          item: item,
          categoryBackgroundColor: categoryBackgroundColor,
          categoryIconColor: categoryIconColor,
          onTap: () => _onItemTap(item),
        );
      }).toList(),
    );
  }
}
