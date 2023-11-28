import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../dto/cosmetic_expiry_model.dart';
import 'expiry_edit_dialog.dart';
import '../../services/expiry_service.dart';

class ExpiryContentCard extends StatelessWidget {
  final CosmeticExpiry cosmetic;
  final VoidCallback onDelete; // Callback for delete
  final VoidCallback onEdit;   // Callback for edit

  ExpiryContentCard({required this.cosmetic, required this.onDelete, required this.onEdit});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4.0,
      margin: EdgeInsets.symmetric(horizontal: 25.0, vertical: 60.0),
      color: Colors.white,
      child: Container(
        margin: EdgeInsets.all(10.0), // Margin inside the card
        decoration: BoxDecoration(
          border: Border.all(color: Colors.orange, width: 2.0), // Orange border inside the card
          borderRadius: BorderRadius.circular(10.0),
        ),
        child: Align(
          alignment: Alignment.bottomRight,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 40.0, vertical: 50.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Text(
                        cosmetic.productName,
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 25),
                      ),
                    ),

                    SizedBox(height: 30,),

                    Center(
                      child: cosmetic.imageUrl != null
                          ? Image.network(cosmetic.imageUrl!,
                          width: 200, height: 200, fit: BoxFit.cover)
                          : Image.asset('assets/images/noImg.jpg',
                          width: 200, height: 200, fit: BoxFit.cover),
                    ),

                    SizedBox(height: 30,),

                    Text(
                        '브랜드 : ${cosmetic.brandName ?? 'NULL'}',
                        style: TextStyle(fontWeight: FontWeight.normal, fontSize: 20)
                    ),

                    SizedBox(height: 20,),


                    Text(
                        '유통기한 : ${formatDate(cosmetic.expiryDate)} 까지',
                        style: TextStyle(fontWeight: FontWeight.normal, fontSize: 20)
                    ),

                    SizedBox(height: 20,),

                    Text(
                        cosmetic.opened == true  ? '개봉 여부 : 개봉' : '개봉 여부 : 미개봉',
                        style: TextStyle(fontWeight: FontWeight.normal, fontSize: 20)
                    ),

                    SizedBox(height: 20,),

                    Text(
                        cosmetic.opened == true
                            ? '개봉일 : ${formatDate(cosmetic.openedDate)}'
                            : '개봉일 : N/A',
                        style: TextStyle(fontWeight: FontWeight.normal, fontSize: 20)
                    ),
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
                    icon: Icon(Icons.mode_edit_outline_outlined, size: 30,),
                  ),
                  IconButton(
                    onPressed: () {
                      onDelete();
                      Navigator.of(context).pop();
                    },
                    icon: Icon(Icons.delete_outline_outlined, size: 30,),
                  ),
                ],
              ),
            ],
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
