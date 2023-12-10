import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../../constants.dart';

class Chart extends StatelessWidget {
  final double Usage;
  final Color color;

  const Chart({
    Key? key,
    required this.Usage, required this.color,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final usedSpace = Usage;
    final freeSpace = 100 - usedSpace;

    List<PieChartSectionData> sections = [
      PieChartSectionData(
        color: color,
        value: usedSpace,
        showTitle: false,
        radius: 25,
      ),
      PieChartSectionData(
        color: color.withOpacity(0.1),
        //primaryColor.withOpacity(0.1),
        value: freeSpace,
        showTitle: false,
        radius: 13,
      ),
    ];

    return SizedBox(
      height: 200,
      child: Stack(
        children: [
          PieChart(
            PieChartData(
              sectionsSpace: 0,
              centerSpaceRadius: 70,
              startDegreeOffset: -90,
              sections: sections,
            ),
          ),
          Positioned.fill(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(height: defaultPadding),
                Text(
                  "${usedSpace.toStringAsFixed(1)}%",
                  style: Theme.of(context).textTheme.headlineMedium!.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    height: 0.5,
                  ),
                ),
                Text("of 100%")
              ],
            ),
          ),
        ],
      ),
    );
  }
}
