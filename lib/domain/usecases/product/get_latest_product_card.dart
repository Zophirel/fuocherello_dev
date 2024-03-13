import 'package:fuocherello/domain/models/product/product.dart';
import 'package:fuocherello/presentation/product/latest_prod_card.dart';

class GetLatestProductCard {
  Product prodotto;

  GetLatestProductCard(this.prodotto);

  LatestProdCard get() {
    return LatestProdCard(
      prodotto: prodotto,
      width: 200,
    );
  }
}
