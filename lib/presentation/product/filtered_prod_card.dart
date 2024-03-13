import 'package:flutter/material.dart';

class FilteredProdCard extends StatelessWidget {
  const FilteredProdCard({
    super.key,
    required this.title,
    required this.dateAndTime,
    required this.place,
    required this.price,
    required this.imgPath,
  });

  final String title;
  final String dateAndTime;
  final String place;
  final String imgPath;
  final String price;

  @override
  Widget build(BuildContext context) {
    String titoloIntero = title;
    String titoloTroncato = "";
    Color cardColor = Theme.of(context).colorScheme.primaryContainer;

    titoloTroncato = titoloIntero.length > 20
        ? "${titoloIntero[0].toUpperCase()}${titoloIntero.substring(1, 20)}\n${titoloIntero[0].toUpperCase()}${titoloIntero.substring(21, 37)} ..."
        : titoloIntero;

    return Card(
      surfaceTintColor: cardColor,
      color: cardColor,
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Container(
              height: 120,
              width: 120,
              decoration: const BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.all(
                  Radius.circular(18),
                ),
              ),
            ),
            Column(
              children: [
                Container(
                  margin: const EdgeInsets.only(left: 25),
                  height: 50,
                  width: 180,
                  child: FittedBox(
                    fit: BoxFit.cover,
                    child: Text(
                      titoloTroncato,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                      maxLines: 2,
                    ),
                  ),
                ),
                Container(
                  margin: const EdgeInsets.only(left: 25),
                  width: 180,
                  height: 20,
                  child: Text("$place - $dateAndTime"),
                ),
                Container(
                  margin: const EdgeInsets.only(left: 0),
                  width: 180,
                  height: 50,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        onPressed: () {},
                        icon: const Icon(Icons.bookmark),
                      ),
                      Text(
                        price,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
