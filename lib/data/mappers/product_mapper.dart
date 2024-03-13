import 'package:fuocherello/data/entities/product/product_data.dart';
import 'package:fuocherello/domain/models/product/product.dart';

class ProductMapper {
  Product fromData(ProductData data) => Product(
      id: data.id,
      author: data.author,
      title: data.title,
      description: data.description,
      price: data.price,
      fileNames: data.fileNames,
      place: data.place,
      category: data.category,
      createdAt: data.createdAt);

  ProductData toData(Product p) => ProductData(
      id: p.id!,
      author: p.author,
      title: p.title,
      description: p.description,
      price: p.price,
      fileNames: p.fileNames,
      place: p.place,
      category: p.category,
      createdAt: p.createdAt);
}
