class ProductDto {
  String? author;
  String? place;
  String? title;
  String? description;
  double? price;
  String? category;
  List<String>? fileNames;
  DateTime? createdAt;

  ProductDto(
      {this.author,
      this.place,
      this.title,
      this.description,
      this.price,
      this.category,
      this.fileNames,
      this.createdAt}) {
    if (category != "legname" &&
        category != "biomasse" &&
        category != "pellet") {
      throw Exception("Categoria errata");
    }
    if (price! < 0) {
      throw Exception("Prezzo errato");
    }
  }

  Map<String, String> headerData() {
    return {
      "Title": title!,
      "Description": description!,
      "Price": "$price",
      "Category": category!,
      "Place": place!,
    };
  }
}
