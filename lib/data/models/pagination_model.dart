/// Model untuk pagination response dari API
class PaginationModel {
  final int totalData;
  final int totalPages;
  final int currentPage;
  final int pageSize;

  const PaginationModel({
    required this.totalData,
    required this.totalPages,
    required this.currentPage,
    required this.pageSize,
  });

  factory PaginationModel.fromJson(Map<String, dynamic> json) {
    return PaginationModel(
      totalData: json['total_data'] as int? ?? 0,
      totalPages: json['total_pages'] as int? ?? 1,
      currentPage: json['current_page'] as int? ?? 1,
      pageSize: json['page_size'] as int? ?? 10,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'total_data': totalData,
      'total_pages': totalPages,
      'current_page': currentPage,
      'page_size': pageSize,
    };
  }

  /// Check apakah ada halaman sebelumnya
  bool get hasPreviousPage => currentPage > 1;

  /// Check apakah ada halaman berikutnya
  bool get hasNextPage => currentPage < totalPages;

  /// Check apakah data kosong
  bool get isEmpty => totalData == 0;

  /// Check apakah hanya ada satu halaman
  bool get isSinglePage => totalPages <= 1;
}
