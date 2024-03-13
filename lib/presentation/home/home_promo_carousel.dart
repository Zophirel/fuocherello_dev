import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';

/// simple header carousel used in [Home]
class PromoCarousel extends StatefulWidget {
  const PromoCarousel({
    super.key,
  });

  @override
  State<PromoCarousel> createState() => _PromoCarouselState();
}

class _PromoCarouselState extends State<PromoCarousel> {
  double carouselWidth = 0;

  @override
  Widget build(BuildContext context) {
    if (MediaQuery.of(context).size.width < 360) {
      carouselWidth = MediaQuery.of(context).size.width - 30;
    } else {
      carouselWidth = 360;
    }
    return CarouselSlider(
      options: CarouselOptions(
        viewportFraction: 1,
        height: 160,
        enableInfiniteScroll: false,
      ),
      items: [1, 2].map((i) {
        return Builder(
          builder: (BuildContext context) {
            return Card(
              surfaceTintColor: Theme.of(context).colorScheme.surfaceVariant,
              color: Theme.of(context).colorScheme.surfaceVariant,
              elevation: 1,
              child: const Padding(
                padding: EdgeInsets.only(left: 20),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          FittedBox(
                            child: Text(
                              '50%',
                              style: TextStyle(
                                  height: 0.8,
                                  fontSize: 84,
                                  fontWeight: FontWeight.bold),
                              maxLines: 1,
                            ),
                          ),
                          FittedBox(
                            child: Text(
                              'su tutta la legna',
                              style: TextStyle(
                                  fontSize: 21, fontWeight: FontWeight.bold),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 2,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 130,
                            child: Image(
                              image:
                                  AssetImage('assets/android/home/legna.png'),
                              height: 130,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      }).toList(),
    );
  }
}
