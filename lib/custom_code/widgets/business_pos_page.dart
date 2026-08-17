import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '/backend/supabase/supabase.dart';
import 'package:pocket_mates_app/custom_code/widgets/subscription_page.dart';

class BusinessPOSPage extends StatefulWidget {
  final double? width;
  final double? height;

  const BusinessPOSPage({
    super.key,
    this.width,
    this.height,
  });

  @override
  State<BusinessPOSPage> createState() => _BusinessPOSPageState();
}

class _BusinessPOSPageState extends State<BusinessPOSPage>
    with SingleTickerProviderStateMixin {
  final _supabase = SupaFlow.client;
  String _currentPlan = 'free';
  
  // Navigation Tabs: 0: Terminal, 1: Catalog, 2: History, 3: Analytics, 4: CRM
  int _selectedTab = 0;
  
  bool _isLoading = true;
  List<Map<String, dynamic>> _catalogItems = [];
  final Map<String, int> _cart = {}; // itemId -> quantity
  
  // Custom temporary items created directly in POS
  List<Map<String, dynamic>> _localItems = [];
  
  // Customer List
  List<Map<String, dynamic>> _customers = [
    {'id': 'c1', 'name': 'Walk-in Customer', 'phone': 'N/A', 'email': 'N/A', 'orders': 0, 'spend': 0.0},
    {'id': 'c2', 'name': 'Adhil Rahman', 'phone': '+91 9876543210', 'email': 'adhil@gmail.com', 'orders': 5, 'spend': 4500.0},
    {'id': 'c3', 'name': 'Fathima Nazrin', 'phone': '+91 8765432109', 'email': 'fathima@gmail.com', 'orders': 3, 'spend': 2100.0},
    {'id': 'c4', 'name': 'Sidharth K', 'phone': '+91 7654321098', 'email': 'sidharth@gmail.com', 'orders': 12, 'spend': 14800.0},
  ];
  String _selectedCustomerId = 'c1';
  
  // Invoice / Transaction History
  List<Map<String, dynamic>> _transactions = [];
  
  // Sales Settings
  final double _taxRate = 12.0; // 12% standard GST/Tax
  double _discountAmount = 0.0;
  String _paymentMethod = 'Cash'; // Cash, Card, Online Transfer, UPI QR
  
  // Add item form controllers
  final _itemNameController = TextEditingController();
  final _itemPriceController = TextEditingController();
  final _itemCategoryController = TextEditingController();
  String _itemType = 'product'; // product, service

  // CRM form controllers
  final _custNameController = TextEditingController();
  final _custPhoneController = TextEditingController();
  final _custEmailController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadCurrentPlan();
    _loadCatalogAndHistory();
  }

  Future<void> _loadCurrentPlan() async {
    final prefs = await SharedPreferences.getInstance();
    if (mounted) {
      setState(() {
        _currentPlan = prefs.getString('handskill_plan') ?? 'free';
      });
    }
  }

  @override
  void dispose() {
    _itemNameController.dispose();
    _itemPriceController.dispose();
    _itemCategoryController.dispose();
    _custNameController.dispose();
    _custPhoneController.dispose();
    _custEmailController.dispose();
    super.dispose();
  }

  Future<void> _loadCatalogAndHistory() async {
    setState(() => _isLoading = true);
    final myId = _supabase.auth.currentUser?.id;
    if (myId == null) {
      setState(() => _isLoading = false);
      return;
    }

    try {
      // 1. Fetch user products & services from supabase gallery table
      final galleryRes = await _supabase
          .from('gallery')
          .select()
          .eq('user_id', myId);
      
      final List<Map<String, dynamic>> fetchedItems = [];
      for (var row in (galleryRes as List)) {
        fetchedItems.add({
          'id': row['id']?.toString() ?? row['gallery_id']?.toString() ?? UniqueKey().toString(),
          'title': row['title'] ?? row['gallery_title'] ?? 'Unnamed Item',
          'price': double.tryParse((row['price'] ?? row['gallery_price'] ?? '0').toString()) ?? 0.0,
          'category': row['category'] ?? row['gallery_category'] ?? 'General',
          'is_service': row['is_service'] == true,
          'image_url': row['image_url'] ?? row['gallery_image_url'] ?? '',
        });
      }

      // 2. Fetch locally created temporary items from Supabase pos_items
      final posItemsRes = await _supabase
          .from('pos_items')
          .select()
          .eq('user_id', myId);
      _localItems = List<Map<String, dynamic>>.from(posItemsRes);

      // 3. Fetch POS transaction history from Supabase
      final transRes = await _supabase
          .from('pos_transactions')
          .select()
          .eq('user_id', myId)
          .order('created_at', ascending: false);
      _transactions = List<Map<String, dynamic>>.from(transRes);

      // 4. Fetch Custom Customers from Supabase
      final custRes = await _supabase
          .from('pos_customers')
          .select()
          .eq('user_id', myId);
      
      if ((custRes as List).isNotEmpty) {
        _customers = List<Map<String, dynamic>>.from(custRes);
      }

      setState(() {
        _catalogItems = [...fetchedItems, ..._localItems];
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Error loading POS data: $e');
      setState(() => _isLoading = false);
    }
  }

  Future<void> _saveLocalPOSData() async {
    // Legacy method for shared prefs. We are now using real-time inserts below.
  }

  void _addLocalItem() {
    final title = _itemNameController.text.trim();
    final price = double.tryParse(_itemPriceController.text.trim()) ?? 0.0;
    final cat = _itemCategoryController.text.trim().isEmpty ? 'General' : _itemCategoryController.text.trim();

    if (title.isEmpty || price <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter valid name and price')),
      );
      return;
    }

    final newId = 'local_${DateTime.now().millisecondsSinceEpoch}';
    final newItem = {
      'id': newId,
      'title': title,
      'price': price,
      'category': cat,
      'is_service': _itemType == 'service',
      'image_url': '',
    };

    setState(() {
      _localItems.add(newItem);
      _catalogItems.add(newItem);
      _itemNameController.clear();
      _itemPriceController.clear();
      _itemCategoryController.clear();
    });

    final myId = _supabase.auth.currentUser?.id;
    if (myId != null) {
      _supabase.from('pos_items').insert({
        'user_id': myId,
        'title': title,
        'price': price,
        'category': cat,
        'is_service': _itemType == 'service',
        'image_url': '',
      }).then((_) {
        debugPrint('Item added to Supabase');
      }).catchError((e) {
        debugPrint('Error saving pos_item: $e');
      });
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('"$title" added to POS catalog!')),
    );
  }

  void _addCustomer() {
    final name = _custNameController.text.trim();
    final phone = _custPhoneController.text.trim();
    final email = _custEmailController.text.trim();

    if (name.isEmpty) return;

    final newCustId = 'cust_${DateTime.now().millisecondsSinceEpoch}';
    final newCust = {
      'id': newCustId,
      'name': name,
      'phone': phone.isEmpty ? 'N/A' : phone,
      'email': email.isEmpty ? 'N/A' : email,
      'orders': 0,
      'spend': 0.0
    };

    setState(() {
      _customers.add(newCust);
      _custNameController.clear();
      _custPhoneController.clear();
      _custEmailController.clear();
    });
    
    final myId = _supabase.auth.currentUser?.id;
    if (myId != null) {
      _supabase.from('pos_customers').insert({
        'user_id': myId,
        'name': name,
        'phone': phone.isEmpty ? 'N/A' : phone,
        'email': email.isEmpty ? 'N/A' : email,
      }).then((_) {
        debugPrint('Customer added to Supabase');
      }).catchError((e) {
        debugPrint('Error saving pos_customer: $e');
      });
    }
  }

  void _addToCart(String itemId) {
    setState(() {
      _cart[itemId] = (_cart[itemId] ?? 0) + 1;
    });
  }

  void _removeFromCart(String itemId) {
    setState(() {
      if (_cart.containsKey(itemId)) {
        if (_cart[itemId] == 1) {
          _cart.remove(itemId);
        } else {
          _cart[itemId] = _cart[itemId]! - 1;
        }
      }
    });
  }

  void _clearCart() {
    setState(() {
      _cart.clear();
      _discountAmount = 0.0;
      _selectedCustomerId = 'c1';
    });
  }

  double get _cartSubtotal {
    double total = 0.0;
    _cart.forEach((itemId, qty) {
      final item = _catalogItems.firstWhere((element) => element['id'] == itemId,
          orElse: () => {'price': 0.0});
      total += (item['price'] as double) * qty;
    });
    return total;
  }

  double get _cartTax {
    return (_cartSubtotal - _discountAmount) * (_taxRate / 100.0);
  }

  double get _cartTotal {
    final net = _cartSubtotal - _discountAmount;
    return (net + _cartTax).clamp(0.0, double.infinity);
  }

  void _checkout() {
    if (_cart.isEmpty) return;

    final customer = _customers.firstWhere((c) => c['id'] == _selectedCustomerId,
        orElse: () => {'name': 'Walk-in Customer'});
    
    // Create new transaction
    final newTx = {
      'invoice_id': 'INV-${DateTime.now().millisecondsSinceEpoch.toString().substring(5)}',
      'date': DateTime.now().toIso8601String(),
      'customer_id': _selectedCustomerId,
      'customer_name': customer['name'],
      'subtotal': _cartSubtotal,
      'discount': _discountAmount,
      'tax': _cartTax,
      'total': _cartTotal,
      'payment_method': _paymentMethod,
      'items': _cart.entries.map((entry) {
        final catalogItem = _catalogItems.firstWhere((element) => element['id'] == entry.key);
        return {
          'id': entry.key,
          'title': catalogItem['title'],
          'price': catalogItem['price'],
          'qty': entry.value,
        };
      }).toList(),
    };

    // Update customer spend/orders
    setState(() {
      final cIndex = _customers.indexWhere((c) => c['id'] == _selectedCustomerId);
      if (cIndex != -1) {
        _customers[cIndex]['orders'] = (_customers[cIndex]['orders'] as int) + 1;
        _customers[cIndex]['spend'] = (_customers[cIndex]['spend'] as double) + _cartTotal;
      }
      _transactions.insert(0, newTx);
      _clearCart();
    });

    final myId = _supabase.auth.currentUser?.id;
    if (myId != null) {
      _supabase.from('pos_transactions').insert({
        'user_id': myId,
        'invoice_id': newTx['invoice_id'],
        'customer_name': newTx['customer_name'],
        'items': newTx['items'],
        'subtotal': newTx['subtotal'],
        'tax': newTx['tax'],
        'discount': newTx['discount'],
        'total': newTx['total'],
        'payment_method': newTx['payment_method'],
      }).catchError((e) => debugPrint('Error saving transaction: $e'));

      // In real scenario we'd query and update specific customer row, 
      // but for now since ID is local, we just rely on customer name match or skip update 
      // if it's the "Walk-in" placeholder.
    }

    // Show Beautiful Checkout Success Overlay
    showDialog(
      context: context,
      builder: (context) => _buildSuccessDialog(newTx),
    );
  }

  Widget _buildSuccessDialog(Map<String, dynamic> tx) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: const Color(0xFF1E1E24),
          borderRadius: BorderRadius.circular(28),
          border: Border.all(color: const Color(0xFFFFD700).withValues(alpha: 0.3), width: 1.5),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.5),
              blurRadius: 30,
              offset: const Offset(0, 10),
            )
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.green.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.check_circle_rounded, color: Colors.greenAccent, size: 56),
            ),
            const SizedBox(height: 20),
            Text(
              'Checkout Successful',
              style: GoogleFonts.outfit(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Invoice #${tx['invoice_id']}',
              style: GoogleFonts.outfit(color: Colors.white54, fontSize: 14),
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  _buildReceiptRow('Customer', tx['customer_name']),
                  _buildReceiptRow('Total Items', '${(tx['items'] as List).length}'),
                  _buildReceiptRow('Payment Method', tx['payment_method']),
                  const Divider(color: Colors.white12, height: 20),
                  _buildReceiptRow('Total Bill', '₹${tx['total'].toStringAsFixed(2)}', isBold: true, color: const Color(0xFFFFD700)),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white10,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Close'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFFD700),
                      foregroundColor: Colors.black,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                      // Navigate to Transaction tab & view this receipt
                      setState(() {
                        _selectedTab = 2;
                      });
                    },
                    child: const Text('View Bill', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReceiptRow(String title, String val, {bool isBold = false, Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: GoogleFonts.outfit(color: Colors.white70, fontSize: 14)),
          Text(val, style: GoogleFonts.outfit(color: color ?? Colors.white, fontSize: 14, fontWeight: isBold ? FontWeight.bold : FontWeight.normal)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 800;

    return Scaffold(
      backgroundColor: const Color(0xFF131316),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color(0xFF1E1E24),
        title: Row(
          children: [
            const Icon(Icons.receipt_long_rounded, color: Color(0xFFFFD700), size: 24),
            const SizedBox(width: 10),
            Text(
              'Handskill POS & ERP',
              style: GoogleFonts.outfit(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white70),
            onPressed: _loadCatalogAndHistory,
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFFFD700)),
              ),
            )
          : Stack(
              children: [
                Row(
                  children: [
                    // Navigation Sidebar (only on desktop/tablet)
                    if (!isMobile) _buildSidebarNav(),
                    
                    // Main Workspace
                    Expanded(
                      child: Container(
                        color: const Color(0xFF131316),
                        child: _buildWorkspace(isMobile),
                      ),
                    ),
                  ],
                ),
                if (_currentPlan == 'free')
                  Positioned.fill(
                    child: Container(
                      color: Colors.black.withValues(alpha: 0.9),
                      child: Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.lock_rounded, color: Color(0xFFFFD700), size: 64),
                            const SizedBox(height: 24),
                            Text(
                              'Premium Tools',
                              style: GoogleFonts.outfit(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'Upgrade to unlock the Advanced POS, Inventory,\nAnalytics, CRM, and PDF Invoicing.',
                              style: GoogleFonts.outfit(color: Colors.white70, fontSize: 16),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 32),
                            ElevatedButton.icon(
                              onPressed: () {
                                Navigator.push(context, MaterialPageRoute(builder: (context) => const SubscriptionPage())).then((_) {
                                  _loadCurrentPlan();
                                });
                              },
                              icon: const Icon(Icons.workspace_premium),
                              label: Text('Upgrade Plan', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 16)),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFFFD700),
                                foregroundColor: Colors.black,
                                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
              ],
            ),
      bottomNavigationBar: isMobile ? _buildBottomNav() : null,
    );
  }

  Widget _buildSidebarNav() {
    return Container(
      width: 200,
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E24),
        border: Border(right: BorderSide(color: Colors.white.withValues(alpha: 0.05), width: 1)),
      ),
      child: Column(
        children: [
          const SizedBox(height: 24),
          _buildSidebarNavItem(0, 'Terminal', Icons.point_of_sale_rounded),
          _buildSidebarNavItem(1, 'Catalog', Icons.category_rounded),
          _buildSidebarNavItem(2, 'History', Icons.history_rounded),
          _buildSidebarNavItem(3, 'Analytics', Icons.bar_chart_rounded),
          _buildSidebarNavItem(4, 'Customers', Icons.people_alt_rounded),
        ],
      ),
    );
  }

  Widget _buildSidebarNavItem(int index, String label, IconData icon) {
    final isSelected = _selectedTab == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedTab = index),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFFFD700).withValues(alpha: 0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(icon, color: isSelected ? const Color(0xFFFFD700) : Colors.white38, size: 20),
            const SizedBox(width: 12),
            Text(
              label,
              style: GoogleFonts.outfit(
                color: isSelected ? Colors.white : Colors.white54,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                fontSize: 15,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomNav() {
    return BottomNavigationBar(
      currentIndex: _selectedTab,
      onTap: (index) => setState(() => _selectedTab = index),
      backgroundColor: const Color(0xFF1E1E24),
      selectedItemColor: const Color(0xFFFFD700),
      unselectedItemColor: Colors.white24,
      type: BottomNavigationBarType.fixed,
      showSelectedLabels: true,
      showUnselectedLabels: false,
      elevation: 10,
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.point_of_sale_rounded), label: 'POS'),
        BottomNavigationBarItem(icon: Icon(Icons.category_rounded), label: 'Catalog'),
        BottomNavigationBarItem(icon: Icon(Icons.history_rounded), label: 'History'),
        BottomNavigationBarItem(icon: Icon(Icons.bar_chart_rounded), label: 'Stats'),
        BottomNavigationBarItem(icon: Icon(Icons.people_alt_rounded), label: 'CRM'),
      ],
    );
  }

  Widget _buildWorkspace(bool isMobile) {
    switch (_selectedTab) {
      case 0:
        return _buildPOSTerminal(isMobile);
      case 1:
        return _buildCatalogTab();
      case 2:
        return _buildHistoryTab();
      case 3:
        return _buildAnalyticsTab();
      case 4:
        return _buildCRMTab();
      default:
        return const SizedBox();
    }
  }

  // --- TERMINAL VIEW ---
  Widget _buildPOSTerminal(bool isMobile) {
    if (isMobile) {
      return Column(
        children: [
          Expanded(child: _buildTerminalCatalogList()),
          _buildCartSummaryButtonMobile(),
        ],
      );
    }
    
    return Row(
      children: [
        // Left Column: Catalog list for selection
        Expanded(
          flex: 3,
          child: _buildTerminalCatalogList(),
        ),
        
        // Right Column: Checkout cart panel
        Container(
          width: 380,
          decoration: BoxDecoration(
            color: const Color(0xFF1A1A20),
            border: Border(left: BorderSide(color: Colors.white.withValues(alpha: 0.05), width: 1)),
          ),
          child: _buildCartPanel(),
        )
      ],
    );
  }

  Widget _buildTerminalCatalogList() {
    if (_catalogItems.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.storefront, size: 64, color: Colors.white24),
            const SizedBox(height: 16),
            Text(
              'Catalog is empty',
              style: GoogleFonts.outfit(color: Colors.white38, fontSize: 18),
            ),
            const SizedBox(height: 8),
            Text(
              'Add items in the "Catalog" tab',
              style: GoogleFonts.outfit(color: Colors.white24, fontSize: 14),
            ),
          ],
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Checkout Terminal',
            style: GoogleFonts.outfit(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: GridView.builder(
              physics: const BouncingScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: 180,
                childAspectRatio: 0.9,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
              itemCount: _catalogItems.length,
              itemBuilder: (context, index) {
                final item = _catalogItems[index];
                final itemId = item['id'].toString();
                final isService = item['is_service'] == true;
                final qty = _cart[itemId] ?? 0;
                
                return GestureDetector(
                  onTap: () => _addToCart(itemId),
                  child: Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E1E24),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: qty > 0 ? const Color(0xFFFFD700) : Colors.white.withValues(alpha: 0.05),
                        width: qty > 0 ? 1.5 : 1.0,
                      ),
                    ),
                    child: Stack(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              // Icon based on type
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(6),
                                    decoration: BoxDecoration(
                                      color: isService ? Colors.blue.withValues(alpha: 0.1) : Colors.green.withValues(alpha: 0.1),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Icon(
                                      isService ? Icons.design_services_rounded : Icons.inventory_2_rounded,
                                      color: isService ? Colors.blueAccent : Colors.greenAccent,
                                      size: 14,
                                    ),
                                  ),
                                  if (qty > 0)
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFFFD700),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: Text(
                                        '$qty',
                                        style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 10),
                                      ),
                                    ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              // Title
                              Expanded(
                                child: Text(
                                  item['title'],
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: GoogleFonts.outfit(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600),
                                ),
                              ),
                              // Price
                              Text(
                                '₹${item['price']}',
                                style: GoogleFonts.outfit(color: const Color(0xFFFFD700), fontSize: 14, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ),
                        if (qty > 0)
                          Positioned(
                            bottom: 8,
                            right: 8,
                            child: GestureDetector(
                              onTap: () => _removeFromCart(itemId),
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: const BoxDecoration(
                                  color: Colors.redAccent,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.remove, size: 12, color: Colors.white),
                              ),
                            ),
                          )
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
  }

  Widget _buildCartSummaryButtonMobile() {
    if (_cart.isEmpty) return const SizedBox();
    
    return Container(
      padding: const EdgeInsets.all(16),
      color: const Color(0xFF1E1E24),
      child: SafeArea(
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFFFD700),
            foregroundColor: Colors.black,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            padding: const EdgeInsets.symmetric(vertical: 16),
          ),
          onPressed: () {
            showModalBottomSheet(
              context: context,
              backgroundColor: const Color(0xFF1A1A20),
              shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
              builder: (context) => Container(
                padding: const EdgeInsets.only(top: 8),
                height: MediaQuery.of(context).size.height * 0.7,
                child: _buildCartPanel(),
              ),
            );
          },
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.shopping_cart_checkout, fontWeight: FontWeight.bold),
              const SizedBox(width: 10),
              Text(
                'Checkout Cart (Total: ₹${_cartTotal.toStringAsFixed(2)})',
                style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 15),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCartPanel() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Cart items', style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
              IconButton(icon: const Icon(Icons.delete_sweep, color: Colors.redAccent), onPressed: _clearCart),
            ],
          ),
          Divider(color: Colors.white.withValues(alpha: 0.05), height: 16),
          Expanded(
            child: _cart.isEmpty
                ? Center(
                    child: Text('Cart is empty', style: GoogleFonts.outfit(color: Colors.white24, fontSize: 15)),
                  )
                : ListView.builder(
                    itemCount: _cart.length,
                    itemBuilder: (context, index) {
                      final entry = _cart.entries.elementAt(index);
                      final item = _catalogItems.firstWhere((element) => element['id'] == entry.key);
                      
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(item['title'], style: const TextStyle(color: Colors.white, fontSize: 14)),
                                  Text('₹${item['price']} × ${entry.value}', style: const TextStyle(color: Colors.white38, fontSize: 12)),
                                ],
                              ),
                            ),
                            Text('₹${(item['price'] as double) * entry.value}', style: const TextStyle(color: Color(0xFFFFD700), fontSize: 14, fontWeight: FontWeight.bold)),
                            const SizedBox(width: 8),
                            GestureDetector(
                              onTap: () => _removeFromCart(entry.key),
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: BoxDecoration(color: Colors.redAccent.withValues(alpha: 0.1), shape: BoxShape.circle),
                                child: const Icon(Icons.remove, size: 14, color: Colors.redAccent),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
          Divider(color: Colors.white.withValues(alpha: 0.05), height: 24),
          
          // Customer Picker
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Customer:', style: GoogleFonts.outfit(color: Colors.white70, fontSize: 14)),
              DropdownButton<String>(
                value: _selectedCustomerId,
                dropdownColor: const Color(0xFF1E1E24),
                underline: const SizedBox(),
                items: _customers.map((c) {
                  return DropdownMenuItem(
                    value: c['id'].toString(),
                    child: Text(c['name'], style: const TextStyle(color: Colors.white, fontSize: 13)),
                  );
                }).toList(),
                onChanged: (val) {
                  if (val != null) setState(() => _selectedCustomerId = val);
                },
              )
            ],
          ),
          const SizedBox(height: 8),
          
          // Discount & Payment options
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Discount (₹):', style: GoogleFonts.outfit(color: Colors.white70, fontSize: 14)),
              SizedBox(
                width: 80,
                child: TextField(
                  keyboardType: TextInputType.number,
                  style: const TextStyle(color: Colors.white, fontSize: 13),
                  decoration: const InputDecoration(
                    hintText: '0.0',
                    hintStyle: TextStyle(color: Colors.white24),
                    contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    border: OutlineInputBorder(borderSide: BorderSide(color: Colors.white12)),
                  ),
                  onChanged: (val) {
                    setState(() {
                      _discountAmount = double.tryParse(val) ?? 0.0;
                    });
                  },
                ),
              )
            ],
          ),
          const SizedBox(height: 12),
          
          // Payment Method
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Method:', style: GoogleFonts.outfit(color: Colors.white70, fontSize: 14)),
              DropdownButton<String>(
                value: _paymentMethod,
                dropdownColor: const Color(0xFF1E1E24),
                underline: const SizedBox(),
                items: ['Cash', 'Card', 'UPI QR Code', 'Online Transfer'].map((m) {
                  return DropdownMenuItem(
                    value: m,
                    child: Text(m, style: const TextStyle(color: Colors.white, fontSize: 13)),
                  );
                }).toList(),
                onChanged: (val) {
                  if (val != null) setState(() => _paymentMethod = val);
                },
              )
            ],
          ),
          
          Divider(color: Colors.white.withValues(alpha: 0.05), height: 24),
          
          // Billing values
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Subtotal', style: GoogleFonts.outfit(color: Colors.white54, fontSize: 14)),
              Text('₹${_cartSubtotal.toStringAsFixed(2)}', style: const TextStyle(color: Colors.white70, fontSize: 14)),
            ],
          ),
          if (_discountAmount > 0)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Discount', style: GoogleFonts.outfit(color: Colors.redAccent, fontSize: 14)),
                  Text('-₹${_discountAmount.toStringAsFixed(2)}', style: const TextStyle(color: Colors.redAccent, fontSize: 14)),
                ],
              ),
            ),
          Padding(
            padding: const EdgeInsets.only(top: 4, bottom: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('GST/Tax ($_taxRate%)', style: GoogleFonts.outfit(color: Colors.white54, fontSize: 14)),
                Text('₹${_cartTax.toStringAsFixed(2)}', style: const TextStyle(color: Colors.white70, fontSize: 14)),
              ],
            ),
          ),
          const Divider(color: Colors.white12, height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Total Bill', style: GoogleFonts.outfit(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
              Text('₹${_cartTotal.toStringAsFixed(2)}', style: GoogleFonts.outfit(color: const Color(0xFFFFD700), fontSize: 18, fontWeight: FontWeight.bold)),
            ],
          ),
          
          const SizedBox(height: 24),
          
          // Checkout CTA button
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFFD700),
                foregroundColor: Colors.black,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              onPressed: _cart.isEmpty ? null : _checkout,
              child: Text(
                'Complete Payment',
                style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- CATALOG TAB ---
  Widget _buildCatalogTab() {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('POS Inventory Catalog', style: GoogleFonts.outfit(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)),
            const SizedBox(height: 20),
            
            // Add Inventory Form Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFF1E1E24),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Add Direct Item to POS', style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white70)),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _itemNameController,
                          style: const TextStyle(color: Colors.white),
                          decoration: const InputDecoration(
                            labelText: 'Item Name',
                            labelStyle: TextStyle(color: Colors.white38),
                            enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white12)),
                            focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Color(0xFFFFD700))),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      SizedBox(
                        width: 120,
                        child: TextField(
                          controller: _itemPriceController,
                          keyboardType: TextInputType.number,
                          style: const TextStyle(color: Colors.white),
                          decoration: const InputDecoration(
                            labelText: 'Price (₹)',
                            labelStyle: TextStyle(color: Colors.white38),
                            enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white12)),
                            focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Color(0xFFFFD700))),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _itemCategoryController,
                          style: const TextStyle(color: Colors.white),
                          decoration: const InputDecoration(
                            labelText: 'Category',
                            labelStyle: TextStyle(color: Colors.white38),
                            enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white12)),
                            focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Color(0xFFFFD700))),
                          ),
                        ),
                      ),
                      const SizedBox(width: 20),
                      // Dropdown Type Selector
                      DropdownButton<String>(
                        value: _itemType,
                        dropdownColor: const Color(0xFF1E1E24),
                        items: const [
                          DropdownMenuItem(value: 'product', child: Text('Product', style: TextStyle(color: Colors.white))),
                          DropdownMenuItem(value: 'service', child: Text('Service', style: TextStyle(color: Colors.white))),
                        ],
                        onChanged: (val) {
                          if (val != null) setState(() => _itemType = val);
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFFD700),
                      foregroundColor: Colors.black,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: _addLocalItem,
                    icon: const Icon(Icons.add, size: 18),
                    label: const Text('Add Product/Service', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            Text('Current POS Catalog Items', style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white70)),
            const SizedBox(height: 12),
            
            // Grid of products
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 2.2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
              itemCount: _catalogItems.length,
              itemBuilder: (context, index) {
                final item = _catalogItems[index];
                final isService = item['is_service'] == true;
                
                return Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E1E24),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: isService ? Colors.blue.withValues(alpha: 0.1) : Colors.green.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          isService ? Icons.design_services_rounded : Icons.inventory_2_rounded,
                          color: isService ? Colors.blueAccent : Colors.greenAccent,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(item['title'], style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 13), maxLines: 1, overflow: TextOverflow.ellipsis),
                            const SizedBox(height: 2),
                            Text('₹${item['price']}', style: const TextStyle(color: Color(0xFFFFD700), fontSize: 12, fontWeight: FontWeight.bold)),
                            Text(item['category'], style: const TextStyle(color: Colors.white24, fontSize: 10)),
                          ],
                        ),
                      ),
                      // If it's a locally created item, allow deleting it
                      if (item['id'].toString().startsWith('local_'))
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.redAccent, size: 16),
                          onPressed: () {
                            setState(() {
                              _localItems.removeWhere((x) => x['id'] == item['id']);
                              _catalogItems.removeWhere((x) => x['id'] == item['id']);
                            });
                            _saveLocalPOSData();
                          },
                        ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  // --- HISTORY TAB ---
  Widget _buildHistoryTab() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Transaction Ledger', style: GoogleFonts.outfit(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)),
          const SizedBox(height: 20),
          Expanded(
            child: _transactions.isEmpty
                ? Center(child: Text('No invoice history found', style: GoogleFonts.outfit(color: Colors.white24, fontSize: 15)))
                : ListView.builder(
                    itemCount: _transactions.length,
                    physics: const BouncingScrollPhysics(),
                    itemBuilder: (context, index) {
                      final tx = _transactions[index];
                      final date = DateTime.tryParse(tx['date'] ?? '') ?? DateTime.now();
                      final formattedDate = '${date.day}/${date.month}/${date.year} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
                      
                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1E1E24),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
                        ),
                        child: ExpansionTile(
                          iconColor: const Color(0xFFFFD700),
                          collapsedIconColor: Colors.white38,
                          title: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(tx['invoice_id'] ?? 'INV', style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
                                  Text(formattedDate, style: const TextStyle(color: Colors.white38, fontSize: 12)),
                                ],
                              ),
                              Text('₹${tx['total'].toStringAsFixed(2)}', style: GoogleFonts.outfit(color: const Color(0xFFFFD700), fontWeight: FontWeight.bold, fontSize: 16)),
                            ],
                          ),
                          subtitle: Text('Customer: ${tx['customer_name']}', style: const TextStyle(color: Colors.white54, fontSize: 13)),
                          children: [
                            const Divider(color: Colors.white12, height: 16),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Items Detail:', style: GoogleFonts.outfit(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.bold)),
                                  const SizedBox(height: 8),
                                  // Detail rows
                                  ...(tx['items'] as List).map((i) {
                                    return Padding(
                                      padding: const EdgeInsets.symmetric(vertical: 4),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text('${i['title']} (×${i['qty']})', style: const TextStyle(color: Colors.white54, fontSize: 13)),
                                          Text('₹${(double.tryParse(i['price'].toString()) ?? 0.0) * (i['qty'] as int)}', style: const TextStyle(color: Colors.white70, fontSize: 13)),
                                        ],
                                      ),
                                    );
                                  }),
                                  Divider(color: Colors.white.withValues(alpha: 0.05), height: 16),
                                  _buildReceiptRow('Subtotal', '₹${tx['subtotal'].toStringAsFixed(2)}'),
                                  if (double.parse(tx['discount'].toString()) > 0)
                                    _buildReceiptRow('Discount', '-₹${tx['discount'].toStringAsFixed(2)}'),
                                  _buildReceiptRow('Tax/GST', '₹${tx['tax'].toStringAsFixed(2)}'),
                                  _buildReceiptRow('Method', tx['payment_method']),
                                ],
                              ),
                            )
                          ],
                        ),
                      );
                    },
                  ),
          )
        ],
      ),
    );
  }

  // --- ANALYTICS TAB ---
  Widget _buildAnalyticsTab() {
    double totalRevenue = 0.0;
    double cashRev = 0.0;
    double onlineRev = 0.0;
    
    for (var tx in _transactions) {
      final total = double.tryParse(tx['total'].toString()) ?? 0.0;
      totalRevenue += total;
      if (tx['payment_method'] == 'Cash') {
        cashRev += total;
      } else {
        onlineRev += total;
      }
    }

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Business Performance Analytics', style: GoogleFonts.outfit(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)),
            const SizedBox(height: 20),
            
            // High-fidelity numerical report badges
            Row(
              children: [
                Expanded(
                  child: _buildReportCard('Total Revenue', '₹${totalRevenue.toStringAsFixed(2)}', Icons.payments_rounded, Colors.greenAccent),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildReportCard('Invoices Count', '${_transactions.length}', Icons.description_rounded, const Color(0xFFFFD700)),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildReportCard('Cash Ledger', '₹${cashRev.toStringAsFixed(2)}', Icons.money_rounded, Colors.amber),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildReportCard('Digital Ledger', '₹${onlineRev.toStringAsFixed(2)}', Icons.qr_code_rounded, Colors.blueAccent),
                ),
              ],
            ),
            
            const SizedBox(height: 24),
            
            // Custom drawn Canvas Charts representation
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFF1E1E24),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Weekly Sales Distribution', style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white70)),
                  const SizedBox(height: 24),
                  SizedBox(
                    height: 150,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        _buildBarChartColumn('Mon', 0.2),
                        _buildBarChartColumn('Tue', 0.4),
                        _buildBarChartColumn('Wed', 0.15),
                        _buildBarChartColumn('Thu', 0.7),
                        _buildBarChartColumn('Fri', 0.6),
                        _buildBarChartColumn('Sat', 0.9),
                        _buildBarChartColumn('Sun', 0.35),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReportCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E24),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: color.withValues(alpha: 0.1), shape: BoxShape.circle),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: GoogleFonts.outfit(color: Colors.white38, fontSize: 12)),
                const SizedBox(height: 4),
                Text(value, style: GoogleFonts.outfit(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildBarChartColumn(String day, double heightFactor) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Container(
          width: 20,
          height: (heightFactor * 100).clamp(10.0, 120.0),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFFFFD700), Colors.amber],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
            borderRadius: BorderRadius.circular(6),
          ),
        ),
        const SizedBox(height: 8),
        Text(day, style: const TextStyle(color: Colors.white38, fontSize: 10)),
      ],
    );
  }

  // --- CRM CUSTOMER TAB ---
  Widget _buildCRMTab() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Customer CRM', style: GoogleFonts.outfit(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)),
          const SizedBox(height: 20),
          
          // Add Customer Form
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFF1E1E24),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Register New Customer', style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white70)),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _custNameController,
                        style: const TextStyle(color: Colors.white),
                        decoration: const InputDecoration(
                          labelText: 'Full Name',
                          labelStyle: TextStyle(color: Colors.white38),
                          enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white12)),
                          focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Color(0xFFFFD700))),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: TextField(
                        controller: _custPhoneController,
                        style: const TextStyle(color: Colors.white),
                        decoration: const InputDecoration(
                          labelText: 'Phone',
                          labelStyle: TextStyle(color: Colors.white38),
                          enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white12)),
                          focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Color(0xFFFFD700))),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _custEmailController,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    labelText: 'Email Address',
                    labelStyle: TextStyle(color: Colors.white38),
                    enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white12)),
                    focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Color(0xFFFFD700))),
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFFD700),
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: _addCustomer,
                  child: const Text('Save Customer', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 24),
          Text('Customer Ledger', style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white70)),
          const SizedBox(height: 12),
          
          Expanded(
            child: ListView.builder(
              physics: const BouncingScrollPhysics(),
              itemCount: _customers.length,
              itemBuilder: (context, index) {
                final cust = _customers[index];
                final spend = double.tryParse(cust['spend'].toString()) ?? 0.0;
                
                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E1E24),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(color: Colors.white10, borderRadius: BorderRadius.circular(12)),
                        child: const Icon(Icons.person, color: Colors.white70, size: 24),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(cust['name'], style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
                            const SizedBox(height: 2),
                            Text('Phone: ${cust['phone']} | Email: ${cust['email']}', style: const TextStyle(color: Colors.white38, fontSize: 11)),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text('₹${spend.toStringAsFixed(2)}', style: GoogleFonts.outfit(color: const Color(0xFFFFD700), fontWeight: FontWeight.bold, fontSize: 15)),
                          Text('${cust['orders']} Orders', style: const TextStyle(color: Colors.white38, fontSize: 11)),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
