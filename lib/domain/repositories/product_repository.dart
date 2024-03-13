import 'dart:io';
import 'package:fuocherello/domain/models/product/product.dart';
import 'package:fuocherello/domain/models/product/product_dto.dart';
import 'package:http/http.dart';
import 'package:uuid_type/uuid_type.dart';
import '../enums/product_enums.dart';

abstract class ProductRepository {
  Future<String> getProductThumbnailUrl(Uuid prodId);
  Future<List<Product>> getProducts();
  Future<List<Product>?> getLegname();
  Future<List<Product>?> getBiomasse();
  Future<List<Product>?> getPellet();
  Future<List<Product>> getAuthorProducts(String userId);
  Future<List<Product>> getProductByTitolo(String input);
  Future<Product> getProductById(String prodId);
  Future<List<Product>> getProductByTipo(Category c);
  Future<Product> postProduct(List<File> imageFiles, ProductDto prodotto);
  Future<Response> putProduct(List<File> imageFiles, Product prodotto);
  Future<Response> deleteProduct(Product prodotto);
  Future<List<Product>> getSearchResutls(String input);
  Future<void> saveProductInLocalDb(String id);
  Future<List<Product>> getLatestProducts();
  Future<List<Product>> getUserProducts();
}
