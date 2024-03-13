import 'package:uuid_type/uuid_type.dart';

///Class to rapresent the data needed to parse to create [Product] objects
class ProductData {
  final Uuid id;
  final String author;
  final String title;
  final String description;
  final double price;
  final List<String> fileNames;
  final String place;
  final String category;
  final DateTime createdAt;

  List<String> get imgsJson => fileNames;

  ProductData({
    required this.id,
    required this.author,
    required this.title,
    required this.description,
    required this.price,
    required this.fileNames,
    required this.place,
    required this.category,
    required this.createdAt,
  });

  factory ProductData.fromMap(Map<String, dynamic> data) {
    ProductData productData = ProductData(
        id: Uuid.parse(data['id'] ?? data['Id']),
        author: (data['author'] ?? data["Author"]).toString(),
        title: (data["title"] ?? data["Title"]).toString(),
        description: (data["description"] ?? data["Description"]).toString(),
        price: double.parse((data["price"] ?? data["Price"]).toString()),
        fileNames: List<String>.from(
            (data["product_images"] ?? data["ProductImages"])),
        category: (data["category"] ?? data["Category"]).toString(),
        createdAt: DateTime.parse(
            (data["created_at"] ?? data["CreatedAt"]).toString()),
        place: (data["place"] ?? data["Place"]).toString());
    return productData;
  }

  Map<String, dynamic> toMap() {
    return {
      "id": id,
      "author": author,
      "title": title,
      "description": description,
      "price": price,
      "product_images": fileNames,
      "category": category,
      "created_at": createdAt,
      "place": place,
    };
  }
}
