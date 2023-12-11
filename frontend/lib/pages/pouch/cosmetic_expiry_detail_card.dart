import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../dto/cosmetic_expiry_model.dart';

class ExpiryContentCard extends StatelessWidget {
  final CosmeticExpiry cosmetic;
  final VoidCallback onDelete; // Callback for delete
  final VoidCallback onEdit; // Callback for edit

  const ExpiryContentCard(
      {super.key,
      required this.cosmetic,
      required this.onDelete,
      required this.onEdit});

  @override
  Widget build(BuildContext context) {
    DateTime now = DateTime.now();
    DateTime expiryDate = cosmetic.expiryDate;
    Duration difference = expiryDate.difference(now);
    bool isDatePassed = difference.isNegative;

    return Card(
      elevation: 4.0,
      margin: const EdgeInsets.symmetric(horizontal: 25.0, vertical: 60.0),
      color: Colors.white,
      child: Container(
        margin: const EdgeInsets.all(10.0), // Margin inside the card
        decoration: BoxDecoration(
          border: Border.all(
              color: (isDatePassed ||
                      (!isDatePassed && difference.inDays + 1 <= 100))
                  ? Colors.orange
                  : Colors.black54,
              width: 2.0),
          borderRadius: BorderRadius.circular(10.0),
        ),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.only(bottom: 50),
            child: Align(
              alignment: Alignment.bottomRight,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 40.0, vertical: 50.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Center(
                          child: Text(
                            cosmetic.productName,
                            style: const TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 25),
                          ),
                        ),

                        const SizedBox(
                          height: 30,
                        ),

                        Center(
                          child: cosmetic.imageUrl != null
                              ? Image.network(cosmetic.imageUrl!,
                                  width: 200, height: 200, fit: BoxFit.cover)
                              : Image.asset('assets/images/noImg.jpg',
                                  width: 200, height: 200, fit: BoxFit.cover),
                        ),

                        const SizedBox(
                          height: 30,
                        ),

                        Text('브랜드 : ${cosmetic.brandName ?? '알수없음'}',
                            style: const TextStyle(
                                fontWeight: FontWeight.normal, fontSize: 20)),

                        const SizedBox(
                          height: 20,
                        ),

                        Text('유통기한 : ${formatDate(cosmetic.expiryDate)} 까지',
                            style: const TextStyle(
                                fontWeight: FontWeight.normal, fontSize: 20)),

                        const SizedBox(
                          height: 20,
                        ),

                        Text(
                            cosmetic.opened == true
                                ? '개봉 여부 : 개봉'
                                : '개봉 여부 : 미개봉',
                            style: const TextStyle(
                                fontWeight: FontWeight.normal, fontSize: 20)),

                        const SizedBox(
                          height: 20,
                        ),

                        // 개봉 일 때만 개봉 날짜 표시
                        if (cosmetic.opened)
                          Text('개봉일 : ${formatDate(cosmetic.openedDate)}',
                              style: const TextStyle(
                                  fontWeight: FontWeight.normal, fontSize: 20)),
                      ],
                    ),
                  ),
                  ButtonBar(
                    alignment: MainAxisAlignment.end,
                    children: [
                      IconButton(
                        onPressed: () {
                          onEdit();
                        },
                        icon: const Icon(
                          Icons.mode_edit_outline_outlined,
                          size: 30,
                        ),
                      ),
                      IconButton(
                        onPressed: () {
                          onDelete();
                          Navigator.of(context).pop();
                        },
                        icon: const Icon(
                          Icons.delete_outline_outlined,
                          size: 30,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  String formatDate(DateTime? date) {
    if (date == null) return 'N/A';
    return DateFormat('yyyy-MM-dd').format(date);
  }
}
