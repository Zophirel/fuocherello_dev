import 'dart:convert';
import 'dart:io';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:fuocherello/data/datasources/product_datasource.dart';
import 'package:fuocherello/data/entities/product/product_data.dart';
import 'package:fuocherello/data/mappers/product_mapper.dart';
import 'package:fuocherello/domain/enums/product_enums.dart';
import 'package:fuocherello/domain/models/product/product.dart';
import 'package:fuocherello/domain/models/product/product_dto.dart';
import 'package:fuocherello/domain/repositories/product_repository.dart';
import 'package:fuocherello/helper/singletons/login_manager.dart';
import 'package:http/http.dart';
import 'package:path/path.dart';
import 'package:http_parser/http_parser.dart';
import 'package:uuid_type/src/uuid.dart';

class DbProductRepository implements ProductRepository {
  static LoginManager manager = LoginManager.instance;
  static const FlutterSecureStorage _secureStorage = FlutterSecureStorage();
  final ProductDataSource datasource;
  final ProductMapper mapper;

  DbProductRepository(this.datasource, this.mapper);
  //GET PRODOTTO
  @override
  Future<List<Product>> getProducts() async {
    List<Map<String, dynamic>> fetchedData = await datasource.getProducts();
    List<Product> fetchedProducts = fetchedData
        .map((data) => mapper.fromData(ProductData.fromMap(data)))
        .toList();
    return fetchedProducts;
  }

  @override
  Future<List<Product>> getAuthorProducts(String userId) async {
    List<Map<String, dynamic>> fetchedData =
        await datasource.getAuthorProducts(userId);
    List<Product> fetchedProducts = fetchedData
        .map(
          (data) => mapper.fromData(
            ProductData.fromMap(data),
          ),
        )
        .toList();
    return fetchedProducts;
  }

  @override
  Future<List<Product>> getProductByTitolo(String input) async {
    List<Map<String, dynamic>> fetchedData =
        await datasource.getProductByTitolo(input);
    return fetchedData
        .map(
          (data) => mapper.fromData(
            ProductData.fromMap(data),
          ),
        )
        .toList();
  }

  @override
  Future<Product> getProductById(String prodId) async {
    Map<String, dynamic> fetchedData = await datasource.getProductById(prodId);
    return mapper.fromData(ProductData.fromMap(fetchedData));
  }

  @override
  Future<List<Product>> getProductByTipo(Category c) async {
    List<Map<String, dynamic>> fetchedData =
        await datasource.getProductByTipo(c);
    List<Product> fetchedProducts = fetchedData
        .map(
          (data) => mapper.fromData(
            ProductData.fromMap(data),
          ),
        )
        .toList();
    return fetchedProducts;
  }

  @override
  Future<Product> postProduct(
      List<File> imageFiles, ProductDto prodotto) async {
    var uri = Uri.parse("https://www.zophirel.it:8443/api/product");
    var request = MultipartRequest("POST", uri);
    List<MultipartFile> multipartFile = [];

    //images
    for (File imageFile in imageFiles) {
      var fileName = imageFile.path;
      var stream = ByteStream(Stream.castFrom(imageFile.openRead()));
      var length = await imageFile.length();
      multipartFile.add(
        MultipartFile(
          'files',
          stream,
          length,
          filename: basename(fileName),
          contentType: MediaType.parse('image/jpeg'),
        ),
      );
    }
    request.files.addAll(multipartFile);

    //json product
    request.fields.addAll(prodotto.headerData());

    request.headers.addAll({
      "Content-Type": "multipart/form-data",
      "Accept": "application/json",
      "Authentication": await _secureStorage.read(key: "access_token") ?? "",
    });

    var streamResponse = await request.send();
    print("$streamResponse, ${streamResponse.reasonPhrase}");
    Response response = await Response.fromStream(streamResponse);
    print("PRODUCT RESPONSE BODY ======== ${response.statusCode}");
    var data = json.decode(json.decode(response.body));
    return mapper
        .fromData(ProductData.fromMap(Map<String, dynamic>.from(data)));
  }

  @override
  Future<Response> putProduct(List<File> imageFiles, Product prodotto) async {
    var uri =
        Uri.parse("https://www.zophirel.it:8443/api/product/${prodotto.id}");
    var request = MultipartRequest("PUT", uri);
    List<MultipartFile> multipartFile = [];

    //images
    for (File imageFile in imageFiles) {
      print("IMAGEFILE: ${imageFile.path}");
      var fileName = "${DateTime.now().toUtc().microsecondsSinceEpoch}.jpg";
      var stream = ByteStream(Stream.castFrom(imageFile.openRead()));
      var length = await imageFile.length();

      multipartFile.add(
        MultipartFile(
          'files',
          stream,
          length,
          filename: basename(fileName),
          contentType: MediaType.parse('image/jpeg'),
        ),
      );
    }
    request.files.addAll(multipartFile);
    request.headers.addAll({
      "Content-Type": "multipart/form-data",
      "Accept": "application/json",
      "Authentication": await _secureStorage.read(key: "access_token") ?? "",
    });

    Map<String, String> productData = mapper
        .toData(prodotto)
        .toMap()
        .map((key, value) => MapEntry(key, value.toString()));
    //json product
    request.fields.addAll(productData);

    var streamResponse = await request.send();
    print(streamResponse.reasonPhrase);
    return await Response.fromStream(streamResponse);
  }

  @override
  Future<Response> deleteProduct(Product prodotto) async {
    print("DELETING PRODUCT");
    print("DELETING ${prodotto.id}");
    Response response = Response("", 401);
    if (await manager.isTokenPresent()) {
      var token = await _secureStorage.read(key: "access_token");
      response = await delete(
        Uri.https('www.zophirel.it:8443', '/api/product/${prodotto.id}'),
        headers: <String, String>{
          "Access-Control-Allow-Origin": "*",
          'Content-Type': 'text/plain',
          'Accept': '*/*',
          'Authentication': token ?? "",
        },
      );
    }
    return response;
  }

  @override
  Future<List<Product>> getSearchResutls(String input) async {
    var data = await datasource.getProductByTitolo(input);
    return data.map((e) => mapper.fromData(ProductData.fromMap(e))).toList();
  }

  @override
  Future<void> saveProductInLocalDb(String id) async {
    await datasource.saveProductInLocalDb(id);
  }

  @override
  Future<List<Product>?> getBiomasse() async {
    var data = await datasource.getBiomasse();
    if (data.isEmpty) {
      return null;
    }
    return data.map((e) => mapper.fromData(ProductData.fromMap(e))).toList();
  }

  @override
  Future<List<Product>?> getLegname() async {
    var data = await datasource.getLegname();
    if (data.isEmpty) {
      return null;
    }
    return data.map((e) => mapper.fromData(ProductData.fromMap(e))).toList();
  }

  @override
  Future<List<Product>?> getPellet() async {
    var data = await datasource.getPellet();
    if (data.isEmpty) {
      return null;
    }
    return data.map((e) => mapper.fromData(ProductData.fromMap(e))).toList();
  }

  @override
  Future<List<Product>> getLatestProducts() async {
    print("PRODUCTS ===================");
    List<Product> products = await getProducts();
    products.sort((a, b) => -a.createdAt.compareTo(b.createdAt));
    print("PRODUCTS ===================");
    print(products);
    return products;
  }

  @override
  Future<List<Product>> getUserProducts() async {
    var data = await datasource.getUserProducts();
    List<Product> products =
        data.map((e) => mapper.fromData(ProductData.fromMap(e))).toList();
    products.sort((a, b) => -a.createdAt.compareTo(b.createdAt));
    return products;
  }

  @override
  Future<String> getProductThumbnailUrl(Uuid prodId) async {
    return await datasource.getProductThumbnailUrl(prodId);
  }
}
