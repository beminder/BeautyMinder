import 'package:flutter/cupertino.dart';
import 'package:flutter_svg/svg.dart';

Widget arrowIcon(Color color) {
  return SvgPicture.asset(
    'assets/icons/ic_arrow.svg',
    colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
  );
}
