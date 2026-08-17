import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pocket_mates_app/custom_code/widgets/zoyarex_admin/zoyarex_supabase.dart';
import 'package:pocket_mates_app/custom_code/widgets/zoyarex_admin/zoyarex_login_page.dart';
import 'package:pocket_mates_app/custom_code/widgets/zoyarex_admin/providers/dashboard_provider.dart';
import 'package:pocket_mates_app/custom_code/widgets/zoyarex_admin/zoyarex_outlets_page.dart';
import 'package:pocket_mates_app/custom_code/widgets/zoyarex_admin/zoyarex_products_page.dart';
import 'package:pocket_mates_app/custom_code/widgets/zoyarex_admin/zoyarex_categories_page.dart';
import 'package:pocket_mates_app/custom_code/widgets/zoyarex_admin/zoyarex_addons_page.dart';
import 'package:pocket_mates_app/custom_code/widgets/zoyarex_admin/zoyarex_menus_page.dart';
import 'package:pocket_mates_app/custom_code/widgets/zoyarex_admin/zoyarex_raw_materials_page.dart';
import 'package:pocket_mates_app/custom_code/widgets/zoyarex_admin/zoyarex_planogram_page.dart';
import 'package:pocket_mates_app/custom_code/widgets/zoyarex_admin/zoyarex_floors_page.dart';
import 'package:pocket_mates_app/custom_code/widgets/zoyarex_admin/zoyarex_tables_page.dart';
import 'package:pocket_mates_app/custom_code/widgets/zoyarex_admin/zoyarex_shops_page.dart';
import 'package:pocket_mates_app/custom_code/widgets/zoyarex_admin/zoyarex_warehouses_page.dart';
import 'package:pocket_mates_app/custom_code/widgets/zoyarex_admin/zoyarex_taxes_page.dart';
import 'package:pocket_mates_app/custom_code/widgets/zoyarex_admin/zoyarex_receipt_templates_page.dart';
import 'package:pocket_mates_app/custom_code/widgets/zoyarex_admin/zoyarex_orders_page.dart';
import 'package:pocket_mates_app/custom_code/widgets/zoyarex_admin/zoyarex_online_setup_page.dart';
import 'package:pocket_mates_app/custom_code/widgets/zoyarex_admin/zoyarex_customers_page.dart';
import 'package:pocket_mates_app/custom_code/widgets/zoyarex_admin/zoyarex_customer_groups_page.dart';
import 'package:pocket_mates_app/custom_code/widgets/zoyarex_admin/zoyarex_customer_types_page.dart';
import 'package:pocket_mates_app/custom_code/widgets/zoyarex_admin/zoyarex_roles_page.dart';
import 'package:pocket_mates_app/custom_code/widgets/zoyarex_admin/zoyarex_dining_floors_page.dart';
import 'package:pocket_mates_app/custom_code/widgets/zoyarex_admin/zoyarex_discounts_page.dart';
import 'package:pocket_mates_app/custom_code/widgets/zoyarex_admin/zoyarex_payment_modes_page.dart';
import 'package:pocket_mates_app/custom_code/widgets/zoyarex_admin/zoyarex_payment_terms_page.dart';
import 'package:pocket_mates_app/custom_code/widgets/zoyarex_admin/zoyarex_tags_page.dart';
import 'package:pocket_mates_app/custom_code/widgets/zoyarex_admin/zoyarex_uom_page.dart';
import 'package:pocket_mates_app/custom_code/widgets/zoyarex_admin/zoyarex_sale_invoices_page.dart';
import 'package:pocket_mates_app/custom_code/widgets/zoyarex_admin/zoyarex_purchase_invoices_page.dart';
import 'package:pocket_mates_app/custom_code/widgets/zoyarex_admin/zoyarex_credit_notes_page.dart';
import 'package:pocket_mates_app/custom_code/widgets/zoyarex_admin/zoyarex_debit_notes_page.dart';
import 'package:pocket_mates_app/custom_code/widgets/zoyarex_admin/zoyarex_stock_adjustments_page.dart';
import 'package:pocket_mates_app/custom_code/widgets/zoyarex_admin/zoyarex_stock_transfers_page.dart';
import 'package:pocket_mates_app/custom_code/widgets/zoyarex_admin/zoyarex_payment_ins_page.dart';
import 'package:pocket_mates_app/custom_code/widgets/zoyarex_admin/zoyarex_payment_outs_page.dart';
import 'package:pocket_mates_app/custom_code/widgets/zoyarex_admin/zoyarex_z_reports_page.dart';
import 'package:pocket_mates_app/custom_code/widgets/zoyarex_admin/zoyarex_activity_log_page.dart';
import 'package:pocket_mates_app/custom_code/widgets/zoyarex_admin/zoyarex_reports_dashboard_page.dart';
import 'package:pocket_mates_app/custom_code/widgets/zoyarex_admin/zoyarex_users_page.dart';
import 'package:pocket_mates_app/custom_code/widgets/zoyarex_admin/zoyarex_superadmin_dashboard_page.dart';
import 'package:pocket_mates_app/custom_code/widgets/zoyarex_admin/zoyarex_purchase_returns_page.dart';
import 'package:pocket_mates_app/custom_code/widgets/zoyarex_admin/zoyarex_sale_returns_page.dart';
import 'package:pocket_mates_app/custom_code/widgets/zoyarex_admin/zoyarex_material_requests_page.dart';
import 'package:pocket_mates_app/custom_code/widgets/zoyarex_admin/zoyarex_expenses_page.dart';
import 'package:pocket_mates_app/custom_code/widgets/zoyarex_admin/zoyarex_expense_types_page.dart';
import 'package:pocket_mates_app/custom_code/widgets/zoyarex_admin/zoyarex_price_lists_page.dart';
import 'package:pocket_mates_app/custom_code/widgets/zoyarex_admin/zoyarex_offers_page.dart';
import 'package:pocket_mates_app/custom_code/widgets/zoyarex_admin/zoyarex_mode_of_sale_page.dart';
import 'package:pocket_mates_app/custom_code/widgets/zoyarex_admin/zoyarex_printer_hub_page.dart';
import 'package:pocket_mates_app/custom_code/widgets/zoyarex_admin/zoyarex_cash_sessions_page.dart';
import 'package:pocket_mates_app/custom_code/widgets/zoyarex_admin/zoyarex_reservations_page.dart';
import 'package:pocket_mates_app/custom_code/widgets/zoyarex_admin/zoyarex_waitlist_page.dart';
import 'package:pocket_mates_app/custom_code/widgets/zoyarex_admin/zoyarex_kitchen_display_page.dart';
import 'package:pocket_mates_app/custom_code/widgets/zoyarex_admin/zoyarex_loyalty_points_page.dart';
import 'package:fl_chart/fl_chart.dart';

class ZoyarexDashboardPage extends ConsumerWidget {
  const ZoyarexDashboardPage({Key? key}) : super(key: key);

  Future<void> _logout(BuildContext context) async {
    await ZoyarexSupabase.client.auth.signOut();
    if (context.mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const ZoyarexLoginPage()),
      );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ZoyarexSupabase.client.auth.currentUser;
    final dashboardStatsAsync = ref.watch(dashboardStatsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Zoyarex Admin Dashboard'),
        actions: [
          Builder(
            builder: (context) => IconButton(
              icon: const Icon(Icons.menu),
              onPressed: () => Scaffold.of(context).openEndDrawer(),
            ),
          ),
        ],
      ),
      endDrawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: const BoxDecoration(color: Colors.blue),
              child: Text(
                'Zoyarex Admin\n${user?.email ?? ""}',
                style: const TextStyle(color: Colors.white, fontSize: 20),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.dashboard),
              title: const Text('Dashboard'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            const Divider(),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Text('VENUE & POS', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
            ),
            ListTile(
              leading: const Icon(Icons.storefront),
              title: const Text('Groups / Shops'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder: (_) => const ZoyarexShopsPage()));
              },
            ),
            ListTile(
              leading: const Icon(Icons.store),
              title: const Text('Outlets / Branches'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder: (_) => const ZoyarexOutletsPage()));
              },
            ),
            ListTile(
              leading: const Icon(Icons.category),
              title: const Text('Categories'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder: (_) => const ZoyarexCategoriesPage()));
              },
            ),
            ListTile(
              leading: const Icon(Icons.add_circle),
              title: const Text('Add-ons'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder: (_) => const ZoyarexAddonsPage()));
              },
            ),
            ListTile(
              leading: const Icon(Icons.restaurant_menu),
              title: const Text('Menus'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder: (_) => const ZoyarexMenusPage()));
              },
            ),
            ListTile(
              leading: const Icon(Icons.blender),
              title: const Text('Raw Materials (Recipes)'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder: (_) => const ZoyarexRawMaterialsPage()));
              },
            ),
            ListTile(
              leading: const Icon(Icons.shelves),
              title: const Text('Planogram Assignments'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder: (_) => const ZoyarexPlanogramPage()));
              },
            ),
            ListTile(
              leading: const Icon(Icons.layers),
              title: const Text('Floors'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder: (_) => const ZoyarexFloorsPage()));
              },
            ),
            ListTile(
              leading: const Icon(Icons.table_restaurant),
              title: const Text('Tables'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder: (_) => const ZoyarexTablesPage()));
              },
            ),
            ListTile(
              leading: const Icon(Icons.warehouse),
              title: const Text('Warehouses'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder: (_) => const ZoyarexWarehousesPage()));
              },
            ),
            ListTile(
              leading: const Icon(Icons.inventory),
              title: const Text('Catalog (Products)'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder: (_) => const ZoyarexProductsPage()));
              },
            ),
            const Divider(),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Text('OPERATIONS & FINANCE', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
            ),
            ListTile(
              leading: const Icon(Icons.request_quote),
              title: const Text('Tax Registration'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder: (_) => const ZoyarexTaxesPage()));
              },
            ),
            ListTile(
              leading: const Icon(Icons.print),
              title: const Text('Receipt Templates'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder: (_) => const ZoyarexReceiptTemplatesPage()));
              },
            ),
            ListTile(
              leading: const Icon(Icons.receipt_long),
              title: const Text('Orders & Vouchers'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder: (_) => const ZoyarexOrdersPage()));
              },
            ),
            ListTile(
              leading: const Icon(Icons.wifi),
              title: const Text('Online Setup'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder: (_) => const ZoyarexOnlineSetupPage()));
              },
            ),
            const Divider(),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Text('USER MANAGEMENT', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
            ),
            ListTile(
              leading: const Icon(Icons.people),
              title: const Text('Users Management'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder: (_) => const ZoyarexUsersPage()));
              },
            ),
            ListTile(
              leading: const Icon(Icons.security),
              title: const Text('Roles & Permissions'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder: (_) => const ZoyarexRolesPage()));
              },
            ),
            ListTile(
              leading: const Icon(Icons.support_agent),
              title: const Text('Customers Management'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder: (_) => const ZoyarexCustomersPage()));
              },
            ),
            ListTile(
              leading: const Icon(Icons.group_work),
              title: const Text('Customer Groups'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder: (_) => const ZoyarexCustomerGroupsPage()));
              },
            ),
            ListTile(
              leading: const Icon(Icons.category),
              title: const Text('Customer Types'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder: (_) => const ZoyarexCustomerTypesPage()));
              },
            ),
            const Divider(),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Text('Settings & Configuration', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
            ),
            ListTile(
              leading: const Icon(Icons.table_restaurant),
              title: const Text('Dining Floors'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder: (_) => const ZoyarexDiningFloorsPage()));
              },
            ),
            ListTile(
              leading: const Icon(Icons.payment),
              title: const Text('Payment Modes'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder: (_) => const ZoyarexPaymentModesPage()));
              },
            ),
            ListTile(
              leading: const Icon(Icons.request_quote),
              title: const Text('Payment Terms'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder: (_) => const ZoyarexPaymentTermsPage()));
              },
            ),
            ListTile(
              leading: const Icon(Icons.label),
              title: const Text('Tags'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder: (_) => const ZoyarexTagsPage()));
              },
            ),
            ListTile(
              leading: const Icon(Icons.square_foot),
              title: const Text('Units of Measurement (UOM)'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder: (_) => const ZoyarexUomPage()));
              },
            ),
            ListTile(
              leading: const Icon(Icons.price_change),
              title: const Text('Price Lists'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder: (_) => const ZoyarexPriceListsPage()));
              },
            ),
            ListTile(
              leading: const Icon(Icons.local_offer),
              title: const Text('Offers & Promos'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder: (_) => const ZoyarexOffersPage()));
              },
            ),
            ListTile(
              leading: const Icon(Icons.delivery_dining),
              title: const Text('Mode of Sale'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder: (_) => const ZoyarexModeOfSalePage()));
              },
            ),
            ListTile(
              leading: const Icon(Icons.discount),
              title: const Text('Discounts'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder: (_) => const ZoyarexDiscountsPage()));
              },
            ),
            const Divider(),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Text('Invoices & Vouchers', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
            ),
            ListTile(
              leading: const Icon(Icons.receipt_long),
              title: const Text('Sale Invoices'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder: (_) => const ZoyarexSaleInvoicesPage()));
              },
            ),
            ListTile(
              leading: const Icon(Icons.local_shipping),
              title: const Text('Purchase Invoices'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder: (_) => const ZoyarexPurchaseInvoicesPage()));
              },
            ),
            ListTile(
              leading: const Icon(Icons.receipt),
              title: const Text('Credit Notes'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder: (_) => const ZoyarexCreditNotesPage()));
              },
            ),
            ListTile(
              leading: const Icon(Icons.receipt_long),
              title: const Text('Debit Notes'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder: (_) => const ZoyarexDebitNotesPage()));
              },
            ),
            ListTile(
              leading: const Icon(Icons.keyboard_return),
              title: const Text('Sale Returns'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder: (_) => const ZoyarexSaleReturnsPage()));
              },
            ),
            ListTile(
              leading: const Icon(Icons.assignment_return),
              title: const Text('Purchase Returns'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder: (_) => const ZoyarexPurchaseReturnsPage()));
              },
            ),
            ListTile(
              leading: const Icon(Icons.inventory),
              title: const Text('Stock Adjustments'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder: (_) => const ZoyarexStockAdjustmentsPage()));
              },
            ),
            ListTile(
              leading: const Icon(Icons.sync_alt),
              title: const Text('Stock Transfers'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder: (_) => const ZoyarexStockTransfersPage()));
              },
            ),
            ListTile(
              leading: const Icon(Icons.arrow_downward),
              title: const Text('Payment Ins'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder: (_) => const ZoyarexPaymentInsPage()));
              },
            ),
            ListTile(
              leading: const Icon(Icons.arrow_upward),
              title: const Text('Payment Outs'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder: (_) => const ZoyarexPaymentOutsPage()));
              },
            ),
            ListTile(
              leading: const Icon(Icons.outbox),
              title: const Text('Material Requests'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder: (_) => const ZoyarexMaterialRequestsPage()));
              },
            ),
            const Divider(),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Text('FINANCE & EXPENSES', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
            ),
            ListTile(
              leading: const Icon(Icons.money_off),
              title: const Text('Expenses'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder: (_) => const ZoyarexExpensesPage()));
              },
            ),
            ListTile(
              leading: const Icon(Icons.category),
              title: const Text('Expense Types'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder: (_) => const ZoyarexExpenseTypesPage()));
              },
            ),
            const Divider(),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Text('Reports & Analytics', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
            ),
            ListTile(
              leading: const Icon(Icons.summarize),
              title: const Text('Z-Reports (Closure)'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder: (_) => const ZoyarexZReportsPage()));
              },
            ),
            ListTile(
              leading: const Icon(Icons.history),
              title: const Text('Activity Log'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder: (_) => const ZoyarexActivityLogPage()));
              },
            ),
            ListTile(
              leading: const Icon(Icons.analytics),
              title: const Text('Other Reports'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder: (_) => const ZoyarexReportsDashboardPage()));
              },
            ),
            const Divider(),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Text('PRINTING & HARDWARE', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
            ),
            ListTile(
              leading: const Icon(Icons.print),
              title: const Text('Printer Hub'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder: (_) => const ZoyarexPrinterHubPage()));
              },
            ),
            const Divider(),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Text('POS & DINING', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
            ),
            ListTile(
              leading: const Icon(Icons.point_of_sale),
              title: const Text('Cash Sessions'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder: (_) => const ZoyarexCashSessionsPage()));
              },
            ),
            ListTile(
              leading: const Icon(Icons.event_seat),
              title: const Text('Reservations'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder: (_) => const ZoyarexReservationsPage()));
              },
            ),
            ListTile(
              leading: const Icon(Icons.queue),
              title: const Text('Waitlist'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder: (_) => const ZoyarexWaitlistPage()));
              },
            ),
            ListTile(
              leading: const Icon(Icons.kitchen),
              title: const Text('Kitchen Displays (KDS)'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder: (_) => const ZoyarexKitchenDisplayPage()));
              },
            ),
            ListTile(
              leading: const Icon(Icons.stars),
              title: const Text('Loyalty Points'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder: (_) => const ZoyarexLoyaltyPointsPage()));
              },
            ),
            const Divider(),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Text('SYSTEM', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
            ),
            if (user?.email == 'superadmin@vaasits.com')
              ListTile(
                leading: const Icon(Icons.admin_panel_settings, color: Colors.purple),
                title: const Text('Super Admin Portal', style: TextStyle(color: Colors.purple, fontWeight: FontWeight.bold)),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const ZoyarexSuperadminDashboardPage()));
                },
              ),
            const Divider(),
          ],
        ),
      ),
      body: dashboardStatsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
        data: (stats) {
          final overall = stats.overallStats;
          
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Welcome, ${user?.email ?? "Admin"}!',
                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 24),
                
                // KPI Cards
                GridView.count(
                  crossAxisCount: MediaQuery.of(context).size.width > 800 ? 4 : 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  children: [
                    _buildKpiCard('Total Orders', overall['orderCount'].toString(), Icons.receipt),
                    _buildKpiCard('Completed Sales', '₹${overall['completedOrderAmount']}', Icons.attach_money),
                    _buildKpiCard('Active Orders', overall['activeOrderCount'].toString(), Icons.pending_actions),
                    _buildKpiCard('Unique Customers', overall['uniqueCustomerCount'].toString(), Icons.people),
                  ],
                ),
                const SizedBox(height: 32),

                // Charts Section
                if (stats.hourlyActiveOrderGroup.isNotEmpty) ...[
                  const Text('Hourly Active Orders', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 300,
                    child: _buildHourlyChart(stats.hourlyActiveOrderGroup),
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildKpiCard(String title, String value, IconData icon) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 40, color: Colors.blueAccent),
            const SizedBox(height: 12),
            Text(value, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text(title, textAlign: TextAlign.center, style: const TextStyle(fontSize: 14, color: Colors.grey)),
          ],
        ),
      ),
    );
  }

  Widget _buildHourlyChart(List<dynamic> hourlyData) {
    if (hourlyData.isEmpty) return const Center(child: Text("No Data"));

    List<BarChartGroupData> barGroups = [];
    double maxY = 0;

    for (int i = 0; i < hourlyData.length; i++) {
      final item = hourlyData[i];
      final completed = (item['completed_order_count'] ?? 0).toDouble();
      final active = (item['active_order_count'] ?? 0).toDouble();
      final cancelled = (item['cancelled_order_count'] ?? 0).toDouble();

      final total = completed + active + cancelled;
      if (total > maxY) maxY = total;

      barGroups.add(
        BarChartGroupData(
          x: i,
          barRods: [
            BarChartRodData(
              toY: completed,
              color: Colors.blue,
              width: 15,
            ),
            BarChartRodData(
              toY: active,
              color: Colors.orange,
              width: 15,
            ),
            BarChartRodData(
              toY: cancelled,
              color: Colors.red,
              width: 15,
            ),
          ],
        ),
      );
    }

    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: maxY + (maxY * 0.2), // Add 20% headroom
        barTouchData: BarTouchData(enabled: true),
        titlesData: FlTitlesData(
          show: true,
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                if (value.toInt() >= 0 && value.toInt() < hourlyData.length) {
                  return Text('${hourlyData[value.toInt()]['hour']}h', style: const TextStyle(fontSize: 10));
                }
                return const Text('');
              },
            ),
          ),
          leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        gridData: const FlGridData(show: false),
        borderData: FlBorderData(show: false),
        barGroups: barGroups,
      ),
    );
  }
}
