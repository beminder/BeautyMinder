import 'package:beautyminder/pages/product/product_detail_page.dart';
import 'package:flutter/material.dart';

import '../../dto/cosmetic_model.dart';
import '../../services/search_service.dart';
import '../../services/keywordRank_service.dart';
import '../../widget/appBar.dart';

class SearchResultPage extends StatefulWidget {
  final List<Cosmetic> searchResults;
  final String searchQuery;

  const SearchResultPage(
      {Key? key, required this.searchQuery, required this.searchResults})
      : super(key: key);

  @override
  _SearchResultPageState createState() => _SearchResultPageState();
}

class _SearchResultPageState extends State<SearchResultPage> {
  String searchQuery = ''; // 검색어를 저장할 변수
  final TextEditingController textController = TextEditingController();

  bool isApiCallProcess = false;
  bool isLoading = true;

  List searchHistory = [];

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
    // 이곳에서 검색 결과를 표시하거나 처리할 수 있음
    return Scaffold(
      appBar: SearchAppBar(
        title: _title(),
        context: context,
        onBack: () {
          // Custom back button behavior
          print('Custom back button pressed');
          // Perform additional actions if needed
          Navigator.pop(context, searchHistory);
        },
      ),
      body: _searchResultPageUI(),
    );
  }

  Widget _title() {
    return Container(
      height: 40,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        mainAxisSize: MainAxisSize.max,
        children: [
          SizedBox(
            width: 10,
          ),
          Flexible(
            flex: 1,
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
          SizedBox(
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
                print('////////////searchQuery : $searchQuery');
              } catch (e) {
                print('Error searching anything: $e');
              }
            },
            icon: Icon(
              Icons.search,
              color: Color(0xffd86a04),
            ),
          ),
        ],
      ),
    );
  }

  Widget _searchResultPageUI() {
    return Container(
        child: Column(
      children: <Widget>[
        const SizedBox(height: 40),
        _resultText(),
        _divider(),
        const SizedBox(height: 20),
        widget.searchResults.isEmpty
            ? const Center(
                child: Text(
                  '검색결과가 없습니다',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.normal,
                    color: Colors.grey,
                  ),
                ),
              )
            : _productList(),
      ],
    ));
  }

  Widget _resultText() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            width: MediaQuery.of(context).size.width/1.5,
            child: Text(
              "검색 결과 : ${widget.searchQuery}",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xffd86a04),
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Text(
            "${widget.searchResults.length}개의 제품",
            style: TextStyle(
              fontSize: 15,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _productList() {
    return Expanded(
      child: ListView.builder(
        itemCount: widget.searchResults.length,
        itemBuilder: (context, index) {
          final product = widget.searchResults![index];
          return GestureDetector(
            onTap: () async {
              _navigateToProductDetailPage(product);
            },
            child: Container(
              height: 70,
              child: ListTile(
                leading: (product?.images != null && product.images!.isNotEmpty)
                    ? Container(
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
                  product.name,
                  style: TextStyle(
                    fontSize: 18,
                    letterSpacing: 0,
                  ),
                  overflow: TextOverflow.ellipsis,
                ), // 이름 표시
                // 다른 정보도 필요하다면 여기에 추가
              ),
            ),
          );
        },
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
      )).then((value) {
        // 이전 페이지로부터 데이터가 반환되었을 때, 현재 페이지를 다시 새로 고침
        if (value != null && value is bool && value) {
          _getAllNeeds();
        }
      });
      print('////////////searchQuery : $searchQuery');
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
