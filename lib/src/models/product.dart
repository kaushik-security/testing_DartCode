import 'package:json_annotation/json_annotation.dart';

part 'product.g.dart';

@JsonSerializable()
class Product {
  final String id;
  final String name;
  final String description;
  final double price;
  final String category;
  final int stock;
  final List<String> tags;
  final Map<String, dynamic>? specifications;
  final DateTime createdAt;
  final bool isAvailable;

  Product({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.category,
    required this.stock,
    this.tags = const [],
    this.specifications,
    DateTime? createdAt,
    this.isAvailable = true,
  }) : createdAt = createdAt ?? DateTime.now();

  /// Create product from JSON
  factory Product.fromJson(Map<String, dynamic> json) => _$ProductFromJson(json);

  /// Convert product to JSON
  Map<String, dynamic> toJson() => _$ProductToJson(this);

  /// Calculate total value of products in stock
  double get totalValue => price * stock;

  /// Check if product is in stock
  bool get inStock => stock > 0;

  /// Get product status
  String get status {
    if (!isAvailable) return 'unavailable';
    if (stock == 0) return 'out_of_stock';
    if (stock < 10) return 'low_stock';
    return 'in_stock';
  }

  /// Apply discount to price
  Product applyDiscount(double discountPercentage) {
    if (discountPercentage < 0 || discountPercentage > 100) {
      throw ArgumentError('Discount percentage must be between 0 and 100');
    }
    final discountAmount = price * (discountPercentage / 100);
    return copyWith(price: price - discountAmount);
  }

  /// Create a copy of product with modified fields
  Product copyWith({
    String? id,
    String? name,
    String? description,
    double? price,
    String? category,
    int? stock,
    List<String>? tags,
    Map<String, dynamic>? specifications,
    DateTime? createdAt,
    bool? isAvailable,
  }) {
    return Product(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      price: price ?? this.price,
      category: category ?? this.category,
      stock: stock ?? this.stock,
      tags: tags ?? this.tags,
      specifications: specifications ?? this.specifications,
      createdAt: createdAt ?? this.createdAt,
      isAvailable: isAvailable ?? this.isAvailable,
    );
  }

  @override
  String toString() {
    return 'Product(id: $id, name: $name, price: $price, stock: $stock, status: $status)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Product && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
