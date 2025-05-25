import 'package:flutter/material.dart';
import '../../../data/services/seller_service.dart';
import '../../../domain/models/order.dart';
import 'package:cached_network_image/cached_network_image.dart';

class OrdersPage extends StatefulWidget {
  const OrdersPage({super.key});

  @override
  State<OrdersPage> createState() => _OrdersPageState();
}

class _OrdersPageState extends State<OrdersPage> {
  final SellerService _sellerService = SellerService();
  List<Order> _orders = [];
  List<Order> _filteredOrders = []; // Список для отображения после фильтрации
  bool _isLoading = true;
  String? _error;
  final TextEditingController _searchController = TextEditingController(); // Контроллер для поля поиска
  OrderStatus? _selectedStatus; // Переменная для хранения выбранного статуса

  @override
  void initState() {
    super.initState();
    _loadOrders();
    // Добавляем слушатель для поля поиска
    _searchController.addListener(_filterOrders);
  }

  @override
  void dispose() {
    _searchController.dispose(); // Очищаем контроллер при удалении виджета
    super.dispose();
  }

  Future<void> _loadOrders() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      final orders = await _sellerService.getSellerOrders();
      setState(() {
        _orders = orders;
        _filteredOrders = orders; // Изначально отфильтрованный список равен полному
        _isLoading = false;
      });
      // Явно вызываем фильтрацию после загрузки, чтобы применить текущий текст поиска (если есть)
      _filterOrders();

    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
      // Добавляем вызов filterOrders и сюда на случай ошибки
      _filterOrders();
    }
  }

  // Метод для фильтрации заказов
  void _filterOrders() {
    final query = _searchController.text.toLowerCase().trim(); // Удаляем пробелы по краям
    setState(() {
      _filteredOrders = _orders.where((order) {
        final orderNumberMatch = order.id?.toLowerCase().contains(query) ?? false;
        final productNameMatch = order.items.any((item) => item.name.toLowerCase().contains(query));

        // Проверяем соответствие выбранному статусу
        final statusMatch = _selectedStatus == null || order.status == _selectedStatus;

        return (orderNumberMatch || productNameMatch) && statusMatch;
      }).toList();
      
      // Если поисковый запрос пустой и статус не выбран, показываем все заказы
      if (query.isEmpty && _selectedStatus == null) {
         _filteredOrders = List.from(_orders);
      }
    });
  }

  // Метод для отображения диалога выбора статуса
  void _showStatusFilter() {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: const Text('Все заказы'),
                onTap: () {
                  setState(() {
                    _selectedStatus = null; // Сброс фильтра
                  });
                  _filterOrders();
                  Navigator.pop(context);
                },
              ),
              ...OrderStatus.values.map((status) => ListTile(
                title: Text(_getStatusText(status)),
                onTap: () {
                  setState(() {
                    _selectedStatus = status;
                  });
                  _filterOrders();
                  Navigator.pop(context);
                },
              )).toList(),
            ],
          ),
        );
      },
    );
  }

  Future<void> _updateOrderStatus(Order order, String newStatus) async {
    try {
      if (order.id == null) {
        throw Exception('ID заказа не найден');
      }
      
      await _sellerService.updateOrderStatus(order.id!, newStatus);
      await _loadOrders(); // Перезагружаем список заказов
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Статус заказа обновлен'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Ошибка при обновлении статуса: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  String _getStatusText(OrderStatus status) {
    switch (status) {
      case OrderStatus.pending:
        return 'В обработке';
      case OrderStatus.completed:
        return 'Завершён';
      case OrderStatus.canceled:
        return 'Отменён';
    }
  }

  Color _getStatusColor(OrderStatus status) {
    switch (status) {
      case OrderStatus.pending:
        return Colors.orange;
      case OrderStatus.completed:
        return Colors.green;
      case OrderStatus.canceled:
        return Colors.red;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Заказы',
          style: TextStyle(
            fontFamily: 'Inter',
            fontWeight: FontWeight.bold,
            fontSize: 23,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadOrders,
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Номер заказа, товар',
                prefixIcon: Icon(Icons.search, color: Colors.grey[600]),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.grey[200],
                contentPadding: EdgeInsets.symmetric(vertical: 15.0, horizontal: 10.0)
              ),
            ),
          ),
          // Добавляем информационное сообщение для поиска
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 0.0),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Для корректной работы поиска обновите страницу',
                style: TextStyle(
                  fontSize: 12.0,
                  color: Colors.grey[600],
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: GestureDetector(
              onTap: _showStatusFilter,
              child: Row(
                children: [
                  Icon(Icons.filter_list, color: Colors.grey[700]),
                  SizedBox(width: 8.0),
                  Text(
                    _selectedStatus == null
                        ? 'Все заказы'
                        : _getStatusText(_selectedStatus!),
                    style: TextStyle(fontSize: 16.0, color: Colors.grey[700]),
                  ),
                  Icon(Icons.arrow_drop_down, color: Colors.grey[700]),
                ],
              ),
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _error != null
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Ошибка при загрузке заказов',
                              style: TextStyle(color: Colors.red),
                            ),
                            const SizedBox(height: 8),
                            ElevatedButton(
                              onPressed: _loadOrders,
                              child: const Text('Повторить'),
                            ),
                          ],
                        ),
                      )
                    : _filteredOrders.isEmpty
                        ? const Center(
                            child: Text(
                              'Нет заказов',
                              style: TextStyle(fontSize: 16),
                            ),
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            itemCount: _filteredOrders.length,
                            itemBuilder: (context, index) {
                              final order = _filteredOrders[index];
                              return Card(
                                margin: const EdgeInsets.only(bottom: 16),
                                elevation: 2.0,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
                                child: Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.stretch,
                                    children: [
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            '№${order.id}',
                                            style: const TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          Text(
                                            'от ${order.createdAt.toString().split('.')[0].split(' ')[0]}',
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: Colors.grey[600],
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 8),
                                      Row(
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 8,
                                              vertical: 4,
                                            ),
                                            decoration: BoxDecoration(
                                              color: _getStatusColor(order.status).withOpacity(0.2),
                                              borderRadius: BorderRadius.circular(4),
                                            ),
                                            child: Text(
                                              _getStatusText(order.status),
                                              style: TextStyle(
                                                color: _getStatusColor(order.status),
                                                fontSize: 12,
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 12),
                                          Text(
                                            '${order.totalAmount.toStringAsFixed(2)} ₽',
                                            style: const TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                                      if (order.deliveryAddress != null) ...[
                                        const SizedBox(height: 8),
                                        Row(
                                          children: [
                                            Icon(Icons.location_on, size: 16.0, color: Colors.grey[600]),
                                            SizedBox(width: 4.0),
                                            Expanded(
                                              child: Text(
                                                order.deliveryAddress!,
                                                style: TextStyle(
                                                  fontSize: 14,
                                                  color: Colors.grey[600],
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                      const SizedBox(height: 16),
                                      Row(
                                        children: [
                                          ...order.items.take(4).map((item) => Padding(
                                            padding: const EdgeInsets.only(right: 8.0),
                                            child: item.image.isNotEmpty
                                                ? (item.image == 'assets/images/bouquet_sample.png'
                                                    ? ClipRRect(
                                                        borderRadius: BorderRadius.circular(8.0),
                                                        child: Image.asset(
                                                            item.image,
                                                            width: 60, 
                                                            height: 60, 
                                                            fit: BoxFit.cover,
                                                        ),
                                                      )
                                                    : ClipRRect(
                                                        borderRadius: BorderRadius.circular(8.0),
                                                        child: CachedNetworkImage(
                                                            imageUrl: item.image,
                                                            width: 60, 
                                                            height: 60, 
                                                            fit: BoxFit.cover,
                                                            placeholder: (context, url) => Container(
                                                              width: 60,
                                                              height: 60,
                                                              color: Colors.grey[300],
                                                            ),
                                                            errorWidget: (context, url, error) => Container(
                                                              width: 60,
                                                              height: 60,
                                                              color: Colors.grey[300],
                                                              child: Icon(Icons.error),
                                                            ),
                                                        ),
                                                      ))
                                                : Container(
                                                    width: 60, 
                                                    height: 60, 
                                                    color: Colors.grey[300],
                                                    child: Icon(Icons.image_not_supported),
                                                  ),
                                          )),
                                          if (order.items.length > 4) Expanded(child: Text('+${order.items.length - 4} еще', style: TextStyle(color: Colors.grey[600]))),
                                        ],
                                      ),
                                      if (order.items.isNotEmpty) ...[ // Добавляем этот блок, если в заказе есть товары
                                        const SizedBox(height: 16),
                                        const Text(
                                          'Состав заказа:',
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black,
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: order.items.map((item) {
                                            return Text(
                                              '${item.name} (${item.quantity} шт.)',
                                              style: TextStyle(
                                                fontSize: 14,
                                                color: Colors.grey[800],
                                              ),
                                            );
                                          }).toList(),
                                        ),
                                      ],
                                      if (order.status == OrderStatus.pending) ...[
                                        const SizedBox(height: 16),
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.end,
                                          children: [
                                            TextButton(
                                              onPressed: () => _updateOrderStatus(order, 'canceled'),
                                              child: const Text(
                                                'Отменить',
                                                style: TextStyle(color: Colors.red),
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                            ElevatedButton(
                                              onPressed: () => _updateOrderStatus(order, 'completed'),
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor: const Color(0xFF9191E9),
                                                foregroundColor: Colors.white,
                                              ),
                                              child: const Text('Завершить'),
                                            ),
                                          ],
                                        ),
                                      ],
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
} 