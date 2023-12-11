import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../dto/cosmetic_expiry_model.dart';

class ExpiryEditDialog extends StatefulWidget {
  final CosmeticExpiry expiry;
  final Function(CosmeticExpiry) onUpdate;

  const ExpiryEditDialog(
      {super.key, required this.expiry, required this.onUpdate});

  @override
  State<ExpiryEditDialog> createState() => _ExpiryEditDialogState();
}

class _ExpiryEditDialogState extends State<ExpiryEditDialog> {
  late bool opened;
  late DateTime expiryDate;
  DateTime? openedDate;

  String formatDate(DateTime date) {
    return DateFormat('yyyy-MM-dd').format(date);
  }

  @override
  void initState() {
    super.initState();
    opened = widget.expiry.opened;
    expiryDate = widget.expiry.expiryDate;
    openedDate = widget.expiry.openedDate;
  }

  Future<void> _selectDate(BuildContext context,
      {bool isExpiryDate = true}) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: isExpiryDate ? expiryDate : openedDate ?? DateTime.now(),
      firstDate: DateTime(2010),
      lastDate: DateTime(2040),
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: const ColorScheme.light(
              primary: Colors.orange, // 달력의 주요 색상을 오렌지로 설정
            ),
            // primaryColor: Colors.grey, // 배경색
            // hintColor: Colors.orange, // 선택된 날짜의 색상
            // buttonTheme: ButtonThemeData(textTheme: ButtonTextTheme.primary),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        if (isExpiryDate) {
          expiryDate = picked;
        } else {
          openedDate = picked;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
      titlePadding:
          const EdgeInsets.symmetric(vertical: 40.0, horizontal: 50.0),
      title: const Text(
        '제품 정보를 수정해주세요',
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 24,
        ),
        // overflow: TextOverflow.ellipsis,
      ),
      content: StatefulBuilder(
        builder: (BuildContext context, StateSetter setState) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: const Text(
                  '제품명',
                  style: TextStyle(
                    fontSize: 18,
                  ),
                ),
                trailing: Container(
                  width: 150,
                  child: Text(
                    widget.expiry.productName,
                    style: const TextStyle(
                      fontSize: 18,
                    ),
                    textAlign: TextAlign.end,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
              ListTile(
                title: const Text(
                  '브랜드',
                  style: TextStyle(
                    fontSize: 18,
                  ),
                ),
                trailing: Container(
                  width: 150,
                  child: Text(
                    '${widget.expiry.brandName}',
                    style: const TextStyle(
                      fontSize: 18,
                    ),
                    textAlign: TextAlign.end,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
              SwitchListTile(
                title: const Text(
                  '개봉 여부',
                  style: TextStyle(
                    fontSize: 18,
                  ),
                ),
                value: opened,
                onChanged: (bool value) {
                  setState(() {
                    opened = value;
                    if (!opened) {
                      openedDate = null;
                    }
                  });
                },
                activeColor: Colors.white,
                activeTrackColor: Colors.orange,
              ),
              ListTile(
                title: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '유통기한',
                      style: TextStyle(
                        fontSize: 18,
                      ),
                    ),
                    const Spacer(), // 조절 가능한 간격
                    Text(
                      expiryDate != null ? formatDate(expiryDate) : '유통기한 선택',
                      style: const TextStyle(
                        fontSize: 18,
                      ),
                    ),
                  ],
                ),
                trailing: const Icon(Icons.calendar_today),
                onTap: () => _selectDate(context),
              ),
              if (opened)
                ListTile(
                  title: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '개봉일',
                        style: TextStyle(
                          fontSize: 18,
                        ),
                      ),
                      const Spacer(), // 조절 가능한 간격
                      Text(
                        openedDate != null ? formatDate(openedDate!) : '개봉일 선택',
                        style: const TextStyle(
                          fontSize: 18,
                        ),
                      ),
                    ],
                  ),
                  trailing: const Icon(Icons.calendar_today),
                  onTap: () => _selectDate(context, isExpiryDate: false),
                ),
            ],
          );
        },
      ),
      actions: [
        TextButton(
          style: TextButton.styleFrom(foregroundColor: Colors.orange),
          onPressed: () {
            // 새로운 CosmeticExpiry 객체 생성 및 현재 상태로 업데이트
            CosmeticExpiry updatedExpiry = CosmeticExpiry(
              id: widget.expiry.id,
              productName: widget.expiry.productName,
              brandName: widget.expiry.brandName,
              expiryDate: expiryDate,
              expiryRecognized: widget.expiry.expiryRecognized,
              imageUrl: widget.expiry.imageUrl,
              cosmeticId: widget.expiry.cosmeticId,
              opened: opened,
              openedDate: openedDate, // 수정된 openedDate
            );
            widget.onUpdate(updatedExpiry);
            Navigator.of(context).pop(updatedExpiry);
            Navigator.of(context).pop(updatedExpiry);
          },
          child: const Text(
            '수정',
            style: TextStyle(
                color: Colors.orange,
                fontSize: 20,
                fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }
}
