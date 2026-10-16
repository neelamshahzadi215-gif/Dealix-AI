import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

import '../../models/product/product.dart';
import '../../services/mock/mock_data_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _searchController =
      TextEditingController();

  final MockDataService _mockDataService = MockDataService();

  final stt.SpeechToText _speechToText =
      stt.SpeechToText();

  List<Product> _products = [];
  List<String> _recentSearches = [];

  bool _loading = true;
  bool _isListening = false;

  int _selectedIndex = 0;

  static const Color deepGreen = Color(0xFF012A22);
  static const Color deepGreen2 = Color(0xFF033D30);
  static const Color buttonGreen = Color(0xFF079866);
  static const Color lightGreen = Color(0xFF0BB77B);
  static const Color white = Color(0xFFFFFFFF);
  static const Color darkText = Color(0xFF172033);
  static const Color greyText = Color(0xFF64748B);
  static const Color paleGreen = Color(0xFFEFFAF7);
  static const Color borderGreen = Color(0xFFD7EEE7);

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _speechToText.stop();
    super.dispose();
  }

  // =========================================================
  // LOAD PRODUCTS
  // =========================================================

  Future<void> _loadData() async {
    try {
      final products = await _mockDataService.getProducts();

      if (!mounted) return;

      setState(() {
        _products = products;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _loading = false;
      });

      _message('Unable to load products.');
    }
  }

  // =========================================================
  // SEARCH
  // =========================================================

  void _search([String? value]) {
    final query = (value ?? _searchController.text).trim();

    if (query.isEmpty) {
      _message('Please enter a product name.');
      return;
    }

    final normalizedQuery = query.toLowerCase();

    final matches = _products.where((product) {
      return product.name.toLowerCase().contains(normalizedQuery) ||
          product.brand.toLowerCase().contains(normalizedQuery) ||
          product.model.toLowerCase().contains(normalizedQuery) ||
          product.category.toLowerCase().contains(normalizedQuery) ||
          product.barcode.toLowerCase().contains(normalizedQuery);
    }).toList();

    setState(() {
      _searchController.text = query;

      _recentSearches.removeWhere(
        (item) => item.toLowerCase() == query.toLowerCase(),
      );

      _recentSearches.insert(0, query);

      if (_recentSearches.length > 10) {
        _recentSearches = _recentSearches.take(10).toList();
      }
    });

    if (matches.isEmpty) {
      _message('No product found for "$query".');
      return;
    }

    _showSearchResults(matches, query);
  }

  // =========================================================
  // SEARCH RESULTS
  // =========================================================

  void _showSearchResults(
    List<Product> products,
    String query,
  ) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.72,
          decoration: const BoxDecoration(
            color: white,
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(28),
            ),
          ),
          child: Column(
            children: [
              const SizedBox(height: 12),
              Container(
                width: 42,
                height: 5,
                decoration: BoxDecoration(
                  color: Colors.black12,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.search_rounded,
                      color: buttonGreen,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Results for "$query"',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: darkText,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.fromLTRB(
                    20,
                    8,
                    20,
                    24,
                  ),
                  itemCount: products.length,
                  separatorBuilder: (_, _) =>
                      const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    return _productResultCard(
                      products[index],
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _productResultCard(Product product) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: paleGreen,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: borderGreen,
        ),
      ),
      child: Row(
        children: [
          _productIcon(product),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: darkText,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${product.brand} • ${product.category}',
                  style: const TextStyle(
                    color: greyText,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 7),
                Text(
                  'PKR ${product.price.toStringAsFixed(0)}',
                  style: const TextStyle(
                    color: buttonGreen,
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
          const Icon(
            Icons.chevron_right_rounded,
            color: greyText,
          ),
        ],
      ),
    );
  }

  Widget _productIcon(Product product) {
    IconData icon;

    switch (product.category.toLowerCase()) {
      case 'smartphone':
        icon = Icons.smartphone_rounded;
        break;
      case 'audio':
        icon = Icons.headphones_rounded;
        break;
      case 'laptop':
        icon = Icons.laptop_rounded;
        break;
      default:
        icon = Icons.shopping_bag_rounded;
    }

    return Container(
      width: 58,
      height: 58,
      decoration: BoxDecoration(
        color: white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Icon(
        icon,
        color: buttonGreen,
        size: 28,
      ),
    );
  }

  // =========================================================
  // BARCODE SCANNER
  // =========================================================

  Future<void> _openBarcodeScanner() async {
    final scannedCode = await Navigator.push<String>(
      context,
      MaterialPageRoute(
        builder: (_) => const _BarcodeScannerScreen(),
      ),
    );

    if (!mounted ||
        scannedCode == null ||
        scannedCode.isEmpty) {
      return;
    }

    final normalizedCode = scannedCode.trim();

    final matches = _products.where(
      (product) => product.barcode == normalizedCode,
    );

    if (matches.isEmpty) {
      _searchController.text = normalizedCode;

      _message(
        'Barcode scanned: $normalizedCode\n'
        'No matching product found in mock data.',
      );

      return;
    }

    final product = matches.first;

    _searchController.text = product.name;

    setState(() {
      _recentSearches.removeWhere(
        (item) =>
            item.toLowerCase() ==
            product.name.toLowerCase(),
      );

      _recentSearches.insert(
        0,
        product.name,
      );

      if (_recentSearches.length > 10) {
        _recentSearches =
            _recentSearches.take(10).toList();
      }
    });

    _showSearchResults(
      [product],
      'Scanned Product',
    );
  }

  // =========================================================
  // VOICE SEARCH
  // =========================================================

  Future<void> _startVoiceSearch() async {
    if (_isListening) {
      await _speechToText.stop();

      if (mounted) {
        setState(() {
          _isListening = false;
        });
      }

      return;
    }

    final available = await _speechToText.initialize(
      onStatus: (status) {
        if (status == 'done' ||
            status == 'notListening') {
          if (mounted) {
            setState(() {
              _isListening = false;
            });
          }
        }
      },
      onError: (error) {
        if (mounted) {
          setState(() {
            _isListening = false;
          });

          _message(
            'Voice search error. Please try again.',
          );
        }
      },
    );

    if (!available) {
      _message(
        'Voice recognition is not available on this device.',
      );
      return;
    }

    if (!mounted) return;

    setState(() {
      _isListening = true;
    });

    _message('Listening... Speak a product name.');

    await _speechToText.listen(
      onResult: (result) {
        if (!mounted) return;

        final recognizedText =
            result.recognizedWords.trim();

        if (recognizedText.isNotEmpty) {
          setState(() {
            _searchController.text = recognizedText;
          });

          if (result.finalResult) {
            _speechToText.stop();

            setState(() {
              _isListening = false;
            });

            _search(recognizedText);
          }
        }
      },
    );
  }

  // =========================================================
  // PASTE LINK
  // =========================================================

  Future<void> _pasteLink() async {
    final clipboardData =
        await Clipboard.getData('text/plain');

    final text =
        clipboardData?.text?.trim() ?? '';

    if (text.isEmpty) {
      _message('No link found in clipboard.');
      return;
    }

    final uri = Uri.tryParse(text);

    if (uri == null ||
        !(uri.scheme == 'http' ||
            uri.scheme == 'https')) {
      _searchController.text = text;

      _message(
        'Clipboard text is not a valid product link.',
      );

      return;
    }

    _searchController.text = text;

    _showLinkDialog(text);
  }

  void _showLinkDialog(String link) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(22),
          ),
          title: const Row(
            children: [
              Icon(
                Icons.link_rounded,
                color: buttonGreen,
              ),
              SizedBox(width: 10),
              Text('Product Link'),
            ],
          ),
          content: Text(
            link,
            maxLines: 5,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: greyText,
              fontSize: 14,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text(
                'Cancel',
                style: TextStyle(
                  color: greyText,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);

                _message(
                  'Product link received successfully.',
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: buttonGreen,
                foregroundColor: white,
              ),
              child: const Text('Continue'),
            ),
          ],
        );
      },
    );
  }

  // =========================================================
  // RECENT SEARCHES
  // =========================================================

  Widget _recentSection() {
    if (_recentSearches.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Expanded(
              child: Text(
                'Recent Searches',
                style: TextStyle(
                  color: white,
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            GestureDetector(
              onTap: _viewAllRecentSearches,
              child: const Text(
                'View all',
                style: TextStyle(
                  color: lightGreen,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        ..._recentSearches.take(3).map(
          (search) => Padding(
            padding: const EdgeInsets.only(
              bottom: 9,
            ),
            child: _recentCard(search),
          ),
        ),
      ],
    );
  }

  Widget _recentCard(String search) {
    return GestureDetector(
      onTap: () {
        _searchController.text = search;
        _search(search);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 11,
        ),
        decoration: BoxDecoration(
          color: white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: paleGreen,
                borderRadius:
                    BorderRadius.circular(11),
              ),
              child: const Icon(
                Icons.history_rounded,
                color: buttonGreen,
                size: 21,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                search,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: darkText,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const Icon(
              Icons.chevron_right_rounded,
              color: greyText,
              size: 21,
            ),
          ],
        ),
      ),
    );
  }

  void _viewAllRecentSearches() {
    if (_recentSearches.isEmpty) {
      _message('No recent searches yet.');
      return;
    }

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return Container(
          height:
              MediaQuery.of(context).size.height * 0.65,
          decoration: const BoxDecoration(
            color: white,
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(28),
            ),
          ),
          child: Column(
            children: [
              const SizedBox(height: 12),

              Container(
                width: 42,
                height: 5,
                decoration: BoxDecoration(
                  color: Colors.black12,
                  borderRadius:
                      BorderRadius.circular(10),
                ),
              ),

              const SizedBox(height: 18),

              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                ),
                child: Row(
                  children: [
                    const Expanded(
                      child: Text(
                        'Recent Searches',
                        style: TextStyle(
                          color: darkText,
                          fontSize: 19,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        setState(() {
                          _recentSearches.clear();
                        });

                        Navigator.pop(context);
                      },
                      child: const Text(
                        'Clear all',
                        style: TextStyle(
                          color: buttonGreen,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 5),

              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.fromLTRB(
                    20,
                    8,
                    20,
                    24,
                  ),
                  itemCount: _recentSearches.length,
                  separatorBuilder: (_, _) =>
                      const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    final search =
                        _recentSearches[index];

                    return GestureDetector(
                      onTap: () {
                        Navigator.pop(context);

                        _searchController.text =
                            search;

                        _search(search);
                      },
                      child: Container(
                        padding:
                            const EdgeInsets.symmetric(
                          horizontal: 15,
                          vertical: 14,
                        ),
                        decoration: BoxDecoration(
                          color: paleGreen,
                          borderRadius:
                              BorderRadius.circular(16),
                          border: Border.all(
                            color: borderGreen,
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: white,
                                borderRadius:
                                    BorderRadius.circular(
                                  12,
                                ),
                              ),
                              child: const Icon(
                                Icons.history_rounded,
                                color: buttonGreen,
                                size: 21,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                search,
                                maxLines: 1,
                                overflow:
                                    TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: darkText,
                                  fontSize: 14,
                                  fontWeight:
                                      FontWeight.w600,
                                ),
                              ),
                            ),
                            const Icon(
                              Icons
                                  .arrow_forward_ios_rounded,
                              color: greyText,
                              size: 15,
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // =========================================================
  // MESSAGE
  // =========================================================

  void _message(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 2),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      );
  }

  // =========================================================
  // BUILD
  // =========================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: deepGreen,
      body: SafeArea(
        child: _content(),
      ),
      bottomNavigationBar: _bottomNavigation(),
    );
  }

  Widget _content() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [
            deepGreen,
            deepGreen2,
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: RefreshIndicator(
        color: buttonGreen,
        onRefresh: _loadData,
        child: SingleChildScrollView(
          physics:
              const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(
            20,
            16,
            20,
            28,
          ),
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              _topBar(),

              const SizedBox(height: 28),

              _heading(),

              const SizedBox(height: 22),

              _searchBar(),

              const SizedBox(height: 14),

              _scanButton(),

              const SizedBox(height: 20),

              _quickActions(),

              if (_recentSearches.isNotEmpty) ...[
                const SizedBox(height: 28),
                _recentSection(),
              ],

              if (_loading) ...[
                const SizedBox(height: 28),
                const Center(
                  child: CircularProgressIndicator(
                    color: lightGreen,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  // =========================================================
  // TOP BAR
  // =========================================================

  Widget _topBar() {
    return Row(
      children: [
        Container(
          width: 38,
          height: 38,
          padding: const EdgeInsets.all(5),
          decoration: BoxDecoration(
            color: white.withValues(alpha: 0.08),
            borderRadius:
                BorderRadius.circular(11),
          ),
          child: SvgPicture.asset(
            'assets/images/dealix_logo_transparent.svg',
            fit: BoxFit.contain,
          ),
        ),

        const SizedBox(width: 8),

        const Expanded(
          child: Text(
            'Dealix AI',
            style: TextStyle(
              color: white,
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),

        IconButton(
          onPressed: () {
            _message('No new notifications.');
          },
          padding: EdgeInsets.zero,
          icon: const Icon(
            Icons.notifications_rounded,
            color: white,
            size: 24,
          ),
        ),
      ],
    );
  }

  // =========================================================
  // HEADING
  // =========================================================

  Widget _heading() {
    return const Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        Text(
          'Smart Shopping',
          style: TextStyle(
            color: white,
            fontSize: 28,
            fontWeight: FontWeight.w800,
            height: 1.05,
          ),
        ),
        Text(
          'Starts Here',
          style: TextStyle(
            color: white,
            fontSize: 28,
            fontWeight: FontWeight.w800,
            height: 1.05,
          ),
        ),
        SizedBox(height: 9),
        Text(
          'Compare prices • Track history • Find\n'
          'better deals',
          style: TextStyle(
            color: Colors.white70,
            fontSize: 12.5,
            height: 1.4,
          ),
        ),
      ],
    );
  }

  // =========================================================
  // SEARCH BAR
  // =========================================================

  Widget _searchBar() {
    return Container(
      height: 54,
      decoration: BoxDecoration(
        color: white,
        borderRadius:
            BorderRadius.circular(18),
      ),
      child: TextField(
        controller: _searchController,
        textInputAction:
            TextInputAction.search,
        onSubmitted: (_) => _search(),
        style: const TextStyle(
          color: darkText,
          fontSize: 14,
        ),
        decoration: InputDecoration(
          hintText:
              'Search for a product, brand...',
          hintStyle: const TextStyle(
            color: greyText,
            fontSize: 13,
          ),
          prefixIcon: const Icon(
            Icons.search_rounded,
            color: greyText,
            size: 21,
          ),
          suffixIcon: IconButton(
            onPressed: _startVoiceSearch,
            icon: Icon(
              _isListening
                  ? Icons.mic_rounded
                  : Icons.mic_none_rounded,
              color: _isListening
                  ? Colors.red
                  : buttonGreen,
              size: 21,
            ),
          ),
          border: InputBorder.none,
          contentPadding:
              const EdgeInsets.symmetric(
            horizontal: 14,
            vertical: 16,
          ),
        ),
      ),
    );
  }

  // =========================================================
  // SCAN PRODUCT
  // =========================================================

  Widget _scanButton() {
    return GestureDetector(
      onTap: _openBarcodeScanner,
      child: Container(
        width: double.infinity,
        height: 52,
        decoration: BoxDecoration(
          color: buttonGreen,
          borderRadius:
              BorderRadius.circular(17),
        ),
        child: const Row(
          mainAxisAlignment:
              MainAxisAlignment.center,
          children: [
            Icon(
              Icons.qr_code_scanner_rounded,
              color: white,
              size: 23,
            ),
            SizedBox(width: 10),
            Text(
              'Scan Product',
              style: TextStyle(
                color: white,
                fontSize: 15,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // =========================================================
  // QUICK ACTIONS
  // =========================================================

  Widget _quickActions() {
    return Row(
      children: [
        Expanded(
          child: _quickAction(
            icon: Icons.qr_code_2_rounded,
            title: 'Barcode',
            onTap: _openBarcodeScanner,
          ),
        ),

        const SizedBox(width: 12),

        Expanded(
          child: _quickAction(
            icon: Icons.mic_none_rounded,
            title: 'Voice',
            onTap: _startVoiceSearch,
          ),
        ),

        const SizedBox(width: 12),

        Expanded(
          child: _quickAction(
            icon: Icons.link_rounded,
            title: 'Paste Link',
            onTap: _pasteLink,
          ),
        ),
      ],
    );
  }

  Widget _quickAction({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            height: 62,
            width: double.infinity,
            decoration: BoxDecoration(
              color: white,
              borderRadius:
                  BorderRadius.circular(17),
            ),
            child: Center(
              child: Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: paleGreen,
                  borderRadius:
                      BorderRadius.circular(11),
                ),
                child: Icon(
                  icon,
                  color: buttonGreen,
                  size: 21,
                ),
              ),
            ),
          ),

          const SizedBox(height: 7),

          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: white,
              fontSize: 11.5,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  // =========================================================
  // BOTTOM NAVIGATION
  // =========================================================

  Widget _bottomNavigation() {
    return Container(
      decoration: const BoxDecoration(
        color: white,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(24),
        ),
      ),
      padding: const EdgeInsets.fromLTRB(
        8,
        8,
        8,
        8,
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            _navItem(
              icon: Icons.home_rounded,
              label: 'Home',
              index: 0,
            ),

            _navItem(
              icon: Icons.notifications_none_rounded,
              label: 'Alerts',
              index: 1,
            ),

            Expanded(
              child: GestureDetector(
                onTap: _openBarcodeScanner,
                child: Column(
                  mainAxisSize:
                      MainAxisSize.min,
                  children: [
                    Container(
                      width: 50,
                      height: 50,
                      decoration:
                          const BoxDecoration(
                        color: buttonGreen,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.qr_code_scanner_rounded,
                        color: white,
                        size: 24,
                      ),
                    ),
                    const SizedBox(height: 3),
                    const Text(
                      'Scan',
                      style: TextStyle(
                        color: buttonGreen,
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            _navItem(
              icon: Icons.favorite_border_rounded,
              label: 'Saved',
              index: 2,
            ),

            _navItem(
              icon: Icons.person_outline_rounded,
              label: 'Profile',
              index: 3,
            ),
          ],
        ),
      ),
    );
  }

  Widget _navItem({
    required IconData icon,
    required String label,
    required int index,
  }) {
    final selected =
        _selectedIndex == index;

    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedIndex = index;
          });

          if (index != 0) {
            _message(
              '$label section coming soon.',
            );
          }
        },
        child: Column(
          mainAxisSize:
              MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: selected
                  ? buttonGreen
                  : greyText,
              size: 23,
            ),
            const SizedBox(height: 3),
            Text(
              label,
              style: TextStyle(
                color: selected
                    ? buttonGreen
                    : greyText,
                fontSize: 9.5,
                fontWeight: selected
                    ? FontWeight.w700
                    : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// =============================================================
// BARCODE SCANNER SCREEN
// =============================================================

class _BarcodeScannerScreen
    extends StatefulWidget {
  const _BarcodeScannerScreen();

  @override
  State<_BarcodeScannerScreen>
      createState() =>
          _BarcodeScannerScreenState();
}

class _BarcodeScannerScreenState
    extends State<_BarcodeScannerScreen> {
  bool _hasScanned = false;

  void _handleBarcode(
    BarcodeCapture capture,
  ) {
    if (_hasScanned) return;

    for (final barcode
        in capture.barcodes) {
      final value = barcode.rawValue;

      if (value != null &&
          value.trim().isNotEmpty) {
        _hasScanned = true;

        Navigator.pop(
          context,
          value.trim(),
        );

        return;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: const Text(
          'Scan Product',
        ),
      ),
      body: Stack(
        children: [
          MobileScanner(
            onDetect: _handleBarcode,
          ),

          Center(
            child: Container(
              width: 280,
              height: 180,
              decoration: BoxDecoration(
                border: Border.all(
                  color: Colors.green,
                  width: 3,
                ),
                borderRadius:
                    BorderRadius.circular(20),
              ),
            ),
          ),

          Positioned(
            left: 30,
            right: 30,
            bottom: 40,
            child: Container(
              padding:
                  const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color:
                    Colors.black.withValues(
                  alpha: 0.65,
                ),
                borderRadius:
                    BorderRadius.circular(16),
              ),
              child: const Text(
                'Place the barcode inside the box',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight:
                      FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}