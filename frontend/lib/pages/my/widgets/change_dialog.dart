import 'package:beautyminder/pages/my/widgets/default_dialog.dart';
import 'package:flutter/material.dart';

class ChangeDialog extends StatefulWidget {
  const ChangeDialog({
    Key? key,
    this.icon,
    required this.title,
    required this.subtitle,
  }) : super(key: key);

  final Widget? icon;
  final String title;
  final String subtitle;

  @override
  State<ChangeDialog> createState() => _ChangeDialogState();
}

class _ChangeDialogState extends State<ChangeDialog> {
  final _textEditingController = TextEditingController();
  final GlobalKey<FormState> globalFormKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _textEditingController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      backgroundColor: Colors.white,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const SizedBox(width: 20),
                Center(
                  child: Text(
                    widget.title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context, null),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            Flexible(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
                child: Form(
                  key: globalFormKey,
                  child: TextFormField(
                    controller: _textEditingController,
                    validator: (val) {
                      if (val == null || val.isEmpty) {
                        if(widget.title == '닉네임') {
                          return '${widget.title}이 입력되지 않았습니다.';
                        }
                        else {
                          return '${widget.title}가 입력되지 않았습니다.';
                        }
                      }
                    },
                    decoration: InputDecoration(
                      hintText: widget.subtitle,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(
                          color: Color(0xffd86a04), // 클릭 시 테두리 색상 변경
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(
                          color: Color(0xffd86a04), // 클릭 시 테두리 색상 변경
                        ),
                      ),
                      // isDense: true,
                    ),
                    cursorColor: Colors.grey,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),
            DefaultDialogButton(
              onTap: () {
                if (globalFormKey.currentState?.validate() ?? false) {
                  Navigator.pop(context, _textEditingController.text);
                }
              },
              backgroundColor: const Color(0xFFFF820E),
              text: '변경하기',
              textColor: Colors.white,
            ),
          ],
        ),
      ),
    );
  }
}
