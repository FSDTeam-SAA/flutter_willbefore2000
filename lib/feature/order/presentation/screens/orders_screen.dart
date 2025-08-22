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
        return _buildMyOrderCard(order);
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
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  spreadRadius: 1,
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: [
                // Table Header
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
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
                        flex: 3,
                        child: Text(
                          'Product Name',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Text(
                          'Date',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Text(
                          'Status',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Text(
                          'Action',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                // Table Rows
                ...historyOrders.asMap().entries.map((entry) {
                  final index = entry.key;
                  final order = entry.value;
                  return _buildOrderHistoryRow(order, index);
                }),
              ],
            ),
          ),
          const SizedBox(height: 20),

          if (historyOrders.length > 5) _buildPagination(historyOrders.length),
        ],
      ),
    );
  }

  Widget _buildMyOrderCard(Order order) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Store name and status
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(Icons.store, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  const Text(
                    'Smilestreats',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: _getStatusColor(order.status),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  order.statusText,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Product items
          ...order.items.map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                children: [
                  // Product image
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      color: Colors.grey[100],
                    ),
                    child: _buildProductImage(item.product.imageUrls),
                  ),
                  const SizedBox(width: 12),

                  // Product details
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.product.title,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '\$${item.product.effectivePrice.toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.black87,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Quantity
                  Text(
                    'Qty:${item.quantity}',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Total
          const SizedBox(height: 8),
          Text(
            'Total (${order.items.length} item${order.items.length > 1 ? 's' : ''}): \$${order.total.toStringAsFixed(0)}',
            style: const TextStyle(fontSize: 14, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderHistoryRow(Order order, int index) {
    final mainProduct = order.items.isNotEmpty ? order.items.first : null;
    final isEven = index % 2 == 0;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: isEven ? Colors.white : Colors.grey[50],
        border: Border(
          bottom: BorderSide(color: Colors.grey[200]!, width: 0.5),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Text(
              mainProduct != null
                  ? '${mainProduct.product.title.length > 15 ? '${mainProduct.product.title.substring(0, 15)}...' : mainProduct.product.title}'
                  : 'Order #${order.id.substring(0, 8)}',
              style: const TextStyle(fontSize: 13, color: Colors.black87),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              DateFormat('MM/dd/yyyy').format(order.createdAt),
              style: const TextStyle(fontSize: 13, color: Colors.black87),
            ),
          ),
          Expanded(
            flex: 2,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: _getStatusColor(order.status),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                order.statusText,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: TextButton(
              onPressed: () => _showOrderSummary(order),
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              ),
              child: const Text(
                'See Details',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.blue,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPagination(int totalOrders) {
    final totalPages = (totalOrders / 5).ceil();

    return Column(
      children: [
        Text(
          'Showing 1 to 5 of $totalOrders results',
          style: TextStyle(fontSize: 12, color: Colors.grey[600]),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildPaginationButton('<', isActive: false),
            ...List.generate(
              totalPages > 5 ? 5 : totalPages,
              (index) =>
                  _buildPaginationButton('${index + 1}', isActive: index == 0),
            ),
            _buildPaginationButton('>', isActive: false),
          ],
        ),
      ],
    );
  }

  Widget _buildPaginationButton(String text, {bool isActive = false}) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 2),
      child: Material(
        color: isActive ? Colors.green : Colors.white,
        borderRadius: BorderRadius.circular(6),
        child: InkWell(
          onTap: () {},
          borderRadius: BorderRadius.circular(6),
          child: Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: Colors.grey[300]!),
            ),
            child: Center(
              child: Text(
                text,
                style: TextStyle(
                  fontSize: 12,
                  color: isActive ? Colors.white : Colors.grey[700],
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showOrderSummary(Order order) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Smilestreats Order Summary',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close, size: 20),
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.grey[100],
                      padding: const EdgeInsets.all(4),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Product Items
              ...order.items.map(
                (item) => Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Row(
                    children: [
                      Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          color: Colors.grey[100],
                        ),
                        child: _buildProductImage(item.product.imageUrls),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.product.title,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 4),
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
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Order Summary
              Column(
                children: [
                  _buildSummaryRow(
                    'Subtotal',
                    '\$${order.subtotal.toStringAsFixed(2)}',
                  ),
                  _buildSummaryRow('Tax', '\$${order.tax.toStringAsFixed(2)}'),
                  const Divider(height: 24),
                  _buildSummaryRow(
                    'Total',
                    '\$${order.total.toStringAsFixed(2)}',
                    isTotal: true,
                  ),
                ],
              ),
              const SizedBox(height: 24),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.download, size: 18),
                  label: const Text(
                    'Download Now',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green[600],
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    elevation: 0,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getStatusColor(OrderStatus status) {
    switch (status) {
      case OrderStatus.delivered:
        return Colors.green;
      case OrderStatus.pending:
        return Colors.orange;
      case OrderStatus.cancelled:
        return Colors.red;
      case OrderStatus.processing:
        return Colors.blue;
      case OrderStatus.shipped:
        return Colors.teal;
      default:
        return Colors.grey;
    }
  }

  Widget _buildProductImage(List<String> imageUrls) {
    // Check if we have valid image URLs
    if (imageUrls.isEmpty) {
      return Icon(Icons.image, color: Colors.grey[400]);
    }

    final imageUrl = imageUrls.first.trim();

    // Validate URL format
    if (imageUrl.isEmpty ||
        (!imageUrl.startsWith('http://') && !imageUrl.startsWith('https://'))) {
      return Icon(Icons.image, color: Colors.grey[400]);
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: Image.network(
        imageUrl,
        fit: BoxFit.cover,
        width: 60,
        height: 60,
        errorBuilder: (context, error, stackTrace) {
          print('🐞 DEBUG: Image load failed for URL: $imageUrl');
          print('🐞 DEBUG: Error: $error');
          return Icon(Icons.image, color: Colors.grey[400]);
        },
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Center(
            child: SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                value: loadingProgress.expectedTotalBytes != null
                    ? loadingProgress.cumulativeBytesLoaded /
                          loadingProgress.expectedTotalBytes!
                    : null,
              ),
            ),
          );
        },
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
              fontWeight: isTotal ? FontWeight.w600 : FontWeight.w400,
              color: Colors.black87,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: isTotal ? 16 : 14,
              fontWeight: isTotal ? FontWeight.w600 : FontWeight.w500,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}
