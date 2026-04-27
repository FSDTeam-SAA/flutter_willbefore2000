// lib/features/notification/presentation/screens/notification_screen.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/routes/route_endpoint.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  final user = FirebaseAuth.instance.currentUser;

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser == null) {
      return const Scaffold(
        body: Center(child: Text('Please log in to see notifications')),
      );
    }

    debugPrint("NotificationScreen: Querying for user ${currentUser.uid}");

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        actions: [
          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('users')
                .doc(currentUser.uid)
                .collection('notifications')
                .where('read', isEqualTo: false)
                .snapshots(),
            builder: (context, snapshot) {
              final unreadCount = snapshot.data?.docs.length ?? 0;
              return unreadCount > 0
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.only(right: 16),
                        child: Chip(
                          backgroundColor: Colors.red,
                          label: Text(
                            '$unreadCount',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    )
                  : const SizedBox();
            },
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(currentUser.uid)
            .collection('notifications')
            .orderBy('createdAt', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final docs = snapshot.data!.docs;

          if (docs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.notifications_off,
                    size: 64,
                    color: Colors.grey,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No notifications yet\nUID: ${currentUser.uid}',
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final data = docs[index].data() as Map<String, dynamic>;
              final docId = docs[index].id;

              final title = data['title'] ?? 'Notification';
              final message = data['message'] ?? '';
              final isRead = data['read'] == true;
              final timestamp = (data['createdAt'] as Timestamp?)?.toDate();

              return Card(
                elevation: isRead ? 0 : 2,
                color: isRead ? Colors.white : Colors.blue[50],
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: isRead
                      ? BorderSide.none
                      : const BorderSide(color: Colors.blue, width: 1),
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  leading: Icon(
                    data['type'] == 'order_shipped'
                        ? Icons.local_shipping
                        : data['type'] == 'new_product'
                        ? Icons.add_shopping_cart
                        : Icons.notifications,
                    color: isRead ? Colors.grey : Colors.blue,
                  ),
                  title: Text(
                    title,
                    style: TextStyle(
                      fontWeight: isRead ? FontWeight.normal : FontWeight.bold,
                    ),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(message),
                      if (timestamp != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text(
                            timeago.format(timestamp),
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                        ),
                      if (data['tracking_number'] != null &&
                          data['tracking_number'].toString().isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text(
                            'Tracking: ${data['tracking_number']}',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue,
                            ),
                          ),
                        ),
                      if (data['metadata'] != null &&
                          data['metadata']['label_url'] != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: TextButton.icon(
                            onPressed: () =>
                                _launchURL(data['metadata']['label_url']),
                            icon: const Icon(Icons.picture_as_pdf, size: 14),
                            label: const Text(
                              'View Shipping Label',
                              style: TextStyle(fontSize: 12),
                            ),
                            style: TextButton.styleFrom(
                              padding: EdgeInsets.zero,
                              minimumSize: Size.zero,
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              foregroundColor: Colors.teal,
                            ),
                          ),
                        ),
                    ],
                  ),
                  trailing: isRead
                      ? null
                      : const Icon(Icons.circle, size: 10, color: Colors.blue),
                  onTap: () async {
                    // Mark as read on tap
                    if (!isRead) {
                      await FirebaseFirestore.instance
                          .collection('users')
                          .doc(currentUser.uid)
                          .collection('notifications')
                          .doc(docId)
                          .update({'read': true});
                    }

                    // Extract product ID from top level or metadata
                    final productId =
                        data['productId'] ??
                        (data['metadata'] != null
                            ? data['metadata']['productId']
                            : null);

                    // Navigate to product details
                    // Navigate to product details
                    if (productId != null && productId.isNotEmpty) {
                      context.pushNamed(
                        'product_details',
                        pathParameters: {'productId': productId},
                      );
                    }

                    // Navigate to orders screen
                    if (data['orderId'] != null) {
                      context.push(RoutePaths.orders);
                    }
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }

  Future<void> _launchURL(String urlString) async {
    final Uri url = Uri.parse(urlString);
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Could not launch $urlString')));
      }
    }
  }
}
