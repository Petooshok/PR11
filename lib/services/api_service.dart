import 'package:dio/dio.dart';
import '../models/manga_item.dart';
import '../models/cart_model.dart';

class ApiService {
  final Dio _dio = Dio();
  static const String baseUrl = 'http://localhost:8080'; // Ваш серверный URL

  // Метод для получения всех манга-товаров
  Future<List<MangaItem>> fetchProducts() async {
    try {
      final response = await _dio.get('$baseUrl/products');
      if (response.statusCode == 200) {
        List<MangaItem> products = (response.data as List)
            .map((item) => MangaItem.fromJson(item))
            .toList();
        return products;
      } else {
        throw Exception('Failed to load products: ${response.statusCode} - ${response.data}');
      }
    } catch (e) {
      print('Error fetching products: $e');
      throw Exception('Error fetching products: $e');
    }
  }

  // Метод для изменения статуса манга-товара через PUT
  Future<void> changeProductStatus(MangaItem mangaItem) async {
    print("changeProductStatus function called");
    try {
      final response = await _dio.put(
        '$baseUrl/products/${mangaItem.id}',
        data: mangaItem.toJson(),
        options: Options(headers: {'Content-Type': 'application/json'}),
      );

      print(response.statusCode);
      if (response.statusCode == 200) {
        return;
      } else {
        throw Exception('Failed to change Product Status: ${response.statusCode} - ${response.data}');
      }
    } catch (e) {
      throw Exception('Error fetching change Product Status: $e');
    }
  }

  // Метод для создания нового манга-товара
  Future<MangaItem> createProduct(MangaItem item) async {
    try {
      final response = await _dio.post(
        '$baseUrl/products', // Путь для создания
        data: item.toJson(),
        options: Options(headers: {'Content-Type': 'application/json'}),
      );
      if (response.statusCode == 201) {
        return MangaItem.fromJson(response.data);
      } else {
        throw Exception('Failed to create product: ${response.statusCode} - ${response.data}');
      }
    } catch (e) {
      throw Exception('Error creating product: $e');
    }
  }

  // Метод для удаления манга-товара
  Future<void> deleteProduct(int id) async {
    try {
      final response = await _dio.delete('$baseUrl/products/$id'); // Путь для удаления
      if (response.statusCode != 204) {
        throw Exception('Failed to delete product: ${response.statusCode} - ${response.data}');
      }
    } catch (e) {
      throw Exception('Error deleting product: $e');
    }
  }

  // Метод для получения манга-товара по ID
  Future<MangaItem> getProductById(int id) async {
    try {
      final response = await _dio.get('$baseUrl/products/$id');
      if (response.statusCode == 200) {
        return MangaItem.fromJson(response.data);
      } else {
        throw Exception('Failed to load product with id $id');
      }
    } catch (e) {
      throw Exception('Error fetching product by id: $e');
    }
  }

  // Метод для получения избранных манга-товаров
  Future<List<MangaItem>> getFavoriteProducts(int userId) async {
    try {
      final response = await _dio.get('$baseUrl/favorites/$userId');
      if (response.statusCode == 200) {
        List<MangaItem> favorites = (response.data as List)
            .map((favorite) => MangaItem.fromJson(favorite))
            .toList();
        return favorites;
      } else {
        throw Exception('Failed to load favorites');
      }
    } catch (e) {
      throw Exception('Error fetching favorites: $e');
    }
  }

  // Метод для добавления манга-товара в избранное
  Future<void> addProductToFavorite(int userId, MangaItem product) async {
    try {
      await _dio.post('$baseUrl/favorites/$userId', data: product.toJson());
    } catch (e) {
      throw Exception('Error adding product to favorites: $e');
    }
  }

  // Метод для удаления манга-товара из избранного
  Future<void> deleteProductFromFavorite(int userId, int productId) async {
    try {
      await _dio.delete('$baseUrl/favorites/$userId/$productId');
    } catch (e) {
      throw Exception('Error deleting product from favorites: $e');
    }
  }

  // Метод для получения товаров в корзине
  Future<List<CartModel>> getCartProducts(int userId) async {
    try {
      final response = await _dio.get('$baseUrl/carts/$userId');
      if (response.statusCode == 200) {
        List<CartModel> cart = (response.data as List)
            .map((cartItem) => CartModel.fromJson(cartItem))
            .toList();
        return cart;
      } else {
        throw Exception('Failed to load cart products');
      }
    } catch (e) {
      throw Exception('Error fetching cart products: $e');
    }
  }

  // Метод для добавления манга-товара в корзину
  Future<void> addProductToCart(int userId, MangaItem cartItem) async {
    try {
      await _dio.post('$baseUrl/carts/$userId', data: cartItem.toJson());
    } catch (e) {
      throw Exception('Error adding product to cart: $e');
    }
  }

  // Метод для удаления манга-товара из корзины
  Future<void> deleteProductFromCart(int userId, int productId) async {
    try {
      await _dio.delete('$baseUrl/carts/$userId/$productId');
    } catch (e) {
      throw Exception('Error deleting product from cart: $e');
    }
  }

  // Метод для увеличения количества манга-товара в корзине
  Future<void> updateCartProductPlus(int userId, int productId) async {
    try {
      await _dio.put('$baseUrl/carts/$userId/$productId/plus');
    } catch (e) {
      throw Exception('Error updating cart product plus: $e');
    }
  }

  // Метод для уменьшения количества манга-товара в корзине
  Future<void> updateCartProductMinus(int userId, int productId) async {
    try {
      await _dio.put('$baseUrl/carts/$userId/$productId/minus');
    } catch (e) {
      throw Exception('Error updating cart product minus: $e');
    }
  }
}