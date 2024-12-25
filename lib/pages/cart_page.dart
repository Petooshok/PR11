import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import '../models/cart_model.dart';
import '../services/api_service.dart'; // Импортируем ApiService
import 'manga_details_screen.dart'; // Импортируем страницу с описанием

class CartPage extends StatefulWidget {
  @override
  _CartPageState createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  List<CartModel> _cartItems = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchCartItems();
  }

  Future<void> _fetchCartItems() async {
    try {
      final cartItems = await ApiService().getCartProducts(1); // Предположим, что у нас есть пользователь с ID 1
      setState(() {
        _cartItems = cartItems;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      print('Error fetching cart items: $e');
    }
  }

  Future<void> _removeFromCart(CartModel item) async {
    try {
      await ApiService().deleteProductFromCart(1, item.id); // Предположим, что у нас есть пользователь с ID 1
      setState(() {
        _cartItems.remove(item);
      });
    } catch (e) {
      print('Error removing item from cart: $e');
    }
  }

  Future<void> _updateCartItemQuantity(CartModel item, bool increase) async {
    try {
      if (increase) {
        await ApiService().updateCartProductPlus(1, item.id); // Предположим, что у нас есть пользователь с ID 1
      } else {
        await ApiService().updateCartProductMinus(1, item.id); // Предположим, что у нас есть пользователь с ID 1
      }
      setState(() {
        item.quantity += increase ? 1 : -1;
      });
    } catch (e) {
      print('Error updating cart item quantity: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: const Color(0xFF191919), // Темно-черный фон
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              _buildHeader(context, true), // Добавляем заголовок
              Expanded(
                child: _isLoading
                    ? Center(child: CircularProgressIndicator())
                    : _cartItems.isEmpty
                        ? Center(
                            child: Text(
                              'Не стесняйтесь выбрать мангу, чтобы потом здесь ее увидеть!',
                              style: TextStyle(
                                fontSize: 20.0,
                                color: Color(0xFFECDBBA),
                              ),
                              textAlign: TextAlign.center,
                            ),
                          )
                        : ListView.builder(
                            itemCount: _cartItems.length,
                            itemBuilder: (context, index) {
                              final item = _cartItems[index];
                              return _buildSlidableCartItemCard(context, item);
                            },
                          ),
              ),
              if (_cartItems.isNotEmpty) _buildTotalPrice(),
              if (_cartItems.isNotEmpty) _buildActionButtons(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, bool isMobile) {
    return Align(
      alignment: Alignment.topCenter,
      child: Text(
        'MANgo100',
        style: TextStyle(
          fontSize: isMobile ? 30.0 : 40.0,
          color: const Color(0xFFECDBBA),
          fontFamily: 'Tektur',
        ),
      ),
    );
  }

  Widget _buildSlidableCartItemCard(BuildContext context, CartModel item) {
    return Slidable(
      key: Key(item.title ?? ''),
      endActionPane: ActionPane(
        motion: ScrollMotion(),
        children: [
          SlidableAction(
            onPressed: (context) {
              setState(() {
                _removeFromCart(item);
              });
            },
            backgroundColor: Colors.transparent,
            foregroundColor: const Color(0xFFC84B31),
            icon: Icons.delete,
            label: 'Удалить',
          ),
        ],
      ),
      child: _buildCartItemCard(context, item),
    );
  }

  Widget _buildCartItemCard(BuildContext context, CartModel item) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => MangaDetailsScreen(
              title: item.title ?? '',
              price: item.price ?? '',
              index: _cartItems.indexOf(item),
              additionalImages: item.additionalImages ?? [],
              description: item.description ?? '',
              format: item.format ?? '',
              publisher: item.publisher ?? '',
              imagePath: item.imagePath ?? '',
              chapters: item.chapters ?? '',
              onDelete: () => _removeFromCart(item),
            ),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 10),
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: const Color(0xFFECDBBA),
          borderRadius: BorderRadius.circular(35),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(28),
              child: Image.network(
                item.imagePath ?? '',
                fit: BoxFit.cover,
                width: 160,
                height: 200,
                errorBuilder: (context, error, stackTrace) {
                  return const Center(child: Text('Ошибка загрузки изображения'));
                },
              ),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.title ?? '',
                      style: const TextStyle(
                        fontSize: 26.0,
                        color: Color(0xFF2D4263),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      item.format ?? '',
                      style: const TextStyle(
                        fontSize: 20.0,
                        color: Color(0xFF2D4263),
                        fontFamily: 'Tektur',
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 10),
                    Text(
                      '${item.price ?? ''} x ${item.quantity} = ${int.tryParse(item.price?.replaceAll(' рублей', '') ?? '0') ?? 0 * item.quantity} рублей',
                      style: const TextStyle(
                        fontSize: 24.0,
                        color: Color(0xFF2D4263),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        _buildIconButton(
                          icon: Icons.remove,
                          onTap: () {
                            if (item.quantity > 1) {
                              _updateCartItemQuantity(item, false);
                            } else {
                              _removeFromCart(item);
                            }
                          },
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '${item.quantity}',
                          style: const TextStyle(
                            fontSize: 20.0,
                            color: Color(0xFF2D4263),
                          ),
                        ),
                        const SizedBox(width: 8),
                        _buildIconButton(
                          icon: Icons.add,
                          onTap: () {
                            _updateCartItemQuantity(item, true);
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTotalPrice() {
    int totalPrice = 0;
    for (var item in _cartItems) {
      totalPrice += (int.tryParse(item.price?.replaceAll(' рублей', '') ?? '0') ?? 0) * item.quantity;
    }

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 20),
      child: Text(
        'Итого: $totalPrice рублей',
        style: const TextStyle(
          fontSize: 24.0,
          color: Color(0xFFECDBBA),
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  // Общий стиль для кнопок
  Widget _buildIconButton({required IconData icon, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 24, // Размер кнопки
        height: 24, // Размер кнопки
        decoration: BoxDecoration(
          shape: BoxShape.rectangle,
          color: const Color(0xFFC84B31),
          borderRadius: BorderRadius.circular(6), // Небольшое скругление углов
        ),
        child: Icon(
          icon,
          color: const Color(0xFFECDBBA),
          size: 18, // Размер иконки
        ),
      ),
    );
  }

  // Кнопка для заказа и удаления всех товаров
  Widget _buildActionButtons(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween, // Выравнивание кнопок по краям
      children: [
        ElevatedButton(
          onPressed: () {
            setState(() {
              _cartItems.clear();
            });
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFC84B31), // Красная кнопка для удаления всех товаров
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14), // Уменьшенное скругление
            ),
          ),
          child: const Icon(
            Icons.delete_forever, // Иконка мусорки
            color: Colors.white,
          ),
        ),
        ElevatedButton(
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Заказ оформлен')),
            );
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFC84B31),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14), // Уменьшенное скругление
            ),
          ),
          child: const Icon(
            Icons.attach_money, // Иконка двух монет или купюр
            color: Color(0xFFECDBBA),
          ),
        ),
      ],
    );
  }
}