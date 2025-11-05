import 'package:test/test.dart';
import 'package:dart_scan_project/src/models/product.dart';

void main() {
  group('Product Model Tests', () {
    test('Creates product correctly', () {
      final product = Product(
        id: 'prod-123',
        name: 'Test Product',
        description: 'A test product for unit testing',
        price: 99.99,
        category: 'Electronics',
        stock: 50,
        tags: ['electronics', 'test'],
        specifications: {'color': 'blue', 'size': 'medium'},
      );

      expect(product.id, equals('prod-123'));
      expect(product.name, equals('Test Product'));
      expect(product.description, equals('A test product for unit testing'));
      expect(product.price, equals(99.99));
      expect(product.category, equals('Electronics'));
      expect(product.stock, equals(50));
      expect(product.tags, equals(['electronics', 'test']));
      expect(product.specifications, equals({'color': 'blue', 'size': 'medium'}));
      expect(product.isAvailable, isTrue);
      expect(product.createdAt, isNotNull);
    });

    test('Calculates total value correctly', () {
      final product = Product(
        id: 'prod-123',
        name: 'Test Product',
        description: 'Test',
        price: 10.0,
        category: 'Test',
        stock: 5,
      );

      expect(product.totalValue, equals(50.0));
    });

    test('Checks stock status correctly', () {
      final inStockProduct = Product(
        id: 'prod-123',
        name: 'Test Product',
        description: 'Test',
        price: 10.0,
        category: 'Test',
        stock: 5,
      );

      final outOfStockProduct = Product(
        id: 'prod-124',
        name: 'Out of Stock Product',
        description: 'Test',
        price: 10.0,
        category: 'Test',
        stock: 0,
      );

      final unavailableProduct = Product(
        id: 'prod-125',
        name: 'Unavailable Product',
        description: 'Test',
        price: 10.0,
        category: 'Test',
        stock: 5,
        isAvailable: false,
      );

      expect(inStockProduct.inStock, isTrue);
      expect(inStockProduct.status, equals('in_stock'));

      expect(outOfStockProduct.inStock, isFalse);
      expect(outOfStockProduct.status, equals('out_of_stock'));

      expect(unavailableProduct.inStock, isTrue); // Has stock but not available
      expect(unavailableProduct.status, equals('unavailable'));
    });

    test('Applies discount correctly', () {
      final product = Product(
        id: 'prod-123',
        name: 'Test Product',
        description: 'Test',
        price: 100.0,
        category: 'Test',
        stock: 10,
      );

      final discounted = product.applyDiscount(20); // 20% discount

      expect(discounted.price, equals(80.0));
      expect(discounted.id, equals(product.id));
      expect(discounted.name, equals(product.name));

      // Test invalid discount
      expect(() => product.applyDiscount(-10), throwsA(isA<ArgumentError>()));
      expect(() => product.applyDiscount(150), throwsA(isA<ArgumentError>()));
    });

    test('Serializes to JSON correctly', () {
      final product = Product(
        id: 'prod-123',
        name: 'Test Product',
        description: 'Test description',
        price: 99.99,
        category: 'Electronics',
        stock: 50,
        tags: ['tag1', 'tag2'],
        specifications: {'spec': 'value'},
        isAvailable: false,
      );

      final json = product.toJson();

      expect(json['id'], equals('prod-123'));
      expect(json['name'], equals('Test Product'));
      expect(json['description'], equals('Test description'));
      expect(json['price'], equals(99.99));
      expect(json['category'], equals('Electronics'));
      expect(json['stock'], equals(50));
      expect(json['tags'], equals(['tag1', 'tag2']));
      expect(json['specifications'], equals({'spec': 'value'}));
      expect(json['is_available'], equals(false));
    });

    test('Deserializes from JSON correctly', () {
      final json = {
        'id': 'prod-123',
        'name': 'Test Product',
        'description': 'Test description',
        'price': 99.99,
        'category': 'Electronics',
        'stock': 50,
        'tags': ['tag1', 'tag2'],
        'specifications': {'spec': 'value'},
        'created_at': '2023-01-01T00:00:00.000',
        'is_available': true,
      };

      final product = Product.fromJson(json);

      expect(product.id, equals('prod-123'));
      expect(product.name, equals('Test Product'));
      expect(product.description, equals('Test description'));
      expect(product.price, equals(99.99));
      expect(product.category, equals('Electronics'));
      expect(product.stock, equals(50));
      expect(product.tags, equals(['tag1', 'tag2']));
      expect(product.specifications, equals({'spec': 'value'}));
      expect(product.isAvailable, isTrue);
    });

    test('Copy with works correctly', () {
      final product = Product(
        id: 'prod-123',
        name: 'Test Product',
        description: 'Test',
        price: 100.0,
        category: 'Electronics',
        stock: 50,
      );

      final copied = product.copyWith(
        name: 'Updated Product',
        price: 120.0,
        stock: 30,
      );

      expect(copied.id, equals('prod-123'));
      expect(copied.name, equals('Updated Product'));
      expect(copied.description, equals('Test'));
      expect(copied.price, equals(120.0));
      expect(copied.category, equals('Electronics'));
      expect(copied.stock, equals(30));
    });

    test('Equality works correctly', () {
      final product1 = Product(
        id: 'prod-123',
        name: 'Test Product',
        description: 'Test',
        price: 100.0,
        category: 'Test',
        stock: 10,
      );

      final product2 = Product(
        id: 'prod-123',
        name: 'Different Product',
        description: 'Different',
        price: 200.0,
        category: 'Different',
        stock: 20,
      );

      final product3 = Product(
        id: 'prod-456',
        name: 'Test Product',
        description: 'Test',
        price: 100.0,
        category: 'Test',
        stock: 10,
      );

      expect(product1 == product2, isTrue); // Same ID
      expect(product1 == product3, isFalse); // Different ID
    });
  });
}
