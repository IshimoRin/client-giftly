import 'package:flutter/material.dart';
import 'package:client_giftly/domain/models/order.dart';

class OrderCard extends StatelessWidget {
  final Order order;
  final Function(OrderStatus) onStatusChanged;

  const OrderCard({
    super.key,
    required this.order,
    required this.onStatusChanged,
  });

  String _getStatusText(OrderStatus status) {
    switch (status) {
      case OrderStatus.new_:
        return 'Новый';
      case OrderStatus.processing:
        return 'В обработке';
      case OrderStatus.ready:
        return 'Готов';
      case OrderStatus.delivered:
        return 'Доставлен';
      case OrderStatus.cancelled:
        return 'Отменен';
    }
  }

  Color _getStatusColor(OrderStatus status) {
    switch (status) {
      case OrderStatus.new_:
        return Colors.blue;
      case OrderStatus.processing:
        return Colors.orange;
      case OrderStatus.ready:
        return Colors.green;
      case OrderStatus.delivered:
        return Colors.grey;
      case OrderStatus.cancelled:
        return Colors.red;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Заказ #${order.id}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: _getStatusColor(order.status),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    _getStatusText(order.status),
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Клиент: ${order.customerName}',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 4),
            Text(
              'Телефон: ${order.customerPhone}',
              style: const TextStyle(fontSize: 16),
            ),
            if (order.customerEmail != null) ...[
              const SizedBox(height: 4),
              Text(
                'Email: ${order.customerEmail}',
                style: const TextStyle(fontSize: 16),
              ),
            ],
            const SizedBox(height: 8),
            Text(
              'Адрес доставки: ${order.deliveryAddress}',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 8),
            const Text(
              'Товары:',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            ...order.items.map((item) => Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Text(
                    '${item.product.name} - ${item.quantity} шт. x ${item.price} ₽',
                    style: const TextStyle(fontSize: 16),
                  ),
                )),
            const SizedBox(height: 8),
            Text(
              'Итого: ${order.totalAmount} ₽',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            if (order.comment != null) ...[
              const SizedBox(height: 8),
              Text(
                'Комментарий: ${order.comment}',
                style: const TextStyle(fontSize: 16),
              ),
            ],
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Изменить статус'),
                        content: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: OrderStatus.values.map((status) {
                            return ListTile(
                              title: Text(_getStatusText(status)),
                              onTap: () {
                                onStatusChanged(status);
                                Navigator.pop(context);
                              },
                            );
                          }).toList(),
                        ),
                      ),
                    );
                  },
                  child: const Text('Изменить статус'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
} 