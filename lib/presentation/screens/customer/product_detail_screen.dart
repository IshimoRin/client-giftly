class _ProductDetailScreenState extends State<ProductDetailScreen> {
  late Product _product;
  bool _isLoading = false;
  bool _isFavorite = false;
  final ProductService _productService = ProductService();

  @override
  void initState() {
    super.initState();
    _product = widget.product;
    _loadFavoriteStatus();
  }

  Future<void> _loadFavoriteStatus() async {
    try {
      final favorites = await _productService.getFavorites();
      setState(() {
        _isFavorite = favorites.any((f) => f.id == _product.id);
      });
    } catch (e) {
      print('Ошибка при загрузке статуса избранного: $e');
    }
  }

  Future<void> _toggleFavorite() async {
    try {
      setState(() {
        _isLoading = true;
      });

      final updatedProduct = await _productService.toggleFavorite(_product);
      setState(() {
        _product = updatedProduct;
        _isFavorite = updatedProduct.isFavorite;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_isFavorite ? 'Добавлено в избранное' : 'Удалено из избранного'),
          duration: const Duration(seconds: 2),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Ошибка: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_product.name),
        actions: [
          IconButton(
            icon: Icon(
              _isFavorite ? Icons.favorite : Icons.favorite_border,
              color: _isFavorite ? Colors.red : null,
            ),
            onPressed: _isLoading ? null : _toggleFavorite,
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ... остальной код без изменений ...
          ],
        ),
      ),
    );
  }
} 