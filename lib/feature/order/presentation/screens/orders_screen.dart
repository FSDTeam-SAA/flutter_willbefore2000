import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../domain/entities/order_entities.dart';
import '../providers/order_provider.dart';

class OrdersScreen extends ConsumerStatefulWidget {
  const OrdersScreen({super.key});

  @override
  ConsumerState<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends ConsumerState<OrdersScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ordersState = ref.watch(orderProvider);

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('Orders'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.green,
          unselectedLabelColor: Colors.grey,
          indicatorColor: Colors.green,
          tabs: const [
            Tab(text: 'My Orders'),
            Tab(text: 'Order History'),
          ],
        ),
      ),
      body: ordersState.when(
        data: (orders) => TabBarView(
          controller: _tabController,
          children: [_buildMyOrderTab(orders), _buildOrderHistoryTab(orders)],
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Error: $error')),
      ),
    );
  }

  Widget _buildMyOrderTab(List<Order> orders) {
    final activeOrders = orders
        .where(
          (order) =>
              order.status != OrderStatus.delivered &&
              order.status != OrderStatus.cancelled,
        )
        .toList();

    if (activeOrders.isEmpty) {
      return const Center(child: Text('No active orders'));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: activeOrders.length,
      itemBuilder: (context, index) {
        final order = activeOrders[index];
        return _buildOrderCard(order, showDetails: true);
      },
    );
  }

  Widget _buildOrderHistoryTab(List<Order> orders) {
    final historyOrders = orders
        .where(
          (order) =>
              order.status == OrderStatus.delivered ||
              order.status == OrderStatus.cancelled,
        )
        .toList();

    if (historyOrders.isEmpty) {
      return const Center(child: Text('No order history'));
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Order History Table
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                // Table Header
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(12),
                      topRight: Radius.circular(12),
                    ),
                  ),
                  child: const Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: Text(
                          'Product Name',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Text(
                          'Date',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Text(
                          'Status',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Text(
                          'Action',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                // Table Rows
                ...historyOrders.map((order) => _buildOrderHistoryRow(order)),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Pagination (if needed)
          if (historyOrders.length > 5) _buildPagination(),
        ],
      ),
    );
  }

  Widget _buildOrderCard(Order order, {bool showDetails = false}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Order ID and Status
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Order #${order.id.substring(0, 8)}',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: order.statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  order.statusText,
                  style: TextStyle(
                    color: order.statusColor,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Product Items
          ...order.items.map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  // Product Image
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      color: Colors.grey[200],
                      image: item.product.imageUrls.isNotEmpty
                          ? DecorationImage(
                              image: NetworkImage(item.product.imageUrls.first),
                              fit: BoxFit.cover,
                            )
                          : null,
                    ),
                  ),
                  const SizedBox(width: 12),

                  // Product Details
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.product.title,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Text(
                          '\$${item.product.effectivePrice.toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Quantity and Total
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        'Qty: ${item.quantity}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                      Text(
                        '\$${item.totalPrice.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // Order Total and Date
          const Divider(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total: \$${order.total.toStringAsFixed(2)}',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(
                DateFormat('MMM dd, yyyy').format(order.createdAt),
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildOrderHistoryRow(Order order) {
    final mainProduct = order.items.isNotEmpty ? order.items.first : null;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.grey[200]!)),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              mainProduct != null
                  ? '${mainProduct.product.title}${order.items.length > 1 ? ' +${order.items.length - 1} more' : ''}'
                  : 'Order #${order.id.substring(0, 8)}',
              style: const TextStyle(fontSize: 12),
            ),
          ),
          Expanded(
            child: Text(
              DateFormat('MM/dd/yyyy').format(order.createdAt),
              style: const TextStyle(fontSize: 12),
            ),
          ),
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: order.statusColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                order.statusText,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
          Expanded(
            child: TextButton(
              onPressed: () => _showOrderSummary(order),
              child: const Text(
                'Details',
                style: TextStyle(fontSize: 12, color: Colors.blue),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPagination() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text('Showing 1 to 5 of 12 results'),
        const SizedBox(width: 16),
        Row(
          children: [
            _buildPaginationButton('1', isActive: true),
            _buildPaginationButton('2'),
            _buildPaginationButton('3'),
            _buildPaginationButton('4'),
            _buildPaginationButton('>'),
          ],
        ),
      ],
    );
  }

  Widget _buildPaginationButton(String text, {bool isActive = false}) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 2),
      child: ElevatedButton(
        onPressed: () {},
        style: ElevatedButton.styleFrom(
          backgroundColor: isActive ? Colors.green : Colors.white,
          foregroundColor: isActive ? Colors.white : Colors.grey,
          minimumSize: const Size(32, 32),
          padding: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(4),
            side: BorderSide(color: Colors.grey[300]!),
          ),
        ),
        child: Text(text, style: const TextStyle(fontSize: 12)),
      ),
    );
  }

  void _showOrderSummary(Order order) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Order Summary',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Product Items
              ...order.items.map(
                (item) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Row(
                    children: [
                      Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          color: Colors.grey[200],
                          image: item.product.imageUrls.isNotEmpty
                              ? DecorationImage(
                                  image: NetworkImage(
                                    item.product.imageUrls.first,
                                  ),
                                  fit: BoxFit.cover,
                                )
                              : null,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.product.title,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Text(
                              '${item.quantity} x \$${item.product.effectivePrice.toStringAsFixed(2)}',
                              style: const TextStyle(
                                fontSize: 14,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        '\$${item.totalPrice.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Order Summary
              Column(
                children: [
                  _buildSummaryRow(
                    'Subtotal',
                    '\$${order.subtotal.toStringAsFixed(2)}',
                  ),
                  _buildSummaryRow('Tax', '\$${order.tax.toStringAsFixed(2)}'),
                  const Divider(),
                  _buildSummaryRow(
                    'Total',
                    '\$${order.total.toStringAsFixed(2)}',
                    isTotal: true,
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Download Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.download),
                  label: const Text('Download Receipt'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green[600],
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value, {bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: isTotal ? 16 : 14,
              fontWeight: isTotal ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: isTotal ? 16 : 14,
              fontWeight: isTotal ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}
