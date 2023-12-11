import 'package:beautyminder/services/favorites_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../../dto/cosmetic_model.dart';
import '../../widget/appBar.dart';
import '../../widget/my_page_header.dart';
import '../product/product_detail_page.dart';

class MyFavoritePage extends StatefulWidget {
  const MyFavoritePage({Key? key}) : super(key: key);

  @override
  State<MyFavoritePage> createState() => _MyFavoritePageState();
}

class _MyFavoritePageState extends State<MyFavoritePage> {
  List favorites = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    getFavorites();
  }

  getFavorites() async {
    try {
      final info = await FavoritesService.getFavorites();
      setState(() {
        favorites = info.value!;
        isLoading = false;
      });
    } catch (e) {
      Fluttertoast.showToast(
        msg: '$e',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
      );
    }
  }

  _navigateToProductDetailPage(int index) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProductDetailPage(
            searchResults: Cosmetic(
              id: favorites[index]['id'] ?? '',
              name: favorites[index]['name'] ?? '',
              brand: favorites[index]['brand'],
              images: List<String>.from(favorites[index]['images'] ?? []),
              glowpickUrl: favorites[index]['glowpickUrl'],
              expirationDate: favorites[index]['expirationDate'] != null
                  ? DateTime.tryParse(favorites[index]['expirationDate'])
                  : null,
              createdAt: favorites[index]['createdAt'] != null
                  ? DateTime.parse(favorites[index]['createdAt'])
                  : DateTime.now(),
              purchasedDate: favorites[index]['purchasedDate'] != null
                  ? DateTime.tryParse(favorites[index]['purchasedDate'])
                  : null,
              category: favorites[index]['category'] ?? 'Unknown',
              averageRating:
                  (favorites[index]['averageRating'] as num?)?.toDouble() ??
                      0.0,
              reviewCount: favorites[index]['reviewCount'] as int? ?? 0,
              totalRating: favorites[index]['totalRating'] as int? ?? 0,
              keywords: List<String>.from(favorites[index]['keywords'] ?? []),
            ),
            updateFavorites: (isFavorite) {
              if (!isFavorite) {
                setState(() {
                  favorites.removeAt(index);
                });
              }
            }),
      ),
    );

    // If the result is true, it means the favorite status has changed
    if (result == true) {
      // Refresh the favorites list
      getFavorites();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CommonAppBar(
        automaticallyImplyLeading: true,
        context: context,
      ),
      body: isLoading
          ? const SpinKitThreeInOut(
              color: Color(0xffd86a04),
              size: 50.0,
              duration: Duration(seconds: 2),
            )
          : Column(
              children: [
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20.0),
                  child: MyPageHeader('즐겨찾기 제품'),
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: favorites.length,
                    itemBuilder: (context, index) => GestureDetector(
                      onTap: () {
                        _navigateToProductDetailPage(index);
                      },
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 10),
                        leading: Image.network(
                          favorites[index]['images'][0] ?? '',
                          height: 80,
                          width: 80,
                        ),
                        title: Text(
                          favorites[index]['name'],
                          style: const TextStyle(fontSize: 18),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}
