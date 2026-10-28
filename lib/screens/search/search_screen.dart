import 'dart:io';

import '../../core/routes/app_router.dart';
import 'package:dealix_ai/models/product/product.dart';
import 'package:dealix_ai/services/mock/mock_data_service.dart';
import 'package:dealix_ai/services/mock/recent_search_service.dart';
import 'package:dealix_ai/services/guest_usage_session.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../core/theme/app_colors.dart';
import '../../widgets/common/account_required_dialog.dart';
import 'gallery_screen.dart';

class SearchScreen extends StatefulWidget {
  final String initialQuery;

  const SearchScreen({super.key, required this.initialQuery});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  final ImagePicker _imagePicker = ImagePicker();

  List<Product> _allProducts = [];
  List<Product> _filteredProducts = [];
  List<Product> _recentSearches = [];

  bool _isLoading = true;
  bool _hasError = false;
  bool _initialSearchBlocked = false;

  File? _selectedImage;
  String _searchQuery = '';
  final GuestUsageSession _guestSession = GuestUsageSession.instance;

  final List<String> _popularSearches = [
    'Samsung',
    'AirPods',
    'Dell',
    'iPhone',
  ];

  @override
  void initState() {
    super.initState();
    _searchController.text = widget.initialQuery;
    _searchQuery = widget.initialQuery.trim();

    if (_searchQuery.isNotEmpty && !_guestSession.tryUseSearch()) {
      _searchQuery = '';
      _searchController.clear();
      _initialSearchBlocked = true;
    }

    _loadInitialData();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && _initialSearchBlocked) {
        showAccountRequiredDialog(context);
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadInitialData() async {
    setState(() {
      _isLoading = true;
      _hasError = false;
    });

    try {
      final products = await MockDataService().getProducts();
      final recent = await RecentSearchService().getRecentSearches();

      if (!mounted) return;

      setState(() {
        _allProducts = products;
        _filteredProducts = _filterProducts(_searchQuery);
        _recentSearches = recent;
        _isLoading = false;
        _hasError = false;
      });
    } catch (_) {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
        _hasError = true;
      });

      _showThemedMessage('Products load nahi ho sake.');
    }
  }

  List<Product> _filterProducts(String query) {
    if (query.trim().isEmpty) {
      return List<Product>.from(_allProducts);
    }

    final search = query.trim().toLowerCase();

    return _allProducts.where((product) {
      return product.name.toLowerCase().contains(search) ||
          product.brand.toLowerCase().contains(search) ||
          product.model.toLowerCase().contains(search) ||
          product.category.toLowerCase().contains(search) ||
          product.barcode.toLowerCase().contains(search);
    }).toList();
  }

  void _searchProducts([String? value]) {
    final query = (value ?? _searchController.text).trim();

    setState(() {
      _searchQuery = query;
      _filteredProducts = _filterProducts(query);
    });
  }

  void _onSearchChanged(String value) {
    if (_searchQuery.isEmpty) return;

    setState(() {
      _searchQuery = '';
      _filteredProducts = List<Product>.from(_allProducts);
    });
  }

  void _submitSearch([String? value]) {
    final query = (value ?? _searchController.text).trim();
    if (query.isEmpty) {
      _searchProducts();
      return;
    }

    if (!_guestSession.tryUseSearch()) {
      showAccountRequiredDialog(context);
      return;
    }

    _searchProducts(query);
  }

  void _selectPopularSearch(String value) {
    _searchController.text = value;
    _submitSearch(value);
    FocusScope.of(context).unfocus();
  }

  void _clearSearch() {
    _searchController.clear();

    setState(() {
      _searchQuery = '';
      _filteredProducts = List<Product>.from(_allProducts);
      _selectedImage = null;
    });

    FocusScope.of(context).unfocus();
  }

  Future<void> _openProduct(Product product) async {
    try {
      await RecentSearchService().addRecentSearch(product);
      final recent = await RecentSearchService().getRecentSearches();

      if (!mounted) return;

      setState(() {
        _recentSearches = recent;
      });

      _showThemedMessage('${product.name} added to recent searches.');
    } catch (_) {
      if (!mounted) return;
      _showThemedMessage('Could not update recent searches.');
    }
  }

  Future<void> _clearRecentSearches() async {
    try {
      await RecentSearchService().clearRecentSearches();

      if (!mounted) return;

      setState(() {
        _recentSearches = [];
      });

      _showThemedMessage('Recent searches cleared.');
    } catch (_) {
      if (!mounted) return;
      _showThemedMessage('Could not clear recent searches.');
    }
  }

  Future<void> _pickCameraImage() async {
    try {
      final image = await _imagePicker.pickImage(
        source: ImageSource.camera,
        imageQuality: 85,
      );

      if (!mounted || image == null) return;

      setState(() {
        _selectedImage = File(image.path);
      });

      _showThemedMessage('Photo captured successfully.');
    } catch (_) {
      if (!mounted) return;

      _showThemedMessage('Unable to open camera. Please check permissions.');
    }
  }

  Future<void> _openCustomGallery() async {
    try {
      final image = await Navigator.push<File>(
        context,
        MaterialPageRoute<File>(builder: (context) => const GalleryScreen()),
      );

      if (!mounted || image == null) return;

      setState(() {
        _selectedImage = image;
      });

      _showThemedMessage('Image selected successfully.');
    } catch (_) {
      if (!mounted) return;

      _showThemedMessage('Unable to select image. Please try again.');
    }
  }

  void _showNotConnectedMessage(String section) {
    _showThemedMessage('$section screen is not connected yet.');
  }

  void _showThemedMessage(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(
                Icons.check_circle_outline_rounded,
                color: AppColors.secondaryTeal,
                size: 22,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  message,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          backgroundColor: AppColors.softMint,
          behavior: SnackBarBehavior.floating,
          elevation: 3,
          margin: const EdgeInsets.all(16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
            side: const BorderSide(color: AppColors.border),
          ),
          duration: const Duration(seconds: 2),
        ),
      );
  }

  Widget _buildSectionTitle(
    String title, {
    String? actionText,
    VoidCallback? onAction,
  }) {
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
        ),
        if (actionText != null)
          TextButton(
            onPressed: onAction,
            style: TextButton.styleFrom(
              foregroundColor: AppColors.primaryGreen,
            ),
            child: Text(actionText),
          ),
      ],
    );
  }

  Widget _buildSearchField() {
    return TextField(
      controller: _searchController,
      onChanged: _onSearchChanged,
      onSubmitted: _submitSearch,
      textInputAction: TextInputAction.search,
      style: const TextStyle(color: AppColors.textPrimary),
      decoration: InputDecoration(
        hintText: 'Search for a product, brand...',
        hintStyle: const TextStyle(
          color: AppColors.textSecondary,
          fontSize: 13,
        ),
        prefixIcon: const Icon(
          Icons.search_rounded,
          color: AppColors.secondaryTeal,
        ),
        suffixIcon: _searchQuery.isNotEmpty
            ? IconButton(
                onPressed: _clearSearch,
                icon: const Icon(
                  Icons.close_rounded,
                  color: AppColors.textSecondary,
                ),
              )
            : null,
        filled: true,
        fillColor: AppColors.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 15,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(
            color: AppColors.secondaryTeal,
            width: 1.5,
          ),
        ),
      ),
    );
  }

  // Camera aur Gallery: white background + secondary teal icon/text.
  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
  }) {
    return Expanded(
      child: SizedBox(
        height: 48,
        child: OutlinedButton.icon(
          onPressed: onPressed,
          icon: Icon(icon, size: 19, color: AppColors.secondaryTeal),
          label: Text(
            label,
            style: const TextStyle(
              color: AppColors.secondaryTeal,
              fontWeight: FontWeight.w600,
            ),
          ),
          style: OutlinedButton.styleFrom(
            backgroundColor: AppColors.white,
            foregroundColor: AppColors.secondaryTeal,
            side: const BorderSide(color: AppColors.border),
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSelectedImage() {
    final image = _selectedImage;

    if (image == null) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.only(top: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.file(
              image,
              width: 76,
              height: 76,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  width: 76,
                  height: 76,
                  color: AppColors.softMint,
                  child: const Icon(
                    Icons.image_not_supported_outlined,
                    color: AppColors.secondaryTeal,
                  ),
                );
              },
            ),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Image selected',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Image is ready for product identification.',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () {
              setState(() => _selectedImage = null);
            },
            icon: const Icon(
              Icons.close_rounded,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentSearches() {
    if (_recentSearches.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle(
          'Recent Searches',
          actionText: 'Clear',
          onAction: _clearRecentSearches,
        ),
        const SizedBox(height: 4),
        ..._recentSearches
            .take(3)
            .map(
              (product) => ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const CircleAvatar(
                  backgroundColor: AppColors.softMint,
                  child: Icon(
                    Icons.history_rounded,
                    color: AppColors.secondaryTeal,
                  ),
                ),
                title: Text(
                  product.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                subtitle: Text(
                  product.brand,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                  ),
                ),
                trailing: const Icon(
                  Icons.north_west_rounded,
                  size: 17,
                  color: AppColors.textSecondary,
                ),
                onTap: () {
                  _searchController.text = product.name;
                  _submitSearch(product.name);
                  FocusScope.of(context).unfocus();
                },
              ),
            ),
        const SizedBox(height: 12),
      ],
    );
  }

  Widget _buildPopularSearches() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Popular Right Now'),
        const SizedBox(height: 8),
        Wrap(
          spacing: 9,
          runSpacing: 9,
          children: _popularSearches.map((search) {
            return ActionChip(
              label: Text(search),
              onPressed: () => _selectPopularSearch(search),
              backgroundColor: AppColors.white,
              side: const BorderSide(color: AppColors.border),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(22),
              ),
              labelStyle: const TextStyle(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w500,
              ),
              avatar: const Icon(
                Icons.trending_up_rounded,
                size: 17,
                color: AppColors.secondaryTeal,
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildProductCard(Product product) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: InkWell(
        onTap: () => _openProduct(product),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Container(
                width: 76,
                height: 76,
                decoration: BoxDecoration(
                  color: AppColors.lightMint,
                  borderRadius: BorderRadius.circular(12),
                ),
                clipBehavior: Clip.antiAlias,
                child: product.imageUrl.isNotEmpty
                    ? Image.network(
                        product.imageUrl,
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) {
                          return const Icon(
                            Icons.shopping_bag_outlined,
                            color: AppColors.secondaryTeal,
                            size: 32,
                          );
                        },
                      )
                    : const Icon(
                        Icons.shopping_bag_outlined,
                        color: AppColors.secondaryTeal,
                        size: 32,
                      ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${product.brand} • ${product.category}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 7),
                    Text(
                      '${product.currency} ${product.price}',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppColors.secondaryTeal,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 4),
              const Icon(
                Icons.chevron_right_rounded,
                color: AppColors.textSecondary,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildResults() {
    if (_isLoading) {
      return const Padding(
        padding: EdgeInsets.all(40),
        child: Center(
          child: CircularProgressIndicator(color: AppColors.secondaryTeal),
        ),
      );
    }

    if (_hasError) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const Icon(
                Icons.error_outline_rounded,
                size: 44,
                color: AppColors.error,
              ),
              const SizedBox(height: 12),
              const Text(
                'Something went wrong',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: _loadInitialData,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.secondaryTeal,
                  foregroundColor: AppColors.white,
                ),
                child: const Text('Try Again'),
              ),
            ],
          ),
        ),
      );
    }

    if (_filteredProducts.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 36),
        child: Center(
          child: Column(
            children: [
              const Icon(
                Icons.search_off_rounded,
                size: 48,
                color: AppColors.textSecondary,
              ),
              const SizedBox(height: 12),
              const Text(
                'No products found',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Try another product name or brand.',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.textSecondary),
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: _clearSearch,
                child: const Text(
                  'Clear Search',
                  style: TextStyle(color: AppColors.secondaryTeal),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Search Results'),
        const SizedBox(height: 8),
        ..._filteredProducts.map(_buildProductCard),
      ],
    );
  }

  Widget _buildTipCard() {
    return Container(
      margin: const EdgeInsets.only(top: 22),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.lightbulb_outline_rounded,
            color: AppColors.secondaryTeal,
            size: 23,
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Smart Shopping Tip',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                SizedBox(height: 5),
                Text(
                  'Search by product name or brand, or choose an image to get started.',
                  style: TextStyle(
                    fontSize: 12,
                    height: 1.5,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    bool selected = false,
  }) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 7),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 23,
                color: selected
                    ? AppColors.secondaryTeal
                    : AppColors.textSecondary,
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                  color: selected
                      ? AppColors.secondaryTeal
                      : AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBottomNavigation() {
    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.fromLTRB(8, 9, 8, 7),
        decoration: BoxDecoration(
          color: AppColors.white,
          border: const Border(top: BorderSide(color: AppColors.border)),
          boxShadow: [
            BoxShadow(
              color: AppColors.textPrimary.withValues(alpha: 0.04),
              blurRadius: 12,
              offset: const Offset(0, -3),
            ),
          ],
        ),
        child: Row(
          children: [
            _buildNavItem(
              icon: Icons.home_rounded,
              label: 'Home',
              onTap: () {
                if (Navigator.canPop(context)) {
                  Navigator.pop(context);
                } else {
                  _showNotConnectedMessage('Home');
                }
              },
            ),
            _buildNavItem(
              icon: Icons.notifications_none_rounded,
              label: 'Alerts',
              onTap: () => _showNotConnectedMessage('Alerts'),
            ),
            Expanded(
              child: InkWell(
                onTap: () {
  Navigator.pushNamed(context, AppRouter.aiScan);
},
                borderRadius: BorderRadius.circular(16),
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 2),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 49,
                        height: 43,
                        decoration: BoxDecoration(
                          color: AppColors.secondaryTeal,
                          borderRadius: BorderRadius.circular(15),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.secondaryTeal.withValues(
                                alpha: 0.22,
                              ),
                              blurRadius: 8,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.qr_code_scanner_rounded,
                          color: AppColors.white,
                          size: 25,
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Scan',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: AppColors.secondaryTeal,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            _buildNavItem(
              icon: Icons.bookmark_border_rounded,
              label: 'Saved',
              onTap: () => _showNotConnectedMessage('Saved'),
            ),
            _buildNavItem(
              icon: Icons.person_outline_rounded,
              label: 'Profile',
              onTap: () => _showNotConnectedMessage('Profile'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.appBackground,
      appBar: AppBar(
        backgroundColor: const Color(0xFF012A22),
        foregroundColor: AppColors.white,
        surfaceTintColor: const Color(0xFF012A22),
        elevation: 0,
        titleSpacing: 20,
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Find Your Product',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: AppColors.white,
              ),
            ),
            SizedBox(height: 3),
            Text(
              'Search smarter with Dealix AI',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w400,
                color: AppColors.white,
              ),
            ),
          ],
        ),
      ),
      body: SafeArea(
        top: false,
        child: RefreshIndicator(
          color: AppColors.secondaryTeal,
          onRefresh: _loadInitialData,
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              // Home Screen jaisa dark green gradient.
              Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFF012A22), Color(0xFF033D30)],
                  ),
                ),
                padding: const EdgeInsets.fromLTRB(20, 10, 20, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSearchField(),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        _buildActionButton(
                          icon: Icons.camera_alt_rounded,
                          label: 'Camera',
                          onPressed: _pickCameraImage,
                        ),
                        const SizedBox(width: 10),
                        _buildActionButton(
                          icon: Icons.photo_library_outlined,
                          label: 'Gallery',
                          onPressed: _openCustomGallery,
                        ),
                      ],
                    ),
                    _buildSelectedImage(),
                  ],
                ),
              ),

              // Popular searches aur neeche ka content light rahega.
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (_searchQuery.isEmpty) ...[
                      _buildRecentSearches(),
                      _buildPopularSearches(),
                      _buildTipCard(),
                    ] else ...[
                      _buildResults(),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomNavigation(),
    );
  }
}
