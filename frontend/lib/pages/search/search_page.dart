import 'package:beautyminder/dto/keywordRank_model.dart';
import 'package:beautyminder/pages/product/product_detail_page.dart';
import 'package:beautyminder/pages/search/search_result_page.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../dto/cosmetic_model.dart';
import '../../services/keyword_rank_service.dart';
import '../../services/search_service.dart';
import '../../widget/appBar.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({Key? key, required this.data, required this.data2})
      : super(key: key);

  final KeyWordRank? data;
  final ProductRank? data2;

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  String searchQuery = ''; // 검색어를 저장할 변수
  final TextEditingController textController = TextEditingController();

  bool isApiCallProcess = false;
  bool isLoading = true;

  List searchHistory = [];

  @override
  void dispose() {
    textController.dispose(); // 필요한 경우 컨트롤러를 해제합니다.
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _getAllNeeds();
  }

  //필요한 서비스 호출
  Future<void> _getAllNeeds() async {
    // 이미 API 호출이 진행 중인지 확인
    if (isApiCallProcess) {
      return;
    }
    // API 호출 중임을 표시
    setState(() {
      isLoading = true;
      isApiCallProcess = true;
    });

    try {
      //검색어 히스토리
      final loadedHistory = await KeywordRankService.getSearchHistory();
      setState(() {
        searchHistory = loadedHistory ?? [];
      });
    } catch (e) {
      print('An error occurred while loading expiries: $e');
    } finally {
      setState(() {
        isLoading = false;
        isApiCallProcess = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: SearchAppBar(
        title: _title(),
        context: context,
      ),
      body: _searchPageUI(),
    );
  }

  Widget _title() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      mainAxisSize: MainAxisSize.max,
      children: [
        Flexible(
          flex: 1,
          child: SizedBox(
            height: 40,
            child: TextField(
              controller: textController,
              onChanged: (text) {
                searchQuery = text;
              },
              decoration: const InputDecoration(
                contentPadding: EdgeInsets.symmetric(
                  vertical: 3,
                  horizontal: 15,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.all(
                    Radius.circular(10), //포커스 시
                  ),
                  borderSide: BorderSide(
                    color: Color(0xffd86a04),
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.all(
                    Radius.circular(10), // 활성화 상태 모서리를 둥글게 조정
                  ),
                  borderSide: BorderSide(
                    color: Colors.grey,
                  ),
                ),
                hintText: "검색 키워드를 입력해주세요.",
              ),
            ),
          ),
        ),
        const SizedBox(
          width: 8,
        ),
        IconButton(
          onPressed: () async {
            try {
              final result = await SearchService.searchAnything(searchQuery);
              print(result);

              Navigator.of(context).push(
                MaterialPageRoute(
                    builder: (context) => SearchResultPage(
                          searchQuery: searchQuery,
                          searchResults: result,
                        )),
              );
            } catch (e) {
              print('Error searching anything: $e');
            }
          },
          icon: const Icon(
            Icons.search,
            color: Color(0xffd86a04),
          ),
        ),
      ],
    );
  }

  Widget _searchPageUI() {
    if ((widget.data?.keywords?.length == 0) &&
        (widget.data2?.cosmetics.length == 0)) {
      return Column(
        children: [
          _searchHistory(),
          _noKeywordRanking(),
          _noProductRanking(),
          // const SizedBox(height: 20),
        ],
      );
    } else if ((widget.data?.keywords?.length != 0) &&
        (widget.data2?.cosmetics.length == 0)) {
      if ((widget.data?.keywords?.length ?? 0) >= 6) {
        print("length : ${widget.data?.keywords?.length}");
        return SingleChildScrollView(
          child: Column(
            children: [
              _searchHistory(),
              _keywordRankingIfMoreThanSix(),
              _noProductRanking(),
              // const SizedBox(height: 20),
            ],
          ),
        );
      } else {
        print("length : ${widget.data?.keywords?.length}");
        return SingleChildScrollView(
          child: Column(
            children: [
              _searchHistory(),
              _keywordRankingIfLessThanFive(),
              _noProductRanking(),
              // const SizedBox(height: 20),
            ],
          ),
        );
      }
    } else if ((widget.data?.keywords?.length == 0) &&
        (widget.data2?.cosmetics.length != 0)) {
      return SingleChildScrollView(
          child: Column(
        children: [
          _searchHistory(),
          _noKeywordRanking(),
          _productRanking(),
          // const SizedBox(height: 20),
        ],
      ));
    } else {
      if ((widget.data?.keywords?.length ?? 0) >= 6) {
        return SingleChildScrollView(
          child: Column(
            children: [
              _searchHistory(),
              _keywordRankingIfMoreThanSix(),
              _productRanking(),
              // const SizedBox(height: 20),
            ],
          ),
        );
      } else {
        print("length : ${widget.data?.keywords?.length}");
        return SingleChildScrollView(
          child: Column(
            children: [
              _searchHistory(),
              _keywordRankingIfLessThanFive(),
              _productRanking(),
              // const SizedBox(height: 20),
            ],
          ),
        );
      }
    }
  }

  Widget _searchHistory() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: _buildHistoryButtons(),
      ),
    );
  }

  List<Widget> _buildHistoryButtons() {
    if (searchHistory.isEmpty) {
      return [
        const Padding(
          padding: EdgeInsets.all(8.0),
          child: Text(
            '검색 히스토리가 없습니다.',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey,
            ),
          ),
        ),
      ];
    }
    return [
      for (int i = 0;
          i < (searchHistory.length < 5 ? searchHistory.length : 5);
          i++)
        _buildHistoryButton(searchHistory[i]),
    ];
  }

  Widget _buildHistoryButton(String keyword) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 10),
      child: ElevatedButton(
        onPressed: () {
          _navigateToSearchResultPage(keyword);
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.grey[300], // Gray color
          foregroundColor: Colors.black54, // Text color
          elevation: 0,
        ),
        child: Text(keyword),
      ),
    );
  }

  Widget _noKeywordRanking() {
    return Column(children: [
      const SizedBox(height: 30),
      const Padding(
        padding: EdgeInsets.symmetric(horizontal: 20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '실시간 검색 랭킹',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xffd86a04),
              ),
            ),
          ],
        ),
      ),
      _divider(),
      const SizedBox(height: 40),
      const Center(
        child: Text(
          '실시간 랭킹 순위를 불러올 수 없습니다.',
          style: TextStyle(fontSize: 18, color: Colors.grey),
        ),
      ),
      const SizedBox(height: 40),
    ]);
  }

  Widget _noProductRanking() {
    return Column(children: [
      const SizedBox(height: 40),
      const Padding(
        padding: EdgeInsets.symmetric(horizontal: 20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '실시간 제품 랭킹',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xffd86a04),
              ),
            ),
          ],
        ),
      ),
      _divider(),
      const SizedBox(height: 40),
      const Center(
        child: Text(
          '실시간 랭킹 순위를 불러올 수 없습니다.',
          style: TextStyle(fontSize: 18, color: Colors.grey),
        ),
      ),
    ]);
  }

  Widget _keywordRankingIfMoreThanSix() {
    final formattedDate = _formatDateTime(widget.data?.updatedAt);

    return Container(
      height: MediaQuery.of(context).size.height / 2 - 60,
      child: Column(
        children: [
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 1),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  '실시간 검색 랭킹',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xffd86a04),
                  ),
                ),
                Text(
                  formattedDate,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.normal,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
          _divider(),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Row(
              children: [
                Expanded(
                  child: ListView.builder(
                    physics:
                        const NeverScrollableScrollPhysics(), // Disable scrolling
                    shrinkWrap: true,
                    itemCount: (widget.data?.keywords?.length ?? 0) ~/ 2,
                    itemBuilder: (context, index) {
                      final keyword = widget.data?.keywords![index];
                      final rank = index + 1;
                      return ListTile(
                        title: Text(
                          '$rank순위 : $keyword',
                          overflow: TextOverflow.ellipsis,
                        ),
                        onTap: () async {
                          if (keyword != null) {
                            _navigateToSearchResultPage(keyword);
                          }
                        },
                      );
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ListView.builder(
                    physics: const NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    itemCount: (widget.data?.keywords?.length ?? 0) ~/ 2,
                    itemBuilder: (context, index) {
                      final startIndex =
                          (widget.data?.keywords?.length ?? 0) ~/ 2 + index;
                      final keyword = widget.data?.keywords![startIndex];
                      final rank = startIndex + 1;
                      return ListTile(
                        title: Text(
                          '$rank순위 : $keyword',
                          overflow: TextOverflow.ellipsis,
                        ),
                        onTap: () async {
                          if (keyword != null) {
                            _navigateToSearchResultPage(keyword);
                          }
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _keywordRankingIfLessThanFive() {
    final formattedDate = _formatDateTime(widget.data?.updatedAt);

    return Container(
      height: MediaQuery.of(context).size.height / 2 - 60,
      child: Column(
        children: [
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  '실시간 검색 랭킹',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xffd86a04),
                  ),
                ),
                Text(
                  formattedDate,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.normal,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
          _divider(),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: ListView.builder(
              physics:
                  const NeverScrollableScrollPhysics(), // Disable scrolling
              shrinkWrap: true,
              itemCount: widget.data?.keywords?.length ?? 0,
              itemBuilder: (context, index) {
                final keyword = widget.data?.keywords![index];
                final rank = index + 1;
                return ListTile(
                  title: Text(
                    '$rank순위 : $keyword',
                    overflow: TextOverflow.ellipsis,
                  ),
                  onTap: () async {
                    if (keyword != null) {
                      _navigateToSearchResultPage(keyword);
                    }
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  String _formatDateTime(String? dateTimeString) {
    if (dateTimeString == null) {
      return '';
    }

    final dateTime = DateTime.parse(dateTimeString);
    final formattedDate =
        DateFormat('yyyy년 MM월 dd일 HH시 mm분 기준').format(dateTime);

    return formattedDate;
  }

  Widget _productRanking() {
    final formattedDate2 = _formatDateTime(widget.data2?.updatedAt);

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                '실시간 제품 랭킹',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xffd86a04),
                ),
              ),
              if (widget.data2 != null)
                Text(
                  formattedDate2,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.normal,
                    color: Colors.grey,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
            ],
          ),
        ),
        _divider(),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Column(
            children: [
              const SizedBox(height: 10),
              for (int index = 0; index < 3; index++)
                if (index < (widget.data2?.cosmetics?.length ?? 0))
                  _buildProductTile(widget.data2!.cosmetics[index], index + 1),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildProductTile(Cosmetic product, int rank) {
    return GestureDetector(
      onTap: () async {
        _navigateToProductDetailPage(product);
      },
      child: Container(
        height: 70,
        margin: const EdgeInsets.only(bottom: 10),
        child: ListTile(
          leading:
              (product?.images != null && product.images?.isNotEmpty == true)
                  ? SizedBox(
                      width: 70,
                      height: 70,
                      child: Image.network(
                        product.images![0],
                        width: 100,
                        height: 100,
                        fit: BoxFit.cover,
                      ),
                    )
                  : Container(
                      width: 70.0,
                      height: 70.0,
                      color: Colors.white,
                    ),
          title: Text(
            '${product.name}',
            style: const TextStyle(
              fontSize: 18,
              letterSpacing: 0,
            ),
            overflow: TextOverflow.ellipsis,
          ), // Display product name
          // Add more information if needed
        ),
      ),
    );
  }

  void _navigateToProductDetailPage(Cosmetic product) async {
    try {
      print(product);

      Navigator.of(context).push(MaterialPageRoute(
        builder: (context) => ProductDetailPage(
          searchResults: product,
        ),
      ));
    } catch (e) {
      print('Error searching anything: $e');
    }
  }

  void _navigateToSearchResultPage(String keyword) async {
    try {
      final result = await SearchService.searchAnything(keyword);

      final updatedHistory = await Navigator.of(context).push(MaterialPageRoute(
        builder: (context) => SearchResultPage(
          searchQuery: keyword,
          searchResults: result,
        ),
      ));

      if (updatedHistory != null && updatedHistory is List) {
        setState(() {
          searchHistory = updatedHistory;
        });
      }
    } catch (e) {
      print('Error searching anything: $e');
    }
  }

  Widget _divider() {
    return const Divider(
      height: 20,
      thickness: 1,
      indent: 20,
      endIndent: 20,
      color: Colors.grey,
    );
  }
}

// // 결과 클래스
// class Result<T> {
//   final T? value;
//   final String? error;
//
//   Result.success(this.value) : error = null; // 성공
//   Result.failure(this.error) : value = null; // 실패
//
//   bool get isSuccess => value != null;
// }
