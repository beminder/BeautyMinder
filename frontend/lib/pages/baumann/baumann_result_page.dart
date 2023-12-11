import 'package:beautyminder/pages/home/home_page.dart';
import 'package:dio/src/response.dart';
import 'package:flutter/material.dart';
import 'package:kg_charts/kg_charts.dart';

import '../../services/api_service.dart';
import '../../widget/appBar.dart';

class BaumannResultPage extends StatefulWidget {
  const BaumannResultPage({Key? key, required this.resultData})
      : super(key: key);

  final Response<dynamic> resultData;

  @override
  State<BaumannResultPage> createState() => _BaumannResultPageState();
}

class _BaumannResultPageState extends State<BaumannResultPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CommonAppBar(automaticallyImplyLeading: false, context: context,),
      body: SingleChildScrollView(
        child: baumannResultUI(),
      ),
    );
  }

  Widget baumannResultUI() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 50),
          _typeText(),
          const SizedBox(height: 50),
          _spiderChart(),
          const SizedBox(height: 10),
          _judgePigmentationResult(),
          _judgeHydrationResult(),
          _judgeElasticityResult(),
          _judgeMoistureRetentionResult(),
          _judgeSensiticityResult(),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                // 모서리가 둥근 네모난 박스로 만들기
                color: Colors.grey[200], // 박스의 배경색 설정
              ),
              padding: const EdgeInsets.all(10), // 박스의 안쪽 여백 설정
              child: _descriptionType(),
            ),
          ),
          const SizedBox(height: 10),
          _navigateToHomeButton(),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _typeText() {
    String skinType = widget.resultData.data['skinType'] ?? 'N/A';

    return RichText(
      text: TextSpan(
        style: const TextStyle(
          color: Colors.black,
          fontWeight: FontWeight.bold,
          fontSize: 20,
        ),
        children: [
          const TextSpan(text: '피부타입은 "'),
          TextSpan(
            text: skinType,
            style: const TextStyle(
              color: Color(0xffd86a04), // 특정 부분의 텍스트 색상 변경
            ),
          ),
          const TextSpan(text: '" 입니다.'),
        ],
      ),
    );
  }

  Widget _spiderChart() {
    return Center(
      child: RadarWidget(
        radarMap: RadarMapModel(
          legend: [
            LegendModel('각 타입 별 점수', const Color(0XFF0EBD8D)),
          ],
          indicator: [
            IndicatorModel("색소침착도", 57),
            IndicatorModel("유수분 밸런스", 44),
            IndicatorModel("탄력", 85),
            IndicatorModel("수분 보유력", 100),
            IndicatorModel("민감도", 64),
          ],
          data: [
            MapDataModel([
              widget.resultData.data['scores']['pigmentation'],
              widget.resultData.data['scores']['hydration'],
              widget.resultData.data['scores']['elasticity'],
              widget.resultData.data['scores']['moistureRetention'],
              widget.resultData.data['scores']['sensitivity']
            ]),
          ],
          radius: 120,
          duration: 2000,
          shape: Shape.square,
          maxWidth: 50,
          line: LineModel(4),
        ),
        textStyle: const TextStyle(color: Colors.black, fontSize: 14),
        isNeedDrawLegend: true,
        lineText: (p, length) => "${(p * 100 ~/ length)}%",
        dilogText: (IndicatorModel indicatorModel,
            List<LegendModel> legendModels, List<double> mapDataModels) {
          StringBuffer text = StringBuffer("");
          for (int i = 0; i < mapDataModels.length; i++) {
            text.write(
                "${mapDataModels[i].toString()}/${indicatorModel.maxValues}");
            if (i != mapDataModels.length - 1) {
              text.write("\n");
            }
          }
          return text.toString();
        },
        outLineText: (data, max) =>
            "${(data * 100 ~/ max).toStringAsFixed(2)}%",
      ),
    );
  }

  Widget _judgePigmentationResult() {
    if (widget.resultData.data['scores']['pigmentation'] / 57 * 100 >= 75) {
      return const Text('색소침착도 : 좋음');
    } else {
      return const Text('색소침착도 : 보통');
    }
  }

  Widget _judgeHydrationResult() {
    if (widget.resultData.data['scores']['hydration'] / 44 * 100 >= 75) {
      return const Text('유수분 밸런스 : 좋음');
    } else {
      return const Text('유수분 밸런스 : 보통');
    }
  }

  Widget _judgeElasticityResult() {
    if (widget.resultData.data['scores']['elasticity'] / 85 * 100 >= 75) {
      return const Text('탄력 : 좋음');
    } else {
      return const Text('탄력 : 보통');
    }
  }

  Widget _judgeMoistureRetentionResult() {
    if (widget.resultData.data['scores']['moistureRetention'] >= 65) {
      return const Text('수분 보유력 : 좋음');
    } else {
      return const Text('수분 보유력 : 보통');
    }
  }

  Widget _judgeSensiticityResult() {
    if (widget.resultData.data['scores']['sensitivity'] / 64 * 100 >= 75) {
      return const Text('민감도 : 좋음');
    } else {
      return const Text('민감도 : 보통');
    }
  }

  Widget _descriptionType() {
    //1.DSPT
    if (widget.resultData.data['skinType'] == 'DSPT') {
      return Container(
        padding: const EdgeInsets.all(20),
        child: const Text(
          '건조하고 민감성이 높으며 피부톤이 고르지 못한 편이지만 탄력이 있는 유형\n\n이 피부 유형은 피부 염증과 색소 침착이 특징입니다. 스킨케어 요법은 건조함과 염증을 먼저 치료한 다음 색소침착을 다뤄야 합니다.',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.normal,
            fontSize: 15,
          ),
        ),
      );
    }

    //2.DSNT
    else if (widget.resultData.data['skinType'] == 'DSNT') {
      return Container(
        padding: const EdgeInsets.all(20),
        child: const Text(
          '건조하고 민감성이 높으며 피부톤이 고른 편이고 탄력이 있는 유형\n\n피부 건조함은 이 피부 유형의 주요 특징이며, 종종 피부 염증을 겪기도 합니다. 또한 피부 톤이 고른 편이며 주름이 거의 없거나 없습니다. 리놀레산과 오메가-3 지방산이 풍부한 오일을 식단에 추가하는 것이 좋습니다.',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.normal,
            fontSize: 15,
          ),
        ),
      );
    }

    //3.DSPW
    else if (widget.resultData.data['skinType'] == 'DSPW') {
      return Container(
        padding: const EdgeInsets.all(20),
        child: const Text(
          '건조하고 민감성이 높으며 피부톤이 고르지 못한 편이고 주름이 생기기 쉬운 유형\n\n이 피부 유형은 반복적인 피부 염증, 불규칙한 피부 톤 및 주름이 생기기 쉬운 특징을 보입니다. DSPW 유형은 색소 침착과 주름을 치료하면서 건조함과 염증을 악화시키지 않는 피부 관리 방법이 필요합니다.',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.normal,
            fontSize: 15,
          ),
        ),
      );
    }

    //4.DSNW
    else if (widget.resultData.data['skinType'] == 'DSNW') {
      return Container(
        padding: const EdgeInsets.all(20),
        child: const Text(
          '건조하고 민감성이 높으며 피부톤이 고른 편이고 주름이 생기기 쉬운 유형\n\n피부 건조함과 염증은 이 피부 유형의 주요 특징입니다. DSNW 유형은 피부 톤이 고른 편이지만 주름이 발생하기 쉽습니다. 관리 방법에는 피부 장벽 복구 보습제, 매일 사용하기 좋은 피부 항산화제, 밤에 사용할 수 있는 레티노이드, 그리고 염증을 줄이는 성분이 포함되어야 합니다.',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.normal,
            fontSize: 15,
          ),
        ),
      );
    }

    //5.OSPT
    else if (widget.resultData.data['skinType'] == 'OSPT') {
      return Container(
        padding: const EdgeInsets.all(20),
        child: const Text(
          '유분기가 있고 민감성이 높으며 피부톤이 고르지 못한 편이고 탄력이 있는 유형\n\n이 피부 유형은 염증과 피부 톤 불규칙성이 특징입니다. 이 피부 유형은 노화로부터 피부를 보호하는 피부 색소침착과 피지에서 자연적으로 발생하는 항산화 물질로 인해 다른 유형보다 주름에 민감하지 않습니다.',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.normal,
            fontSize: 15,
          ),
        ),
      );
    }

    //6.OSNT
    else if (widget.resultData.data['skinType'] == 'OSNT') {
      return Container(
        padding: const EdgeInsets.all(20),
        child: const Text(
          '유분기가 있고 민감성이 높으며 피부톤이 고른 편이고 탄력이 있는 유형\n\n이 피부 유형은 지성 및 염증이 특징입니다. OSNT는 항산화 성분이 풍부한 피지가 보호 효과가 있기 때문에 주름에 덜 취약합니다. 이 피부 유형은 좋은 생활 습관을 실천한다면 나이가 들수록 관리하기가 더 쉬워질 것입니다. ',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.normal,
            fontSize: 15,
          ),
        ),
      );
    }

    //7.OSPW
    else if (widget.resultData.data['skinType'] == 'OSPW') {
      return Container(
        padding: const EdgeInsets.all(20),
        child: const Text(
          '유분기가 있고 민감성이 높으며 피부톤이 고르지 못한 편이고 주름이 생기기 쉬운 유형\n\nOSPW에는 피부 염증이 있고 색소가 고르지 않으며 주름이 생기는 경향이 있습니다. 피부에서 자연적으로 발생하는 유분은 어느 정도 항산화 보호 기능을 제공하지만 취약한 피부 타입을 보호하기에는 충분하지 않습니다. 최상의 결과를 얻으려면 일관된 일일 요법을 따르는 것이 중요합니다.',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.normal,
            fontSize: 15,
          ),
        ),
      );
    }

    //8.OSNW
    else if (widget.resultData.data['skinType'] == 'OSNW') {
      return Container(
        padding: const EdgeInsets.all(20),
        child: const Text(
          '유분기가 있고 민감성이 높으며 피부톤이 고른 편이고 주름이 생기기 쉬운 유형\n\nOSNW는 염증이 있으며 피부 노화에 취약합니다. 피지에 함유된 높은 수준의 항산화 물질은 피부 노화를 예방하는 데 도움이 될 수 있지만, 항산화제, 레티노이드 및 항염증 성분을 매일 피부 관리 요법에 사용해야 합니다.',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.normal,
            fontSize: 15,
          ),
        ),
      );
    }

    //9.ORPT
    else if (widget.resultData.data['skinType'] == 'ORPT') {
      return Container(
        padding: const EdgeInsets.all(20),
        child: const Text(
          '유분기가 있고 민감성이 낮으며 피부톤이 고르지 못한 편이고 탄력이 있는 유형\n\n이 피부 타입은 다른 피부 타입에 비해 주름과 자극에 덜 민감하지만, 균일한 피부톤을 유지하려면 매일 자외선 차단제를 바르는 것은 필수입니다. ORPT는 피부톤을 고르게 하기 위해 활성 성분의 농도가 더 높은 제품이 필요합니다. ',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.normal,
            fontSize: 15,
          ),
        ),
      );
    }

    //10.ORNT
    else if (widget.resultData.data['skinType'] == 'ORNT') {
      return Container(
        padding: const EdgeInsets.all(20),
        child: const Text(
          '유분기가 있고 민감성이 낮으며 피부톤이 고른 편이고 탄력이 있는 유형\n\n아주 이상적인 피부 타입입니다. 이 피부 타입은 적당량의 피지를 생성합니다. 피지에는 강력한 항노화 성분인 비타민E가 다량 함유되어 있습니다. ORNT는 피부톤도 균일하고 피부 노화 위험도 낮습니다.',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.normal,
            fontSize: 15,
          ),
        ),
      );
    }

    //11.ORPW
    else if (widget.resultData.data['skinType'] == 'ORPW') {
      return Container(
        padding: const EdgeInsets.all(20),
        child: const Text(
          '유분기가 있고 민감성이 낮으며 피부톤이 고르지 못한 편이고 주름이 생기기 쉬운 유형\n\n이 피부 타입은 피부톤이 고르지 않고 주름이 잘 생기는 것이 특징입니다. 피부의 피지가 노화를 방지하는 데 도움이 되지만, 이 피부 타입은 식단과 스킨케어 요법에 항산화제를 추가해야 합니다. ORPW에는 활성 성분의 농도가 더 높은 제품이 필요합니다.   ',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.normal,
            fontSize: 15,
          ),
        ),
      );
    }

    //12.ORNW
    else if (widget.resultData.data['skinType'] == 'ORNW') {
      return Container(
        padding: const EdgeInsets.all(20),
        child: const Text(
          '유분기가 있고 민감성이 낮으며 피부톤이 고른 편이고 주름이 생기기 쉬운 유형\n\n이 피부 타입은 주름이 잘 생기는 경향이 있지만, 항산화 물질이 풍부한 피지 덕분에 완전 건성 피부 타입에 비해선 주름이 덜 생깁니다. 그렇지만 주름을 예방하고 줄이기 위해 레티노이드 및 알파 하이드록시산과 같은 성분이 필요합니다. ',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.normal,
            fontSize: 15,
          ),
        ),
      );
    }

    //13.DRPT
    else if (widget.resultData.data['skinType'] == 'DRPT') {
      return Container(
        padding: const EdgeInsets.all(20),
        child: const Text(
          '건조하고 민감성이 낮으며 피부톤이 고르지 못한 편이고 탄력이 있는 유형\n\n이 피부 유형의 주요 특징은 피부 건조함과 색소 침착 불규칙성입니다. 이 유형의 피부는 염증이 드물며 주름이 거의 없습니다. 피부 관리 방법에는 매일 SPF 30+의 자외선 차단제, 보습제 및 피부 미백 성분이 포함된 제품을 이용하는 것입니다.',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.normal,
            fontSize: 15,
          ),
        ),
      );
    }

    //14.DRNT
    else if (widget.resultData.data['skinType'] == 'DRNT') {
      return Container(
        padding: const EdgeInsets.all(20),
        child: const Text(
          '건조하고 민감성이 낮으며 피부톤이 고른 편이고 탄력이 있는 유형\n\n건조한 피부가 이 피부 유형의 주요 특징으로, 피부 톤이 고르고 주름이 거의 없는 것이 특징입니다. 각질 제거 성분, 보습제, 그리고 매일 SPF 15+의 자외선 차단제를 권장합니다. 거품 클렌저는 피해야 합니다.',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.normal,
            fontSize: 15,
          ),
        ),
      );
    }

    //15.DRPW
    else if (widget.resultData.data['skinType'] == 'DRPW') {
      return Container(
        padding: const EdgeInsets.all(20),
        child: const Text(
          '건조하고 민감성이 낮으며 피부톤이 고르지 못한 편이고 주름이 생기기 쉬운 유형\n\n피부 건조함, 고르지 못한 색소침착, 주름에 대한 민감성은 DRPW 피부 유형의 주된 특징입니다. 스킨케어 제품에는 일일 SPF, 약간의 항산화제, 레티노이드, 보습제, 알파 하이드록시산 및 피부 톤을 균일하게 해주는 성분이 포함되어야 합니다.',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.normal,
            fontSize: 15,
          ),
        ),
      );
    }

    //16.DRNW
    else if (widget.resultData.data['skinType'] == 'DRNW') {
      return Container(
        padding: const EdgeInsets.all(20),
        child: const Text(
          '건조하고 민감성이 낮으며 피부톤이 고른 편이고 주름이 생기기 쉬운 유형\n\n이 피부 타입은 피부톤이 균일하지만 건조함과 주름이 생기기 쉽습니다. 스킨케어 제품에는 SPF 15+, 일일 국소 항산화제 및 야간 레티노이드가 포함되어야 합니다. 좋은 생활습관을 장려하고 식단에 항산화 보충제를 추가해야 합니다.',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.normal,
            fontSize: 15,
          ),
        ),
      );
    }

    //else
    else {
      return Container(
        padding: const EdgeInsets.all(20),
        child: const Text(
          '타입에 대한 결과가 없습니다.',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.normal,
            fontSize: 15,
          ),
        ),
      );
    }
  }

  Widget _navigateToHomeButton() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Container(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: () async {
            final userProfileResult = await APIService.getUserProfile();
            // 버튼을 클릭했을 때 홈페이지로 이동하는 함수 호출
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => HomePage(
                        user: userProfileResult.value,
                      )),
            );
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xfffe9738),
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(5.0), // Adjust the radius as needed
            ),
          ),
          child: const Text(
            '홈으로 가기',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
            ),
          ),
        ),
      ),
    );
  }
}
